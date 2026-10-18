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
  final _messagesController = ScrollController();

  @override
  void dispose() {
    _composerController.dispose();
    _messagesController.dispose();
    super.dispose();
  }

  void _sendMessage(String profileId) {
    final text = _composerController.text.trim();
    if (text.isEmpty) return;

    widget.onSendMessage(profileId, text);
    _composerController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_messagesController.hasClients) return;
      _messagesController.animateTo(
        _messagesController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
    });
  }

  void _back() {
    FocusScope.of(context).unfocus();
    widget.onBack();
  }

  void _showAttachmentSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final option in [
              ('Kamera', Icons.camera_alt_outlined),
              ('Galeri', Icons.photo_outlined),
              ('Dokumen', Icons.insert_drive_file_outlined),
            ])
              ListTile(
                leading: Icon(option.$2),
                title: Text(option.$1),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lampiran demo belum tersedia.'),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showEmojiSheet() {
    const emojis = ['😊', '❤️', '😂', '😍', '👋', '☕'];
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final emoji in emojis)
                ActionChip(
                  label: Text(emoji, style: const TextStyle(fontSize: 24)),
                  onPressed: () {
                    _insertEmoji(emoji);
                    Navigator.of(sheetContext).pop();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _insertEmoji(String emoji) {
    final value = _composerController.value;
    final selection = value.selection;
    final start = selection.isValid ? selection.start : value.text.length;
    final end = selection.isValid ? selection.end : value.text.length;
    final text = value.text.replaceRange(start, end, emoji);
    _composerController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: start + emoji.length),
    );
  }

  void _showChatOptions() {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('Info percakapan'),
          onTap: () {
            Navigator.of(sheetContext).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Info percakapan demo.')),
            );
          },
        ),
      ),
    );
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
          height: 72,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Kembali ke daftar chat',
                  onPressed: _back,
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                _ProfileAvatar(profile: selectedProfile, size: 44),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              selectedProfile.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          Text(
                            ', ${selectedProfile.age}',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Row(
                        children: [
                          _OnlineDot(),
                          SizedBox(width: 5),
                          Text('Online', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Panggil ${selectedProfile.name}',
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Panggilan dengan ${selectedProfile.name} belum tersedia.',
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.call_outlined),
                ),
                IconButton(
                  tooltip: 'Opsi chat',
                  onPressed: _showChatOptions,
                  icon: const Icon(Icons.more_horiz),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: messages.isEmpty
              ? const Center(child: Text('Mulai percakapanmu di sini.'))
              : ListView.builder(
                  controller: _messagesController,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  itemCount: messages.length + 1,
                  itemBuilder: (context, index) => index == 0
                      ? const _DateSeparator()
                      : _MessageBubble(
                          message: messages[index - 1],
                          profile: selectedProfile,
                        ),
                ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 10, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                tooltip: 'Tambahkan lampiran',
                onPressed: _showAttachmentSheet,
                color: Theme.of(context).colorScheme.primary,
                icon: const Icon(Icons.add_circle_outline_rounded),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE9E1DC)),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
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
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          onSubmitted: (_) => _sendMessage(selectedProfile.id),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Pilih emoji',
                        onPressed: _showEmojiSheet,
                        icon: const Icon(Icons.emoji_emotions_outlined),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              IconButton.filled(
                key: const Key('chat-send'),
                tooltip: 'Kirim pesan',
                onPressed: () => _sendMessage(selectedProfile.id),
                icon: const Icon(Icons.send_rounded),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OnlineDot extends StatelessWidget {
  const _OnlineDot();

  @override
  Widget build(BuildContext context) => Container(
    width: 8,
    height: 8,
    decoration: const BoxDecoration(
      color: Color(0xFF4D9B70),
      shape: BoxShape.circle,
    ),
  );
}

class _DateSeparator extends StatelessWidget {
  const _DateSeparator();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'Hari ini',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    ),
  );
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.profile});

  final ChatMessage message;
  final DatingProfile profile;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final bubbleColor = message.isMine
        ? colors.primary
        : const Color(0xFFF1EBE5);
    final textColor = message.isMine ? Colors.white : colors.onSurface;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: message.isMine
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isMine) ...[
            Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 2),
              child: _ProfileAvatar(profile: profile, size: 28),
            ),
          ],
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(message.isMine ? 18 : 4),
                    bottomRight: Radius.circular(message.isMine ? 4 : 18),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(message.text, style: TextStyle(color: textColor)),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            message.timeLabel,
                            style: TextStyle(
                              color: textColor.withValues(alpha: 0.72),
                              fontSize: 11,
                            ),
                          ),
                          if (message.isMine) ...[
                            const SizedBox(width: 4),
                            Semantics(
                              label: 'Dibaca',
                              child: Icon(
                                Icons.done_all,
                                size: 15,
                                color: textColor.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.profile, this.size = 48});

  final DatingProfile profile;
  final double size;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    excludeSemantics: true,
    image: true,
    label: 'Foto ${profile.name}',
    child: ClipOval(
      child: Image.network(
        profile.imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => CircleAvatar(
          radius: size / 2,
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Theme.of(context).colorScheme.onSecondary,
          child: Text(profile.name.substring(0, 1)),
        ),
      ),
    ),
  );
}
