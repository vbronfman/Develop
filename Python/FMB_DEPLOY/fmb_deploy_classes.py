#fmb_deploy
# classes definitions
#

#from settings  import logger
import fmb_deploy_utils
from queue import Queue

undef=''

# Note the added (object) - this is the preferred way of creating new classes
class Product(object):
    
    def __init__(self,
    env=None,
    prod=undef, #prod - actually stands for 'process'
    ITsystem=undef, # ITsystem stands for "product". like vantive, ba and so on.
    account=undef,
    db=undef,
    cmd=undef,
    proc=undef, # pointer on instance of Proc::Reliable
    timeout=undef,
    status = undef,
    opers=None):
        if env is None:
            self.env = []
            
        if opers is None:
            self.opers = []
            
        self.prod=prod, #prod - actually stands for 'process'
        self.ITsystem=ITsystem, # ITsystem stands for "product". like vantive, ba and so on.
        self.account=account,
        self._db=db,
        self._cmd=cmd,
        self.proc=proc, # pointer on instance of Proc::Reliable
        self.timeout=timeout,
        self.status = status,
### end of class definition ###

#proj,view,label,proj_area
#Starteam checkout session 
class Session:
    #
    function =None
    session=[]
    checked_files={}
    
    def __init__(self,
    product=None, #type of files
    proj=None,
    view=None,
    label=None,
    proj_area=None, #destination folder
    database=None,
    function=None,
    extensions=None,
    cmd=None, #starteam command: checkout, list
    status = None,
    opers=None):
        self.product=product
        self.proj=proj
        self.view=view
        self.label=label
        self.proj_area=proj_area
        self.status=status
        self.opers=opers
        self.database=database
        self.function=function
        self.extensions=extensions
        
    @classmethod
    def fmb(cls):
        func_name=Session.fmb.__name__
        logger.info("I am the {} classmethod on {}".format(func_name, cls))
        
    @classmethod
    def txt(cls):
        func_name=Session.txt.__name__
        logger.info("I am the {} classmethod on {}".format(func_name, cls))
        logger.info("Do nothing")
        return False
        

