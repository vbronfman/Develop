from django.conf.urls import patterns, include, url

from django.contrib import admin
admin.autodiscover()

urlpatterns = patterns('',
    # Examples:
    # url(r'^$', 'dj_apache.views.home', name='home'),
    # url(r'^blog/', include('blog.urls')),
     url(r'^$', 'dj_apache.env_mngr.views.home', name='home'),
    url(r'^env_mngr/obsolete$', 'dj_apache.env_mngr.views.show_form'),
    url(r'^env_mngr$', 'dj_apache.env_mngr.views.show_form_all_prods'),

    #url(r'^env_mngr/(?P<prod>\w+)/(?P<env>\w+)/(?P<oper>\w+)$', 'dj_apache.env_mngr.views.manage_form'),
    url(r'^execute_req$', 'dj_apache.env_mngr.views.manage_form',name='manage_form'),
    url(r'^help$', 'dj_apache.env_mngr.views.show_help',name='show_help'),
    url(r'^show_log$', 'dj_apache.env_mngr.views.show_log',name='show_log'),
    url(r'^login/', 'dj_apache.env_mngr.login.login', name = 'login'),
#in te,porary way! shouls be moved to separate project!
    url(r'^fmbdeploy/', 'dj_apache.fmbdeploy.views.call2fmbdeploy', name = 'call2fmbdeploy'),
    url(r'^fmbdeploy/execute_req$', 'dj_apache.fmbdeploy.views.call2fmbdeploy', name = 'call2fmbdeploy'),


    url(r'^admin/', include(admin.site.urls)),
)
