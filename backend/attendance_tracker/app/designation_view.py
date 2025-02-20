from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.response import Response
from django.shortcuts import render, get_object_or_404
from django.db.models.deletion import ProtectedError
from .models import Designation
from .serializers import DesignationSerializer

@api_view(['GET', 'POST', 'PUT', 'DELETE'])
def designation_list(request):
    if request.method == 'GET':
        ports = Designation.objects.all().order_by('name')
        serializer = DesignationSerializer(ports, many=True)
        return Response(serializer.data)

    elif request.method == 'POST':
        serializer = DesignationSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    elif request.method == 'PUT':
        try:
            id = request.GET.get('id')
            designation = Designation.objects.get(id=id)
        except Designation.DoesNotExist:
            return Response(status=status.HTTP_404_NOT_FOUND)
        serializer = DesignationSerializer(designation, data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    elif request.method == 'DELETE':
        try:
            id = request.GET.get('id')
            designation = Designation.objects.get(id=id)
        except Designation.DoesNotExist:
            return Response(status=status.HTTP_404_NOT_FOUND)
        try:
            designation.delete()
            return Response(status=status.HTTP_204_NO_CONTENT)
        except ProtectedError as e:
            referenced_objects = [str(obj) for obj in e.protected_objects]
            error_message = f"Cannot delete Designation '{designation.name}' because it is referenced by the following employees: {', '.join(referenced_objects)}. Please reassign or remove these references before attempting to delete."
            return Response(status=status.HTTP_400_BAD_REQUEST, data={'error_message': error_message})
