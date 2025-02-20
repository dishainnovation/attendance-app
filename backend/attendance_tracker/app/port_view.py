from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.response import Response
from django.db.models.deletion import ProtectedError
from .models import Port, Port
from .serializers import PortSerializer

@api_view(['GET', 'POST', 'PUT', 'DELETE'])
def port_list(request):
    if request.method == 'GET':
        ports = Port.objects.all().order_by('name')
        serializer = PortSerializer(ports, many=True)
        return Response(serializer.data)

    elif request.method == 'POST':
        serializer = PortSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    elif request.method == 'PUT':
        id = request.GET.get('id')
        port = Port.objects.get(id=id)
        serializer = PortSerializer(port, data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    elif request.method == 'DELETE':
        id = request.GET.get('id')
        port = Port.objects.get(id=id)
        try:
            port.delete()
            return Response(status=status.HTTP_204_NO_CONTENT)
        except ProtectedError as e:
            error_message = f"Cannot delete Port '{port.name}' because it has associated records. Please remove those records before attempting to delete."
            return Response(status=status.HTTP_400_BAD_REQUEST, data={'error_message': error_message})
