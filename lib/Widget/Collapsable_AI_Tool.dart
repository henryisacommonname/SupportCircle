import '../Core/Services/chatgpt_API_service.dart';
import 'package:flutter/material.dart';

class collapsible_Chat extends StatefulWidget {
  final Chat_API api;
  const collapsible_Chat({super.key, required this.api});
  @override
  State<collapsible_Chat> createState() => Dock_State();
}

class Dock_State extends State<collapsible_Chat> {
  bool Open = false;
  final controller = TextEditingController();
  final List<Map<String, String>> messages = [];
  bool Busy = false;

  Future<void> connector() async {
    final text = controller.text.trim();
    if (text.isEmpty || Busy) {
      return;
    }
    setState(() {
      messages.add({"role": "user", "content": text});
      Busy = true;
    });
    controller.clear();
    try {
      final Reponse = await widget.api.chat_json(
        System_Prompt:
            "You are a community service helper and assist users by answering their questions kindly. Return ONLY JSON of the form {'reply': string}",
        User_Prompt: text,
      );
      final reply = (Reponse['reply'] ?? '').toString();
      setState(() {
        messages.add({"role": "assistant", "content": reply});
      });
    } catch (e) {
      setState(() {
        messages.add({"role": "assistant", "content": 'ERROR: $e'});
      });
    } finally {
      Busy = false;
      setState(() => Busy = false);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final docWidth = MediaQuery.of(
      context,
    ).size.width.clamp(320, 420).toDouble();
    return Stack(
      children: [
        Positioned(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            child: Open
                ? Column(
                    children: [
                      AppBar(
                        automaticallyImplyLeading: false,
                        title: Text(
                          'Welcome to the AI Chatroom! Ask any questions if needed!',
                        ),
                        actions: [
                          IconButton(
                            onPressed: () => setState(() => Open = false),
                            icon: Icon(Icons.close),
                          ),
                        ],
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: messages.length,
                          padding: const EdgeInsets.all(16),
                          itemBuilder: (context, i) {
                            final Message = messages[i];
                            final isUser = Message['role'] == 'user';
                            final avatar = CircleAvatar(
                              radius: 16,
                              backgroundColor: isUser
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.secondary,
                              child: Icon(
                                isUser
                                    ? Icons.person
                                    : (Icons.psychology_outlined),
                                size: 20,
                                color: Colors.white,
                              ),
                            );
                            final bubble = Container(
                              padding: const EdgeInsets.all(10),
                              constraints: BoxConstraints(
                                maxWidth: docWidth * 0.85,
                              ),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? Theme.of(
                                        context,
                                      ).colorScheme.primaryContainer
                                    : Theme.of(
                                        context,
                                      ).colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(Message['content'] ?? ''),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: controller,
                                minLines: 1,
                                maxLines: 6,
                                decoration: InputDecoration(
                                  hintText: "ask the AI",
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                onSubmitted: (_) => connector(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: Busy ? null : connector,
                              icon: Busy
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(),
                                    )
                                  : Icon(Icons.keyboard_return),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ),
        Positioned(
          child: FloatingActionButton.small(
            onPressed: () => setState(() => Open = !Open),
            child: Icon(Open ? Icons.chevron_left : Icons.chat_bubble_outline),
          ),
        ),
      ],
    );
  }
}
