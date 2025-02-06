from attendance_tracker.models import PreventiveMaintenance
from attendance_tracker.serializers.maintenance_serializers import PreventiveMaintenanceSerializer
from rest_framework import viewsets

class PreventiveMaintenanceViewSet(viewsets.ModelViewSet):
    queryset = PreventiveMaintenance.objects.all()
    serializer_class = PreventiveMaintenanceSerializer
