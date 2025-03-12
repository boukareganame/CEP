from django.db import models
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
from django.conf import settings

# Create your models here.

class Category(models.Model):
    title = models.CharField(max_length=100)
    icon = models.CharField(max_length=50)
    route = models.CharField(max_length=100)

    def __str__(self):
        return self.title


class CustomUserManager(BaseUserManager):
    def create_user(self, email, password=None, **extra_fields):
        if not email:
            raise ValueError('L\'email doit être défini')
        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        return self.create_user(email, password, **extra_fields)

class CustomUser(AbstractBaseUser, PermissionsMixin):
    ROLE_ELEVE = 'eleve'
    ROLE_ENSEIGNANT = 'enseignant'
    ROLE_PARENT = 'parent'
    ROLE_ADMIN = 'admin'

    ROLE_CHOICES = [
        (ROLE_ELEVE, 'Élève'),
        (ROLE_ENSEIGNANT, 'Enseignant'),
        (ROLE_PARENT, 'Parent'),
        (ROLE_ADMIN, 'Administrateur'),
    ]

    email = models.EmailField(unique=True)
    role = models.CharField(max_length=20, choices=ROLE_CHOICES, default=ROLE_ELEVE) # Ajout du champ role
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)
    date_joined = models.DateTimeField(auto_now_add=True)

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['role'] # Ajout de role aux champs requis

    objects = CustomUserManager()

    def __str__(self):
        return self.email



class Cours(models.Model):
    titre = models.CharField(max_length=255)
    description = models.TextField()
    enseignant = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    date_creation = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.titre

class Exercice(models.Model):
    titre = models.CharField(max_length=255)
    contenu = models.TextField()
    cours = models.ForeignKey(Cours, on_delete=models.CASCADE, related_name="exercices")
    date_creation = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.titre

class Eleve(models.Model):
    enseignant = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    nom = models.CharField(max_length=100)
    email = models.EmailField()

# core/models.py
from django.db import models
from django.conf import settings

class Module(models.Model):
    titre = models.CharField(max_length=255)
    description = models.TextField(blank=True, null=True)
    cours = models.ForeignKey('Cours', on_delete=models.CASCADE, related_name='modules')

    def __str__(self):
        return self.titre

class Lecon(models.Model):
    titre = models.CharField(max_length=255)
    description = models.TextField(blank=True, null=True)
    module = models.ForeignKey(Module, on_delete=models.CASCADE, related_name='lecons')
    video_url = models.URLField(blank=True, null=True)
    image_url = models.URLField(blank=True, null=True)
    audio_url = models.URLField(blank=True, null=True)
    texte = models.TextField(blank=True, null=True)

    def __str__(self):
        return self.titre


class Quiz(models.Model):
    titre = models.CharField(max_length=255)
    lecon = models.ForeignKey('Lecon', on_delete=models.CASCADE, related_name='quiz')

    def __str__(self):
        return self.titre

class Question(models.Model):
    quiz = models.ForeignKey(Quiz, on_delete=models.CASCADE, related_name='questions')
    texte = models.TextField()
    reponse_correcte = models.CharField(max_length=255)
    reponse_1 = models.CharField(max_length=255)
    reponse_2 = models.CharField(max_length=255)
    reponse_3 = models.CharField(max_length=255)

    def __str__(self):
        return self.texte
