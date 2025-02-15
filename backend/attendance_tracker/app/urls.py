from django.urls import path, include
from rest_framework.routers import DefaultRouter
from app import attendance_view, employee_view, port_view, shift_view, site_view
from . import designation_view

router = DefaultRouter()
router.register(r'site', site_view.SiteViewSet, basename='site')
router.register(r'shift', shift_view.ShiftViewSet, basename='shift')

urlpatterns = [
    path('login/', employee_view.login_view),
    path('designation/', designation_view.designation_list),
    path('employee/', employee_view.employee_list),
    path('employee/<int:id>/', employee_view.employee_view),
    path('port/', port_view.port_list),
    path('shift/<int:id>/', shift_view.shift_view),
    path('', include(router.urls)),
    path('attendance/', attendance_view.attendance_list),
]
