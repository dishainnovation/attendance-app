from rest_framework import serializers
from .models import PreventiveMaintenance

class PreventiveMaintenanceSerializer(serializers.ModelSerializer):
    class Meta:
        model = PreventiveMaintenance
        fields = '__all__'
