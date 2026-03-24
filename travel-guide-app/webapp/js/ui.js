// UI Utilities
class UIManager {
    constructor() {
        this.initNavigation();
        this.initModals();
    }

    initNavigation() {
        // Handle navigation link clicks
        const navLinks = document.querySelectorAll('[data-section]');
        navLinks.forEach(link => {
            link.addEventListener('click', (e) => {
                e.preventDefault();
                const sectionId = link.getAttribute('data-section');
                this.showSection(sectionId);

                // Update active nav link
                document.querySelectorAll('.nav-link').forEach(l => l.classList.remove('active'));
                if (link.classList.contains('nav-link')) {
                    link.classList.add('active');
                }
            });
        });
    }

    showSection(sectionId) {
        // Hide all sections
        document.querySelectorAll('.section').forEach(section => {
            section.classList.remove('active');
        });

        // Show target section
        const targetSection = document.getElementById(sectionId);
        if (targetSection) {
            targetSection.classList.add('active');
        }

        // Scroll to top
        window.scrollTo({ top: 0, behavior: 'smooth' });
    }

    initModals() {
        // Close modal when clicking close button or outside
        const modals = document.querySelectorAll('.modal');
        modals.forEach(modal => {
            const closeBtn = modal.querySelector('.modal-close');
            if (closeBtn) {
                closeBtn.addEventListener('click', () => this.closeModal(modal));
            }

            modal.addEventListener('click', (e) => {
                if (e.target === modal) {
                    this.closeModal(modal);
                }
            });
        });

        // Close on Escape key
        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape') {
                modals.forEach(modal => this.closeModal(modal));
            }
        });
    }

    openModal(modalId, content) {
        const modal = document.getElementById(modalId);
        if (modal) {
            const contentDiv = modal.querySelector(`#${modalId}Content`);
            if (contentDiv) {
                contentDiv.innerHTML = content;
            }
            modal.classList.add('active');
            document.body.style.overflow = 'hidden';
        }
    }

    closeModal(modal) {
        if (typeof modal === 'string') {
            modal = document.getElementById(modal);
        }
        if (modal) {
            modal.classList.remove('active');
            document.body.style.overflow = '';
        }
    }

    showLoading(containerId) {
        const container = document.getElementById(containerId);
        if (container) {
            container.innerHTML = '<div class="loading">Loading...</div>';
        }
    }

    showError(containerId, message) {
        const container = document.getElementById(containerId);
        if (container) {
            container.innerHTML = `<div class="error">${message}</div>`;
        }
    }

    getTourImage(tour) {
        // Realistic Unsplash photos based on tour type and ID
        const tourImages = {
            1: "https://images.unsplash.com/photo-1451337516015-6b6e9a44a8a3?w=800&q=80",  // Desert dunes
            2: "https://images.unsplash.com/photo-1583073757788-21d5ec36e40a?w=800&q=80",  // Desert sunrise
            3: "https://images.unsplash.com/photo-1582672060674-bc2bd808a8b5?w=800&q=80",  // Burj Khalifa
            4: "https://images.unsplash.com/photo-1512632578888-169bbbc64f33?w=800&q=80",  // Mosque
            5: "https://images.unsplash.com/photo-1605649487212-47bdab064df7?w=800&q=80",  // Marina
            6: "https://images.unsplash.com/photo-1518684079-3c830dcef090?w=800&q=80",  // Old Dubai souk
            7: "https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=800&q=80",  // Arabic food
            8: "https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=800&q=80",  // Dubai skyline
            9: "https://images.unsplash.com/photo-1473496169904-658ba7c44d8a?w=800&q=80",  // Luxury desert
            10: "https://images.unsplash.com/photo-1518684079-3c830dcef090?w=800&q=80", // Abu Dhabi
            11: "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&q=80", // Dune buggy
            12: "https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800&q=80", // Dubai Creek
            13: "https://images.unsplash.com/photo-1562095241-8c6714fd4178?w=800&q=80", // Dubai Mall
            14: "https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=800&q=80", // Hot air balloon
            15: "https://images.unsplash.com/photo-1556910103-1c02745aae4d?w=800&q=80", // Cooking class
        };

        return tour.cover_image || tourImages[tour.id] || 'https://images.unsplash.com/photo-1488646953014-85cb44e25828?w=800&q=80';
    }

    createTourCard(tour) {
        const imageUrl = this.getTourImage(tour);

        return `
            <div class="tour-card" data-tour-id="${tour.id}">
                <img src="${imageUrl}" alt="${tour.title}" class="tour-image" onerror="this.src='https://images.unsplash.com/photo-1488646953014-85cb44e25828?w=800&q=80'">
                <div class="tour-content">
                    <div class="tour-header">
                        <div>
                            <h3 class="tour-title">${tour.title}</h3>
                            <div class="tour-location">
                                <i class="fas fa-map-marker-alt"></i>
                                <span>${tour.city}, ${tour.country}</span>
                            </div>
                        </div>
                        <span class="tour-type">${this.formatTourType(tour.tour_type)}</span>
                    </div>
                    <p class="tour-description">${tour.description}</p>
                    <div class="tour-details">
                        <div class="tour-detail">
                            <i class="fas fa-clock"></i>
                            <span>${tour.duration_hours}h</span>
                        </div>
                        <div class="tour-detail">
                            <i class="fas fa-users"></i>
                            <span>Max ${tour.max_group_size}</span>
                        </div>
                        <div class="tour-detail">
                            <i class="fas fa-signal"></i>
                            <span>${this.capitalize(tour.difficulty_level)}</span>
                        </div>
                    </div>
                    <div class="tour-footer">
                        <div class="tour-price">
                            $${tour.price_per_person} <span>/ person</span>
                        </div>
                        ${tour.average_rating ? `
                            <div class="tour-rating">
                                <i class="fas fa-star"></i>
                                <span>${tour.average_rating.toFixed(1)}</span>
                            </div>
                        ` : ''}
                    </div>
                </div>
            </div>
        `;
    }

    createGuideCard(guide) {
        const initial = guide.user?.first_name?.[0] || guide.city?.[0] || 'G';
        const fullName = guide.user ? `${guide.user.first_name} ${guide.user.last_name}` : 'Local Guide';

        return `
            <div class="guide-card" data-guide-id="${guide.id}">
                <div class="guide-header">
                    <div class="guide-avatar">${initial}</div>
                    <div class="guide-info">
                        <h3>${fullName}</h3>
                        <div class="guide-location">
                            <i class="fas fa-map-marker-alt"></i>
                            ${guide.city}, ${guide.country}
                        </div>
                        ${guide.is_verified ? `
                            <div class="guide-verified">
                                <i class="fas fa-check-circle"></i>
                                Verified Guide
                            </div>
                        ` : ''}
                    </div>
                </div>
                <p class="guide-description">${guide.description}</p>
                <div class="guide-stats">
                    <div class="guide-stat">
                        <span class="guide-stat-value">${guide.experience_years}</span>
                        <span class="guide-stat-label">Years Exp</span>
                    </div>
                    <div class="guide-stat">
                        <span class="guide-stat-value">${guide.average_rating?.toFixed(1) || 'N/A'}</span>
                        <span class="guide-stat-label">Rating</span>
                    </div>
                    <div class="guide-stat">
                        <span class="guide-stat-value">${guide.total_reviews || 0}</span>
                        <span class="guide-stat-label">Reviews</span>
                    </div>
                </div>
                <div class="guide-languages">
                    <i class="fas fa-language"></i>
                    Languages: ${guide.languages}
                </div>
                <div class="guide-equipment">
                    ${guide.has_camera ? '<div class="equipment-icon" title="Camera"><i class="fas fa-camera"></i></div>' : ''}
                    ${guide.has_car ? '<div class="equipment-icon" title="Car"><i class="fas fa-car"></i></div>' : ''}
                    ${guide.has_bike ? '<div class="equipment-icon" title="Bike"><i class="fas fa-bicycle"></i></div>' : ''}
                    ${guide.has_drone ? '<div class="equipment-icon" title="Drone"><i class="fas fa-drone"></i></div>' : ''}
                </div>
                <div class="guide-rate">
                    <div>
                        <div class="rate-value">$${guide.hourly_rate}/hr</div>
                        ${guide.daily_rate ? `<div class="rate-label">$${guide.daily_rate}/day</div>` : ''}
                    </div>
                </div>
            </div>
        `;
    }

    createCategoryCard(category) {
        return `
            <div class="category-card" data-category-id="${category.id}">
                ${category.icon ? `<img src="${category.icon}" alt="${category.name}">` : '<i class="fas fa-map-marked-alt"></i>'}
                <h3>${category.name}</h3>
            </div>
        `;
    }

    formatTourType(type) {
        const types = {
            'food': 'Food Trip',
            'bike': 'Bike Trip',
            'hike': 'Hike & Photos',
            'cultural': 'Cultural',
            'adventure': 'Adventure',
            'historical': 'Historical',
            'nightlife': 'Nightlife',
            'custom': 'Custom'
        };
        return types[type] || type;
    }

    capitalize(str) {
        return str.charAt(0).toUpperCase() + str.slice(1);
    }

    async renderTours(tours, containerId) {
        const container = document.getElementById(containerId);
        if (!container) return;

        if (!tours || tours.length === 0) {
            container.innerHTML = '<div class="loading">No tours found</div>';
            return;
        }

        container.innerHTML = tours.map(tour => this.createTourCard(tour)).join('');

        // Only add click handlers for non-carousel containers (tours page)
        // For carousel (featuredTours), we want pure hover interaction only
        const isCarousel = containerId === 'featuredTours' || containerId === 'expertGuides';

        if (!isCarousel) {
            container.querySelectorAll('.tour-card').forEach(card => {
                card.addEventListener('click', () => {
                    const tourId = card.getAttribute('data-tour-id');
                    this.showTourDetail(tourId);
                });
            });
        }
    }

    async renderGuides(guides, containerId) {
        const container = document.getElementById(containerId);
        if (!container) return;

        if (!guides || guides.length === 0) {
            container.innerHTML = '<div class="loading">No guides found</div>';
            return;
        }

        container.innerHTML = guides.map(guide => this.createGuideCard(guide)).join('');

        // Add click handlers
        container.querySelectorAll('.guide-card').forEach(card => {
            card.addEventListener('click', () => {
                const guideId = card.getAttribute('data-guide-id');
                this.showGuideDetail(guideId);
            });
        });
    }

    async renderCategories(categories, containerId) {
        const container = document.getElementById(containerId);
        if (!container) return;

        if (!categories || categories.length === 0) {
            container.innerHTML = '<div class="loading">No categories found</div>';
            return;
        }

        container.innerHTML = categories.map(category => this.createCategoryCard(category)).join('');

        // Add click handlers
        container.querySelectorAll('.category-card').forEach(card => {
            card.addEventListener('click', async () => {
                const categoryId = card.getAttribute('data-category-id');
                await this.filterToursByCategory(categoryId);
            });
        });
    }

    initCarousel(containerId, interval = 4000) {
        const container = document.getElementById(containerId);
        if (!container) return;

        let scrollInterval;
        let isPaused = false;

        const startAutoScroll = () => {
            scrollInterval = setInterval(() => {
                if (isPaused) return;

                const cardWidth = 320 + 24; // card width + gap (updated for new design)
                const scrollAmount = cardWidth * 3; // Scroll 3 items at a time
                const maxScroll = container.scrollWidth - container.clientWidth;

                if (container.scrollLeft >= maxScroll - 10) {
                    // Loop back to start
                    container.scrollTo({ left: 0, behavior: 'smooth' });
                } else {
                    container.scrollBy({ left: scrollAmount, behavior: 'smooth' });
                }
            }, interval);
        };

        // Pause on hover
        container.addEventListener('mouseenter', () => {
            isPaused = true;
        });

        container.addEventListener('mouseleave', () => {
            isPaused = false;
        });

        // Start auto-scroll
        startAutoScroll();

        // Return cleanup function
        return () => clearInterval(scrollInterval);
    }

    async filterToursByCategory(categoryId) {
        try {
            const data = await api.getToursByCategory(categoryId);
            this.showSection('tours');
            await this.renderTours(data, 'toursGrid');
        } catch (error) {
            console.error('Error filtering tours:', error);
        }
    }

    async showTourDetail(tourId) {
        try {
            const tour = await api.getTourById(tourId);
            const imageUrl = tour.cover_image || 'https://via.placeholder.com/800x400?text=Tour+Image';

            const content = `
                <img src="${imageUrl}" alt="${tour.title}" style="width: 100%; height: 300px; object-fit: cover; border-radius: 8px; margin-bottom: 1.5rem;" onerror="this.src='https://via.placeholder.com/800x400?text=Tour+Image'">
                <h2>${tour.title}</h2>
                <div style="display: flex; gap: 1rem; margin: 1rem 0; flex-wrap: wrap;">
                    <span class="tour-type">${this.formatTourType(tour.tour_type)}</span>
                    <span style="color: var(--text-secondary);"><i class="fas fa-map-marker-alt"></i> ${tour.city}, ${tour.country}</span>
                </div>
                <p style="color: var(--text-secondary); margin-bottom: 1.5rem;">${tour.description}</p>

                <h3 style="margin-bottom: 1rem;">Tour Details</h3>
                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1rem; margin-bottom: 1.5rem;">
                    <div><strong>Duration:</strong> ${tour.duration_hours} hours</div>
                    <div><strong>Max Group Size:</strong> ${tour.max_group_size} people</div>
                    <div><strong>Min Age:</strong> ${tour.min_age}+</div>
                    <div><strong>Difficulty:</strong> ${this.capitalize(tour.difficulty_level)}</div>
                    <div><strong>Meeting Point:</strong> ${tour.meeting_point}</div>
                    <div><strong>Price:</strong> $${tour.price_per_person} per person</div>
                </div>

                ${tour.guides && tour.guides.length > 0 ? `
                    <h3 style="margin-bottom: 1rem;">Your Guides</h3>
                    <div style="margin-bottom: 1.5rem;">
                        ${tour.guides.map(guide => `
                            <div style="background: var(--bg-light); padding: 1rem; border-radius: 8px; margin-bottom: 0.5rem;">
                                <strong>${guide.user?.first_name || 'Guide'}</strong> - ${guide.languages}
                            </div>
                        `).join('')}
                    </div>
                ` : ''}

                <button class="btn btn-primary" style="width: 100%; padding: 1rem; font-size: 1.1rem;">
                    <i class="fas fa-calendar-check"></i> Book This Tour
                </button>
            `;

            this.openModal('tourModal', content);
        } catch (error) {
            console.error('Error loading tour details:', error);
        }
    }

    async showGuideDetail(guideId) {
        try {
            const guide = await api.getGuideById(guideId);
            const initial = guide.user?.first_name?.[0] || guide.city?.[0] || 'G';
            const fullName = guide.user ? `${guide.user.first_name} ${guide.user.last_name}` : 'Local Guide';

            const content = `
                <div style="text-align: center; margin-bottom: 2rem;">
                    <div style="width: 120px; height: 120px; border-radius: 50%; background: var(--primary-color); color: white; display: flex; align-items: center; justify-content: center; font-size: 3rem; font-weight: bold; margin: 0 auto 1rem;">${initial}</div>
                    <h2 style="margin-bottom: 0.5rem;">${fullName}</h2>
                    <div style="color: var(--text-secondary); margin-bottom: 0.5rem;">
                        <i class="fas fa-map-marker-alt"></i> ${guide.city}, ${guide.country}
                    </div>
                    ${guide.is_verified ? '<div style="color: var(--success-color); font-weight: 600;"><i class="fas fa-check-circle"></i> Verified Guide</div>' : ''}
                </div>

                <div style="display: flex; gap: 2rem; justify-content: center; margin-bottom: 2rem; padding: 1.5rem; background: var(--bg-light); border-radius: 8px;">
                    <div style="text-align: center;">
                        <div style="font-size: 2rem; font-weight: bold; color: var(--primary-color);">${guide.experience_years}</div>
                        <div style="font-size: 0.85rem; color: var(--text-secondary);">Years Experience</div>
                    </div>
                    <div style="text-align: center;">
                        <div style="font-size: 2rem; font-weight: bold; color: var(--primary-color);">${guide.average_rating?.toFixed(1) || 'N/A'}</div>
                        <div style="font-size: 0.85rem; color: var(--text-secondary);">Average Rating</div>
                    </div>
                    <div style="text-align: center;">
                        <div style="font-size: 2rem; font-weight: bold; color: var(--primary-color);">${guide.total_reviews || 0}</div>
                        <div style="font-size: 0.85rem; color: var(--text-secondary);">Reviews</div>
                    </div>
                </div>

                <h3 style="margin-bottom: 1rem;">About</h3>
                <p style="color: var(--text-secondary); margin-bottom: 1.5rem;">${guide.description}</p>

                <h3 style="margin-bottom: 1rem;">Languages</h3>
                <p style="color: var(--text-secondary); margin-bottom: 1.5rem;">${guide.languages}</p>

                <h3 style="margin-bottom: 1rem;">Equipment</h3>
                <div style="display: flex; gap: 1rem; margin-bottom: 1.5rem; flex-wrap: wrap;">
                    ${guide.has_camera ? '<span style="padding: 0.5rem 1rem; background: var(--bg-light); border-radius: 20px;"><i class="fas fa-camera"></i> Professional Camera</span>' : ''}
                    ${guide.has_car ? '<span style="padding: 0.5rem 1rem; background: var(--bg-light); border-radius: 20px;"><i class="fas fa-car"></i> Car</span>' : ''}
                    ${guide.has_bike ? '<span style="padding: 0.5rem 1rem; background: var(--bg-light); border-radius: 20px;"><i class="fas fa-bicycle"></i> Bike</span>' : ''}
                    ${guide.has_drone ? '<span style="padding: 0.5rem 1rem; background: var(--bg-light); border-radius: 20px;"><i class="fas fa-drone"></i> Drone</span>' : ''}
                </div>

                <h3 style="margin-bottom: 1rem;">Rates</h3>
                <div style="background: var(--bg-light); padding: 1.5rem; border-radius: 8px; margin-bottom: 1.5rem;">
                    <div style="font-size: 1.5rem; font-weight: bold; color: var(--primary-color); margin-bottom: 0.5rem;">$${guide.hourly_rate}/hour</div>
                    ${guide.daily_rate ? `<div style="color: var(--text-secondary);">$${guide.daily_rate}/day</div>` : ''}
                </div>

                <button class="btn btn-primary" style="width: 100%; padding: 1rem; font-size: 1.1rem;">
                    <i class="fas fa-envelope"></i> Contact Guide
                </button>
            `;

            this.openModal('guideModal', content);
        } catch (error) {
            console.error('Error loading guide details:', error);
        }
    }
}

// Create global UI manager instance
const uiManager = new UIManager();
