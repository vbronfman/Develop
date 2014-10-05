from xml.etree import ElementTree as ET
from threading import Thread
from queue import Queue
import time
import os
import subprocess
import tempfile


from django.conf import settings
from django.http import HttpResponseRedirect, HttpResponse

import logging

# Get an instance of a logger
logger = logging.getLogger('myproject.custom')


undef=""

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
    
def get_cfg(cfg_file):
    '''
    Fetch definitions from XML
    '''
    func_name=get_cfg.__name__
    prod_list=[]
    try:
        fh=ET.parse(cfg_file)
        #fh=ET.parse(ET.fromstring(xmlstring))
        
#ParseError        
    except Exception as error:
        logger.error ("An exception was thrown!")
        logger.error (str(error))
        exit()
    else:
        logger.info( ' XML is valid')


    for prod in fh.findall('.//product'):
        #print "DEBUG prod.get('state')",prod.get('state')
        if prod.get('state') == "disabled":
            continue
        
        product=Product() #creates object of class
        
        #print "DEbug product object",product
        
        product.prod=prod.get('name')
        #print "DEBUG prod.product",product.prod
        
        for env in [ e  for e in prod.findall('environment') if
                    e.get('state') !='disabled']:
                    (product.env).append(env.get("env"))
                    #print "DEBUG search for environments env.get('env')", product.env
        
        cmd=prod.find('cmd')
       # print "DEBUG cmd=",cmd
        
        for command in cmd:
                    #if cmd.get("status") !="" :
            (product.opers).append(command.tag)
                    
            #print "DEBUG search for environments env.get('cmd')", product.opers
       
        prod_list.append(product)
    
    #print "list.append(product)",__file__, prod_list
        
    return prod_list 
     
     

# Manages launching tasks in queue      
def run_job_in_thread(jobs):
    '''
    Manage paralell launch
    jobs - dictionary of products to run {prod:[env,mode]}
    '''
    func_name=run_job_in_thread.__name__
    try:
        job_queue = Queue()
        res_queue = Queue()
        #stdout and stderr of subprocess
        stdstr_queue = Queue()
        
        start=time.time()
        
        #print "DEBUG function %s  job_queue=" %(func_name), job_queue,res_queue
        
        #Determine Number of threads to use, but max out at 25
        if len(jobs) < 25:
            num_threads = len(jobs)
        else:
            num_threads = 25          
        

        #Start thread pool
        for i in range(num_threads):
            #for cmd in cmds:
           # for job,params in jobs.iteritems():
            #print "DEBUG func_name num_threads is  " ,job,params
                #target is a function to launch
                #in my case getResponseparams1 status=getResponseparams1 (prod,env,oper)
                # Creates same workers which will take parameteres to launch from the job_queue 
            worker = Thread(target=getResponseparams, args=(job_queue,res_queue,stdstr_queue))
            worker.setDaemon(True)
            worker.start()
                
        logger.info('Main Thread Waiting')
        
        for job,params in jobs.items():
            logger.info("DEBUG %s job %s,params %s: %s " % (func_name ,job,params[0],params[1]))
            #job - product,params[0] - environmnet  ,params[1] = operation 
            job_queue.put([job,params[0],params[1]])
            
        job_queue.join() #wait for all jobs'll come to finish
        end=time.time()
        
        logger.info( "Dispatch Completed in %s seconds" % (end-start))
        
        items_to_send=[]
        #get result from queue
        while res_queue.empty() != True:
            #items_to_send.append([prod,env,status])
            items_to_send.append(res_queue.get_nowait())
             
        logger.info( "DEBUG %s %s" % (func_name,items_to_send) )
        return items_to_send,stdstr_queue
    except Exception as err:
        logger.error( " %s: %s" % (func_name, err))
    finally:
        pass
        

