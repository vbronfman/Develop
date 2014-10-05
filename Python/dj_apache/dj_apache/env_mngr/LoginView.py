from django.contrib import auth
from django.http import HttpResponseRedirect
from django.shortcuts import render


def login_view(request):
    err_msg = None
    # if the request method is POST the process the POST values otherwise just render the page
    if request.method == 'POST':
        username = request.POST.get('username', '')
        password = request.POST.get('password', '')
        user = auth.authenticate(username=username, password=password)
        if user is not None and user.is_active:
            # Correct password, and the user is marked "active"
            auth.login(request, user)
            # Redirect to dashboard
            return HttpResponseRedirect('env_mngr')
        else:
            # Show a message     
            err_msg='Please enter your username and password below.'
    return render(request, 'login_form.htm', {'login': err_msg})