// Guides Page Controller
class GuidesController {
    constructor() {
        this.currentFilters = { is_verified: true };
        this.init();
    }

    init() {
        // Search input
        const searchInput = document.getElementById('guideSearch');
        if (searchInput) {
            let searchTimeout;
            searchInput.addEventListener('input', (e) => {
                clearTimeout(searchTimeout);
                searchTimeout = setTimeout(() => {
                    this.currentFilters.search = e.target.value;
                    this.loadGuides();
                }, 500);
            });
        }

        // Verified filter
        const verifiedFilter = document.getElementById('verifiedFilter');
        if (verifiedFilter) {
            verifiedFilter.addEventListener('change', (e) => {
                if (e.target.checked) {
                    this.currentFilters.is_verified = true;
                } else {
                    delete this.currentFilters.is_verified;
                }
                this.loadGuides();
            });
        }

        // Equipment filters
        const cameraFilter = document.getElementById('cameraFilter');
        if (cameraFilter) {
            cameraFilter.addEventListener('change', (e) => {
                if (e.target.checked) {
                    this.currentFilters.has_camera = true;
                } else {
                    delete this.currentFilters.has_camera;
                }
                this.loadGuides();
            });
        }

        const carFilter = document.getElementById('carFilter');
        if (carFilter) {
            carFilter.addEventListener('change', (e) => {
                if (e.target.checked) {
                    this.currentFilters.has_car = true;
                } else {
                    delete this.currentFilters.has_car;
                }
                this.loadGuides();
            });
        }

        const bikeFilter = document.getElementById('bikeFilter');
        if (bikeFilter) {
            bikeFilter.addEventListener('change', (e) => {
                if (e.target.checked) {
                    this.currentFilters.has_bike = true;
                } else {
                    delete this.currentFilters.has_bike;
                }
                this.loadGuides();
            });
        }
    }

    async loadGuides() {
        try {
            uiManager.showLoading('guidesGrid');
            const data = await api.getGuides(this.currentFilters);
            const guides = data.results || data;
            await uiManager.renderGuides(guides, 'guidesGrid');
        } catch (error) {
            console.error('Error loading guides:', error);
            uiManager.showError('guidesGrid', 'Failed to load guides. Please try again.');
        }
    }

    async loadExpertGuides() {
        try {
            // Load first 6 verified guides for expert section
            const data = await api.getGuides({ is_verified: true, page_size: 6 });
            const guides = data.results || data;
            await uiManager.renderGuides(guides, 'expertGuides');
        } catch (error) {
            console.error('Error loading expert guides:', error);
            uiManager.showError('expertGuides', 'Failed to load expert guides.');
        }
    }
}

// Create global guides controller instance
const guidesController = new GuidesController();
