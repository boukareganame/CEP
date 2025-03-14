from django.shortcuts import render

from rest_framework.response import Response
from .models import Category, CustomUser, Cours, Exercice, Eleve, Module, Lecon, Quiz, Question, Notification
from .serializers import CategorySerializer, RegisterSerializer, UserSerializer, LoginSerializer, CoursSerializer, ExerciceSerializer, EleveSerializer, ModuleSerializer, LeconSerializer, QuizSerializer, QuestionSerializer, NotificationSerializer
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from django.contrib.auth.models import User
from django.contrib.auth import authenticate, get_user_model, login
from django.http import JsonResponse
import json
from rest_framework.generics import CreateAPIView
from rest_framework.authtoken.models import Token
from rest_framework.views import APIView
from rest_framework import generics, permissions, viewsets, status, filters
from django_filters.rest_framework import DjangoFilterBackend


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
                return Response({
                    'token': token.key,
                    'role': user.role,
                    'id': user.id
                }, status=status.HTTP_200_OK)
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


class CoursViewSet(viewsets.ModelViewSet):
    serializer_class = CoursSerializer
    permission_classes = [permissions.IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter]
    filterset_fields = ['module']
    search_fields = ['titre', 'description']

    def get_queryset(self):
        user = self.request.user
        if user.is_staff:
            return Cours.objects.all()
        return Cours.objects.filter(enseignant=user)

    def perform_create(self, serializer):
        serializer.save(enseignant=self.request.user)


class ExerciceViewSet(viewsets.ModelViewSet):
    serializer_class = ExerciceSerializer
    permission_classes = [permissions.IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter]
    filterset_fields = ['cours__module']
    search_fields = ['titre', 'description']

    def get_queryset(self):
        user = self.request.user
        if user.is_staff:
            return Exercice.objects.all()
        return Exercice.objects.filter(cours__enseignant=user)

    def perform_create(self, serializer):
        serializer.save(cours__enseignant=self.request.user)



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
        serializer.save(cours__enseignant=self.request.user)

class TeacherExerciseDeleteView(generics.DestroyAPIView):
    queryset = Exercice.objects.all()
    serializer_class = ExerciceSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Exercice.objects.filter(enseigant=self.request.user)


class CoursListView(generics.ListAPIView):
    queryset = Cours.objects.all()
    serializer_class = CoursSerializer
    permission_classes = [permissions.AllowAny]

class CoursDetailView(generics.RetrieveAPIView):
    queryset = Cours.objects.all()
    serializer_class = CoursSerializer
    permission_classes = [permissions.AllowAny]

class ModuleDetailView(generics.RetrieveAPIView):
    queryset = Module.objects.all()
    serializer_class = ModuleSerializer
    permission_classes = [permissions.AllowAny]

class LeconDetailView(generics.RetrieveAPIView):
    queryset = Lecon.objects.all()
    serializer_class = LeconSerializer
    permission_classes = [permissions.AllowAny]


class QuizDetailView(generics.RetrieveAPIView):
    queryset = Quiz.objects.all()
    serializer_class = QuizSerializer
    permission_classes = [permissions.AllowAny]

class QuestionDetailView(generics.RetrieveAPIView):
    queryset = Question.objects.all()
    serializer_class = QuestionSerializer
    permission_classes = [permissions.AllowAny]



class ModuleList(generics.ListAPIView):
    queryset = Module.objects.all()
    serializer_class = ModuleSerializer

class ModuleCreate(generics.CreateAPIView):
    queryset = Module.objects.all()
    serializer_class = ModuleSerializer

class NotificationViewSet(viewsets.ModelViewSet):
    serializer_class = NotificationSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Notification.objects.filter(user=self.request.user).order_by('-timestamp')

class MarkNotificationAsRead(generics.UpdateAPIView):
    queryset = Notification.objects.all()
    serializer_class = NotificationSerializer
    permission_classes = [permissions.IsAuthenticated]

    def partial_update(self, request, *args, **kwargs):
        instance = self.get_object()
        instance.is_read = True
        instance.save()
        return self.retrieve(request, *args, **kwargs)