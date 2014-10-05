##############################################
# fmb_demployer - FMB Deployment tool  
# Developed by V.Bronfman at 10/06/14
#
# Version is 1.0
# 
# Dependencies: Python 3.3, Borland StarTeam client
# Use configuration file
# Perform check-out of SC (StarTeam so far) to destination folder and
# compile fmb files in front of DB
# Future development:
# - multiple version labeles
# - exchange mandatory command line args with values in config file
#############################################

'''
FmbDeployer main module
'''

import settings 
from fmb_deploy_utils import *
from fmb_deploy_classes import *

logger = logging.getLogger(__name__)

logger.info('Program started')

args=get_opts()
if not args:
    logger.error('Failed work up input arguments')
    exit (1)
    
[proj_area,db,func,extensions]=get_cfg(args['config_file'],args)
#get arguments
if not proj_area :
    logger.error('Failed work up input arguments')
    exit (1)
    
#creates object of Session class
session=Session(args['prod'],args['proj'],args['view'],args['label'], proj_area,db,func,extensions)
ret=checkout(session)

if not ret:
    exit (1)

logger.debug(" {}".format( session.checked_files.keys()))

if not post_deploy_procedure(session):
    exit (1)
    
print_report(session)




