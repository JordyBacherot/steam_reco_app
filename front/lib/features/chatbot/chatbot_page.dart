// File: front/features/chatbot/chatbot_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:front/models/chat_message.dart';
import 'package:front/services/chatbot_service.dart';
// N'oublie pas d'importer tes nouveaux widgets :
import 'package:front/features/chatbot/widgets/chat_bubble.dart';
import 'package:front/features/chatbot/widgets/chat_input.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final List<ChatMessage> _messages = [
    ChatMessage(
        role: 'assistant',
        content:
            "Salut ! Je suis ton conseiller jeu vidéo personnel. Dis-moi ce que tu aimes, je te trouve ta prochaine pépite ! 🎮")
  ];

  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  late final ChatbotService _chatbotService;

  @override
  void initState() {
    super.initState();
    _chatbotService = Provider.of<ChatbotService>(context, listen: false);
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _resetConversation() {
    setState(() {
      _messages.clear();
      _messages.add(ChatMessage(
          role: 'assistant',
          content:
              "Salut ! Je suis ton conseiller jeu vidéo personnel. Dis-moi ce que tu aimes, je te trouve ta prochaine pépite ! 🎮"));
      _chatbotService.resetSession();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Nouvelle discussion démarrée.")),
    );
  }

  Future<void> _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;

    _textController.clear();

    setState(() {
      _messages.add(ChatMessage(role: 'user', content: text));
      _messages.add(ChatMessage(role: 'assistant', content: ''));
      _isLoading = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    final history = _messages.sublist(0, _messages.length - 2);

    try {
      final stream = _chatbotService.sendMessageStream(
        message: text,
        history: history,
      );

      await for (final chunk in stream) {
        setState(() {
          final lastMessageIndex = _messages.length - 1;
          final currentContent = _messages[lastMessageIndex].content;

          _messages[lastMessageIndex] =
              ChatMessage(role: 'assistant', content: currentContent + chunk);
        });

        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Assistant IA'),
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Nouvelle discussion',
            onPressed: _isLoading ? null : _resetConversation,
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                // Utilisation du nouveau widget ChatBubble
                return ChatBubble(message: _messages[index]);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          // Utilisation du nouveau widget ChatInput
          ChatInput(
            controller: _textController,
            isLoading: _isLoading,
            onSubmitted: _handleSubmitted,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
