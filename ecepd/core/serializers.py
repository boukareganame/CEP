from rest_framework import serializers
from .models import Category, CustomUser
from django.contrib.auth import get_user_model
from rest_framework.authtoken.models import Token
from django.contrib.auth import authenticate

User = get_user_model()

class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = '__all__'


class RegisterSerializer(serializers.ModelSerializer):
    class Meta:
        model = CustomUser  # Utiliser CustomUser
        fields = ('id', 'email', 'password', 'role') #Modification ici
        extra_kwargs = {'password': {'write_only': True}}

    def create(self, validated_data):
        password = validated_data.pop('password', None)
        instance = self.Meta.model(**validated_data)
        if password is not None:
            instance.set_password(password)
        instance.save()
        return instance

class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)

class UserSerializer(serializers.ModelSerializer):
    role = serializers.CharField(source='role', read_only=True) #Modification ici

    class Meta:
        model = CustomUser #Modification ici
        fields = ['id', 'email', 'role'] #Modification ici