from attendance_tracker.models import Employee
from attendance_tracker.serializers.employees_serializers import EmployeeSerializer
from rest_framework import viewsets
from rest_framework.response import Response
from rest_framework import status
from rest_framework.decorators import api_view


class EmployeeViewSet(viewsets.ModelViewSet):
    queryset = Employee.objects.all()
    serializer_class = EmployeeSerializer
@api_view(['GET'])
def login_view(request):
    if request.method == 'GET':
        user_id = request.GET.get('user_id')
        password = request.GET.get('password')
        # Authenticate the Employee
        employeeData = Employee.objects.filter(user_id=user_id, password=password).first()
        
        if employeeData is not None:
            serializer = EmployeeSerializer(employeeData)
            return Response(serializer.data, status=status.HTTP_200_OK)
        else:
            return Response({'error': 'Invalid credentials'}, status=status.HTTP_400_BAD_REQUEST)
    
