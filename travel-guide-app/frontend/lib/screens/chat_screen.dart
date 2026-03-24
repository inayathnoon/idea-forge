import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/tour.dart';
import '../models/guide.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ApiService _apiService = ApiService();

  List<ChatMessage> _messages = [];
  bool _isLoading = false;

  // User preferences collected during chat
  String? _selectedCity;
  List<String> _selectedInterests = [];

  @override
  void initState() {
    super.initState();
    _addBotMessage(
      'Hello! I\'m your travel guide assistant. I\'ll help you find the perfect tour and guide for your trip.\n\nWhich city are you planning to visit?',
    );
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: false));
    });
    _scrollToBottom();
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleMessage(String text) async {
    if (text.trim().isEmpty) return;

    _addUserMessage(text);
    _messageController.clear();

    setState(() => _isLoading = true);

    // Simple conversation flow
    if (_selectedCity == null) {
      // First question - asking for city
      _selectedCity = text.trim();
      _addBotMessage(
        'Great! You\'re planning to visit $_selectedCity.\n\nWhat type of experience are you interested in? (You can select multiple)\n\n1. Food tasting\n2. Bike tours\n3. Cultural experiences\n4. Adventure activities\n5. Historical sites',
      );
    } else if (_selectedInterests.isEmpty) {
      // Second question - asking for interests
      _parseInterests(text);
      _addBotMessage(
        'Excellent choice! Let me find the best tours and guides for you in $_selectedCity...',
      );

      // Get recommendations from backend
      await _getRecommendations();
    }

    setState(() => _isLoading = false);
  }

  void _parseInterests(String text) {
    final lowerText = text.toLowerCase();
    if (lowerText.contains('food') || lowerText.contains('1')) {
      _selectedInterests.add('food');
    }
    if (lowerText.contains('bike') || lowerText.contains('2')) {
      _selectedInterests.add('bike');
    }
    if (lowerText.contains('cultur') || lowerText.contains('3')) {
      _selectedInterests.add('culture');
    }
    if (lowerText.contains('adventure') || lowerText.contains('4')) {
      _selectedInterests.add('adventure');
    }
    if (lowerText.contains('histor') || lowerText.contains('5')) {
      _selectedInterests.add('historical');
    }
  }

  Future<void> _getRecommendations() async {
    try {
      final response = await _apiService.getChatRecommendations({
        'city': _selectedCity,
        'interests': _selectedInterests,
      });

      final tours = (response['tours'] as List)
          .map((json) => Tour.fromJson(json))
          .toList();
      final guides = (response['guides'] as List)
          .map((json) => Guide.fromJson(json))
          .toList();

      if (tours.isNotEmpty || guides.isNotEmpty) {
        setState(() {
          _messages.add(ChatMessage(
            text: response['message'] ?? 'Here are my recommendations:',
            isUser: false,
            tours: tours,
            guides: guides,
          ));
        });
        _scrollToBottom();
      } else {
        _addBotMessage(
          'I couldn\'t find any tours or guides matching your preferences in $_selectedCity. Would you like to try a different city or interests?',
        );
      }
    } catch (e) {
      _addBotMessage(
        'Sorry, I encountered an error while searching. Please make sure the backend is running and try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personalized Tour Assistant'),
        backgroundColor: const Color(0xFFFF9800),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  SizedBox(width: 16),
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('Thinking...'),
                ],
              ),
            ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              backgroundColor: const Color(0xFFFF9800),
              radius: 18,
              child: const Icon(
                Icons.smart_toy,
                size: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: message.isUser
                        ? const Color(0xFF2196F3)
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.black87,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
                if (message.tours != null && message.tours!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Recommended Tours:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...message.tours!.map((tour) => _buildTourRecommendation(tour)),
                ],
                if (message.guides != null && message.guides!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Recommended Guides:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...message.guides!.map((guide) => _buildGuideRecommendation(guide)),
                ],
              ],
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: const Color(0xFF2196F3),
              radius: 18,
              child: const Icon(
                Icons.person,
                size: 20,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTourRecommendation(Tour tour) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 60,
              height: 60,
              color: Colors.grey[300],
              child: tour.coverImage.isNotEmpty
                  ? Image.network(
                      tour.coverImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.tour),
                    )
                  : const Icon(Icons.tour),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tour.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '\$${tour.pricePerPerson.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Color(0xFF2196F3),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.star, size: 12, color: Colors.amber),
                    const SizedBox(width: 2),
                    Text(
                      tour.averageRating.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideRecommendation(Guide guide) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFF2196F3).withOpacity(0.2),
            child: guide.user.profilePicture != null
                ? ClipOval(
                    child: Image.network(
                      guide.user.profilePicture!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.person,
                        size: 30,
                        color: Color(0xFF2196F3),
                      ),
                    ),
                  )
                : const Icon(
                    Icons.person,
                    size: 30,
                    color: Color(0xFF2196F3),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        guide.user.fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    if (guide.isVerified)
                      const Icon(Icons.verified, size: 16, color: Colors.green),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '\$${guide.hourlyRate.toStringAsFixed(0)}/hr',
                      style: const TextStyle(
                        color: Color(0xFF2196F3),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.star, size: 12, color: Colors.amber),
                    const SizedBox(width: 2),
                    Text(
                      '${guide.averageRating.toStringAsFixed(1)} (${guide.totalReviews})',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              onSubmitted: _handleMessage,
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: const Color(0xFF2196F3),
            radius: 24,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: () => _handleMessage(_messageController.text),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final List<Tour>? tours;
  final List<Guide>? guides;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.tours,
    this.guides,
  });
}
