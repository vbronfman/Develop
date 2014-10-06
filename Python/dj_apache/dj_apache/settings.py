"""
Django settings for dj_apache project.

For more information on this file, see
https://docs.djangoproject.com/en/1.6/topics/settings/

For the full list of settings and their values, see
https://docs.djangoproject.com/en/1.6/ref/settings/
"""

# Build paths inside the project like this: os.path.join(BASE_DIR, ...)
import os,sys
BASE_DIR = os.path.dirname(os.path.dirname(__file__))
sys.path.append(BASE_DIR)
sys.path.append(BASE_DIR+'\dj_apache\env_mngr')

#print (sys.path)

# Quick-start development settings - unsuitable for production
# See https://docs.djangoproject.com/en/1.6/howto/deployment/checklist/

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = '--8@)shcl+vv&hfofqz1^kd0!@zpgth%#ad5c!9@29&voyj42r'

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = True

TEMPLATE_DEBUG = True

ALLOWED_HOSTS = []


# Application definition

INSTALLED_APPS = (
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
)

MIDDLEWARE_CLASSES = (
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
    
)

ROOT_URLCONF = 'dj_apache.urls'

WSGI_APPLICATION = 'dj_apache.wsgi.application'

# application definitions: should be updated upon deployment
#CFG_FILE="D:\\Develop\\Python\\dj_apache\\dj_apache\\env_mngr\\monitor_conf.xml"
ENGINE_HOST='test_user@it4tst3'
ENGINE="/ITLAB_share/itlab/Monitor/cmd_engine.pl"
ENGINE_LOG='-nolog'
CONFIG_FILE="/ITLAB_share/itlab/Monitor/monitor_conf.xml"
#development environment
SSH_CMD="C:\\cygwin\\bin\\ssh.exe";
SCP_CMD="C:\\cygwin\\bin\\scp.exe";
SSH_PARAMS=' -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i /home/vbronfman/.ssh/id_rsa'
# In production environment
#SSH_CMD="c:\Program Files\\OpenSSH\\bin\\ssh.exe";
#SCP_CMD="C:\\cygwin\\bin\\scp.exe";
#SSH_PARAMS=' -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i "C:\\Program Files\\OpenSSH\\etc\\ssh_host_rsa_key" '


# Database
# https://docs.djangoproject.com/en/1.6/ref/settings/#databases

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': os.path.join(BASE_DIR, 'db.sqlite3'),
    }
}

# Internationalization
# https://docs.djangoproject.com/en/1.6/topics/i18n/

LANGUAGE_CODE = 'en-us'

TIME_ZONE = 'UTC'

USE_I18N = True

USE_L10N = True

USE_TZ = True


# Static files (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/1.6/howto/static-files/

STATIC_URL = '/static/'

LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'verbose': {
            'format': '%(levelname)s %(asctime)s %(module)s %(process)d %(thread)d %(message)s'
        },
        'simple': {
            'format': '%(levelname)s %(message)s'
        },
    },

    'handlers': {
        'file': {
            'level': 'DEBUG',
            'class': 'logging.FileHandler',
            'formatter': 'verbose',
            'filename': 'debug.log',
        },
        'console':{
            'level': 'DEBUG',
            'class': 'logging.StreamHandler',
            'formatter': 'simple'
        },

            
    },
    'loggers': {
        'django.request': {
            'handlers': ['file'],
            'level': 'DEBUG',
            'propagate': True,
        },
        'myproject.custom': {
            'handlers': ['console', 'file'],
            'level': 'INFO',
            
        }

    },
}

