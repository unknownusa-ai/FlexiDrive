from rest_framework import serializers


class RegisterSerializer(serializers.Serializer):
    tipo_identificacion_id = serializers.IntegerField(min_value=1)
    nombre_completo = serializers.CharField(max_length=180)
    numero_identificacion = serializers.CharField(max_length=50)
    correo = serializers.EmailField(max_length=254)
    telefono = serializers.CharField(max_length=40)
    contrasena = serializers.CharField(min_length=8, write_only=True)


class LoginSerializer(serializers.Serializer):
    correo = serializers.EmailField(max_length=254)
    contrasena = serializers.CharField(write_only=True)
