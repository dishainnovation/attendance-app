from rest_framework import viewsets
from rest_framework.response import Response
from rest_framework import status
from rest_framework.decorators import api_view
from .models import AppUser
from .serializers import UserSerializer

class UserViewSet(viewsets.ModelViewSet):
    queryset = AppUser.objects.all()
    serializer_class = UserSerializer
@api_view(['GET'])
def login_view(request):
    if request.method == 'GET':
        user_id = request.GET.get('user_id')
        password = request.GET.get('password')
        print(user_id, password)
        # Authenticate the user
        user = AppUser.objects.filter(user_id=user_id, password=password).first()
        
        if user is not None:
            serializer = UserSerializer(user)
            return Response(serializer.data, status=status.HTTP_200_OK)
        else:
            return Response({'error': 'Invalid credentials'}, status=status.HTTP_400_BAD_REQUEST)
    
