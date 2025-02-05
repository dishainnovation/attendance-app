from django.db import models
from users.models import AppUser

class PreventiveMaintenance(models.Model):
    user = models.ForeignKey(AppUser, on_delete=models.CASCADE)
    device_id = models.CharField(max_length=100)
    before_photo = models.ImageField(upload_to='before_photos/')
    after_photo = models.ImageField(upload_to='after_photos/')
    maintenance_date = models.DateTimeField()
    description = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
