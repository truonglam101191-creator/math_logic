import 'package:flutter/material.dart';
import 'package:logic_mathematics/cores/themes/app_colors.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class LoadingWidget extends StatelessWidget {
  final String message;
  final int? progress;

  const LoadingWidget({required this.message, this.progress, super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Align(
          alignment: const Alignment(0, 1 / 3),
          child: Container(
            padding: EdgeInsets.all(8.w),
            margin: EdgeInsets.symmetric(horizontal: 5.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFE4E1), Color(0xFFE6E6FA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFFFB6C1).withOpacity(0.3),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryDark.withOpacity(0.2),
                        AppColors.primaryDark.withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryDark,
                    ),
                    strokeWidth: 3,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '🤖 AI Assistant',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 14.sp,
                    height: 1.4,
                    color: AppColors.primaryDark.withOpacity(0.8),
                  ),
                ),
                if (progress != null) ...[
                  SizedBox(height: 2.h),
                  Text(
                    '$progress%',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                SizedBox(height: 2.h),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.smart_toy,
                      color: AppColors.primaryDark.withOpacity(0.6),
                      size: 4.w,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Please wait...',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primaryDark.withOpacity(0.6),
                        fontSize: 12.sp,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
