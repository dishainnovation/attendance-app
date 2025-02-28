from .employee_view import employee_object
from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.response import Response
from django.http import JsonResponse
from .models import Attendance, Employee, Port, Shift
from .serializers import AttendanceSerializer
import face_recognition
from PIL import Image, ExifTags
import io
import numpy as np
from django.http import HttpResponse
import requests

@api_view(['GET', 'POST', 'PUT', 'DELETE'])
def attendance_list(request):
    if request.method == 'GET':
        ports = Attendance.objects.all().order_by('attendance_date')
        employee = request.GET.get('employee')
        date = request.GET.get('date')
        if(employee is not None and date is not None):
            attendance_records = Attendance.objects.filter(employee=employee,attendance_date=date)
            attendance_data = []
            for att in attendance_records:
                attendance_data.append(attendance_object(att))
                
            return JsonResponse(attendance_data, safe=False)

        serializer = AttendanceSerializer(ports, many=True)
        return Response(serializer.data)

    elif request.method == 'POST':
        try:
            employee_id = request.data['employee_id']
            employee = Employee.objects.get(id=employee_id)
            user_image = request.FILES.get('user_photo')
            print(employee.profile_image.url)

            def download_file_from_url(url, local_filename):
                response = requests.get(url, stream=True)
                with open(local_filename, 'wb') as f:
                    for chunk in response.iter_content(chunk_size=8192):
                        if chunk:  # filter out keep-alive new chunks
                            f.write(chunk)


            download_file_from_url(employee.profile_image.url, 'profileImage.jpg')
            image_from_s3 = open('profileImage.jpg', 'rb')

            print(image_from_s3)

            match = compare(user_image, image_from_s3)
            print(match)
            if match['match']:
                attendance = Attendance(
                    attendance_date = request.data['attendance_date'],
                    employee = employee,
                    port = Port.objects.get(id = request.data['port_id']),
                    shift = Shift.objects.get(id=request.data['shift_id']),
                    check_in_time = request.data['check_in_time'],
                    check_out_time = None,
                    check_in_latitude = request.data['check_in_latitude'],
                    check_in_longitude = request.data['check_in_longitude'],
                    check_in_photo = user_image,
                    check_out_photo = None,
                    attendance_type = request.data['attendance_type']
                )
                attendance.save()
                return Response(status=status.HTTP_201_CREATED)
            else:
                return Response(status=status.HTTP_204_NO_CONTENT)
        except Attendance.DoesNotExist:
            return Response(status=status.HTTP_400_BAD_REQUEST)
    
    elif request.method == 'PUT':
        try:
            id = request.GET.get('id')
            attendance = Attendance.objects.get(id=id)
        except Attendance.DoesNotExist:
            return Response(status=status.HTTP_404_NOT_FOUND)
        
        employee_id = request.data['employee_id']
        employee = Employee.objects.get(id=employee_id)
        user_image = request.FILES.get('user_photo')
        if user_image is None:
            attendance.attendance_date = request.data['attendance_date']
            attendance.employee = employee
            attendance.port = Port.objects.get(id = request.data['port_id'])
            attendance.shift = Shift.objects.get(id=request.data['shift_id'])
            attendance.check_out_time = request.data['check_in_time']
            attendance.check_out_latitude = request.data['check_out_latitude']
            attendance.check_out_longitude = request.data['check_out_longitude']
            # attendance.check_out_photo = user_image
            attendance.attendance_type = request.data['attendance_type']

            attendance.save()
            return Response(status=status.HTTP_201_CREATED)
        
        def download_file_from_url(url, local_filename):
                response = requests.get(url, stream=True)
                with open(local_filename, 'wb') as f:
                    for chunk in response.iter_content(chunk_size=8192):
                        if chunk:  # filter out keep-alive new chunks
                            f.write(chunk)


        download_file_from_url(employee.profile_image.url, 'profileImage.jpg')
        image_from_s3 = open('profileImage.jpg', 'rb')

        print(image_from_s3)

        match = compare(user_image, image_from_s3)

        if match['match']:
            attendance.attendance_date = request.data['attendance_date']
            attendance.employee = employee
            attendance.port = Port.objects.get(id = request.data['port_id'])
            attendance.shift = Shift.objects.get(id=request.data['shift_id'])
            attendance.check_out_time = request.data['check_in_time']
            attendance.check_out_latitude = request.data['latitude']
            attendance.check_out_longitude = request.data['longitude']
            attendance.check_out_photo = user_image
            attendance.attendance_type = request.data['attendance_type']

            attendance.save()
            return Response(status=status.HTTP_201_CREATED)
        else:
            return Response(status=status.HTTP_204_NO_CONTENT)


    elif request.method == 'DELETE':
        try:
            id = request.GET.get('id')
            attendance = Attendance.objects.get(id=id)
        except Attendance.DoesNotExist:
            return Response(status=status.HTTP_404_NOT_FOUND)
                
        attendance.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)
    
