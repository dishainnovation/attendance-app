# Generated by Django 4.1 on 2025-02-22 10:16

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('app', '0001_initial'),
    ]

    operations = [
        migrations.RenameField(
            model_name='attendance',
            old_name='latitude',
            new_name='check_in_latitude',
        ),
        migrations.RenameField(
            model_name='attendance',
            old_name='longitude',
            new_name='check_in_longitude',
        ),
        migrations.AddField(
            model_name='attendance',
            name='check_out_latitude',
            field=models.FloatField(blank=True, null=True),
        ),
        migrations.AddField(
            model_name='attendance',
            name='check_out_longitude',
            field=models.FloatField(blank=True, null=True),
        ),
        migrations.AlterField(
            model_name='designation',
            name='user_type',
            field=models.CharField(default='OPERATOR', max_length=100),
        ),
    ]
