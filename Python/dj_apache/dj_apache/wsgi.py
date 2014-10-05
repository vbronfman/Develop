"""
WSGI config for dj_apache project.

It exposes the WSGI callable as a module-level variable named ``application``.

For more information on this file, see
https://docs.djangoproject.com/en/1.6/howto/deployment/wsgi/
"""

import os
#added by me
import sys
sys.path.append("C:/Program Files/Apache Software Foundation/Apache2.2/www/wsgi-scripts/dj_apache/dj_apache/")

#end of added by me

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "dj_apache.settings")

#from django.core.wsgi import get_wsgi_application
import django.core.handlers.wsgi

#application = get_wsgi_application()
application=django.core.handlers.wsgi.WSGIHandler()

