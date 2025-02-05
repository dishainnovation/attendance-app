from rest_framework.routers import DefaultRouter
from .views import PortViewSet, TerminalViewSet, ShiftViewSet, AttendanceViewSet

router = DefaultRouter()
router.register(r'ports', PortViewSet)
router.register(r'terminals', TerminalViewSet)
router.register(r'shifts', ShiftViewSet)
router.register(r'attendances', AttendanceViewSet)

urlpatterns = router.urls
