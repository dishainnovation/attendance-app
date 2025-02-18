from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import viewsets
from .models import Shift
from .serializers import ShiftSerializer
from django.db.models.deletion import ProtectedError

class ShiftViewSet(viewsets.ModelViewSet):
    serializer_class = ShiftSerializer
    def get_queryset(self):
        queryset = Shift.objects.all()
        port_id = self.request.query_params.get('port_id', None)
        shift_id = self.request.query_params.get('id', None)
        if shift_id:
            try:
                shift_id = int(shift_id)
                queryset = queryset.filter(id=shift_id)
            except ValueError:
                pass
        if port_id:
            try:
                port_id = int(port_id)
                queryset = queryset.filter(port__id=port_id)
            except ValueError:
                pass
        return queryset
    def destroy(self, request, *args, **kwargs):
        instance = self.get_object()
        try:
            self.perform_destroy(instance)
        except ProtectedError:
            return Response({'error': 'Cannot delete this Shift because it is referenced in Attendance.'}, status=status.HTTP_400_BAD_REQUEST)
        return Response(status=status.HTTP_204_NO_CONTENT)
    
@api_view(['GET'])
def shift_view(request):
    if request.method == 'GET':
        try:
            id = request.GET.get('id')
            shift = Shift.objects.get(id=id)
        except Shift.DoesNotExist:
            return Response(status=status.HTTP_404_NOT_FOUND)
        
        if shift is not None:
            return Response(shift, safe=False)
           
        else:
            return Response({'error': 'Invalid credentials'}, status=status.HTTP_400_BAD_REQUEST)