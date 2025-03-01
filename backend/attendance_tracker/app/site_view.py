from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework import viewsets
from rest_framework.response import Response
from .models import Site
from .serializers import SiteSerializer
class SiteViewSet(viewsets.ModelViewSet):
    serializer_class = SiteSerializer
    def get_queryset(self):
        queryset = Site.objects.all().order_by('name')
        port_id = self.request.query_params.get('port_id', None)
        site_id = self.request.query_params.get('id', None)
        if site_id:
            try:
                site_id = int(site_id)
                queryset = queryset.filter(id=site_id)
            except ValueError:
                pass
        if port_id:
            try:
                port_id = int(port_id)
                queryset = queryset.filter(port__id=port_id)
            except ValueError:
                pass
        return queryset
    
