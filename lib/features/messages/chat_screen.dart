import 'package:flutter/material.dart';
import '../../core/models/chat_model.dart';
import '../../core/services/message_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/constants/app_dimens.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.chat,
    required this.myUid,
    required this.myName,
  });

  final ChatModel chat;
  final String myUid;
  final String myName;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _service = MessageService();
  bool _sending = false;

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _sending) return;
    _ctrl.clear();
    setState(() => _sending = true);
    await _service.sendMessage(
      chatId: widget.chat.id,
      senderId: widget.myUid,
      text: text,
    );
    setState(() => _sending = false);
    // Scroll to bottom after sending.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: AppDimens.durationNormal,
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final otherName = widget.chat.otherName(widget.myUid);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryPastel,
              child: Text(
                otherName.isNotEmpty ? otherName[0].toUpperCase() : '?',
                style: const TextStyle(
                    color: AppColors.primaryLight,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins'),
              ),
            ),
            const SizedBox(width: AppDimens.sm),
            Text(otherName),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── Messages ─────────────────────────────────────────────────
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: _service.getMessages(widget.chat.id),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final msgs = snap.data ?? [];
                if (msgs.isEmpty) {
                  return Center(
                    child: Text('Say hi! 👋',
                        style: Theme.of(context).textTheme.bodySmall),
                  );
                }
                return ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.all(AppDimens.md),
                  itemCount: msgs.length,
                  itemBuilder: (context, i) => _MessageBubble(
                    message: msgs[i],
                    isMe: msgs[i].senderId == widget.myUid,
                  ),
                );
              },
            ),
          ),

          // ── Input Bar ─────────────────────────────────────────────────
          _InputBar(ctrl: _ctrl, onSend: _send, sending: _sending),
        ],
      ),
    );
  }
}

// ── Message Bubble ────────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isMe});
  final MessageModel message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimens.sm),
        padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.md, vertical: AppDimens.sm),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.72),
        decoration: BoxDecoration(
          color: isMe
              ? AppColors.primaryLight
              : isDark
                  ? AppColors.cardDark
                  : AppColors.surfaceLight,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(AppDimens.radiusMd),
            topRight: const Radius.circular(AppDimens.radiusMd),
            bottomLeft: Radius.circular(isMe ? AppDimens.radiusMd : 4),
            bottomRight: Radius.circular(isMe ? 4 : AppDimens.radiusMd),
          ),
          boxShadow: isMe ? AppShadows.floating : (isDark ? AppShadows.cardDark : AppShadows.card),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: isMe ? AppColors.white : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

// ── Input Bar ─────────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  const _InputBar(
      {required this.ctrl, required this.onSend, required this.sending});
  final TextEditingController ctrl;
  final VoidCallback onSend;
  final bool sending;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.fromLTRB(AppDimens.md, AppDimens.sm, AppDimens.sm,
          MediaQuery.of(context).viewInsets.bottom + AppDimens.sm),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: ctrl,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: const InputDecoration(
                  hintText: 'Type a message…',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: AppDimens.sm),
            AnimatedContainer(
              duration: AppDimens.durationNormal,
              child: IconButton(
                onPressed: sending ? null : onSend,
                icon: sending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.send_rounded, color: AppColors.primaryLight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
