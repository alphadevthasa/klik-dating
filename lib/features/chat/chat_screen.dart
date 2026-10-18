import 'package:flutter/material.dart';

import '../../models/chat_message.dart';
import '../../models/dating_profile.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.profiles,
    required this.conversationId,
    required this.messagesByProfile,
    required this.onOpenConversation,
    required this.onBack,
    required this.onSendMessage,
  });

  final List<DatingProfile> profiles;
  final String? conversationId;
  final Map<String, List<ChatMessage>> messagesByProfile;
  final ValueChanged<String> onOpenConversation;
  final VoidCallback onBack;
  final void Function(String profileId, String text) onSendMessage;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _composerController = TextEditingController();

  @override
  void dispose() {
    _composerController.dispose();
    super.dispose();
  }

  void _sendMessage(String profileId) {
    final text = _composerController.text.trim();
    if (text.isEmpty) return;

    widget.onSendMessage(profileId, text);
    _composerController.clear();
  }

  void _back() {
    FocusScope.of(context).unfocus();
    widget.onBack();
  }

  @override
  Widget build(BuildContext context) => PopScope<Object?>(
    canPop: widget.conversationId == null,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop && widget.conversationId != null) _back();
    },
    child: SafeArea(
      child: widget.conversationId == null
          ? _buildConversationList(context)
          : _buildSelectedConversation(context),
    ),
  );

  Widget _buildConversationList(BuildContext context) {
    final conversations = widget.profiles
        .where((profile) => widget.messagesByProfile.containsKey(profile.id))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Percakapan',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Expanded(
          child: conversations.isEmpty
              ? const Center(child: Text('Belum ada percakapan.'))
              : ListView.builder(
                  itemCount: conversations.length,
                  itemBuilder: (context, index) {
                    final profile = conversations[index];
                    final messages = widget.messagesByProfile[profile.id]!;
                    return ListTile(
                      leading: _ProfileAvatar(profile: profile),
                      title: Text('${profile.name}, ${profile.age}'),
                      subtitle: Text(
                        messages.isEmpty
                            ? 'Mulai percakapan'
                            : messages.last.text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => widget.onOpenConversation(profile.id),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSelectedConversation(BuildContext context) {
    DatingProfile? profile;
    for (final candidate in widget.profiles) {
      if (candidate.id == widget.conversationId) {
        profile = candidate;
        break;
      }
    }

    if (profile == null) {
      return Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              tooltip: 'Kembali ke daftar chat',
              onPressed: _back,
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          const Expanded(child: Center(child: Text('Profil tidak ditemukan.'))),
        ],
      );
    }

    final selectedProfile = profile;
    final messages = widget.messagesByProfile[selectedProfile.id] ?? const [];

    return Column(
      children: [
        SizedBox(
          height: 56,
          child: Row(
            children: [
              IconButton(
                tooltip: 'Kembali ke daftar chat',
                onPressed: _back,
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  selectedProfile.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: messages.isEmpty
              ? const Center(child: Text('Mulai percakapanmu di sini.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) =>
                      _MessageBubble(message: messages[index]),
                ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  key: const Key('chat-composer'),
                  controller: _composerController,
                  textInputAction: TextInputAction.send,
                  minLines: 1,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Tulis pesan...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(selectedProfile.id),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                key: const Key('chat-send'),
                tooltip: 'Kirim pesan',
                onPressed: () => _sendMessage(selectedProfile.id),
                icon: const Icon(Icons.send),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final background = message.isMine ? colors.primary : Colors.white;
    final foreground = message.isMine ? colors.onPrimary : colors.onSurface;

    return Align(
      alignment: message.isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(message.text, style: TextStyle(color: foreground)),
              const SizedBox(height: 4),
              Text(
                message.timeLabel,
                style: TextStyle(color: foreground.withValues(alpha: 0.75)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.profile});

  final DatingProfile profile;

  @override
  Widget build(BuildContext context) => ClipOval(
    child: Image.network(
      profile.imageUrl,
      width: 48,
      height: 48,
      fit: BoxFit.cover,
      semanticLabel: 'Foto ${profile.name}',
      errorBuilder: (context, error, stackTrace) =>
          CircleAvatar(child: Text(profile.name.substring(0, 1))),
    ),
  );
}
