from attendance_tracker.models import PreventiveMaintenance
from rest_framework import serializers

class PreventiveMaintenanceSerializer(serializers.ModelSerializer):
    class Meta:
        model = PreventiveMaintenance
        fields = '__all__'
