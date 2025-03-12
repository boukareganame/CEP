from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    category_list,
    user_profile,
    UserListView,
    UserUpdateView,
    UserDeleteView,
    RegisterView,
    LoginView,
    CoursViewSet,
    ExerciceViewSet,
    TeacherCourseListView,
    TeacherExerciseListView,
    TeacherCourseCreateView,
    TeacherCourseDeleteView,
    TeacherExerciseCreateView,
    TeacherExerciseDeleteView,
    CoursListView,
    CoursDetailView,
    ModuleDetailView,
    LeconDetailView,
    QuizDetailView,
    QuestionDetailView
)

router = DefaultRouter()
router.register(r'cours', CoursViewSet, basename='cours')
router.register(r'exercices', ExerciceViewSet, basename='exercice')

urlpatterns = [
    path('categories/', category_list, name='category_list'),
    path('auth/profile/', user_profile, name='user-profile'),
    path('auth/login/', LoginView.as_view(), name="login"),
    path('auth/register/', RegisterView.as_view(), name='register'),
    path('users/', UserListView.as_view(), name='user-list'),
    path('users/<int:pk>/', UserUpdateView.as_view(), name='user-update'),
    path('users/<int:pk>/delete/', UserDeleteView.as_view(), name='user-delete'),
    path('teacher/courses/', TeacherCourseListView.as_view(), name='teacher-course-list'),
    path('teacher/courses/add/', TeacherCourseCreateView.as_view(), name='teacher-course-add'),
    path('teacher/courses/<int:pk>/delete/', TeacherCourseDeleteView.as_view(), name='teacher-course-delete'),
    path('teacher/exercises/', TeacherExerciseListView.as_view(), name='teacher-exercise-list'),
    path('teacher/exercises/add/', TeacherExerciseCreateView.as_view(), name='teacher-exercise-add'),
    path('teacher/exercises/<int:pk>/delete/', TeacherExerciseDeleteView.as_view(), name='teacher-exercise-delete'),
    path('', include(router.urls)),
    path('cours/', CoursListView.as_view(), name='cours-list'),
    path('cours/<int:pk>/', CoursDetailView.as_view(), name='cours-detail'),
    path('modules/<int:pk>/', ModuleDetailView.as_view(), name='module-detail'),
    path('lecons/<int:pk>/', LeconDetailView.as_view(), name='lecon-detail'),
    path('quiz/<int:pk>/', QuizDetailView.as_view(), name='quiz-detail'),
    path('questions/<int:pk>/', QuestionDetailView.as_view(), name='question-detail'),
]
