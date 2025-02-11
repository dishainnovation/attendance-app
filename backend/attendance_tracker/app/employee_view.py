import json
from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.response import Response
from .models import Designation, Employee, Port
from .serializers import EmployeeSerializer
from django.core import serializers


@api_view(['GET', 'POST', 'PUT', 'DELETE'])
def employee_list(request):
    if request.method == 'GET':
        employees = Employee.objects.select_related('designation').all()
        serializer = EmployeeSerializer(employees, many=True)
        return Response(serializer.data)

    elif request.method == 'POST':
        profile_image = request.FILES.get('profile_image')
        employee_code = request.data['employee_code']
        name = request.data['name']
        mobile_number = request.data['mobile_number']
        gender = request.data['gender']
        password = request.data['password']
        designation = Designation.objects.get(id=request.data['designation'])
        date_of_birth = request.data['date_of_birth']
        date_of_joining = request.data['date_of_joining']
        port = Port.objects.get(id = request.data['port'])
        employee = Employee(
            profile_image=profile_image,
            employee_code=employee_code,
            name=name,
            mobile_number=mobile_number,
            gender=gender,
            password=password,
            designation=designation,
            date_of_birth=date_of_birth,
            date_of_joining=date_of_joining,
            port=port
        )
        employee.save()
        return Response(json.dumps(employee.to_dict()), status=status.HTTP_201_CREATED)
    
    elif request.method == 'PUT':
        try:
            id = request.GET.get('id')
            employee = Employee.objects.get(id=id)
        except Employee.DoesNotExist:
            return Response(status=status.HTTP_404_NOT_FOUND)
        
        employee.profile_image = request.FILES.get('profile_image')
        employee.employee_code = request.data['employee_code']
        employee.name = request.data['name']
        employee.mobile_number = request.data['mobile_number']
        employee.gender = request.data['gender']
        employee.password = request.data['password']
        employee.designation = Designation.objects.get(id=request.data['designation'])
        employee.date_of_birth = request.data['date_of_birth']
        employee.date_of_joining = request.data['date_of_joining']
        employee.port = Port.objects.get(id = request.data['port'])
        print(employee.to_dict())
        employee.save()
        return Response(json.dumps(employee.to_dict()), status=status.HTTP_200_OK)
        # serializer = EmployeeSerializer(employee, data=request.data)
        # if serializer.is_valid():
        #     serializer.save()
        #     return Response(serializer.data)
        # return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    elif request.method == 'DELETE':
        try:
            id = request.GET.get('id')
            employee = Employee.objects.get(id=id)
        except Employee.DoesNotExist:
            return Response(status=status.HTTP_404_NOT_FOUND)
        employee.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)

@api_view(['GET'])
def employee_view(request):
    if request.method == 'GET':
        try:
            id = request.GET.get('id')
            employee = Employee.objects.select_related('designation').get(id=id)
        except Employee.DoesNotExist:
            return Response(status=status.HTTP_404_NOT_FOUND)
        
        if employee is not None:
            serializer = EmployeeSerializer(employee)
            return Response(serializer.data, status=status.HTTP_200_OK)
        else:
            return Response({'error': 'Invalid credentials'}, status=status.HTTP_400_BAD_REQUEST)
        
@api_view(['GET'])
def login_view(request):
    if request.method == 'GET':
        employee_code = request.GET.get('employee_code')
        password = request.GET.get('password')
        print(employee_code, password)
        # Authenticate the Employee
        employeeData = Employee.objects.filter(employee_code=employee_code, password=password).first()
        
        if employeeData is not None:
            serializer = EmployeeSerializer(employeeData)
            return Response(serializer.data, status=status.HTTP_200_OK)
        else:
            return Response({'error': 'Invalid credentials'}, status=status.HTTP_400_BAD_REQUEST)
        
