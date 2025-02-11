from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.response import Response
from .models import Designation
from .serializers import DesignationSerializer

@api_view(['GET', 'POST', 'PUT', 'DELETE'])
def designation_list(request):
    if request.method == 'GET':
        ports = Designation.objects.all()
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
        designation.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)
