// Chat Controller
class ChatController {
    constructor() {
        this.messages = [];
        this.conversationState = 'initial';
        this.userPreferences = {};
        this.init();
    }

    init() {
        const sendBtn = document.getElementById('chatSendBtn');
        const input = document.getElementById('chatInput');

        if (sendBtn) {
            sendBtn.addEventListener('click', () => this.sendMessage());
        }

        if (input) {
            input.addEventListener('keypress', (e) => {
                if (e.key === 'Enter') {
                    this.sendMessage();
                }
            });
        }
    }

    async sendMessage() {
        const input = document.getElementById('chatInput');
        const message = input.value.trim();

        if (!message) return;

        // Add user message to chat
        this.addMessage(message, 'user');
        input.value = '';

        // Process message based on conversation state
        await this.processMessage(message);
    }

    addMessage(text, sender = 'bot') {
        const messagesContainer = document.getElementById('chatMessages');
        const messageDiv = document.createElement('div');
        messageDiv.className = `message ${sender}-message`;

        const avatarDiv = document.createElement('div');
        avatarDiv.className = 'message-avatar';
        avatarDiv.innerHTML = sender === 'bot' ? '<i class="fas fa-robot"></i>' : '<i class="fas fa-user"></i>';

        const contentDiv = document.createElement('div');
        contentDiv.className = 'message-content';
        contentDiv.innerHTML = `<p>${text}</p>`;

        messageDiv.appendChild(avatarDiv);
        messageDiv.appendChild(contentDiv);
        messagesContainer.appendChild(messageDiv);

        // Scroll to bottom
        messagesContainer.scrollTop = messagesContainer.scrollHeight;

        this.messages.push({ text, sender });
    }

    async processMessage(message) {
        const lowerMessage = message.toLowerCase();

        switch (this.conversationState) {
            case 'initial':
                // Try to extract city
                if (this.containsCity(lowerMessage)) {
                    this.userPreferences.city = this.extractCity(lowerMessage);
                    this.conversationState = 'asking_interests';
                    this.addMessage(`Great! You're interested in ${this.userPreferences.city}. What activities are you interested in? (e.g., food, culture, adventure, hiking, biking)`);
                } else {
                    this.conversationState = 'asking_city';
                    this.addMessage("I'd be happy to help! Which city are you planning to visit?");
                }
                break;

            case 'asking_city':
                this.userPreferences.city = this.extractCity(message);
                this.conversationState = 'asking_interests';
                this.addMessage(`Perfect! What kind of activities are you interested in ${this.userPreferences.city}? (e.g., food tours, cultural experiences, adventure activities, hiking, biking)`);
                break;

            case 'asking_interests':
                this.userPreferences.interests = this.extractInterests(message);
                this.conversationState = 'complete';
                this.addMessage("Let me find the best tours and guides for you...");
                await this.getRecommendations();
                break;

            case 'complete':
                // Already have recommendations, provide conversational response
                if (lowerMessage.includes('more') || lowerMessage.includes('other') || lowerMessage.includes('different')) {
                    this.conversationState = 'asking_interests';
                    this.addMessage("What other activities would you like to explore?");
                } else {
                    this.addMessage("I've shown you personalized recommendations below. Would you like to search for something else? Just let me know what you're interested in!");
                }
                break;
        }
    }

    containsCity(text) {
        // Simple check for common city-related words
        const cityKeywords = ['visit', 'going to', 'traveling to', 'planning to go', 'trip to'];
        return cityKeywords.some(keyword => text.includes(keyword));
    }

    extractCity(text) {
        // Try to extract city name (capitalize first letter of each word)
        // This is a simple implementation - in production, you'd use NLP
        const words = text.split(' ');

        // Look for capitalized words or common city names
        const commonCities = ['new york', 'los angeles', 'chicago', 'san francisco', 'boston', 'seattle',
                             'miami', 'las vegas', 'paris', 'london', 'tokyo', 'rome', 'barcelona'];

        for (const city of commonCities) {
            if (text.toLowerCase().includes(city)) {
                return city.split(' ').map(w => w.charAt(0).toUpperCase() + w.slice(1)).join(' ');
            }
        }

        // Fallback: look for words after "in", "to", "visit"
        const prepositions = ['in', 'to', 'visit'];
        for (let i = 0; i < words.length; i++) {
            if (prepositions.includes(words[i].toLowerCase()) && words[i + 1]) {
                return words[i + 1].charAt(0).toUpperCase() + words[i + 1].slice(1);
            }
        }

        // If no city found, use current location
        return locationService.getCurrentCity() || 'New York';
    }

    extractInterests(text) {
        const interestMap = {
            'food': ['food', 'eating', 'restaurant', 'culinary', 'dining', 'taste', 'tasting'],
            'culture': ['culture', 'cultural', 'art', 'museum', 'history', 'historical'],
            'adventure': ['adventure', 'exciting', 'thrill', 'extreme'],
            'hiking': ['hike', 'hiking', 'nature', 'trail', 'mountain', 'outdoor'],
            'bike': ['bike', 'biking', 'cycling', 'bicycle'],
            'nightlife': ['nightlife', 'night', 'party', 'bar', 'club']
        };

        const interests = [];
        const lowerText = text.toLowerCase();

        for (const [interest, keywords] of Object.entries(interestMap)) {
            if (keywords.some(keyword => lowerText.includes(keyword))) {
                interests.push(interest);
            }
        }

        // If no specific interests found, default to popular ones
        return interests.length > 0 ? interests : ['food', 'culture'];
    }

    async getRecommendations() {
        try {
            const data = await api.getChatRecommendations(this.userPreferences);

            // Show success message
            this.addMessage(`I found ${data.tours?.length || 0} tours and ${data.guides?.length || 0} expert guides for you!`);

            // Display recommendations
            const recommendationsDiv = document.getElementById('chatRecommendations');
            const toursDiv = document.getElementById('recommendedTours');
            const guidesDiv = document.getElementById('recommendedGuides');

            if (data.tours && data.tours.length > 0) {
                toursDiv.innerHTML = '<h4 style="margin: 1rem 0;">Recommended Tours</h4>';
                const toursGrid = document.createElement('div');
                toursGrid.className = 'tours-grid';
                toursGrid.innerHTML = data.tours.map(tour => uiManager.createTourCard(tour)).join('');

                // Add click handlers
                toursGrid.querySelectorAll('.tour-card').forEach(card => {
                    card.addEventListener('click', () => {
                        const tourId = card.getAttribute('data-tour-id');
                        uiManager.showTourDetail(tourId);
                    });
                });

                toursDiv.appendChild(toursGrid);
            }

            if (data.guides && data.guides.length > 0) {
                guidesDiv.innerHTML = '<h4 style="margin: 2rem 0 1rem;">Recommended Guides</h4>';
                const guidesGrid = document.createElement('div');
                guidesGrid.className = 'guides-grid';
                guidesGrid.innerHTML = data.guides.map(guide => uiManager.createGuideCard(guide)).join('');

                // Add click handlers
                guidesGrid.querySelectorAll('.guide-card').forEach(card => {
                    card.addEventListener('click', () => {
                        const guideId = card.getAttribute('data-guide-id');
                        uiManager.showGuideDetail(guideId);
                    });
                });

                guidesDiv.appendChild(guidesGrid);
            }

            recommendationsDiv.style.display = 'block';
        } catch (error) {
            console.error('Error getting recommendations:', error);
            this.addMessage("I'm sorry, I had trouble getting recommendations. Please try again or browse our tours and guides directly.");
        }
    }
}

// Create global chat controller instance
const chatController = new ChatController();
