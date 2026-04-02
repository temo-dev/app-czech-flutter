import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'chat_message.dart';

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isSending;
  final String? error;
  final bool hasMore;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.isSending = false,
    this.error,
    this.hasMore = true,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? isSending,
    String? error,
    bool? hasMore,
    bool clearError = false,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      error: clearError ? null : (error ?? this.error),
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  RealtimeChannel? _channel;

  ChatNotifier() : super(const ChatState()) {
    _init();
  }

  Future<void> _init() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _loadMessages();
      _subscribeRealtime();
    } catch (e) {
      state = state.copyWith(error: _parseError(e), isLoading: false);
    }
  }

  Future<void> _loadMessages({bool prepend = false}) async {
    final client = Supabase.instance.client;

    List<dynamic> data;

    if (prepend && state.messages.isNotEmpty) {
      final oldest = state.messages.first.createdAt.toUtc().toIso8601String();
      data = await client
          .from('chat_messages')
          .select()
          .lt('created_at', oldest)
          .order('created_at', ascending: false)
          .limit(50) as List<dynamic>;
    } else {
      data = await client
          .from('chat_messages')
          .select()
          .order('created_at', ascending: false)
          .limit(50) as List<dynamic>;
    }

    final fetched = data
        .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    if (prepend) {
      state = state.copyWith(
        messages: [...fetched, ...state.messages],
        hasMore: fetched.length == 50,
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        messages: fetched,
        hasMore: fetched.length == 50,
        isLoading: false,
      );
    }
  }

  void _subscribeRealtime() {
    _channel = Supabase.instance.client
        .channel('public:chat_messages')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'chat_messages',
          callback: (payload) {
            final newMsg = ChatMessage.fromJson(
              payload.newRecord as Map<String, dynamic>,
            );
            if (state.messages.any((m) => m.id == newMsg.id)) return;
            state = state.copyWith(
              messages: [...state.messages, newMsg],
            );
          },
        )
        .subscribe();
  }

  Future<void> sendMessage(
    String message,
    String userId,
    String nickname,
  ) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty) return;

    state = state.copyWith(isSending: true, clearError: true);
    try {
      await Supabase.instance.client.from('chat_messages').insert({
        'user_id': userId,
        'nickname': nickname,
        'message': trimmed,
      });
      state = state.copyWith(isSending: false);
    } catch (e) {
      state = state.copyWith(error: _parseError(e), isSending: false);
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true);
    try {
      await _loadMessages(prepend: true);
    } catch (e) {
      state = state.copyWith(error: _parseError(e), isLoading: false);
    }
  }

  String _parseError(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('network') || msg.contains('connection') || msg.contains('socket')) {
      return 'Lỗi kết nối. Kiểm tra internet của bạn.';
    }
    if (msg.contains('permission') || msg.contains('rls') || msg.contains('policy')) {
      return 'Bạn cần đăng nhập để xem tin nhắn.';
    }
    return 'Có lỗi xảy ra. Vui lòng thử lại.';
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>(
  (ref) => ChatNotifier(),
);
