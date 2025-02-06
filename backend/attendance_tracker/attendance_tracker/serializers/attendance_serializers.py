from attendance_tracker.models import Attendance, Port, Shift, Terminal
from rest_framework import serializers

class PortSerializer(serializers.ModelSerializer):
    class Meta:
        model = Port
        fields = '__all__'

class TerminalSerializer(serializers.ModelSerializer):
    class Meta:
        model = Terminal
        fields = '__all__'

class ShiftSerializer(serializers.ModelSerializer):
    class Meta:
        model = Shift
        fields = '__all__'

class AttendanceSerializer(serializers.ModelSerializer):
    class Meta:
        model = Attendance
        fields = '__all__'
