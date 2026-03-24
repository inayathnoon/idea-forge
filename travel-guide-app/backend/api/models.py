from django.db import models
from django.contrib.auth.models import AbstractUser
from django.core.validators import MinValueValidator, MaxValueValidator


class User(AbstractUser):
    """Custom user model"""
    phone = models.CharField(max_length=20, blank=True)
    profile_picture = models.ImageField(upload_to='profiles/', null=True, blank=True)
    bio = models.TextField(blank=True)

    def __str__(self):
        return self.username


class Category(models.Model):
    """Tour categories (food tasting, bike trip, cultural, adventure, etc.)"""
    name = models.CharField(max_length=100)
    icon = models.ImageField(upload_to='category_icons/', null=True, blank=True)
    description = models.TextField(blank=True)

    class Meta:
        verbose_name_plural = 'Categories'

    def __str__(self):
        return self.name


class Guide(models.Model):
    """Local guide profiles"""
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='guide_profile')
    city = models.CharField(max_length=100)
    country = models.CharField(max_length=100)
    latitude = models.FloatField()
    longitude = models.FloatField()

    # Guide details
    description = models.TextField()
    languages = models.CharField(max_length=200, help_text="Comma-separated list of languages")
    experience_years = models.IntegerField(default=0)

    # Equipment and amenities
    has_camera = models.BooleanField(default=False)
    has_car = models.BooleanField(default=False)
    has_bike = models.BooleanField(default=False)
    has_drone = models.BooleanField(default=False)

    # Pricing
    hourly_rate = models.DecimalField(max_digits=10, decimal_places=2)
    daily_rate = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)

    # Status
    is_verified = models.BooleanField(default=False)
    is_available = models.BooleanField(default=True)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.user.get_full_name()} - {self.city}"

    @property
    def average_rating(self):
        """Calculate average rating from reviews"""
        reviews = self.reviews.all()
        if reviews:
            return sum(r.rating for r in reviews) / len(reviews)
        return 0

    @property
    def total_reviews(self):
        """Get total number of reviews"""
        return self.reviews.count()


class Tour(models.Model):
    """Tours offered by guides"""
    TOUR_TYPE_CHOICES = [
        ('food', 'Food Trip'),
        ('bike', 'Bike Trip'),
        ('hike', 'Hike and Photos'),
        ('cultural', 'Cultural'),
        ('adventure', 'Adventure'),
        ('historical', 'Historical'),
        ('nightlife', 'Nightlife'),
        ('custom', 'Custom'),
    ]

    title = models.CharField(max_length=200)
    description = models.TextField()
    tour_type = models.CharField(max_length=20, choices=TOUR_TYPE_CHOICES)
    categories = models.ManyToManyField(Category, related_name='tours')

    # Location
    city = models.CharField(max_length=100)
    country = models.CharField(max_length=100)
    meeting_point = models.CharField(max_length=300)
    latitude = models.FloatField()
    longitude = models.FloatField()

    # Tour details
    duration_hours = models.DecimalField(max_digits=4, decimal_places=1)
    max_group_size = models.IntegerField()
    min_age = models.IntegerField(default=0)
    difficulty_level = models.CharField(
        max_length=20,
        choices=[('easy', 'Easy'), ('moderate', 'Moderate'), ('hard', 'Hard')]
    )

    # Pricing
    price_per_person = models.DecimalField(max_digits=10, decimal_places=2)

    # Images
    cover_image = models.ImageField(upload_to='tour_images/')

    # Guides offering this tour
    guides = models.ManyToManyField(Guide, related_name='tours')

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.title} - {self.city}"

    @property
    def average_rating(self):
        """Calculate average rating from reviews"""
        reviews = self.reviews.all()
        if reviews:
            return sum(r.rating for r in reviews) / len(reviews)
        return 0


class TourImage(models.Model):
    """Additional images for tours"""
    tour = models.ForeignKey(Tour, on_delete=models.CASCADE, related_name='images')
    image = models.ImageField(upload_to='tour_images/')
    caption = models.CharField(max_length=200, blank=True)

    def __str__(self):
        return f"Image for {self.tour.title}"


class Review(models.Model):
    """Reviews for guides and tours"""
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='reviews')
    guide = models.ForeignKey(Guide, on_delete=models.CASCADE, related_name='reviews', null=True, blank=True)
    tour = models.ForeignKey(Tour, on_delete=models.CASCADE, related_name='reviews', null=True, blank=True)

    rating = models.IntegerField(validators=[MinValueValidator(1), MaxValueValidator(5)])
    title = models.CharField(max_length=200)
    comment = models.TextField()

    # Review aspects
    communication_rating = models.IntegerField(validators=[MinValueValidator(1), MaxValueValidator(5)], null=True)
    knowledge_rating = models.IntegerField(validators=[MinValueValidator(1), MaxValueValidator(5)], null=True)
    value_rating = models.IntegerField(validators=[MinValueValidator(1), MaxValueValidator(5)], null=True)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        target = self.guide if self.guide else self.tour
        return f"Review by {self.user.username} for {target}"


class Booking(models.Model):
    """Booking requests from users"""
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('confirmed', 'Confirmed'),
        ('cancelled', 'Cancelled'),
        ('completed', 'Completed'),
    ]

    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='bookings')
    tour = models.ForeignKey(Tour, on_delete=models.CASCADE, related_name='bookings', null=True, blank=True)
    guide = models.ForeignKey(Guide, on_delete=models.CASCADE, related_name='bookings')

    booking_date = models.DateTimeField()
    number_of_people = models.IntegerField()
    total_price = models.DecimalField(max_digits=10, decimal_places=2)

    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    special_requests = models.TextField(blank=True)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"Booking by {self.user.username} with {self.guide}"


class ChatRecommendation(models.Model):
    """Store AI chatbot recommendations for users"""
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='chat_recommendations')

    # User preferences from chat
    preferences = models.JSONField()  # Store user preferences as JSON

    # Recommended tours and guides
    recommended_tours = models.ManyToManyField(Tour, related_name='chat_recommendations')
    recommended_guides = models.ManyToManyField(Guide, related_name='chat_recommendations')

    # Chat conversation
    conversation_history = models.JSONField()  # Store chat messages

    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Recommendations for {self.user.username} at {self.created_at}"
