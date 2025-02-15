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

- Create a superuser to access the Django admin interface:

```bash
python manage.py createsuperuser
```

## License

This project is licensed under the MIT License.
