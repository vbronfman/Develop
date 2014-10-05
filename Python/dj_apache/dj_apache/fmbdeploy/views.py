from django.shortcuts import render
from django.shortcuts import render_to_response
from django.template import RequestContext

import subprocess
from threading import Thread
from Queue import Queue
import time

import os
from django.conf import settings

import logging

logger=logging.getLogger(__name__)

def call2fmbdeploy(request):
    destionations=['prod5','prod1','prod22','it2tst1']
    projects=['PM_ALM','CRM_BA','CRM_BSS']
    views=['PM_ALM/Develop/FILE_DEPLOYER/TEST_FOLDER','unknown','undef']
    labeles=['TEST_DEPLOY']
    
    context_instance = RequestContext(request)
    
    if request.method == 'POST':
        print("request.POST %s"% request.POST)
        logger.info( "request.POST %s"% request.POST)
        
        destination=request.POST.getlist("Destination")[0]
        project=request.POST.getlist("Project")[0]
        view=request.POST.getlist("View")[0]
        file_list={'New_Text_Document_Copy.fmb':1,'test.fmb':0,'test1.fmb':0}
        
        print ("project {} view {} file_list {} ".format(project,view,file_list))
        
        #FOR DEBUG ONLY!!! SHOULD BE REMOVED!!!
        if not project == "PM_ALM":
            return render_to_response("fmbdeployerror.htm",
                                     )
            
        #END of FOR DEBUG ONLY!!! SHOULD BE REMOVED!!!
        
        
        pass
        return render_to_response("fmbdeployresult.htm",
                              {'destination': destination,
                                'project': project,
                                'view': view,
                                'file_list':file_list,
                                #'result':result
                                },
                                context_instance=RequestContext(request)
                              )
        
    elif  request.method == 'GET':
        logger.info( "method GET")
    
    return render_to_response("fmbdeploystart.htm",
                              {'destionations': destionations,
                                'projects': projects,
                                'views': views,
                                'labeles':labeles },
                              context_instance=RequestContext(request)
                              )
    