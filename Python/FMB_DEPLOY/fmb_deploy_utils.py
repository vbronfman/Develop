'''
Utils
'''
from xml.etree import ElementTree as ET
import settings
import logging
import argparse
import os
import subprocess
import tempfile
import re
import threading
from queue import Queue
import sys
import time

#from settings import logger

logger = logging.getLogger(__name__)

def get_cfg(cfg_file, args=None):
    '''
    Fetch definitions from XML
    '''
    res=0
    func_name=get_cfg.__name__
        
    try:
        fh=ET.parse(cfg_file)
        #fh=ET.parse(ET.fromstring(xmlstring)) 

        path=None
        database=None
        function=None
        
        xpath=".//product[@name=\'{}\']".format(args['prod'])
        node=fh.find(xpath)
        
        if node is not None and ('status' in node.attrib and node.attrib['status'] !='disabled'):
            database=node.find('./deployment/db').text
            path=node.find('./deployment/path').text
            function=node.find('./deployment/type').text
            extensions=node.find('./deployment/extensions').text
        
    except Exception as error:
        logger.error (func_name+" An exception was thrown!")
        logger.error (str(error))
        exit()
    else:
        logger.info('XML is valid')
    return [path,database,function,extensions]
    
         
def get_opts():
    '''
    Preparate program arguments
    '''
    
    func_name=get_opts.__name__
    ret=None
    
    try:
    
        parser = argparse.ArgumentParser( description='FMB deployment tool ver.{}'.format(settings.__version__))
        #parser.add_argument('integers', metavar='N', type=int, nargs='+',
        #               help='an integer for the accumulator')
    
        parser.add_argument('--proj', dest='proj',required=True, 
                       help='SourceSafe project')
        parser.add_argument('--label', dest='label', nargs='?', action='store',
                       required=True, help='StarTeam label')
        parser.add_argument('--view', dest='view', nargs='?', action='store',
                       required=True, help='StarTeam project view')
        parser.add_argument('--product_name', dest='prod', nargs='?', action='store',
                       required=True, help='Name of Product to process')
#Check the conf_file's value is proper and assign default value if doesn't
        parser.add_argument('--conf_file', dest='config_file', action='store',
                       default=settings.CONFIG_FILE,nargs='?',type=file_exist,
                       help='Config file')
        parser.add_argument('--debug', help='Debug level output', action='store_true')
        parser.add_argument('--verbose', help='Verbose output', action='store_true')

    
        args = parser.parse_args()

    # to have dict-like view of the attributes
        ret=vars(parser.parse_args())
    except Exception as error:
        #raise argparse.ArgumentTypeError
        logger.error ("Cought exception!!!" )
        ret=False

    return ret

def file_exist(file):
    '''
    Check file existance
    '''
    
    func_name=file_exist.__name__
    logger.info("{}:{} {}".format(func_name,file,os.path.isfile(file)))
    if not os.path.isfile(file) :
        msg = "%r is not existing file " % file
        raise argparse.ArgumentTypeError(msg)
        
    return file

def checkout(session):
    '''
    Perform SC (Starteam) operation
    '''

    ret=None
    
    try:
        #prepare starteam CLI command        
        ST_CONNECTION_STRING='{0}:{1}@{2}:{3}'.format(settings.STARTEAM_USER,settings.ST_PASSWD, settings.STARTEAMSERVER, settings.STARTEAMSERVERPORT)
        cmd=format(settings.STCMD)
              
#Spawn the StarTeam operation <checkout>
        #status=subprocess.call(ssh_cmd+' '+' '+ssh_params+' '+argv)
        
        args=[cmd,'co','-p','{0}/{1}/{2}'.format(ST_CONNECTION_STRING,session.proj,session.view),'-vl',session.label,'-nologo','-eol','lf', '-o', '-fp',session.proj_area,'-is','-fs','-ts','-x' ]
        
        for i in session.extensions.split('|'): #append the arguments with list of extansions 
            args.append(i)
        
        logger.info(cmd)
        logger.info( args)    
        p=subprocess.Popen(args,universal_newlines=True, stdout=subprocess.PIPE,stderr=subprocess.PIPE)
        
        output, error = p.communicate() #launch process

#        output = p.stdout.read()

        logger.info("return code = {}".format( p.returncode))
        logger.info(output)
        
        if p.returncode != 0:
            logger.error("Checkout failed: {}".format(error))
            ret=False
            #raise Exception
        else:    
            ret=True
            session.checked_files=make_file_list(output) #create list of file names
            
    except Exception as error:
        logger.error ("Cought exception!!!%s" % error,exc_info=True )
        ret=False
            
    return ret


