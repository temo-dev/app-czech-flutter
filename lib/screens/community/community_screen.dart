import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../state/auth/auth_notifier.dart';
import '../../state/community/chat_message.dart';
import '../../state/community/chat_notifier.dart';

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  final _scrollController = ScrollController();
  final _textController = TextEditingController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels <=
        _scrollController.position.minScrollExtent + 100) {
      _triggerLoadMore();
    }
  }

  Future<void> _triggerLoadMore() async {
    if (_isLoadingMore) return;
    final chat = ref.read(chatProvider);
    if (!chat.hasMore || chat.isLoading) return;

    setState(() => _isLoadingMore = true);
    final oldMax = _scrollController.position.maxScrollExtent;
    await ref.read(chatProvider.notifier).loadMore();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final newMax = _scrollController.position.maxScrollExtent;
        _scrollController.jumpTo(
          _scrollController.offset + (newMax - oldMax),
        );
      }
      if (mounted) setState(() => _isLoadingMore = false);
    });
  }

  bool _isAtBottom() {
    if (!_scrollController.hasClients) return true;
    final maxScroll = _scrollController.position.maxScrollExtent;
    return (maxScroll - _scrollController.position.pixels) < 150;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final auth = ref.read(authProvider);
    final text = _textController.text.trim();
    if (text.isEmpty || auth.userId == null) return;

    final nickname =
        auth.nickname ?? auth.email?.split('@').first ?? 'Ẩn danh';
    _textController.clear();
    ref.read(chatProvider.notifier).sendMessage(text, auth.userId!, nickname);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    if (!auth.isLoggedIn) {
      return _LoginPrompt(
        onTap: () => context.push('/login', extra: '/community'),
      );
    }

    final chat = ref.watch(chatProvider);

    ref.listen<ChatState>(chatProvider, (previous, next) {
      if (previous == null) return;
      if (next.messages.length > previous.messages.length) {
        final lastMsg = next.messages.last;
        if (lastMsg.userId == auth.userId || _isAtBottom()) {
          _scrollToBottom();
        }
      }
    });

    return Scaffold(
      backgroundColor: AppColors.bg,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Cộng đồng'),
        backgroundColor: AppColors.white,
        leading: context.canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: () => context.pop(),
              )
            : null,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessagesList(chat, auth.userId ?? ''),
          ),
          if (chat.error != null) _ErrorBanner(error: chat.error!),
          _InputBar(
            controller: _textController,
            isSending: chat.isSending,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(ChatState chat, String currentUserId) {
    if (chat.isLoading && chat.messages.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (chat.messages.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('💬', style: TextStyle(fontSize: 48)),
            SizedBox(height: 16),
            Text(
              'Chưa có tin nhắn nào.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 15),
            ),
            SizedBox(height: 4),
            Text(
              'Hãy là người đầu tiên nhắn tin!',
              style: TextStyle(color: AppColors.textLight, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: chat.messages.length,
          itemBuilder: (context, index) {
            final msg = chat.messages[index];
            final isOwn = msg.userId == currentUserId;
            final showNickname = !isOwn &&
                (index == 0 ||
                    chat.messages[index - 1].userId != msg.userId);
            return _MessageBubble(
              message: msg,
              isOwn: isOwn,
              showNickname: showNickname,
            );
          },
        ),
        if (chat.isLoading && chat.messages.isNotEmpty)
          const Positioned(
            top: 8,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isOwn;
  final bool showNickname;

  const _MessageBubble({
    required this.message,
    required this.isOwn,
    required this.showNickname,
  });

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment:
            isOwn ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (showNickname)
            Padding(
              padding: const EdgeInsets.only(bottom: 3, left: 38),
              child: Text(
                message.nickname,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          Row(
            mainAxisAlignment:
                isOwn ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isOwn) ...[
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.cream,
                  child: Text(
                    message.nickname.isNotEmpty
                        ? message.nickname[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isOwn ? AppColors.primary : AppColors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isOwn ? 18 : 4),
                      bottomRight: Radius.circular(isOwn ? 4 : 18),
                    ),
                    border: isOwn
                        ? null
                        : Border.all(color: AppColors.border, width: 1),
                  ),
                  child: Text(
                    message.message,
                    style: TextStyle(
                      fontSize: 15,
                      color: isOwn ? Colors.white : AppColors.textDark,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
              if (isOwn) const SizedBox(width: 6),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 3,
              left: isOwn ? 0 : 38,
              right: isOwn ? 4 : 0,
            ),
            child: Text(
              _formatTime(message.createdAt),
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InputBar extends StatefulWidget {
  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;

  const _InputBar({
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  @override
  State<_InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<_InputBar> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 8,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: widget.controller,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => widget.onSend(),
              minLines: 1,
              maxLines: 4,
              style:
                  const TextStyle(fontSize: 15, color: AppColors.textDark),
              decoration: InputDecoration(
                hintText: 'Nhắn tin...',
                hintStyle: const TextStyle(
                    color: AppColors.textLight, fontSize: 15),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                filled: true,
                fillColor: AppColors.bg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(
                      color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          AnimatedOpacity(
            opacity: _hasText && !widget.isSending ? 1.0 : 0.4,
            duration: const Duration(milliseconds: 150),
            child: IconButton(
              onPressed:
                  _hasText && !widget.isSending ? widget.onSend : null,
              icon: widget.isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : const Icon(Icons.send_rounded),
              color: AppColors.primary,
              iconSize: 24,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String error;
  const _ErrorBanner({required this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style:
                  const TextStyle(color: AppColors.error, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginPrompt extends StatelessWidget {
  final VoidCallback onTap;
  const _LoginPrompt({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Cộng đồng'),
        backgroundColor: AppColors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Center(
                    child: Text('👥', style: TextStyle(fontSize: 40))),
              ),
              const SizedBox(height: 24),
              const Text(
                'Tham gia cộng đồng',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Đăng nhập để kết nối với hàng ngàn người\nđang học tiếng Séc như bạn.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textMuted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: onTap,
                child: const Text('Đăng nhập / Đăng ký'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
