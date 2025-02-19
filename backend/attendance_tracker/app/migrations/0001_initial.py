# Generated by Django 4.1 on 2025-02-19 09:34

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    initial = True

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='Designation',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=100)),
                ('user_type', models.CharField(default='USER', max_length=100)),
                ('remote_checkin', models.BooleanField(default=False)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
            ],
        ),
        migrations.CreateModel(
            name='Port',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=100)),
                ('location', models.CharField(max_length=200)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
            ],
        ),
        migrations.CreateModel(
            name='Site',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=100)),
                ('latitude', models.FloatField(blank=True, null=True)),
                ('longitude', models.FloatField(blank=True, null=True)),
                ('geofence_area', models.IntegerField(blank=True, null=True)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('port', models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, to='app.port')),
            ],
        ),
        migrations.CreateModel(
            name='Shift',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=100)),
                ('start_time', models.TimeField()),
                ('end_time', models.TimeField()),
                ('duration_hours', models.IntegerField()),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('port', models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, to='app.port')),
            ],
        ),
        migrations.CreateModel(
            name='Employee',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('employee_code', models.CharField(max_length=50)),
                ('name', models.CharField(max_length=100)),
                ('gender', models.CharField(max_length=10)),
                ('date_of_birth', models.DateField()),
                ('date_of_joining', models.DateField()),
                ('mobile_number', models.CharField(blank=True, max_length=20, null=True)),
                ('password', models.CharField(max_length=255)),
                ('profile_image', models.ImageField(blank=True, null=True, upload_to='profile_images/')),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('designation', models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, to='app.designation')),
                ('port', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, to='app.port')),
            ],
        ),
        migrations.CreateModel(
            name='Attendance',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('attendance_date', models.DateField(default=None)),
                ('check_in_time', models.DateTimeField()),
                ('check_out_time', models.DateTimeField(blank=True, null=True)),
                ('latitude', models.FloatField(blank=True, null=True)),
                ('longitude', models.FloatField(blank=True, null=True)),
                ('check_in_photo', models.ImageField(upload_to='check_in_photo/')),
                ('check_out_photo', models.ImageField(blank=True, null=True, upload_to='check_out_photo/')),
                ('attendance_type', models.CharField(default='REGULAR', max_length=20)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('employee', models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, to='app.employee')),
                ('port', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, to='app.port')),
                ('shift', models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, to='app.shift')),
            ],
        ),
    ]
