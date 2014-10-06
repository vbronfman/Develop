##############################################
# env_mngr - Environment Management tool  
# Developed by V.Bronfman at
#
# Current version is 2.0
# 
# Dependencies: Django framework, Python 2.7
# Main definitions are in .\dj_apache\dj_apache\settings.py
#
#
#
#############################################
from django.shortcuts import render
from django.shortcuts import render_to_response
from django.template import RequestContext

from django.conf import settings

import subprocess
from threading import Thread
from queue import Queue
import time

import os,sys

from utils import *
import logging

from django import forms
#from django.forms.formsets import formset_factory

# Get an instance of a logger
#logger = logging.getLogger(__name__)
#logger.error('Something went wrong!')

prods=[]
environments=[]
opers=[]



# Default function.
def home(request):
    return render_to_response("base.htm")
    
def show_help(request):
    return render_to_response("help_form.htm")

#ver 1.0 - single product per launch
def show_form(request):
    '''
    Display initial screen
    '''
    pass

    return render_to_response("send_form.htm",
                              {'prods': prods,
                                'envs': environments,
                                'opers': opers},
                              context_instance=RequestContext(request))
    
# ver 2.0 - shows multiple choices, threaded launches
from django.contrib.auth.decorators import login_required

#@login_required(login_url='/login/')

def show_form_all_prods(request):
    '''
    Display initial screen including status of products
    Use global view dictionary
    '''
    func_name=show_form_all_prods.__name__
    
    # Fetch configuration before render a form. 
    localview={} #a weird solution
    logger.info(" %s"% (localview))#, PROD.prod,PROD.env )
#insert each PRODUCTS from XML been parsed in get_cfg into global dictionary 
    for PROD in get_cfg(fetchConfigXML()):
        localview[PROD.prod]=[PROD.env,PROD.opers,]
        
#!!!in temporary way only!!! should be rafactored !!!
        prods.append(PROD.prod)
    
    ##for debug only!!!!
    #view['Products']=view.keys()
    #print "DEBUG func_name view " , view
    #
    ##activate form
    ##view - dictionary where keys - products
    ##A formset is a layer of abstraction to work with multiple forms on the same page.
    #ProductFormSet = formset_factory(ProductsForm ,extra=len(view))
    #formset = ProductFormSet(initial=[
    #                            {'Environment':[(1,'tstZ'),(2,'text_p')],}
    #                                     ])
    #
    ##form = ProductsForm(initial=view)
    #
    ##end of for debug only!!!
    global view
    view=localview
    logger.info( "%s view %s "%( func_name,view))
    return render_to_response("send_form_all_prods.htm",
                              {'view': view,
                                'envs': environments,
                                'opers': opers,
                                #'form':form,
                                ##'formset':formset,
                                },
                              context_instance=RequestContext(request))
  

def manage_form(request):
    '''
    send ssh request, collect responce and display the result
    '''
    func_name=run_job_in_thread.__name__
    status = "Unknown"
    items=[]
    opers=[]
    envs=[] 
    global items_to_send
    items_to_send=None
    stdout_str=None
    
    context_instance = RequestContext(request)
    
    if request.method == 'POST':
        #use http://jacobian.org/writing/dynamic-form-generation/ as example
        #form = ProductsForm(request.POST)
        logger.info( "Inside POST request.POST %s" % request.POST.items());
        
        #if form.is_valid():
        #    #do_something_with(form.cleaned_data)
        #    print "\n\nDEBUG cleaned.data ",form.cleaned_data
        #
     
     #!!!should be refactored
     #return index in array of PRODUCTS
        jobs={} #array of working threads.Each thread performs remote call
        logger.info( "request.POST %s"% request.POST)
 #rolls through loop by index of 'active_products'.
 #active_products - are indexes array of  selected checkboxes at the send_form_all_prods HTML page.
 # The process relies upon this index to fetch objects from view dictionary in order to show results
 # pretty dull though I don't care
        for i in request.POST.getlist("active_products"):
            i=int(i)
            i-=1
            
            #print "DEBUG ",func_name," i=", i,request.POST.getlist("EnvID")[i], request.POST.getlist("Mode")[i]
            #print ("DEBUG ",func_name, " view " , view.keys())
            jobs[list(view.keys())[i]]=[ request.POST.getlist("EnvID")[i],0]
                   # request.POST.getlist("Mode")[i]]
            str_out="DEBUG request.POST.get(\"EnvId\")[i]: %s "%jobs
            
            # Actually, the major part of the script: makes ssh calls in parallel     
            items_to_send,stdstr_que=run_job_in_thread(jobs) #should fill items to send with values
            logger.info("%s items_to_send %s %s"%(func_name,items_to_send,stdstr_que))
            while stdstr_que.empty() != True:
                stdout_str="%s"%stdstr_que.get_nowait()
            #return HttpResponseRedirect('show_res_mult.htm')#for debug
           
    elif  request.method == 'GET':
        logger.info( "method GET")
        
    return render_to_response('show_res_mult.htm',
                                      {
                                      'items': items_to_send,
                                      'stdout_str':stdout_str,
                                      },
                                    )

# ver 2.0 - shows multiple choices, threaded launches 
def show_log(request):
    '''
    Displays collected stdout messages
    Use global items_to_send dictionary
    '''
    func_name=show_log.__name__
    return render_to_response('show_log_form.htm',
                              {'items': items_to_send,
                               }
                             )

# So far, forms aren't in use by the script
#!!!Forms should be moved out to forms.py
       
class MyForm(forms.Form):
    
    '''Example  .
    i have no Question object so comment it'''
    #question = []
    #questions = Question.objects.all()
    #for q in questions:
    #    question.append(forms.CharField(max_length=100, label=q.questionText))
    
    #def __init__(self, *args, **kwargs):
    #    super(MyForm, self).__init__(*args, **kwargs)
         
        #for i, q in enumerate(Question.objects.all()):
        #    self.fields['%s_field' % i] = forms.CharField(max_length=100, label=q.questionText)
 
class ProductsForm(forms.Form):
    '''get list of products as input or view object?'''
    envs={}
    Product=forms.CharField(label="product")#,initial=myview.keys() )
    Activate = forms.CharField(label="Activate",widget=forms.CheckboxInput,required=False,)
    
    #Environment=forms.ChoiceField(label='Environment ID',choices=zip(range(len(view['OSAGENT'][0])),view['OSAGENT'][0]))
    
    Environment=forms.ChoiceField(label='Environment ID',choices=zip(range(len(envs)),envs))
    
    Operation=forms.ChoiceField( label='Command',)#choices=zip(range(len(prop[1])),prop[1]), ) #should be tuples as input ;help_text="Environment to choose"
    
    
    def __init__(self,envs=None, *args, **kwargs):
        super(ProductsForm, self).__init__(*args, **kwargs)
        
        
         
        #self.fields['%s_field' % i] = forms.CharField
        #active_products=[]
        #for product,prop  in myview.items():
        #    print "DEBUG zip", zip(range(len(prop[1])),prop[1])
         #   print "DEBUG view.product", product

    #choice_field = forms.ChoiceField(widget=forms.RadioSelect, choices=zip(range(len(view['OSAGENT'][1])),view['OSAGENT'][1]))
    

   