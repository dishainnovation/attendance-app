from rest_framework import viewsets
from .models import PreventiveMaintenance
from .serializers import PreventiveMaintenanceSerializer

class PreventiveMaintenanceViewSet(viewsets.ModelViewSet):
    queryset = PreventiveMaintenance.objects.all()
    serializer_class = PreventiveMaintenanceSerializer