def post_deploy_procedure(session):
    '''
    Call func according to Product and make out something on files
    Lets say - compile of fmb
    get func name as 
    '''
    func_name=post_deploy_procedure.__name__
    try:
        #func = getattr(session, session.function)
        func = getattr(sys.modules["fmb_deploy_utils"], session.function)
    except AttributeError:
        logger.error( 'function not found "%s" ' % (session.function))
        return False
    else:
        if func and callable(func):
            func(session.checked_files)
            logger.info('After {} session.checked_files '.format(session.function))
            return True
    

def fmb(checked_files):
    '''
    Placeholder for function
    Manage thread pool (wrong place for it)
    '''
    
    # Create the queue and thread pool.
    global q,res_queue
    q = Queue()
    res_queue=Queue()
    
    for i in range(settings.thread_poolsize):
         t = threading.Thread(target=worker)
         t.daemon = True  # thread dies when main thread (only non-daemon thread) exits.
         t.start()
    
    # stuff work items on the queue (in this case, just a number).
    start = time.perf_counter()

#convey names of files to into queue
    for item in checked_files.items():
        
        q.put(item)

    q.join() # block until all tasks are done
    res_queue.join()
    
    checked_files.clear()
    
    while not res_queue.empty():
        i=res_queue.get()
        checked_files[i[0]]=i[1]
    pass
    
def txt():
    pass


# The worker thread pulls an item from the queue and processes it
def worker():
    '''
    Fetch fmb's names from the queue and call for compile procedure
    '''
    func_name=worker.__name__
    logger.debug(func_name)
    
    while True:
        res=None
        try:            
            #fmb_name=q.get(block = False) #should be blocked
            fmb_item=q.get() #read from queue
            if fmb_item:
                res=do_fmb_compile(fmb_item)
        #what about res?
                logger.info("{} after call to do_fmb_compile res={}".format(func_name,res) )
                q.task_done()
                
                res_queue.put([fmb_item[0],res])
                res_queue.task_done()
        except Exception as error:
            logger.error("{} Exception caught: {}".format(func_name, error))
          
        
def do_fmb_compile(fmb_name): #receive tuples [fmb_name,value]
    '''
    Function runs compile procedure
    '''
    ret=None
    
    try:
        func_name=do_fmb_compile.__name__
        logger.info(func_name+do_fmb_compile.__doc__)
            
        p=subprocess.Popen([settings.COMP_FMX,fmb_name[0]],universal_newlines=True,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
        #p.communicate()
        logger.info([settings.COMP_FMX,fmb_name[0]])
        output, error = p.communicate()

#        output = p.stdout.read()
#        error=p.stderr.read()
        
        logger.info(output)
        logger.info("return code = {}".format( p.returncode))
        if p.returncode != 0:
            logger.info("{}:{}".format(func_name,error))
            
            #logger.info(streamdata)
            logger.error("compile fmb {} failed".format(fmb_name[0]))
            #store output to file
            with open("{}.log".format(fmb_name[0]),"w") as logfile:
                logfile.write(output)
                logfile.write(error)
                logfile.close()
            ret=False
            #raise Exception
        else:
            ret=True
            
    except Exception as error:
        logger.error(func_name+"Exception catched! {}".format(error))
        ret=False
    return ret

def make_file_list (strIn):
    '''
    Prepares a list of files that has been check-out - parses  the 'in' string.
    the Function is vital coupled to the format of 'stcmd co' command
    Pretty uglu - do not say nothing
    '''
    func_name=make_file_list.__name__
    checked_files={}
    logger.debug("{} eof {}".format(func_name,settings.eof)) # 
    
    for i in ((strIn.decode('utf-8')).split(settings.eof)):
        tmp=re.split(":?",i)
        logger.debug("{} eof {};splitted: {}".format(func_name,settings.eof,tmp))
        
        if i and re.search('checked out',tmp[1]):
           logger.info('file checked out "{}"'.format(tmp[0]))
           checked_files[tmp[0]]=1
           
        else:
            pass
            
  
    return checked_files

def print_report(session):
    func_name=print_report.__name__
    logger.info("{} : {}".format(func_name,session))
#print title
    print ("\n\n\tCompilation process result:")
    print ("{}".format('-'*40))
    for name,value in session.checked_files.items():
        if not value:
            print("\t{0} failed in compilation. Check {0}.log for details".format(name))
        else:
            print("\t{} succeed".format(name))
    