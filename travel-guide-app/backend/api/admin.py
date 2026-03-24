from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import (
    User, Category, Guide, Tour, TourImage, Review, Booking, ChatRecommendation
)


@admin.register(User)
class CustomUserAdmin(UserAdmin):
    list_display = ('username', 'email', 'first_name', 'last_name', 'is_staff')
    fieldsets = UserAdmin.fieldsets + (
        ('Additional Info', {'fields': ('phone', 'profile_picture', 'bio')}),
    )


@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ('name', 'description')
    search_fields = ('name',)


class TourImageInline(admin.TabularInline):
    model = TourImage
    extra = 1


@admin.register(Guide)
class GuideAdmin(admin.ModelAdmin):
    list_display = ('user', 'city', 'country', 'average_rating', 'total_reviews', 'is_verified', 'is_available')
    list_filter = ('is_verified', 'is_available', 'city', 'country')
    search_fields = ('user__username', 'user__first_name', 'user__last_name', 'city')
    readonly_fields = ('created_at', 'updated_at', 'average_rating', 'total_reviews')


@admin.register(Tour)
class TourAdmin(admin.ModelAdmin):
    list_display = ('title', 'city', 'tour_type', 'price_per_person', 'duration_hours', 'average_rating')
    list_filter = ('tour_type', 'difficulty_level', 'city')
    search_fields = ('title', 'description', 'city')
    filter_horizontal = ('categories', 'guides')
    inlines = [TourImageInline]
    readonly_fields = ('created_at', 'updated_at', 'average_rating')


@admin.register(Review)
class ReviewAdmin(admin.ModelAdmin):
    list_display = ('user', 'guide', 'tour', 'rating', 'created_at')
    list_filter = ('rating', 'created_at')
    search_fields = ('user__username', 'title', 'comment')
    readonly_fields = ('created_at', 'updated_at')


@admin.register(Booking)
class BookingAdmin(admin.ModelAdmin):
    list_display = ('user', 'guide', 'tour', 'booking_date', 'status', 'total_price')
    list_filter = ('status', 'booking_date')
    search_fields = ('user__username', 'guide__user__username')
    readonly_fields = ('created_at', 'updated_at')


@admin.register(ChatRecommendation)
class ChatRecommendationAdmin(admin.ModelAdmin):
    list_display = ('user', 'created_at')
    readonly_fields = ('created_at',)
    filter_horizontal = ('recommended_tours', 'recommended_guides')
