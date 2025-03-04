from django.db import models
from django.contrib.auth.models import AbstractUser

# Create your models here.

class Category(models.Model):
    title = models.CharField(max_length=100)
    icon = models.CharField(max_length=50)
    route = models.CharField(max_length=100)

    def __str__(self):
        return self.title


class CustomUser(AbstractUser):
    ROLE_CHOICES = [
        ('eleve', 'Élève'),
        ('enseignant', 'Enseignant'),
        ('parent', 'Parent'),
        ('admin', 'Admin'),
    ]
    BADGE_CHOICES = {
        'eleve': "🎓 Bienvenue, élève !",
        'enseignant': "📚 Bienvenue, enseignant !",
        'parent': "👨‍👩‍👧 Bienvenue, parent !",
        'admin': "⚡ Bienvenue, administrateur !",
    }
    role = models.CharField(max_length=20, choices=ROLE_CHOICES, default='eleve')
    badge = models.CharField(max_length=50, blank=True, null=True)  # Ajout du badge

    def save(self, *args, **kwargs):
        if not self.badge:
            self.badge = f"Bienvenue {self.get_role_display()} !"  # Badge automatique
        super().save(*args, **kwargs)
