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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            child: Open
                ? Column(
                    children: [
                      AppBar(
                        title: Text(
                          'Welcome to the AI Chatroom! Ask any questions if needed!',
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}
