from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.response import Response
from django.http import JsonResponse
from .models import Attendance, Employee, Shift, Site
from .serializers import AttendanceSerializer
import face_recognition
from PIL import Image, ExifTags
import io
import numpy as np

@api_view(['GET', 'POST', 'PUT', 'DELETE'])
def attendance_list(request):
    if request.method == 'GET':
        ports = Attendance.objects.all()
        employee = request.GET.get('employee')
        date = request.GET.get('date')
        if(employee is not None and date is not None):
            attendance_records = Attendance.objects.filter(employee=employee,attendance_date=date)
            attendance_data = []
            for att in attendance_records:
                attendance_data.append(attendance_object(att))
                
            print(attendance_data)
            return JsonResponse(attendance_data, safe=False)

        serializer = AttendanceSerializer(ports, many=True)
        return Response(serializer.data)

    elif request.method == 'POST':
        try:
            employee_id = request.data['employee_id']
            employee = Employee.objects.get(id=employee_id)
            print(employee_id)
            user_image = request.FILES.get('user_photo')
            match = compare(user_image, employee.profile_image)

            if match['match']:
                attendance = Attendance(
                    attendance_date = request.data['attendance_date'],
                    employee = employee,
                    site = Site.objects.get(id = request.data['site_id']),
                    shift = Shift.objects.get(id=request.data['shift_id']),
                    check_in_time = request.data['check_in_time'],
                    check_out_time = None,
                    latitude = request.data['latitude'],
                    longitude = request.data['longitude'],
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
        print(employee)
        user_image = request.FILES.get('user_photo')
        match = compare(user_image, employee.profile_image)

        if match['match']:
            attendance.attendance_date = request.data['attendance_date']
            attendance.employee = employee
            attendance.site = Site.objects.get(id = request.data['site_id'])
            attendance.shift = Shift.objects.get(id=request.data['shift_id'])
            attendance.check_out_time = request.data['check_in_time']
            attendance.latitude = request.data['latitude']
            attendance.longitude = request.data['longitude']
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
    file1 = image1
    file2 = image2

    try:
        # Read image files
        image1 = Image.open(io.BytesIO(file1.read()))
        image2 = Image.open(io.BytesIO(file2.read()))

        # Correct orientation
        image1 = correct_image_orientation(image1)
        image2 = correct_image_orientation(image2)

        # Convert images to numpy arrays
        image1 = np.array(image1)
        image2 = np.array(image2)

        encodings1 = face_recognition.face_encodings(image1)
        encodings2 = face_recognition.face_encodings(image2)

        if len(encodings1) == 0 or len(encodings2) == 0:
            return {'match': False}

        result = face_recognition.compare_faces([encodings1[0]], encodings2[0])
        return {'match': bool(result[0])}  # Ensure the boolean value is serialized correctly
    except Exception as e:
        return {'match': False}, 500
    
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
        'employee': attendance.employee.name,
        'site': attendance.site.name,
        'shift': attendance.shift.name,
        'check_in_time': attendance.check_in_time,
        'check_out_time': attendance.check_out_time,
        'latitude': attendance.latitude,
        'longitude': attendance.longitude,
        'check_in_photo': attendance.check_in_photo.url,
        'check_out_photo': check_out_photo,
        'attendance_type': attendance.attendance_type,
        'created_at': attendance.created_at,
        'updated_at': attendance.updated_at,
    }