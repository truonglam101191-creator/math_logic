import 'package:flutter/material.dart';
import 'package:logic_mathematics/cores/themes/app_colors.dart';
import 'package:logic_mathematics/cores/themes/app_theme_helper.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ModernHomeBodyWidget extends StatelessWidget {
  const ModernHomeBodyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppThemeHelper.backgroundColor,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 2.h),

              // Header section
              AppThemeHelper.buildSection(
                title: 'Toán học logic',
                children: [
                  Container(
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                      children: [
                        Row(
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
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Icon(
                                Icons.calculate,
                                color: AppColors.primaryDark,
                                size: 8.w,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Chào mừng bạn!',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontSize: 20.sp,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primaryDark,
                                        ),
                                  ),
                                  SizedBox(height: 1.h),
                                  Text(
                                    'Khám phá thế giới toán học với AI',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontSize: 14.sp,
                                          height: 1.3,
                                          color: AppColors.primaryDark
                                              .withOpacity(0.8),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 3.h),

                        // Stats row
                        Row(
                          children: [
                            _buildStatCard(
                              context: context,
                              icon: Icons.quiz,
                              title: 'Bài tập',
                              value: '150+',
                              color: Colors.blue,
                            ),
                            SizedBox(width: 3.w),
                            _buildStatCard(
                              context: context,
                              icon: Icons.smart_toy,
                              title: 'AI Hỗ trợ',
                              value: '24/7',
                              color: Colors.orange,
                            ),
                            SizedBox(width: 3.w),
                            _buildStatCard(
                              context: context,
                              icon: Icons.trending_up,
                              title: 'Tiến bộ',
                              value: '95%',
                              color: Colors.green,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 3.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 6.w),
            SizedBox(height: 1.h),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 11.sp,
                color: color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
