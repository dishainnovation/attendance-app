from django.contrib.auth.models import AbstractUser
from django.db import models

class AppUser(models.Model):
    user_id = models.AutoField(primary_key=True)
    name = models.CharField(max_length=100)
    email = models.EmailField(unique=True)
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
