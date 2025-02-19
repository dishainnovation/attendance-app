import pandas as pd
from django.core.management.base import BaseCommand

from app.models import Designation, Employee, Port, Shift, Site

class Command(BaseCommand):
    help = 'Import data from an Excel file into the database'

    def handle(self, *args, **kwargs):
        # Path to your Excel file
        
        excel_file = 'data.xlsx'

        # Read the Excel file into a dictionary of DataFrames, one per sheet
        sheets = pd.read_excel(excel_file, sheet_name=None, engine='openpyxl')

        # Process each sheet individually
        for sheet_name, df in sheets.items():
            self.stdout.write(f'Processing sheet: {sheet_name}')

            if sheet_name == 'Designations':
                for index, row in df.iterrows():
                    print(row)
                    designation, created = Designation.objects.get_or_create(
                        name=row['name'],
                        defaults={
                            'user_type': row['user_type'],
                            'remote_checkin': row['remote_checkin']
                        }
                    )
            elif sheet_name == 'Ports':
                for index, row in df.iterrows():
                    print(row)
                    port, created = Port.objects.get_or_create(
                        name=row['name'],
                        defaults={
                            'location': row['location']
                        }
                    )
            elif sheet_name == 'Employees':
                for index, row in df.iterrows():
                    print(row)
                    designation = Designation.objects.get(name=row['designation'])
                    port = Port.objects.get(name=row['port'])
                    Employee.objects.get_or_create(
                        employee_code=row['employee_code'],
                        defaults={
                            'name': row['name'],
                            'gender': row['gender'],
                            'date_of_birth': row['date_of_birth'],
                            'designation': designation,
                            'date_of_joining': row['date_of_joining'],
                            'mobile_number': row['mobile_number'],
                            'password': row['password'],
                            'port': port
                        }
                    )
            elif sheet_name == 'Shifts':
                for index, row in df.iterrows():
                    print(row)
                    port = Port.objects.get(name=row['port'])
                    Shift.objects.get_or_create(
                        port=port,
                        name=row['name'],
                        defaults={
                            'start_time': row['start_time'],
                            'end_time': row['end_time'],
                            'duration_hours': row['duration_hours']
                        }
                    )
            elif sheet_name == 'Terminals':
                for index, row in df.iterrows():
                    print(row)
                    port = Port.objects.get(name=row['port'])
                    Site.objects.get_or_create(
                        port=port,
                        name=row['name'],
                        defaults={
                            'latitude': row['latitude'],
                            'longitude': row['longitude'],
                            'geofence_area': row['geofence_area']
                        }
                    )
            else:
                self.stdout.write(f'Skipping unknown sheet: {sheet_name}')


        self.stdout.write(self.style.SUCCESS('Data imported successfully'))
