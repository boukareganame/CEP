from django.urls import path
from .views import category_list, user_profile, UserListView, UserUpdateView, UserDeleteView, RegisterView, LoginView
from rest_framework.authtoken.views import obtain_auth_token

urlpatterns = [
    path('categories/', category_list, name='category_list'),
    path('auth/profile/', user_profile, name='user-profile'),
    #path('auth/login/', obtain_auth_token, name='api_token_auth'),
    path('auth/login/', LoginView.as_view(), name="login"),
    path('auth/register/', RegisterView.as_view(), name='register'),
    path('users/', UserListView.as_view(), name='user-list'),
    path('users/<int:pk>/', UserUpdateView.as_view(), name='user-update'),
    path('users/<int:pk>/delete/', UserDeleteView.as_view(), name='user-delete'),
]
