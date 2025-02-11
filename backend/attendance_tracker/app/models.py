from django.db import models

class Designation(models.Model):
    name = models.CharField(max_length=100)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

class Port(models.Model):
    name = models.CharField(max_length=100)
    location = models.CharField(max_length=200)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
class Employee(models.Model):
    employee_code = models.CharField(max_length=50)
    name = models.CharField(max_length=100)
    gender = models.CharField(max_length=10)
    date_of_birth = models.DateField()
    designation = models.CharField(max_length=255)
    date_of_joining = models.DateField()
    mobile_number = models.CharField(max_length=20, blank=True, null=True)
    password = models.CharField(max_length=255)
    designation = models.ForeignKey(Designation, on_delete=models.CASCADE)
    profile_image = models.ImageField(upload_to='profile_images/', blank=True, null=True)
    port = models.ForeignKey(Port, on_delete=models.SET_NULL, null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.name
    
    def to_dict(self):
        return {
            'id': self.id,
            'profile_image': self.profile_image.url if self.profile_image else None,
            'employee_code': self.employee_code,
            'name': self.name,
            'mobile_number': self.mobile_number,
            'gender': self.gender,
            'password': self.password,
            'designation': self.designation.id,
            'date_of_birth': self.date_of_birth,
            'date_of_joining': self.date_of_joining,
            'port': self.port.id,
            'port_name': self.port.name
        }


class Site(models.Model):
    port = models.ForeignKey(Port, on_delete=models.CASCADE)
    name = models.CharField(max_length=100)
    latitude = models.FloatField(null=True, blank=True)
    longitude = models.FloatField(null=True, blank=True)
    geofence_area = models.IntegerField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

class Shift(models.Model):
    port = models.ForeignKey(Port, on_delete=models.CASCADE)
    name = models.CharField(max_length=100)
    start_time = models.TimeField()
    end_time = models.TimeField()
    duration_hours = models.IntegerField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

class Attendance(models.Model):
    employee = models.ForeignKey(Employee, on_delete=models.CASCADE)
    site = models.ForeignKey(Site, on_delete=models.SET_NULL, null=True, blank=True)
    shift = models.ForeignKey(Shift, on_delete=models.CASCADE)
    check_in_time = models.DateTimeField()
    check_out_time = models.DateTimeField(null=True, blank=True)
    latitude = models.FloatField(null=True, blank=True)
    longitude = models.FloatField(null=True, blank=True)
    check_in_photo = models.ImageField(upload_to='check_in_photo/')
    check_out_photo = models.ImageField(upload_to='check_out_photo/', blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)