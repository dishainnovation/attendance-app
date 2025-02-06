from django.contrib.auth.models import AbstractUser
from django.db import models

class Employee(models.Model):
    user_id = models.CharField(max_length=255)
    name = models.CharField(max_length=100)
    email = models.EmailField(unique=True)
    phone = models.CharField(max_length=20, blank=True, null=True)
    address = models.CharField(max_length=255, blank=True, null=True)
    hire_date = models.DateTimeField()
    password = models.CharField(max_length=255)
    role_choices = [
        ('Administrator', 'Administrator'),
        ('Operator', 'Operator'),
        ('Engineer', 'Engineer'),
    ]
    role = models.CharField(max_length=20, choices=role_choices)
    profile_image = models.ImageField(upload_to='profile_images/', blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

class PreventiveMaintenance(models.Model):
    user = models.ForeignKey(Employee, on_delete=models.CASCADE)
    device_id = models.CharField(max_length=100)
    before_photo = models.ImageField(upload_to='before_photos/')
    after_photo = models.ImageField(upload_to='after_photos/')
    maintenance_date = models.DateTimeField()
    description = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

class Port(models.Model):
    name = models.CharField(max_length=100)
    location = models.CharField(max_length=200)
    description = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

class Terminal(models.Model):
    port = models.ForeignKey(Port, on_delete=models.CASCADE)
    name = models.CharField(max_length=100)
    latitude = models.FloatField(null=True, blank=True)
    longitude = models.FloatField(null=True, blank=True)
    geofence_area = models.IntegerField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

class Shift(models.Model):
    name = models.CharField(max_length=100)
    start_time = models.TimeField()
    end_time = models.TimeField()
    duration_hours = models.IntegerField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

class Attendance(models.Model):
    user = models.ForeignKey(Employee, on_delete=models.CASCADE)
    terminal = models.ForeignKey(Terminal, on_delete=models.SET_NULL, null=True, blank=True)
    shift = models.ForeignKey(Shift, on_delete=models.CASCADE)
    sign_in_time = models.DateTimeField()
    sign_out_time = models.DateTimeField(null=True, blank=True)
    location_coordinates = models.TextField()
    sign_in_photo = models.ImageField(upload_to='sign_in_photos/')
    sign_out_photo = models.ImageField(upload_to='sign_out_photos/', blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)