import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../Core/Services/chatgpt_api_service.dart';

class CollapsibleChat extends StatefulWidget {
  const CollapsibleChat({super.key, required this.api});

  final ChatApiService api;

  @override
  State<CollapsibleChat> createState() => _CollapsibleChatState();
}

class _CollapsibleChatState extends State<CollapsibleChat> {
  static const double _handleWidth = 36;

  bool _isOpen = false;
  bool _isBusy = false;
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleComposerChange);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleComposerChange);
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isBusy) {
      return;
    }

    setState(() {
      _isBusy = true;
      _messages.add({"role": "user", "content": text});
    });
    _resetComposer();
    _scrollToBottom();

    try {
      final response = await widget.api.chatJson(
        systemPrompt:
            "You are a community service helper and assist users by answering their questions kindly. Return ONLY JSON of the form {'reply': string}",
        userPrompt: text,
      );
      final reply = (response['reply'] ?? '').toString();

      if (!mounted) {
        return;
      }

      setState(() {
        _messages.add({"role": "assistant", "content": reply});
      });
      _scrollToBottom();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _messages.add({
          "role": "assistant",
          "content": 'Sorry, something went wrong. ($error)',
        });
      });
      _scrollToBottom();
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  void _togglePanel() {
    setState(() => _isOpen = !_isOpen);
  }

  void _handleComposerChange() {
    final value = _controller.value;
    if (value.text.isEmpty && value.composing.isValid) {
      _controller.value = value.copyWith(composing: TextRange.empty);
    }
  }

  void _resetComposer() {
    _controller.value = const TextEditingValue();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        curve: Curves.easeOutCubic,
        duration: const Duration(milliseconds: 250),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaSize = MediaQuery.of(context).size;
    final panelWidth = math.min(
      math.max(mediaSize.width * 0.42, 260.0),
      360.0,
    );

    return Stack(
      children: [
        AnimatedPositioned(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeInOutCubic,
          top: 0,
          bottom: 0,
          left: _isOpen ? 0 : -panelWidth + _handleWidth + 12,
          child: SafeArea(
            child: SizedBox(
              width: panelWidth,
              child: Row(
                children: [
                  _ChatHandle(
                    isOpen: _isOpen,
                    onTap: _togglePanel,
                    width: _handleWidth,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: IgnorePointer(
                      ignoring: !_isOpen,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: _isOpen ? 1 : 0,
                        curve: Curves.easeIn,
                        child: _buildPanel(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          top: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _isOpen ? 0 : 1,
                curve: Curves.easeInOut,
                child: IgnorePointer(
                  ignoring: _isOpen,
                  child: FilledButton.icon(
                    onPressed: _togglePanel,
                    icon: const Icon(Icons.chat_bubble_outline, size: 18),
                    label: const Text('AI Assistant'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      textStyle: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPanel(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Material(
        elevation: 8,
        borderRadius: const BorderRadius.horizontal(
          right: Radius.circular(24),
        ),
        clipBehavior: Clip.antiAlias,
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          children: [
            _buildHeader(context),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isUser = message['role'] == 'user';
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Align(
                      alignment: isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: _MessageBubble(
                        isUser: isUser,
                        text: message['content'] ?? '',
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1),
            _buildComposer(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: _togglePanel,
      child: Container(
        color: theme.colorScheme.primaryContainer,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.psychology_outlined,
              size: 20,
              color: theme.colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Need a hand?\nAsk our AI assistant.',
                style: theme.textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComposer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Ask the AI assistant…',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _isBusy ? null : _sendMessage,
            icon: _isBusy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}

class _ChatHandle extends StatelessWidget {
  const _ChatHandle({
    required this.isOpen,
    required this.onTap,
    required this.width,
  });

  final bool isOpen;
  final VoidCallback onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: width,
      child: Center(
        child: Material(
          color: theme.colorScheme.primary,
          elevation: 3,
          shape: const StadiumBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const StadiumBorder(),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
              child: Icon(
                isOpen ? Icons.chevron_left : Icons.chat_bubble_outline,
                color: theme.colorScheme.onPrimary,
                size: width * 0.75,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.isUser,
    required this.text,
  });

  final bool isUser;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bubbleColor = isUser
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.secondaryContainer;
    final textColor = isUser
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSecondaryContainer;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Text(
          text,
          style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
        ),
      ),
    );
  }
}
