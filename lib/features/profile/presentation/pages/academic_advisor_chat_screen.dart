import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

class AcademicAdvisorChatScreen extends StatefulWidget {
  const AcademicAdvisorChatScreen({super.key});

  @override
  State<AcademicAdvisorChatScreen> createState() => _AcademicAdvisorChatScreenState();
}

class _AcademicAdvisorChatScreenState extends State<AcademicAdvisorChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isAdvisorTyping = false;
  Timer? _typingTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_messages.isEmpty) {
      _messages.add(_ChatMessage(text: AppLocalizations.of(context)!.advisorGreeting, isUser: false));
    }
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final l10n = AppLocalizations.of(context)!;
    final text = _messageController.text.trim();
    if (text.isEmpty || _isAdvisorTyping) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _isAdvisorTyping = true;
    });
    _messageController.clear();
    FocusScope.of(context).unfocus();
    _scrollToBottom();

    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(milliseconds: 1300), () {
      if (!mounted) return;
      setState(() {
        _isAdvisorTyping = false;
        _messages.add(_ChatMessage(text: l10n.advisorThanksMessage, isUser: false));
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,

        title: Text(

          l10n.contactAcademicAdvisor,

          maxLines: 1,

          overflow: TextOverflow.ellipsis,

          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: theme.primaryColor),

        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                itemCount: _messages.length + (_isAdvisorTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_isAdvisorTyping && index == _messages.length) {
                    return _TypingBubble(isDark: isDark, text: l10n.advisorTyping);
                  }
                  return _MessageBubble(message: _messages[index], isDark: isDark);
                },
              ),
            ),
            _MessageInput(
              controller: _messageController,
              hintText: l10n.advisorMessageHint,
              isEnabled: !_isAdvisorTyping,
              onSend: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageInput extends StatelessWidget {
  const _MessageInput({
    required this.controller,
    required this.hintText,
    required this.isEnabled,
    required this.onSend,
  });

  final TextEditingController controller;
  final String hintText;
  final bool isEnabled;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(top: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: isEnabled,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              style: GoogleFonts.cairo(fontSize: 15),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: GoogleFonts.cairo(color: AppColors.textGrey),
                filled: true,
                fillColor: isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 48,
            height: 48,
            child: ElevatedButton(
              onPressed: isEnabled ? onSend : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.textGrey.withValues(alpha: 0.3),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Icon(Icons.send_rounded, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isDark});

  final _ChatMessage message;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bubbleColor = message.isUser
        ? Theme.of(context).primaryColor
        : isDark
            ? AppColors.cardDark
            : AppColors.cardLight;
    final textColor = message.isUser ? Colors.white : (isDark ? Colors.white : Colors.black87);

    return Align(
      alignment: message.isUser ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.76),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadiusDirectional.only(
            topStart: const Radius.circular(18),
            topEnd: const Radius.circular(18),
            bottomStart: Radius.circular(message.isUser ? 18 : 4),
            bottomEnd: Radius.circular(message.isUser ? 4 : 18),
          ),
        ),
        child: Text(
          message.text,
          style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w600, color: textColor),
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble({required this.isDark, required this.text});

  final bool isDark;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: 10),
            Flexible(

              child: Text(

                text,

                maxLines: 1,

                overflow: TextOverflow.ellipsis,

                style: GoogleFonts.cairo(

                  fontSize: 14,

                  fontWeight: FontWeight.w600,

                  color: isDark ? Colors.white : Colors.black87,

                ),

              ),

            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMessage {
  const _ChatMessage({required this.text, required this.isUser});

  final String text;
  final bool isUser;
}


