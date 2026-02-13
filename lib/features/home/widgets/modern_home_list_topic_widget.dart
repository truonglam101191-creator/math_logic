import 'package:flutter/material.dart';
import 'package:logic_mathematics/cores/themes/app_colors.dart';
import 'package:logic_mathematics/cores/themes/app_theme_helper.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ModernHomeListTopicWidget extends StatelessWidget {
  const ModernHomeListTopicWidget({super.key});

  final List<TopicItem> topics = const [
    TopicItem(
      title: 'Đại số',
      subtitle: 'Phương trình, bất phương trình',
      icon: Icons.functions,
      color: Colors.blue,
      progress: 0.75,
    ),
    TopicItem(
      title: 'Hình học',
      subtitle: 'Tam giác, tứ giác, đường tròn',
      icon: Icons.change_history,
      color: Colors.green,
      progress: 0.60,
    ),
    TopicItem(
      title: 'Giải tích',
      subtitle: 'Đạo hàm, tích phân',
      icon: Icons.timeline,
      color: Colors.orange,
      progress: 0.45,
    ),
    TopicItem(
      title: 'Xác suất',
      subtitle: 'Thống kê, tổ hợp',
      icon: Icons.pie_chart,
      color: Colors.purple,
      progress: 0.30,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppThemeHelper.backgroundColor,
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: Column(
        children: [
          AppThemeHelper.buildSection(
            title: 'Chủ đề học tập',
            children: [
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: topics.length,
                separatorBuilder: (context, index) =>
                    AppThemeHelper.buildDivider(),
                itemBuilder: (context, index) {
                  final topic = topics[index];
                  return _buildTopicCard(context, topic);
                },
              ),
            ],
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildTopicCard(BuildContext context, TopicItem topic) {
    return InkWell(
      onTap: () {
        // Handle topic tap
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(4.w),
        child: Row(
          children: [
            // Icon
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    topic.color.withOpacity(0.2),
                    topic.color.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: topic.color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(topic.icon, color: topic.color, size: 6.w),
            ),
            SizedBox(width: 4.w),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topic.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    topic.subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 13.sp,
                      height: 1.2,
                      color: AppColors.primaryDark.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(height: 1.h),

                  // Progress bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tiến độ',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontSize: 11.sp,
                                  color: Colors.grey[600],
                                ),
                          ),
                          Text(
                            '${(topic.progress * 100).toInt()}%',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                  color: topic.color,
                                ),
                          ),
                        ],
                      ),
                      SizedBox(height: 0.5.h),
                      LinearProgressIndicator(
                        value: topic.progress,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(topic.color),
                        minHeight: 6,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Arrow icon
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: topic.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                color: topic.color,
                size: 4.w,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TopicItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final double progress;

  const TopicItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.progress,
  });
}
