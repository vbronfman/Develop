#!/usr/bin/env python

'''
 Manage applications and middleware resources are under responcability of ITLAB
 Call for addition scripts deployed on remote hosts:
 - statusCMS
 - osagent.sh
 - statusCMSadapter
 - ioragent
 - status_vantive 
 developed as part # of env_mngr. The rest of scripts are part of Products

 In way to add a new environments :
 - add connection properties of environment to appropriate array under the Global variables->PRODUCT HOSTS
 - update in choose_env() function with properties of new environment in place of <add new environment here>
  The number will exploited as an index for PRODUCTS HOSTS arrays
 - deploy management scripts on remote host

 In way to add a new product
 - add new array of connection properties for involved environments under the Global variables->PRODUCT HOSTS
 - create function manages a new product
 - update choose_prod() function with name of newly created function

 Developed by <Vlad Bronfman>
 - Actually refactored env_mngr.sh
'''

from web import form

from xml.dom import minidom
import xml.etree.cElementTree as et
from pprint import pprint as pp

import getopt

config_file='monitor_conf.xml'
PRODUCTS=['osagent','ioragent','cms','ba','provisioning','vantive']
ENVS={'TST1':[PRODUCTS[0],PRODUCTS[1],PRODUCTS[2]],'TST2':['cms','ba','provisioning'],'TST3':['cms','ba','provisioning']}
        
def read_conf(config_file):
    '''Read configuration data from XML config
    Store data in object'''

    ret=0
    tree=et.parse(config_file)
    root = tree.getroot()
    
    try:
        for child in root:
            print child.tag, child.attrib
            
        iter=root.iter('product')
        
        for i in iter:
            attr=i.attrib
            print attr['name']
        
    except AttributeError:
        print "AttribError occured"
        ret=1
        
    return ret

class Task:
    '''
    Working unit: actually the object performs command
    '''
    
    ENV='unknown'
    PRODUCT='unknown'
    OPER=None 
    
    def __init__(self):
        pass
    
    def get_host(ENV,PRODUCT):
        host=None
        
        return host
        
    
    
    def get_conmmand(ENV,PRODUCT,OPER):
        command=None
        
        return
        
        
    def ssh_command(self,HOST,COMMAND):
        '''
        Launch subprocess which spawn ssh 
        '''
        import subprocess
        import sys
         
        # Ports are handled in ~/.ssh/config since we use OpenSSH
        #COMMAND="uname -a"
         
        ssh = subprocess.Popen(["ssh", "%s" % HOST, COMMAND],
        shell=False,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE)
        result = ssh.stdout.readlines()
        if result == []:
            error = ssh.stderr.readlines()
            print >>sys.stderr, "ERROR: %s" % error
        else:
            print result 
        res=0
        pass
        return res

    def ssh_command_ssh(self,HOST,COMMAND):
        print "In",__name__
        try:
            import paramiko
            
            hostname = '192.168.1.15'
            port = 22
            username = 'jmjones'
            password = 'xxxYYYxxx'
            
            if __name__ == "__main__":
                paramiko.util.log_to_file('paramiko.log')
                s = paramiko.SSHClient()
                s.load_system_host_keys()
                s.connect(hostname, port, username, password)
                stdin, stdout, stderr = s.exec_command('ifconfig')
                print stdout.read()
                s.close()
        except ImportError:
            print "Error load module"
    
    
def main(argv):
    
    import django
    print(django.get_version())

    task=Task()
    task.ssh_command_ssh('vmbatest3','ls')
    task.ssh_command('vmbatest3','ls') 

  #  print 'Returned after read_conf:    ', read_conf(argv)
  #  
  #  task=Task()
  #  task.ENV="TST3"
  #  task.PRODUCT='ba'
  # # task.oper('status')
  ##  task.get_conmmand()
    pass



main(config_file)
