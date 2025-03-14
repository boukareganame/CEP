// screens/notifications_screen.dart
import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<dynamic> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      _notifications = await NotificationService.getNotifications();
      setState(() {});
    } catch (e) {
      print('Erreur lors du chargement des notifications: $e');
    }
  }

  Future<void> _markAsRead(int id) async {
    try {
      await NotificationService.markAsRead(id);
      _loadNotifications();
    } catch (e) {
      print('Erreur lors du marquage comme lu: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notifications')),
      body: ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return ListTile(
            title: Text(notification['message']),
            subtitle: Text(notification['timestamp']),
            trailing: notification['is_read']
                ? Icon(Icons.check_circle, color: Colors.green)
                : IconButton(
                    icon: Icon(Icons.mark_email_read),
                    onPressed: () => _markAsRead(notification['id']),
                  ),
          );
        },
      ),
    );
  }
}