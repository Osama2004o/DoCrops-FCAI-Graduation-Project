import 'package:flutter/material.dart';
import '../widgets/shared_widgets.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: const [
              ChatBubble(
                text:
                    "Hello! I'm your plant care assistant. How can I help you today?",
                isUser: false,
              ),
              ChatBubble(
                text:
                    "My monstera leaves are turning yellow. What should I do?",
                isUser: true,
              ),
              ChatBubble(
                text:
                    "Yellow leaves can be caused by overwatering, insufficient light, or nutrient deficiency. Could you tell me more about your watering schedule?",
                isUser: false,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Type your message...",
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              CircleAvatar(
                backgroundColor: const Color(0xFF2E7D32),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
