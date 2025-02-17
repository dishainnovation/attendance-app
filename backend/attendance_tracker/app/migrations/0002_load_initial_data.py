from django.utils import timezone
from django.db import migrations

def load_initial_data(apps, schema_editor):
    Designation = apps.get_model('app', 'Designation')
    # Add initial data here
    default_designation = Designation.objects.create(name='Super Admin', user_type='SUPER_ADMIN', remote_checkin=True)
    Designation.objects.create(name='Admin', user_type='ADMIN', remote_checkin=False)
    Designation.objects.create(name='Engineer', user_type='SUPERVISOR', remote_checkin=True)
    Designation.objects.create(name='Operator', user_type='USER', remote_checkin=False)

    Port = apps.get_model('app', 'Port')
    Employee = apps.get_model('app', 'Employee')

    # Create a default Port entry
    default_port = Port.objects.create(name='JNPT', location='Mumbai')

    # Create a default Employee entry
    Employee.objects.create(
        employee_code='admin',
        name='Admin',
        gender='Male',
        date_of_birth=timezone.now().date(),
        designation=default_designation,
        date_of_joining=timezone.now().date(),
        mobile_number='1234567890',
        password='admin',
        profile_image=None,
        port=default_port
    )

class Migration(migrations.Migration):
    dependencies = [
        ('app', '0001_initial'),  # Replace with the actual previous migration name
    ]

    operations = [
        migrations.RunPython(load_initial_data),
    ]
