import 'package:get/get.dart';
import 'package:flutter/material.dart';

class NotificationController extends GetxController {
  // Observable variables
  final isLoading = false.obs;
  final notifications = <NotificationModel>[].obs;
  final unreadCount = 0.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }
  
  Future<void> loadNotifications() async {
    isLoading.value = true;
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data
      final mockNotifications = [
        NotificationModel(
          id: '1',
          title: 'Pengaduan Diproses',
          message: 'Pengaduan Anda dengan nomor #001 sedang diproses',
          type: 'status_update',
          isRead: false,
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        NotificationModel(
          id: '2',
          title: 'Pengaduan Selesai',
          message: 'Pengaduan Anda dengan nomor #002 telah selesai ditangani',
          type: 'status_update',
          isRead: true,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];
      
      notifications.assignAll(mockNotifications);
      _updateUnreadCount();
    } catch (e) {
      // Handle error
    } finally {
      isLoading.value = false;
    }
  }
  
  void markAsRead(String id) {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      notifications[index] = notifications[index].copyWith(isRead: true);
      _updateUnreadCount();
    }
  }
  
  void markAllAsRead() {
    for (int i = 0; i < notifications.length; i++) {
      notifications[i] = notifications[i].copyWith(isRead: true);
    }
    _updateUnreadCount();
  }
  
  void _updateUnreadCount() {
    unreadCount.value = notifications.where((n) => !n.isRead).length;
  }
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
