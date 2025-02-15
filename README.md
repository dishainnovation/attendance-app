# Attendance App

This is an attendance tracking application built with Django.

## Installation

Follow these steps to set up and run the project in your local environment.

### Prerequisites

- Python 3.8+
- pip (Python package installer)
- Virtualenv (optional but recommended)

### Setting Up the Virtual Environment

It is recommended to use a virtual environment to isolate the dependencies of this project. You can create and activate a virtual environment using the following commands:

```bash
# Install virtualenv if you don't have it
pip install virtualenv

# Create a virtual environment
virtualenv venv

# Activate the virtual environment
# On Windows
venv\Scripts\activate
# On Unix or MacOS
source venv/bin/activate
```

### Installing Dependencies

Once the virtual environment is activated, navigate to the `backend/attendance_tracker` directory and install the required dependencies using `requirements.txt`:

```bash
cd backend/attendance_tracker
pip install -r requirements.txt
```

### Managing Database Connection

To manage the database connection, follow these steps:

1. **Configure the Database Settings:**

   Open the `settings.py` file in the Django project directory (`backend/attendance_tracker/attendance_tracker`). Locate the `DATABASES` section and configure it according to your database setup. For example:

   ```python
   DATABASES = {
       'default': {
           'ENGINE': 'django.db.backends.postgresql',  # Use 'django.db.backends.sqlite3' for SQLite
           'NAME': 'your_database_name',
           'USER': 'your_database_user',
           'PASSWORD': 'your_database_password',
           'HOST': 'your_database_host',  # Set to 'localhost' if the database is on the same machine
           'PORT': 'your_database_port',  # Default is '5432' for PostgreSQL
       }
   }
   ```

2. **Apply Migrations:**

   After configuring the database settings, apply the migrations to create the necessary database tables.

   ```bash
   python manage.py migrate
   ```

3. **Create a Superuser:**

   Create a superuser to access the Django admin interface.

   ```bash
   python manage.py createsuperuser
   ```

### Running the Project

To run the Django project, navigate to the project directory (where `manage.py` is located) and use the following command:

```bash
python manage.py runserver
```

The application will be available at `http://127.0.0.1:8000/`.

### Deactivating the Virtual Environment

After you are done working on the project, you can deactivate the virtual environment using the following command:

```bash
deactivate
```

## Additional Notes

- Ensure that your database is set up and configured correctly in `settings.py`.
- Migrate the database using the following command if it's the first time you are running the project:

```bash
python manage.py migrate
```

- Create a superuser to access the Django admin ▋
