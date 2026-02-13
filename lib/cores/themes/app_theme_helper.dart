import 'package:flutter/material.dart';
import 'package:logic_mathematics/cores/themes/app_colors.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class AppThemeHelper {
  // Common background color for all pages
  static const Color backgroundColor = Color(0xFFF8F9FF);

  // Standard AppBar design used across the app
  static PreferredSizeWidget buildAppBar({
    required BuildContext context,
    required String title,
    List<Widget>? actions,
    VoidCallback? onBackPressed,
  }) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryDark,
        ),
      ),
      centerTitle: true,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: AppColors.primaryDark,
          ),
          onPressed: onBackPressed ?? () => Navigator.pop(context),
        ),
      ),
      actions: actions?.map((action) {
        return Container(
          margin: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: action,
        );
      }).toList(),
    );
  }

  // Standard section builder
  static Widget buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 3.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(left: 4.w, bottom: 2.h),
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFE4E1), Color(0xFFE6E6FA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFB6C1).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Builder(
              builder: (context) => Text(
                '✨ $title',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFB6C1).withOpacity(0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Column(children: children),
            ),
          ),
        ],
      ),
    );
  }

  // Standard divider
  static Widget buildDivider() {
    return Container(
      height: 1,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, Color(0xFFFFB6C1), Colors.transparent],
        ),
      ),
    );
  }

  // Standard loading widget
  static Widget buildLoadingWidget({String message = 'Loading...'}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryDark),
          ),
          SizedBox(height: 2.h),
          Builder(
            builder: (context) => Text(
              message,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.primaryDark,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Standard error widget
  static Widget buildErrorWidget({required String error}) {
    return Container(
      margin: EdgeInsets.all(4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red[300]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[600], size: 6.w),
          SizedBox(width: 3.w),
          Expanded(
            child: Builder(
              builder: (context) => Text(
                error,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.red[800],
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
