import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart' as mobile_yt;
import 'package:youtube_player_iframe/youtube_player_iframe.dart' as web_yt;
import '../../core/theme/app_colors.dart';
import '../../data/models/exercise.dart';

class VideoWidget extends StatefulWidget {
  final VideoExercise exercise;
  final void Function(bool) onAnswer;

  const VideoWidget({super.key, required this.exercise, required this.onAnswer});

  @override
  State<VideoWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  mobile_yt.YoutubePlayerController? _mobileController;
  web_yt.YoutubePlayerController? _iframeController;
  String? _selected;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _iframeController = web_yt.YoutubePlayerController.fromVideoId(
        videoId: widget.exercise.youtubeId,
        params: const web_yt.YoutubePlayerParams(showControls: true, showFullscreenButton: true),
      );
    } else {
      _mobileController = mobile_yt.YoutubePlayerController(
        initialVideoId: widget.exercise.youtubeId,
        flags: const mobile_yt.YoutubePlayerFlags(autoPlay: false, mute: false),
      );
    }
  }

  @override
  void dispose() {
    _mobileController?.dispose();
    _iframeController?.close();
    super.dispose();
  }

  void _select(String id) {
    if (_selected != null) return;
    setState(() => _selected = id);
    Future.delayed(const Duration(milliseconds: 600), () {
      widget.onAnswer(id == widget.exercise.correctId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Video player
          if (kIsWeb && _iframeController != null)
            web_yt.YoutubePlayer(controller: _iframeController!)
          else if (!kIsWeb && _mobileController != null)
            mobile_yt.YoutubePlayer(controller: _mobileController!, showVideoProgressIndicator: true),
          // Question
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.exercise.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                const SizedBox(height: 16),
                const Text('CÂU HỎI', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 1.5)),
                const SizedBox(height: 8),
                Text(widget.exercise.question, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                const SizedBox(height: 14),
                ...widget.exercise.options.map((opt) {
                  Color bg = AppColors.white, border = AppColors.border, text = AppColors.textDark;
                  if (_selected != null) {
                    if (opt.id == widget.exercise.correctId) { bg = AppColors.success; border = AppColors.success; text = Colors.white; }
                    else if (opt.id == _selected) { bg = AppColors.error; border = AppColors.error; text = Colors.white; }
                    else { bg = AppColors.cream; text = AppColors.textMuted; }
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GestureDetector(
                      onTap: () => _select(opt.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: border, width: 2)),
                        child: Text(opt.text, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: text)),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
