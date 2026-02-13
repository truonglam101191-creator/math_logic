import 'package:flutter/material.dart';
import 'package:logic_mathematics/cores/themes/app_colors.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ChatMessageWidget extends StatelessWidget {
  final String message;
  final bool isUser;
  final bool isSystem;
  final DateTime timestamp;

  const ChatMessageWidget({
    super.key,
    required this.message,
    this.isUser = false,
    this.isSystem = false,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 1.h, horizontal: 4.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isUser && !isSystem) _buildAvatar(false),
          if (!isUser && !isSystem) SizedBox(width: 3.w),
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: 70.w),
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              decoration: BoxDecoration(
                gradient: isSystem
                    ? LinearGradient(
                        colors: [Color(0xFFE8F5E8), Color(0xFFE1F5FE)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : isUser
                    ? LinearGradient(
                        colors: [Color(0xFFFFE4E1), Color(0xFFE6E6FA)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : LinearGradient(
                        colors: [Colors.white, Color(0xFFF8F9FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: isSystem
                        ? Colors.green.withOpacity(0.1)
                        : isUser
                        ? Color(0xFFFFB6C1).withOpacity(0.2)
                        : AppColors.primaryDark.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isSystem)
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.green[600],
                          size: 4.w,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'System',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: Colors.green[600],
                                fontWeight: FontWeight.w600,
                                fontSize: 11.sp,
                              ),
                        ),
                      ],
                    ),
                  if (isSystem) SizedBox(height: 1.h),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 14.sp,
                      height: 1.4,
                      color: isSystem
                          ? Colors.green[800]
                          : isUser
                          ? AppColors.primaryDark
                          : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    _formatTime(timestamp),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.grey[600],
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser && !isSystem) SizedBox(width: 3.w),
          if (isUser && !isSystem) _buildAvatar(true),
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isUser) {
    return Container(
      width: 10.w,
      height: 10.w,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isUser
              ? [Color(0xFFFFB6C1), Color(0xFFFFE4E1)]
              : [Color(0xFF4FC3F7), Color(0xFFE1F5FE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: isUser
                ? Color(0xFFFFB6C1).withOpacity(0.3)
                : Color(0xFF4FC3F7).withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        isUser ? Icons.person : Icons.smart_toy,
        color: isUser ? Colors.pink[700] : Colors.blue[700],
        size: 5.w,
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
