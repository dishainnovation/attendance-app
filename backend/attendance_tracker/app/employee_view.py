from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.response import Response
from django.db.models.deletion import ProtectedError
from .models import Designation, Employee, Port
from django.http import JsonResponse


@api_view(['GET', 'POST', 'PUT', 'DELETE'])
def employee_list(request):
    if request.method == 'GET':
        employees = Employee.objects.select_related('designation').all()
        employee_data = []
        for employee in employees:
            employee_data.append(employee_object(employee))
        
        return JsonResponse(employee_data, safe=False)

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
        newEmployee = employee_object(employee)
        return Response(newEmployee, status=status.HTTP_201_CREATED)
    
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
        employee.save()
        newEmployee = employee_object(employee)
        return Response(newEmployee, status=status.HTTP_200_OK)

    elif request.method == 'DELETE':
        try:
            id = request.GET.get('id')
            employee = Employee.objects.get(id=id)
        except Employee.DoesNotExist:
            return Response(status=status.HTTP_404_NOT_FOUND)
        
        try:
            employee.delete()
            return Response(status=status.HTTP_204_NO_CONTENT)
        except ProtectedError as e:
            error_message = f"Cannot delete Employee '{employee.name}' because he has Attendance records. Please remove the Attendance records before attempting to delete."
            return Response(status=status.HTTP_400_BAD_REQUEST, data={'error_message': error_message})

@api_view(['GET'])
def employee_view(request):
    if request.method == 'GET':
        try:
            id = request.GET.get('id')
            employee = Employee.objects.select_related('designation').get(id=id)
        except Employee.DoesNotExist:
            return Response(status=status.HTTP_404_NOT_FOUND)
        
        if employee is not None:
            resEmployee = employee_object(employee)
            return JsonResponse(resEmployee, safe=False)
           
        else:
            return Response({'error': 'Invalid credentials'}, status=status.HTTP_400_BAD_REQUEST)
        
@api_view(['GET'])
def login_view(request):
    if request.method == 'GET':
        employee_code = request.GET.get('employee_code')
        password = request.GET.get('password')
        # Authenticate the Employee
        employeeData = Employee.objects.filter(employee_code=employee_code, password=password).first()
        
        if employeeData is not None:
            resEmployee = employee_object(employeeData)
            return JsonResponse(resEmployee, safe=False)
        else:
            return Response({'error': 'Invalid credentials'}, status=status.HTTP_400_BAD_REQUEST)
        
def employee_object(employee):
    return {
            'id': employee.id,
            'profile_image': employee.profile_image.url if employee.profile_image else None,
            'employee_code': employee.employee_code,
            'name': employee.name,
            'mobile_number': employee.mobile_number,
            'gender': employee.gender,
            'password': employee.password,
            'date_of_birth': employee.date_of_birth,
            'date_of_joining': employee.date_of_joining,
            'port': employee.port.id,
            'port_name': employee.port.name,
            'designation': {
                'id': employee.designation.id,
                'name': employee.designation.name,
                'user_type': employee.designation.user_type,
                'remote_checkin': employee.designation.remote_checkin
            }
        }