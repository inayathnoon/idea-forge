from rest_framework import serializers
from .models import (
    User, Category, Guide, Tour, TourImage, Review, Booking, ChatRecommendation
)


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('id', 'username', 'email', 'first_name', 'last_name',
                  'phone', 'profile_picture', 'bio')
        read_only_fields = ('id',)


class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = ('id', 'name', 'icon', 'description')


class ReviewSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)

    class Meta:
        model = Review
        fields = ('id', 'user', 'guide', 'tour', 'rating', 'title', 'comment',
                  'communication_rating', 'knowledge_rating', 'value_rating',
                  'created_at', 'updated_at')
        read_only_fields = ('id', 'created_at', 'updated_at')


class TourImageSerializer(serializers.ModelSerializer):
    class Meta:
        model = TourImage
        fields = ('id', 'image', 'caption')


class GuideSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    average_rating = serializers.FloatField(read_only=True)
    total_reviews = serializers.IntegerField(read_only=True)
    reviews = ReviewSerializer(many=True, read_only=True)

    class Meta:
        model = Guide
        fields = ('id', 'user', 'city', 'country', 'latitude', 'longitude',
                  'description', 'languages', 'experience_years',
                  'has_camera', 'has_car', 'has_bike', 'has_drone',
                  'hourly_rate', 'daily_rate', 'is_verified', 'is_available',
                  'average_rating', 'total_reviews', 'reviews',
                  'created_at', 'updated_at')
        read_only_fields = ('id', 'average_rating', 'total_reviews',
                            'created_at', 'updated_at')


class GuideListSerializer(serializers.ModelSerializer):
    """Lighter serializer for list views"""
    user = UserSerializer(read_only=True)
    average_rating = serializers.FloatField(read_only=True)
    total_reviews = serializers.IntegerField(read_only=True)

    class Meta:
        model = Guide
        fields = ('id', 'user', 'city', 'country', 'description', 'languages',
                  'experience_years', 'has_camera', 'has_car', 'has_bike', 'has_drone',
                  'hourly_rate', 'daily_rate', 'is_verified', 'average_rating', 'total_reviews')


class TourSerializer(serializers.ModelSerializer):
    categories = CategorySerializer(many=True, read_only=True)
    guides = GuideListSerializer(many=True, read_only=True)
    images = TourImageSerializer(many=True, read_only=True)
    average_rating = serializers.FloatField(read_only=True)
    reviews = ReviewSerializer(many=True, read_only=True)

    class Meta:
        model = Tour
        fields = ('id', 'title', 'description', 'tour_type', 'categories',
                  'city', 'country', 'meeting_point', 'latitude', 'longitude',
                  'duration_hours', 'max_group_size', 'min_age', 'difficulty_level',
                  'price_per_person', 'cover_image', 'images', 'guides',
                  'average_rating', 'reviews', 'created_at', 'updated_at')
        read_only_fields = ('id', 'average_rating', 'created_at', 'updated_at')


class TourListSerializer(serializers.ModelSerializer):
    """Lighter serializer for list views"""
    categories = CategorySerializer(many=True, read_only=True)
    guide_count = serializers.SerializerMethodField()
    average_rating = serializers.FloatField(read_only=True)

    class Meta:
        model = Tour
        fields = ('id', 'title', 'description', 'tour_type', 'city', 'country',
                  'duration_hours', 'max_group_size', 'difficulty_level',
                  'price_per_person', 'cover_image',
                  'categories', 'guide_count', 'average_rating')

    def get_guide_count(self, obj):
        return obj.guides.count()


class BookingSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    tour = TourListSerializer(read_only=True)
    guide = GuideListSerializer(read_only=True)

    class Meta:
        model = Booking
        fields = ('id', 'user', 'tour', 'guide', 'booking_date',
                  'number_of_people', 'total_price', 'status',
                  'special_requests', 'created_at', 'updated_at')
        read_only_fields = ('id', 'created_at', 'updated_at')


class ChatRecommendationSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    recommended_tours = TourListSerializer(many=True, read_only=True)
    recommended_guides = GuideListSerializer(many=True, read_only=True)

    class Meta:
        model = ChatRecommendation
        fields = ('id', 'user', 'preferences', 'recommended_tours',
                  'recommended_guides', 'conversation_history', 'created_at')
        read_only_fields = ('id', 'created_at')
