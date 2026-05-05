import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/chat_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/message_service.dart';
import '../../core/services/user_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/constants/app_dimens.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final uid = auth.user!.uid;
    final service = MessageService();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<List<ChatModel>>(
        stream: service.getUserChats(uid),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final chats = snap.data ?? [];
          if (chats.isEmpty) return const _EmptyInbox();
          return ListView.separated(
            padding: const EdgeInsets.all(AppDimens.md),
            itemCount: chats.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppDimens.xs),
            itemBuilder: (context, i) => _ChatTile(
              chat: chats[i],
              myUid: uid,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    chat: chats[i],
                    myUid: uid,
                    myName: auth.user?.displayName ?? '',
                  ),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewMessageDialog(context, uid, auth.user?.displayName ?? ''),
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.white,
        child: const Icon(Icons.edit_outlined),
      ),
    );
  }

  void _showNewMessageDialog(BuildContext context, String myUid, String myName) {
    final emailCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Message'),
        content: TextField(
          controller: emailCtrl,
          autofocus: true,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: "Recipient's email address",
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final user = await UserService().findByEmail(emailCtrl.text);
              if (!context.mounted) return;
              if (user == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No user found with that email.'), behavior: SnackBarBehavior.floating),
                );
                return;
              }
              final chatId = await MessageService().getOrCreateChat(
                myUid: myUid, myName: myName,
                otherUid: user.uid, otherName: user.fullName,
              );
              if (!context.mounted) return;
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ChatScreen(
                  chat: ChatModel(id: chatId, participants: [myUid, user.uid],
                      participantNames: {myUid: myName, user.uid: user.fullName}, lastMessage: ''),
                  myUid: myUid, myName: myName,
                ),
              ));
            },
            child: const Text('Open Chat'),
          ),
        ],
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  const _ChatTile({required this.chat, required this.myUid, required this.onTap});
  final ChatModel chat;
  final String myUid;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final name = chat.otherName(myUid);
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimens.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          boxShadow: isDark ? AppShadows.cardDark : AppShadows.card,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24, backgroundColor: AppColors.primaryPastel,
              child: Text(initial, style: const TextStyle(color: AppColors.primaryLight,
                  fontWeight: FontWeight.w700, fontFamily: 'Poppins', fontSize: 16)),
            ),
            const SizedBox(width: AppDimens.md),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 15)),
                const SizedBox(height: 2),
                Text(chat.lastMessage, style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ]),
            ),
            if (chat.lastMessageTime != null)
              Text(_formatTime(chat.lastMessageTime!), style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inDays == 0) return '${t.hour}:${t.minute.toString().padLeft(2, '0')}';
    if (diff.inDays == 1) return 'Yesterday';
    return '${t.day}/${t.month}';
  }
}

class _EmptyInbox extends StatelessWidget {
  const _EmptyInbox();
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.chat_bubble_outline, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
      const SizedBox(height: AppDimens.md),
      Text('No conversations yet', style: Theme.of(context).textTheme.bodyMedium),
      Text('Tap ✏ to start a new chat', style: Theme.of(context).textTheme.bodySmall),
    ]),
  );
}
