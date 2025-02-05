from rest_framework.routers import DefaultRouter
from .views import PreventiveMaintenanceViewSet

router = DefaultRouter()
router.register(r'maintenance', PreventiveMaintenanceViewSet)

urlpatterns = router.urls
