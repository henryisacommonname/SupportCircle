import 'dart:async';

import 'package:flutter/material.dart';

import '../services/chat_api_service.dart';

class CollapsibleChat extends StatefulWidget {
  final ChatApiService api;

  const CollapsibleChat({super.key, required this.api});

  @override
  State<CollapsibleChat> createState() => _CollapsibleChatState();
}

class _CollapsibleChatState extends State<CollapsibleChat>
    with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  bool _isBusy = false;
  String? _statusMessage;
  Timer? _warmupTimer;
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 280),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInCubic,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _warmupTimer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isBusy) return;

    _warmupTimer?.cancel();
    setState(() {
      _isBusy = true;
      _statusMessage = null;
      _messages.add({'role': 'user', 'content': text});
    });

    _warmupTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted || !_isBusy) return;
      setState(() {
        _statusMessage = 'Server starting, please wait...';
      });
    });

    _resetComposer();
    _scrollToBottom();

    try {
      final response = await _callWithWakeupRetry(text);
      final reply = (response['reply'] ?? '').toString();

      if (!mounted) return;

      setState(() {
        _messages.add({'role': 'assistant', 'content': reply});
        _statusMessage = null;
      });
      _scrollToBottom();
    } on ChatApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _messages.add({
          'role': 'assistant',
          'content': error.isWakingUp
              ? 'Server is waking up. Please try again in a moment.'
              : 'Sorry, something went wrong. (${error.message})',
        });
        _statusMessage = null;
      });
      _scrollToBottom();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _messages.add({
          'role': 'assistant',
          'content': 'Sorry, something went wrong. ($error)',
        });
        _statusMessage = null;
      });
      _scrollToBottom();
    } finally {
      _warmupTimer?.cancel();
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<Map<String, dynamic>> _callWithWakeupRetry(String text) async {
    const systemPrompt =
        "You are a community service helper and assist users by answering their questions kindly. Return ONLY JSON of the form {'reply': string}";

    try {
      return await widget.api.chatJson(
        systemPrompt: systemPrompt,
        userPrompt: text,
      );
    } on ChatApiException catch (error) {
      if (!error.isWakingUp) rethrow;

      if (mounted) {
        setState(() {
          _statusMessage = 'Server waking up, retrying...';
        });
      }

      return await widget.api.chatJson(
        systemPrompt: systemPrompt,
        userPrompt: text,
      );
    }
  }

  void _togglePanel() {
    setState(() => _isOpen = !_isOpen);
    if (_isOpen) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _closePanel() {
    if (!_isOpen) return;
    setState(() => _isOpen = false);
    _animationController.reverse();
  }

  void _resetComposer() {
    _controller.clear();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        curve: Curves.easeOutCubic,
        duration: const Duration(milliseconds: 250),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final bottomPadding = mediaQuery.padding.bottom;

    // Card dimensions
    final cardHeight = screenHeight * 0.70;
    final cardWidth = screenWidth - 32; // 16px padding on each side
    final fabBottom = bottomPadding + 80; // Above nav bar

    return Stack(
      children: [
        // Backdrop - tap to close
        if (_isOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: _closePanel,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.4),
                ),
              ),
            ),
          ),

        // Expanded chat card
        Positioned(
          right: 16,
          bottom: fabBottom,
          child: ScaleTransition(
            scale: _scaleAnimation,
            alignment: Alignment.bottomRight,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: IgnorePointer(
                ignoring: !_isOpen,
                child: SizedBox(
                  width: cardWidth,
                  height: cardHeight,
                  child: _buildChatCard(context),
                ),
              ),
            ),
          ),
        ),

        // FAB button
        Positioned(
          right: 16,
          bottom: fabBottom,
          child: AnimatedScale(
            scale: _isOpen ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: AnimatedOpacity(
              opacity: _isOpen ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 150),
              child: _buildFab(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFab(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      elevation: 6,
      shadowColor: theme.colorScheme.primary.withValues(alpha: 0.4),
      borderRadius: BorderRadius.circular(28),
      color: theme.colorScheme.primaryContainer,
      child: InkWell(
        onTap: _togglePanel,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.psychology,
                size: 20,
                color: theme.colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 8),
              Text(
                'Ask AI',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatCard(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      elevation: 16,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          _buildHeader(context),
          if (_statusMessage != null) _StatusBanner(message: _statusMessage!),
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isUser = message['role'] == 'user';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _MessageBubble(
                          isUser: isUser,
                          text: message['content'] ?? '',
                        ),
                      );
                    },
                  ),
          ),
          _buildComposer(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 8, 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.psychology,
              size: 20,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Assistant',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                Text(
                  'Here to help with your questions',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer
                        .withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _closePanel,
            icon: const Icon(Icons.close_rounded),
            color: theme.colorScheme.onPrimaryContainer,
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 48,
              color: theme.colorScheme.outline.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'How can I help you today?',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Ask me anything about volunteering,\ncommunity service, or using the app.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComposer(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              decoration: InputDecoration(
                hintText: 'Type your message...',
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.5),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              onTap: _isBusy ? null : _sendMessage,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.all(12),
                child: _isBusy
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.onPrimary,
                        ),
                      )
                    : Icon(
                        Icons.send_rounded,
                        size: 24,
                        color: theme.colorScheme.onPrimary,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final bool isUser;
  final String text;

  const _MessageBubble({required this.isUser, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 20),
          ),
        ),
        child: Text(
          text,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isUser
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final String message;

  const _StatusBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.5),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.colorScheme.tertiary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onTertiaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
