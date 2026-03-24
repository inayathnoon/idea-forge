from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    CategoryViewSet, GuideViewSet, TourViewSet,
    ReviewViewSet, BookingViewSet, ChatRecommendationViewSet
)

router = DefaultRouter()
router.register(r'categories', CategoryViewSet, basename='category')
router.register(r'guides', GuideViewSet, basename='guide')
router.register(r'tours', TourViewSet, basename='tour')
router.register(r'reviews', ReviewViewSet, basename='review')
router.register(r'bookings', BookingViewSet, basename='booking')
router.register(r'chat-recommendations', ChatRecommendationViewSet, basename='chat-recommendation')

urlpatterns = [
    path('', include(router.urls)),
]
