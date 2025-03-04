from django.shortcuts import render

from rest_framework.response import Response
from .models import Category, CustomUser
from .serializers import CategorySerializer, RegisterSerializer, UserSerializer, LoginSerializer
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from django.contrib.auth.models import User
from django.contrib.auth import authenticate, get_user_model, login
from django.http import JsonResponse
import json
from rest_framework.generics import CreateAPIView
from rest_framework import generics, permissions
from rest_framework.authtoken.models import Token
from rest_framework import status
from django.contrib.auth import authenticate
from rest_framework.views import APIView
# Create your views here.

User = get_user_model()

@api_view(['GET'])
def category_list(request):
    categories = Category.objects.all()
    serializer = CategorySerializer(categories, many=True)
    return Response(serializer.data)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def user_profile(request):
    user = request.user
    return Response({
        'id': user.id,
        'username': user.username,
        'email': user.email,
    })


class RegisterView(CreateAPIView):
    queryset = User.objects.all()
    serializer_class = RegisterSerializer

    def create(self, request, *args, **kwargs):
        print("Données reçues :", request.data)
        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            self.perform_create(serializer)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        else:
            print("Erreurs du serializer :", serializer.errors)  # ✅ Affiche les erreurs
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        response = super().create(request, *args, **kwargs)
        user = User.objects.get(username=request.data["username"])
        token, created = Token.objects.get_or_create(user=user)
        response.data["token"] = token.key  # Ajoute le token à la réponse
        return response



class LoginView(APIView):
    def post(self, request):
        print("Données reçues:", json.dumps(request.data, indent=4))  # 🟢 Ajoute ceci pour voir les données reçues

        serializer = LoginSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.validated_data["user"]
            login(request, user)
            return Response({"message": "Connexion réussie"}, status=status.HTTP_200_OK)
        
        print("Erreurs de validation:", serializer.errors)  # 🟠 Afficher les erreurs du serializer
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class UserListView(generics.ListAPIView):
    queryset = CustomUser.objects.all()
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAdminUser]  # Accessible seulement aux admins

class UserUpdateView(generics.UpdateAPIView):
    queryset = CustomUser.objects.all()
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAdminUser]

class UserDeleteView(generics.DestroyAPIView):
    queryset = CustomUser.objects.all()
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAdminUser]
