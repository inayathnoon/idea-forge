// Main Application
class TravelGuideApp {
    constructor() {
        this.init();
    }

    async init() {
        console.log('Travel Guide App initializing...');

        try {
            // Initialize location
            await this.initLocation();

            // Load home page content
            await this.loadHomePage();

            // Set up event listeners
            this.setupEventListeners();

            console.log('Travel Guide App initialized successfully!');
        } catch (error) {
            console.error('Error initializing app:', error);
        }
    }

    async initLocation() {
        try {
            const location = await locationService.initLocation();
            console.log('Location initialized:', location);
        } catch (error) {
            console.error('Error initializing location:', error);
        }
    }

    async loadHomePage() {
        try {
            // Load categories
            console.log('Loading categories...');
            const categoriesData = await api.getCategories();
            const categories = categoriesData.results || categoriesData;
            await uiManager.renderCategories(categories, 'categoriesGrid');

            // Load featured tours
            console.log('Loading featured tours...');
            await toursController.loadFeaturedTours();

            // Load expert guides
            console.log('Loading expert guides...');
            await guidesController.loadExpertGuides();

            // Initialize carousels with auto-scroll
            console.log('Initializing carousels...');
            uiManager.initCarousel('featuredTours', 4000);
            uiManager.initCarousel('expertGuides', 4000);

        } catch (error) {
            console.error('Error loading home page:', error);
        }
    }

    setupEventListeners() {
        // Get Location button
        const getLocationBtn = document.getElementById('getLocationBtn');
        if (getLocationBtn) {
            getLocationBtn.addEventListener('click', async () => {
                try {
                    getLocationBtn.disabled = true;
                    getLocationBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Getting location...';

                    const location = await locationService.initLocation();
                    console.log('Location updated:', location);

                    // Reload content with new location
                    await toursController.loadFeaturedTours();
                    await guidesController.loadExpertGuides();

                    getLocationBtn.innerHTML = '<i class="fas fa-check"></i> Location Updated!';
                    setTimeout(() => {
                        getLocationBtn.disabled = false;
                        getLocationBtn.innerHTML = '<i class="fas fa-crosshairs"></i> Use My Location';
                    }, 2000);

                } catch (error) {
                    console.error('Error getting location:', error);
                    getLocationBtn.innerHTML = '<i class="fas fa-times"></i> Error';
                    setTimeout(() => {
                        getLocationBtn.disabled = false;
                        getLocationBtn.innerHTML = '<i class="fas fa-crosshairs"></i> Use My Location';
                    }, 2000);
                }
            });
        }

        // Section navigation triggers content loading
        const navLinks = document.querySelectorAll('.nav-link');
        navLinks.forEach(link => {
            link.addEventListener('click', async () => {
                const section = link.getAttribute('data-section');

                if (section === 'tours') {
                    await toursController.loadTours();
                } else if (section === 'experts') {
                    await guidesController.loadGuides();
                }
            });
        });
    }
}

// Initialize app when DOM is ready
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => {
        new TravelGuideApp();
    });
} else {
    new TravelGuideApp();
}
