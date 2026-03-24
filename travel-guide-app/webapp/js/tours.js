// Tours Page Controller
class ToursController {
    constructor() {
        this.currentFilters = {};
        this.init();
    }

    init() {
        // Search input
        const searchInput = document.getElementById('tourSearch');
        if (searchInput) {
            let searchTimeout;
            searchInput.addEventListener('input', (e) => {
                clearTimeout(searchTimeout);
                searchTimeout = setTimeout(() => {
                    this.currentFilters.search = e.target.value;
                    this.loadTours();
                }, 500);
            });
        }

        // Tour type filter
        const tourTypeFilter = document.getElementById('tourTypeFilter');
        if (tourTypeFilter) {
            tourTypeFilter.addEventListener('change', (e) => {
                if (e.target.value) {
                    this.currentFilters.tour_type = e.target.value;
                } else {
                    delete this.currentFilters.tour_type;
                }
                this.loadTours();
            });
        }

        // Difficulty filter
        const difficultyFilter = document.getElementById('difficultyFilter');
        if (difficultyFilter) {
            difficultyFilter.addEventListener('change', (e) => {
                if (e.target.value) {
                    this.currentFilters.difficulty_level = e.target.value;
                } else {
                    delete this.currentFilters.difficulty_level;
                }
                this.loadTours();
            });
        }

        // Sort filter
        const sortFilter = document.getElementById('sortFilter');
        if (sortFilter) {
            sortFilter.addEventListener('change', (e) => {
                if (e.target.value) {
                    this.currentFilters.ordering = e.target.value;
                } else {
                    delete this.currentFilters.ordering;
                }
                this.loadTours();
            });
        }
    }

    async loadTours() {
        try {
            uiManager.showLoading('toursGrid');
            const data = await api.getTours(this.currentFilters);
            const tours = data.results || data;
            await uiManager.renderTours(tours, 'toursGrid');
        } catch (error) {
            console.error('Error loading tours:', error);
            uiManager.showError('toursGrid', 'Failed to load tours. Please try again.');
        }
    }

    async loadFeaturedTours() {
        try {
            // Load first 6 tours for featured section
            const data = await api.getTours({ page_size: 6 });
            const tours = data.results || data;
            await uiManager.renderTours(tours, 'featuredTours');
        } catch (error) {
            console.error('Error loading featured tours:', error);
            uiManager.showError('featuredTours', 'Failed to load tours.');
        }
    }
}

// Create global tours controller instance
const toursController = new ToursController();
