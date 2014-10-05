
from threading import Thread
#from Queue import Queue
import time
import os
import sys
import subprocess
import tempfile

import logging

__version__ = "1.0.2"

if sys.platform == 'win32':
    STCMD='C:\Program Files\Borland\StarTeam Cross-Platform 2009\stcmd.exe'
    #STCMD='D:\Develop\Python\FMB_DEPLOY\catch_input.py'
    COMP_FMX='notepad.exe'
    eof='\r\n'
    logfile='{}\\file-deployer-{}.log'.format(os.getenv('TMP'),time.strftime('%H_%M_%d-%m-%y'))
else:
    #pretty vulnearble but I couldn't care less
    #STCMD=os.getenv('HOME')+'/StarTeamCP_2009/bin/stcmd'
    STCMD='stcmd'
    COMP_FMX='/ba/app01/oracle/product/OraHome_1/bin/comp_fmx'
    eof='\n'
    logfile='{}/file-deployer-{}.log'.format('/tmp',time.strftime('%H:%M_%d-%m-%y'))

# set up logging to file - see previous section for more details
logging.basicConfig(level=logging.DEBUG,
                    format='%(asctime)s %(name)-12s %(levelname)-8s %(message)s',
                    datefmt='%m-%d %H:%M',
                    filename=logfile,
                    filemode='w')

# define a Handler which writes INFO messages or higher to the sys.stderr
console = logging.StreamHandler()

# set a format which is simpler for console use
formatter = logging.Formatter('%(name)-12s: %(levelname)-8s %(message)s')
# tell the handler to use this format
console.setFormatter(formatter)
# add the handler to the root logger
logging.getLogger('').addHandler(console)

if '--verbose' in sys.argv:
    
    console.setLevel(logging.INFO)
elif '--debug' in sys.argv:
    console.setLevel(logging.DEBUG)
else:
    console.setLevel(logging.ERROR)

# Build paths inside the project like this: os.path.join(BASE_DIR, ...)

BASE_DIR = os.path.dirname(os.path.dirname(__file__))


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
CONFIG_FILE="deploy.cfg"
#development environment
SSH_CMD="C:\\cygwin\\bin\\ssh.exe";
SCP_CMD="C:\\cygwin\\bin\\scp.exe";
SSH_PARAMS=' -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i /home/vbronfman/.ssh/id_rsa'


STARTEAM_USER='ccmngr'
ST_PASSWD='QweQwe11'
STARTEAMSERVER='starteam1'
STARTEAMSERVERPORT='49201'
# In production environment
#SSH_CMD="c:\Program Files\\OpenSSH\\bin\\ssh.exe";
#SCP_CMD="C:\\cygwin\\bin\\scp.exe";
#SSH_PARAMS=' -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i "C:\\Program Files\\OpenSSH\\etc\\ssh_host_rsa_key" '
thread_poolsize=5


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

#LOGGING = {
#    'version': 1,
#    'disable_existing_loggers': False,
#    'formatters': {
#        'verbose': {
#            'format': '%(levelname)s %(asctime)s %(module)s %(process)d %(thread)d %(message)s'
#        },
#        'simple': {
#            'format': '%(levelname)s %(message)s'
#        },
#    },
#
#    'handlers': {
#        'file': {
#            'level': 'DEBUG',
#            'class': 'logging.FileHandler',
#            'formatter': 'verbose',
#            'filename': 'debug.log',
#        },
#        'console':{
#            'level': 'DEBUG',
#            'class': 'logging.StreamHandler',
#            'formatter': 'simple'
#        },
#
#            
#    },
#    'loggers': {
#        'django.request': {
#            'handlers': ['file'],
#            'level': 'DEBUG',
#            'propagate': True,
#        },
#        'settings': {
#            'handlers': ['console', 'file'],
#            'level': 'INFO',
#            
#        },
#        'utils': {
#            'handlers': ['console', 'file'],
#            'level': 'DEBUG',
#            
#        }
#
#    },
#}
