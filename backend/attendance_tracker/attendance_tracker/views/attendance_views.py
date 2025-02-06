from attendance_tracker.models import Attendance, Port, Shift, Terminal
from attendance_tracker.serializers.attendance_serializers import AttendanceSerializer, PortSerializer, ShiftSerializer, TerminalSerializer
from rest_framework import viewsets

class PortViewSet(viewsets.ModelViewSet):
    queryset = Port.objects.all()
    serializer_class = PortSerializer

class TerminalViewSet(viewsets.ModelViewSet):
    queryset = Terminal.objects.all()
    serializer_class = TerminalSerializer

class ShiftViewSet(viewsets.ModelViewSet):
    queryset = Shift.objects.all()
    serializer_class = ShiftSerializer

class AttendanceViewSet(viewsets.ModelViewSet):
    queryset = Attendance.objects.all()
    serializer_class = AttendanceSerializer
