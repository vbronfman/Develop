#from dashboard.dashviews import left, right, topright
from dj_apache.env_mngr import LoginView 
from django.shortcuts import render
from django.http import HttpResponseRedirect
from django.contrib.auth.decorators import login_required

#@login_required(login_url='/login/')
#def dash(request):
#    return render(request, 'dash_template.html', 
#        {'left': left.dash_left(request), 
#         'right': right.dash_right(), 
#        'topright': topright.top_right(request)})

def login(request):
    print "DEBUG in login request"
    if not request.user.is_authenticated():
        #return render(request, 'login_form.htm', {'login': LoginView.login_view(request)})
        return LoginView.login_view(request)

    else:
        print "DEBUG in login request else  HttpResponseRedirect('/')"
        return HttpResponseRedirect('/')

def logout(request):
    return render(request, 'logout.html', {'logout': LogoutView.logout_view(request)}) and HttpResponseRedirect('/login/')