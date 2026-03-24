// API Configuration
const API_BASE_URL = 'http://localhost:8000/api';

// API Client
class APIClient {
    constructor(baseUrl) {
        this.baseUrl = baseUrl;
    }

    async fetch(endpoint, options = {}) {
        const url = `${this.baseUrl}${endpoint}`;
        try {
            const response = await fetch(url, {
                ...options,
                headers: {
                    'Content-Type': 'application/json',
                    ...options.headers,
                },
            });

            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }

            return await response.json();
        } catch (error) {
            console.error(`API Error (${endpoint}):`, error);
            throw error;
        }
    }

    // Categories
    async getCategories() {
        return this.fetch('/categories/');
    }

    // Tours
    async getTours(params = {}) {
        const queryString = new URLSearchParams(params).toString();
        return this.fetch(`/tours/${queryString ? '?' + queryString : ''}`);
    }

    async getTourById(id) {
        return this.fetch(`/tours/${id}/`);
    }

    async getToursByCategory(categoryId) {
        return this.fetch(`/tours/by_category/?category_id=${categoryId}`);
    }

    async getToursByLocation(city) {
        return this.fetch(`/tours/by_location/?city=${encodeURIComponent(city)}`);
    }

    async getNearbyTours(latitude, longitude, radius = 50) {
        return this.fetch(`/tours/nearby/?latitude=${latitude}&longitude=${longitude}&radius=${radius}`);
    }

    async searchTours(query) {
        return this.fetch(`/tours/?search=${encodeURIComponent(query)}`);
    }

    // Guides
    async getGuides(params = {}) {
        const queryString = new URLSearchParams(params).toString();
        return this.fetch(`/guides/${queryString ? '?' + queryString : ''}`);
    }

    async getGuideById(id) {
        return this.fetch(`/guides/${id}/`);
    }

    async getExpertGuides(city) {
        return this.fetch(`/guides/experts/?city=${encodeURIComponent(city)}`);
    }

    async getNearbyGuides(latitude, longitude, radius = 50) {
        return this.fetch(`/guides/nearby/?latitude=${latitude}&longitude=${longitude}&radius=${radius}`);
    }

    // Chat Recommendations
    async getChatRecommendations(preferences) {
        return this.fetch('/chat-recommendations/get_recommendations/', {
            method: 'POST',
            body: JSON.stringify({ preferences }),
        });
    }

    // Reviews
    async getReviews(params = {}) {
        const queryString = new URLSearchParams(params).toString();
        return this.fetch(`/reviews/${queryString ? '?' + queryString : ''}`);
    }

    // Bookings
    async createBooking(bookingData) {
        return this.fetch('/bookings/', {
            method: 'POST',
            body: JSON.stringify(bookingData),
        });
    }
}

// Create global API instance
const api = new APIClient(API_BASE_URL);
