// Location Service
class LocationService {
    constructor() {
        this.currentLocation = null;
        this.currentCity = 'Loading...';
    }

    async getCurrentPosition() {
        return new Promise((resolve, reject) => {
            if (!navigator.geolocation) {
                reject(new Error('Geolocation is not supported by your browser'));
                return;
            }

            navigator.geolocation.getCurrentPosition(
                position => {
                    this.currentLocation = {
                        latitude: position.coords.latitude,
                        longitude: position.coords.longitude,
                    };
                    resolve(this.currentLocation);
                },
                error => {
                    console.error('Error getting location:', error);
                    reject(error);
                },
                {
                    enableHighAccuracy: true,
                    timeout: 10000,
                    maximumAge: 300000, // 5 minutes
                }
            );
        });
    }

    async getCityFromCoords(latitude, longitude) {
        try {
            // Using OpenStreetMap Nominatim for reverse geocoding (free, no API key needed)
            const response = await fetch(
                `https://nominatim.openstreetmap.org/reverse?format=json&lat=${latitude}&lon=${longitude}&zoom=10`
            );
            const data = await response.json();

            if (data && data.address) {
                const city = data.address.city ||
                            data.address.town ||
                            data.address.village ||
                            data.address.county ||
                            'Unknown';
                const country = data.address.country || '';

                this.currentCity = city;
                return { city, country };
            }
        } catch (error) {
            console.error('Error getting city from coordinates:', error);
        }

        // Default fallback
        this.currentCity = 'Dubai';
        return { city: 'Dubai', country: 'UAE' };
    }

    async initLocation() {
        try {
            const position = await this.getCurrentPosition();
            const location = await this.getCityFromCoords(
                position.latitude,
                position.longitude
            );

            // Update UI
            this.updateLocationDisplay(location.city);

            return {
                ...position,
                ...location,
            };
        } catch (error) {
            console.error('Location initialization error:', error);

            // Set default location
            this.currentCity = 'Dubai';
            this.updateLocationDisplay('Dubai');

            return {
                latitude: 25.2048,
                longitude: 55.2708,
                city: 'Dubai',
                country: 'UAE',
            };
        }
    }

    updateLocationDisplay(city) {
        const locationDisplay = document.getElementById('currentCity');
        if (locationDisplay) {
            locationDisplay.textContent = city;
        }
    }

    getCurrentCity() {
        return this.currentCity;
    }
}

// Create global location service instance
const locationService = new LocationService();
