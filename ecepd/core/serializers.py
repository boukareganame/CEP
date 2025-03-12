from rest_framework import serializers
from .models import Category, CustomUser, Cours, Exercice, Eleve, Module, Lecon, Quiz, Question
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
    class Meta:
        model = CustomUser #Modification ici
        fields = ['id', 'email', 'role'] #Modification ici


class ExerciceSerializer(serializers.ModelSerializer):
    class Meta:
        model = Exercice
        fields = '__all__'

class EleveSerializer(serializers.ModelSerializer):
    class Meta:
        model = Eleve
        fields = '_all_'

# core/serializers.py

class LeconSerializer(serializers.ModelSerializer):
    class Meta:
        model = Lecon
        fields = '__all__'

class ModuleSerializer(serializers.ModelSerializer):
    lecons = LeconSerializer(many=True, read_only=True)

    class Meta:
        model = Module
        fields = '__all__'

class CoursSerializer(serializers.ModelSerializer):
    modules = ModuleSerializer(many=True, read_only=True)

    class Meta:
        model = Cours
        fields = '__all__'


class QuestionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Question
        fields = '__all__'

class QuizSerializer(serializers.ModelSerializer):
    questions = QuestionSerializer(many=True, read_only=True)

    class Meta:
        model = Quiz
        fields = '__all__'