def compare(image1, image2):
    try:
        # Read and process the images
        def process_image(image_file):
            image = Image.open(io.BytesIO(image_file.read()))
            image = correct_image_orientation(image)
            return np.array(image)
        
        image_array1 = process_image(image1)
        
        image_array2 = process_image(image2)

        # Compute face encodings
        encodings1 = face_recognition.face_encodings(image_array1)
        encodings2 = face_recognition.face_encodings(image_array2)

        if len(encodings1) == 0 or len(encodings2) == 0:
            return {'match': False}

        # Compare faces
        result = face_recognition.compare_faces([encodings1[0]], encodings2[0])
        return {'match': bool(result[0])}  # Ensure the boolean value is serialized correctly

    except Exception as e:
        print(e)
        return {'match': False}

def correct_image_orientation(image):
    try:
        for orientation in ExifTags.TAGS.keys():
            if ExifTags.TAGS[orientation] == 'Orientation':
                break
        exif = image._getexif()
        if exif is not None:
            orientation = exif.get(orientation, 1)
            if orientation == 3:
                image = image.rotate(180, expand=True)
            elif orientation == 6:
                image = image.rotate(270, expand=True)
            elif orientation == 8:
                image = image.rotate(90, expand=True)
    except (AttributeError, KeyError, IndexError):
        # Image does not have EXIF data
        pass
    return image

def attendance_object(attendance):
    if not attendance.check_out_photo:
        check_out_photo = None
    else:
        check_out_photo = attendance.check_out_photo.url
    
    return {
        'id': attendance.id,
        'employee': employee_object(attendance.employee),
        'attendance_date': attendance.attendance_date,
        'port': attendance.port.id,
        'shift': attendance.shift.id,
        'check_in_time': attendance.check_in_time,
        'check_out_time': attendance.check_out_time,
        'check_in_latitude': attendance.check_in_latitude,
        'check_in_longitude': attendance.check_in_longitude,
        'check_out_latitude': attendance.check_out_latitude,
        'check_out_longitude': attendance.check_out_longitude,
        'check_in_photo': attendance.check_in_photo.url,
        'check_out_photo': check_out_photo,
        'attendance_type': attendance.attendance_type,
        'created_at': attendance.created_at,
        'updated_at': attendance.updated_at,
    }

def attendance_report(request):
    # Get the start_date and end_date from query parameters
    start_date = request.GET.get('start_date')
    end_date = request.GET.get('end_date')
    employee_name = request.GET.get('employee_name')
    port_id = request.GET.get('port_id')

    if not start_date or not end_date:
        return HttpResponse('Please provide start_date and end_date as query parameters.', status=400)

    # Fetch data from the database for the specified date range
    filters = {'attendance_date__range': [start_date, end_date]}
    if employee_name:
        filters['employee__name__icontains'] = employee_name
    if port_id:
        filters['port'] = port_id
    
    attendances = Attendance.objects.filter(**filters)
    attendance_data = []
    for attendance in attendances:
        attendance_data.append(attendance_object(attendance))
    return JsonResponse(attendance_data, safe=False)
