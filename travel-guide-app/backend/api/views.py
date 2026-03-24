from rest_framework import viewsets, filters, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
from django.db.models import Q, Count
from geopy.distance import geodesic

from .models import (
    Category, Guide, Tour, Review, Booking, ChatRecommendation
)
from .serializers import (
    CategorySerializer, GuideSerializer, GuideListSerializer,
    TourSerializer, TourListSerializer, ReviewSerializer,
    BookingSerializer, ChatRecommendationSerializer
)


class CategoryViewSet(viewsets.ReadOnlyModelViewSet):
    """
    API endpoint for tour categories
    """
    queryset = Category.objects.all()
    serializer_class = CategorySerializer
    filter_backends = [filters.SearchFilter]
    search_fields = ['name', 'description']


class GuideViewSet(viewsets.ReadOnlyModelViewSet):
    """
    API endpoint for guides
    Supports filtering by location, equipment, and search
    """
    queryset = Guide.objects.filter(is_available=True).select_related('user')
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['city', 'country', 'is_verified', 'has_camera', 'has_car', 'has_bike']
    search_fields = ['user__first_name', 'user__last_name', 'description', 'city', 'languages']
    ordering_fields = ['hourly_rate', 'experience_years']

    def get_serializer_class(self):
        if self.action == 'list':
            return GuideListSerializer
        return GuideSerializer

    @action(detail=False, methods=['get'])
    def nearby(self, request):
        """Get guides near a specific location"""
        lat = request.query_params.get('latitude')
        lon = request.query_params.get('longitude')
        radius = float(request.query_params.get('radius', 50))  # km

        if not lat or not lon:
            return Response(
                {'error': 'latitude and longitude parameters are required'},
                status=status.HTTP_400_BAD_REQUEST
            )

        user_location = (float(lat), float(lon))
        guides = Guide.objects.filter(is_available=True)

        # Filter guides within radius
        nearby_guides = []
        for guide in guides:
            guide_location = (guide.latitude, guide.longitude)
            distance = geodesic(user_location, guide_location).km
            if distance <= radius:
                nearby_guides.append(guide)

        serializer = self.get_serializer(nearby_guides, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=['get'])
    def experts(self, request):
        """Get top-rated expert guides in a location"""
        city = request.query_params.get('city')

        if not city:
            return Response(
                {'error': 'city parameter is required'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Get guides with highest ratings
        guides = Guide.objects.filter(
            city__iexact=city,
            is_available=True,
            is_verified=True
        ).select_related('user')

        # Sort by average rating (calculated property)
        guides_with_ratings = [(g, g.average_rating) for g in guides]
        guides_with_ratings.sort(key=lambda x: x[1], reverse=True)
        sorted_guides = [g[0] for g[0] in guides_with_ratings[:20]]

        serializer = self.get_serializer(sorted_guides, many=True)
        return Response(serializer.data)


class TourViewSet(viewsets.ReadOnlyModelViewSet):
    """
    API endpoint for tours
    Supports filtering by type, location, price, and search
    """
    queryset = Tour.objects.all().prefetch_related('categories', 'guides', 'images')
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['tour_type', 'city', 'country', 'difficulty_level']
    search_fields = ['title', 'description', 'city']
    ordering_fields = ['price_per_person', 'duration_hours', 'created_at']

    def get_serializer_class(self):
        if self.action == 'list':
            return TourListSerializer
        return TourSerializer

    @action(detail=False, methods=['get'])
    def by_category(self, request):
        """Get tours filtered by category"""
        category_id = request.query_params.get('category_id')

        if not category_id:
            return Response(
                {'error': 'category_id parameter is required'},
                status=status.HTTP_400_BAD_REQUEST
            )

        tours = Tour.objects.filter(categories__id=category_id)
        serializer = TourListSerializer(tours, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=['get'])
    def by_location(self, request):
        """Get all tours in a specific location"""
        city = request.query_params.get('city')

        if not city:
            return Response(
                {'error': 'city parameter is required'},
                status=status.HTTP_400_BAD_REQUEST
            )

        tours = Tour.objects.filter(city__iexact=city).prefetch_related('categories', 'guides')
        serializer = TourListSerializer(tours, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=['get'])
    def nearby(self, request):
        """Get tours near a specific location"""
        lat = request.query_params.get('latitude')
        lon = request.query_params.get('longitude')
        radius = float(request.query_params.get('radius', 50))  # km

        if not lat or not lon:
            return Response(
                {'error': 'latitude and longitude parameters are required'},
                status=status.HTTP_400_BAD_REQUEST
            )

        user_location = (float(lat), float(lon))
        tours = Tour.objects.all()

        # Filter tours within radius
        nearby_tours = []
        for tour in tours:
            tour_location = (tour.latitude, tour.longitude)
            distance = geodesic(user_location, tour_location).km
            if distance <= radius:
                nearby_tours.append(tour)

        serializer = TourListSerializer(nearby_tours, many=True)
        return Response(serializer.data)


class ReviewViewSet(viewsets.ModelViewSet):
    """
    API endpoint for reviews
    """
    queryset = Review.objects.all().select_related('user', 'guide', 'tour')
    serializer_class = ReviewSerializer
    filter_backends = [DjangoFilterBackend, filters.OrderingFilter]
    filterset_fields = ['guide', 'tour', 'rating']
    ordering_fields = ['created_at', 'rating']


class BookingViewSet(viewsets.ModelViewSet):
    """
    API endpoint for bookings
    """
    queryset = Booking.objects.all().select_related('user', 'guide', 'tour')
    serializer_class = BookingSerializer
    filter_backends = [DjangoFilterBackend, filters.OrderingFilter]
    filterset_fields = ['status', 'guide', 'tour']
    ordering_fields = ['booking_date', 'created_at']


class ChatRecommendationViewSet(viewsets.ModelViewSet):
    """
    API endpoint for AI chatbot recommendations
    """
    queryset = ChatRecommendation.objects.all().prefetch_related(
        'recommended_tours', 'recommended_guides'
    )
    serializer_class = ChatRecommendationSerializer

    @action(detail=False, methods=['post'])
    def get_recommendations(self, request):
        """
        Get personalized tour recommendations based on user preferences
        This is a placeholder - integrate with actual AI service
        """
        preferences = request.data.get('preferences', {})
        city = preferences.get('city')
        interests = preferences.get('interests', [])

        # Basic recommendation logic (replace with AI model)
        tours = Tour.objects.filter(city__iexact=city)

        if interests:
            # Filter by tour type based on interests
            tour_type_map = {
                'food': 'food',
                'bike': 'bike',
                'hiking': 'hike',
                'culture': 'cultural',
                'adventure': 'adventure'
            }
            tour_types = [tour_type_map.get(i, i) for i in interests]
            tours = tours.filter(tour_type__in=tour_types)

        # Get top guides in the city
        guides = Guide.objects.filter(
            city__iexact=city,
            is_available=True,
            is_verified=True
        )[:5]

        return Response({
            'tours': TourListSerializer(tours[:10], many=True).data,
            'guides': GuideListSerializer(guides, many=True).data,
            'message': 'Based on your preferences, here are some recommendations!'
        })