# Major worker: launches commands by ssh and collects responses.
def getResponseparams(q,res_q=None,stdstr_q=None):
    '''
    Make ssh call to remote procedure and returns return code
    gets the params from queue prod,env,oper
    '''
    func_name=getResponseparams.__name__
    #!!!should be moved to outter config file
    engine_host=settings.ENGINE_HOST
    #engine="/ITLAB_share/itlab/Monitor/cmd_engine.pl"
    engine=settings.ENGINE
    config_file=settings.CONFIG_FILE
    ssh_cmd=settings.SSH_CMD
    ssh_params=settings.SSH_PARAMS
    engine_log=settings.ENGINE_LOG
    
    logger.info( "DEBUG %s params: %s %s %s %s %s %s"%(func_name,ssh_cmd,ssh_params,engine_host,engine,config_file,engine_log))
    
    while True: 
        job=q.get()
        prod=job[0]
        env=job[1]
        cmd=job[2]
        
        #very raw approach - have to modify as soon as possible
        argv="%s perl -S -I /ITLAB_share/itlab/perl/lib %s %s %s %s %s %s" % (engine_host,engine,prod,env,cmd,config_file,engine_log)
        
        to_print="DEBUG func %s job: %s " % (func_name,argv)
        logger.info(to_print )
        #status=subprocess.call(ssh_cmd+' '+' '+ssh_params+' '+argv)
        
        p=subprocess.Popen("%s %s %s" %(ssh_cmd,ssh_params,argv),stdout=subprocess.PIPE,stderr=subprocess.PIPE,universal_newlines=True);#,close_fds=True);
        #p=subprocess.Popen(ssh_cmd,ssh_params,argv,stdout=subprocess.PIPE,stderr=subprocess.PIPE,universal_newlines=True)
		
        output,error= p.communicate() 
        		
        print ("OUTPUT", output)

        #p=subprocess.Popen([ssh_cmd, engine_host,argv],stdout=subprocess.PIPE,stderr=subprocess.PIPE)
        #output = p.stdout.read()
        #error=p.stderr.read()
		
		
        
        logger.info( "after popen: output=%s,error=%s ;"% (output, error))
        
 #check status
        #argv=engine_host+' '+'perl -S -I /ITLAB_share/itlab/perl/lib'+' '+engine+' '+prod+' '+env+' '+'status'+' '+config_file
        argv="%s perl -S -I /ITLAB_share/itlab/perl/lib %s %s %s %s %s %s" % (engine_host,engine,prod,env,'status',config_file,engine_log)
        
        logger.info( "ARGV: "+argv)
        status=subprocess.call(ssh_cmd+' '+' '+ssh_params+' '+argv)
        #print "DEBUG %s " % func_name, subprocess.call([ssh_cmd, argv])
        logger.info( "Status after subprocess spawn status=%s"%(status))
        
        #Returns result over queue
        if res_q != None:
            #res_q.put_nowait([prod,env,status])
            res_q.put_nowait([prod,env,status,output,error])
            stdstr_q.put_nowait([output,error])
            res_q.task_done()
            
        q.task_done()
    return status

def fetchConfigXML():
    ''' Copy XML config onto client every launch of application
    should be added sihronising mechanism
    or read by string or what ever
    '''
    
    '''
    import hashlib
with open( <path-to-file>, "rb" ) as theFile:
    m = hashlib.md5( )
    for line in theFile:
        m.update( line )
with open( <path-to-hashfile>, "wb" ) as theFile:
    theFile.write( m.digest( ) )
    '''
    
    func_name=fetchConfigXML.__name__
    #!!!should be moved to outter config file
    engine_host=settings.ENGINE_HOST
    #engine="/ITLAB_share/itlab/Monitor/cmd_engine.pl"
    engine=settings.ENGINE
    config_file=settings.CONFIG_FILE
    ssh_cmd=settings.SSH_CMD
    ssh_params=settings.SSH_PARAMS   
    
    'if MD5 !=remote hash - should be added '
    #create a temp file for receive content of Unix's XML file into
    (os_level,file_path)=tempfile.mkstemp(suffix='', prefix='tmp', dir=None, text=False)
    
    logger.info( "%s %s %s cat %s" %(func_name,ssh_cmd,engine_host, config_file))
    #status=subprocess.call(ssh_cmd+' '+engine_host+' cat '+config_file)
    #p=subprocess.Popen("%s %s:%s %s" %(scp_cmd,engine_host,config_file,file_path),stdout=subprocess.PIPE,stderr=subprocess.PIPE)
    p=subprocess.Popen("%s %s %s cat %s" %(ssh_cmd,ssh_params,engine_host, config_file),stdout=subprocess.PIPE,stderr=subprocess.PIPE);#,close_fds=True)
    
    #grab stdout, stdout for error checking
    output = p.stdout.read() #check if valid?
    error = p.stderr.read()
    #logger.info( "after popen: output=%s,error=%s ;"% (output, error))
    try:
        #
        if os.path.exists(file_path):
            logger.info( "%s file_path=%s"% (func_name,file_path))
            with open(file_path,'w') as fp:
                fp.write( output.decode("utf-8") )
    except Exception as error:
        logger.error ("An exception was thrown!")
        logger.error (str(error))
        exit()
        
    return file_path
