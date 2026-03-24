"""
WSGI config for travel_guide project.
"""

import os

from django.core.wsgi import get_wsgi_application

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'travel_guide.settings')

application = get_wsgi_application()
