from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.response import Response
from .models import Attendance
from .serializers import AttendanceSerializer

@api_view(['GET', 'POST', 'PUT', 'DELETE'])
def attendance_list(request):
    if request.method == 'GET':
        ports = Attendance.objects.all()
        employee = request.GET.get('employee')
        date = request.GET.get('date')
        if(employee is not None and date is not None):
            attendance_records = Attendance.objects.filter(employee=employee,attendance_date=date)
            serializer = AttendanceSerializer(attendance_records, many=True)
            return Response(serializer.data)

        serializer = AttendanceSerializer(ports, many=True)
        return Response(serializer.data)

    elif request.method == 'POST':
        serializer = AttendanceSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    elif request.method == 'PUT':
        try:
            id = request.GET.get('id')
            attendance = Attendance.objects.get(id=id)
        except Attendance.DoesNotExist:
            return Response(status=status.HTTP_404_NOT_FOUND)
        
        
        serializer = AttendanceSerializer(attendance, data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    elif request.method == 'DELETE':
        try:
            id = request.GET.get('id')
            attendance = Attendance.objects.get(id=id)
        except Attendance.DoesNotExist:
            return Response(status=status.HTTP_404_NOT_FOUND)
                
        attendance.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)

