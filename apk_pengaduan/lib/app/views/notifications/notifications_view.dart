import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/notification_controller.dart';
import '../../utils/constants.dart';
import '../../utils/app_utils.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationController>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        centerTitle: true,
        actions: [
          Obx(() => controller.unreadCount.value > 0
              ? TextButton(
                  onPressed: controller.markAllAsRead,
                  child: const Text('Tandai Semua'),
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.loadNotifications,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          if (controller.notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: AppSizes.spacing16),
                  Text(
                    'Belum ada notifikasi',
                    style: TextStyle(
                      fontSize: AppSizes.fontSize16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(AppSizes.spacing16),
            itemCount: controller.notifications.length,
            itemBuilder: (context, index) {
              final notification = controller.notifications[index];
              
              return Card(
                margin: const EdgeInsets.only(bottom: AppSizes.spacing12),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(AppSizes.spacing8),
                    decoration: BoxDecoration(
                      color: _getNotificationColor(notification.type).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getNotificationIcon(notification.type),
                      color: _getNotificationColor(notification.type),
                    ),
                  ),
                  title: Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.message,
                        style: TextStyle(
                          color: notification.isRead ? AppColors.textSecondary : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSizes.spacing4),
                      Text(
                        AppUtils.formatRelativeTime(notification.createdAt),
                        style: const TextStyle(
                          fontSize: AppSizes.fontSize12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  trailing: notification.isRead
                      ? null
                      : Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                  onTap: () {
                    if (!notification.isRead) {
                      controller.markAsRead(notification.id);
                    }
                  },
                ),
              );
            },
          );
        }),
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'status_update':
        return Icons.update;
      case 'new_message':
        return Icons.message;
      case 'reminder':
        return Icons.alarm;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'status_update':
        return AppColors.primaryColor;
      case 'new_message':
        return AppColors.infoColor;
      case 'reminder':
        return AppColors.warningColor;
      default:
        return AppColors.textSecondary;
    }
  }
}
