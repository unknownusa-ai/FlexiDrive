from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.accounts.domain.models import IdentificationType


class IdentificationTypeListView(APIView):
    """API endpoint para listar tipos de identificación"""
    
    authentication_classes = []
    permission_classes = []
    
    def get(self, request):
        """Retorna lista de tipos de identificación disponibles"""
        identification_types = IdentificationType.objects.all().order_by('id')
        
        data = [
            {
                'id': ident_type.id,
                'name': ident_type.name,
            }
            for ident_type in identification_types
        ]
        
        return Response(data, status=status.HTTP_200_OK)
