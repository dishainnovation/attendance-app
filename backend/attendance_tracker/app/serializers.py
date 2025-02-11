from rest_framework import serializers
from .models import Attendance, Designation, Employee, Port, Shift, Site

from django import forms

class Employeeorm(forms.ModelForm):
    class Meta:
        model = Employee
        fields = '__all__'

class DesignationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Designation
        fields = '__all__'

class EmployeeSerializer(serializers.ModelSerializer):
    designation_name = serializers.CharField(source='designation.name')
    port_name = serializers.CharField(source='port.name')
    class Meta:
        model = Employee
        fields = '__all__'
        read_only_fields = ['designation_name','port_name']

class PortSerializer(serializers.ModelSerializer):
    class Meta:
        model = Port
        fields = '__all__'

class SiteSerializer(serializers.ModelSerializer):
    port_name = serializers.CharField(source='port.name')
    class Meta:
        model = Site
        fields = '__all__'
        read_only_fields = ['port_name']

class ShiftSerializer(serializers.ModelSerializer):
    port_name = serializers.CharField(source='port.name')
    class Meta:
        model = Shift
        fields = '__all__'
        read_only_fields = ['port_name']

class AttendanceSerializer(serializers.ModelSerializer):
    class Meta:
        model = Attendance
        fields = '__all__'

