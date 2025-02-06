from django.contrib import admin
from django.urls import path, include
from rest_framework.routers import DefaultRouter

from attendance_tracker.views.attendance_views import AttendanceViewSet, PortViewSet, ShiftViewSet, TerminalViewSet
from attendance_tracker.views.employees_views import EmployeeViewSet, login_view
from attendance_tracker.views.maintenance_views import PreventiveMaintenanceViewSet

router = DefaultRouter()
router.register(r'employees', EmployeeViewSet)
router.register(r'attendance', AttendanceViewSet)
router.register(r'port', PortViewSet)
router.register(r'terminal', TerminalViewSet)
router.register(r'shift', ShiftViewSet)
router.register(r'maintenance', PreventiveMaintenanceViewSet)

urlpatterns = [
    path('', include(router.urls)),
    path('login/', login_view, name='login'),
]