from django.shortcuts import render

from rest_framework.response import Response
from .models import Category, CustomUser, Cours, Exercice, Eleve
from .serializers import CategorySerializer, RegisterSerializer, UserSerializer, LoginSerializer, CoursSerializer, ExerciceSerializer, EleveSerializer
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from django.contrib.auth.models import User
from django.contrib.auth import authenticate, get_user_model, login
from django.http import JsonResponse
import json
from rest_framework.generics import CreateAPIView
from rest_framework.authtoken.models import Token
from django.contrib.auth import authenticate
from rest_framework.views import APIView
from rest_framework import generics, permissions, viewsets, status
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
        'email': user.email,
    })


class RegisterView(generics.CreateAPIView):
    queryset = CustomUser.objects.all()
    serializer_class = RegisterSerializer

    def create(self, request, *args, **kwargs):
        print("Données reçues :", request.data)
        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save() #Modification ici.
            token, created = Token.objects.get_or_create(user=user)
            response_data = serializer.data
            response_data['token'] = token.key
            return Response(response_data, status=status.HTTP_201_CREATED)
        else:
            print("Erreurs du serializer :", serializer.errors)
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)



class LoginView(APIView):
    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        if serializer.is_valid():
            email = serializer.validated_data['email']
            password = serializer.validated_data['password']
            user = authenticate(request, username=email, password=password)
            if user:
                token, created = Token.objects.get_or_create(user=user)
                return Response({'token': token.key, 'role': user.role}, status=status.HTTP_200_OK)
            else:
                return Response({'message': 'Email ou mot de passe incorrect'}, status=status.HTTP_401_UNAUTHORIZED)
        else:
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)



class IsAdminOrEnseignant(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user.is_authenticated and (request.user.is_staff or request.user.role == 'admin')

class UserListView(generics.ListAPIView):
    queryset = CustomUser.objects.all()
    serializer_class = UserSerializer
    permission_classes = [IsAdminOrEnseignant]

class UserUpdateView(generics.UpdateAPIView):
    queryset = CustomUser.objects.all()
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAdminUser]

class UserDeleteView(generics.DestroyAPIView):
    queryset = CustomUser.objects.all()
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAdminUser]

from rest_framework import viewsets, permissions

class CoursViewSet(viewsets.ModelViewSet):
    serializer_class = CoursSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.is_staff:  # Admins voient tous les cours
            return Cours.objects.all()
        return Cours.objects.filter(enseignant=user)  # Enseignants voient leurs propres cours

    def perform_create(self, serializer):
        serializer.save(enseignant=self.request.user)  # Associer le cours à l'enseignant connecté

class ExerciceViewSet(viewsets.ModelViewSet):
    serializer_class = ExerciceSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Exercice.objects.all()

class TeacherCourseListView(generics.ListAPIView):
    serializer_class = CoursSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        teacher = self.request.user
        return Cours.objects.filter(enseignant=teacher) # Modification ici



class TeacherExerciseListView(generics.ListAPIView):
    serializer_class = ExerciceSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        teacher = self.request.user
        return Exercice.objects.filter(enseignant=teacher) # Modification ici

# core/views.py
class TeacherExerciseListView(generics.ListAPIView):
    serializer_class = ExerciceSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        teacher = self.request.user
        return Exercice.objects.filter(cours__enseignant=teacher) #Modify here

class TeacherStudentListView(generics.ListAPIView):
    serializer_class = EleveSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        teacher = self.request.user
        return Eleve.objects.filter(enseignant=teacher)


class TeacherCourseCreateView(generics.CreateAPIView):
    serializer_class = CoursSerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        serializer.save(enseignant=self.request.user)

class TeacherCourseDeleteView(generics.DestroyAPIView):
    queryset = Cours.objects.all()
    serializer_class = CoursSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Cours.objects.filter(enseignant=self.request.user)

class TeacherExerciseCreateView(generics.CreateAPIView):
    serializer_class = ExerciceSerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        serializer.save(cours__enseignant=self.request.user) #change here, if needed.

class TeacherExerciseDeleteView(generics.DestroyAPIView):
    queryset = Exercice.objects.all()
    serializer_class = ExerciceSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Exercice.objects.filter(enseigant=self.request.user)


