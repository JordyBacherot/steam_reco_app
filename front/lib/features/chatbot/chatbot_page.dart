import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:front/models/chat_message.dart';
import 'package:provider/provider.dart';
import 'package:front/services/chatbot_service.dart';
import 'package:front/core/theme/app_theme.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  // Liste qui stocke tout l'historique de la conversation actuelle
  final List<ChatMessage> _messages = [
    ChatMessage(
        role: 'assistant',
        content: "Salut ! Je suis ton conseiller jeu vidéo personnel. Dis-moi ce que tu aimes, je te trouve ta prochaine pépite ! 🎮")
  ];

  // Contrôleur pour lire et effacer ce que l'utilisateur tape dans le champ de texte
  final TextEditingController _textController = TextEditingController();

  // Contrôleur pour gérer le défilement (scroll) de la liste des messages
  final ScrollController _scrollController = ScrollController();

  // Indique si on attend une réponse de l'API (pour désactiver le bouton envoyer)
  bool _isLoading = false;

  // Fonction utilitaire pour scroller tout en bas de la liste automatiquement
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // No longer manually instantiating ChatbotService
  late final ChatbotService _chatbotService;

  @override
  void initState() {
    super.initState();
    _chatbotService = Provider.of<ChatbotService>(context, listen: false);
  }

  // Permet à l'utilisateur de réinitialiser le contexte de la discussion
  void _resetConversation() {
    setState(() {
      _messages.clear();
      _messages.add(
        ChatMessage(
            role: 'assistant',
            content: "Salut ! Je suis ton conseiller jeu vidéo personnel. Dis-moi ce que tu aimes, je te trouve ta prochaine pépite ! 🎮")
      );
      _chatbotService.resetSession();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Nouvelle discussion démarrée.")),
    );
  }

  // Déclenché quand l'utilisateur clique sur "Envoyer" (ou touche Entrée)
  Future<void> _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return; // Ignore les messages vides

    _textController.clear(); // Vide le champ de texte

    // 1. Mise à jour de l'interface (setState) pour ajouter le message utilisateur
    setState(() {
      _messages.add(ChatMessage(role: 'user', content: text));

      // ASTUCE STREAMING : On crée TOUT DE SUITE une bulle vide pour l'assistant.
      // Cette bulle va se remplir progressivement à mesure qu'on reçoit les mots.
      _messages.add(ChatMessage(role: 'assistant', content: ''));
      _isLoading = true;
    });

    // on scroll en bas pour voir la nouvelle bulle vide
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    // 2. Préparation de l'historique à l'IA (On enlève les 2 derniers messages :
    // le message actuel de l'utilisateur et la bulle vide qu'on vient de créer)
    final history = _messages.sublist(0, _messages.length - 2);

    // 3. Appel à l'API via notre Service (Lancement du Stream)
    try {
      final stream = _chatbotService.sendMessageStream(
        message: text,
        history: history,
      );

      // On écoute le Stream : chaque "chunk" est un nouveau morceau de texte envoyé par le serveur
      await for (final chunk in stream) {
        setState(() {
          // On récupère l'index de la dernière bulle (celle de l'assistant)
          final lastMessageIndex = _messages.length - 1;
          final currentContent = _messages[lastMessageIndex].content;

          // On remplace la bulle par une nouvelle bulle contenant l'ancien texte + le nouveau mot
          _messages[lastMessageIndex] =
              ChatMessage(role: 'assistant', content: currentContent + chunk);
        });

        // On scroll vers le bas à chaque nouveau mot pour suivre la lecture
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    } finally {
      // Quoi qu'il arrive (succès ou erreur), on remet isLoading à false
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildMessage(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.isAssistant)
            const CircleAvatar(
              backgroundColor: AppTheme.darkerBlue,
              child: Icon(Icons.smart_toy, color: AppTheme.primaryBlue, size: 20),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? AppTheme.primaryBlue.withOpacity(0.2)
                    : AppTheme.darkerBlue,
                borderRadius: BorderRadius.circular(16),
                border: message.isUser
                    ? Border.all(
                        color: AppTheme.primaryBlue.withOpacity(0.5))
                    : null,
              ),
              child: MarkdownBody(
                data: message.content,
                selectable: true,
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(color: Colors.white),
                  h1: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                  h2: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                  h3: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                  listBullet: const TextStyle(color: Colors.white),
                  code: TextStyle(
                    backgroundColor: Colors.black.withOpacity(0.4),
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (message.isUser)
            const CircleAvatar(
              backgroundColor: AppTheme.primaryBlue,
              child: Icon(Icons.person, color: AppTheme.darkBlue, size: 20),
            ),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color:
            AppTheme.darkerBlue, // Couleurs Steam pour la barre de saisie
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 4,
            color: Colors.black.withOpacity(0.3),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                onSubmitted: _isLoading ? null : _handleSubmitted,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Posez une question sur vos jeux...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppTheme.darkBlue,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                color: AppTheme.primaryBlue, // Bouton d'envoi bleu Steam
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: AppTheme.darkBlue),
                onPressed: _isLoading
                    ? null
                    : () => _handleSubmitted(_textController.text),
              ),
            ),
          ],
        ),
      ),
    );
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
                return _buildMessage(_messages[index]);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          _buildTextComposer(),
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
