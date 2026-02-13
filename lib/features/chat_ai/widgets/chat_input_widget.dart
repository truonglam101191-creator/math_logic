import 'package:flutter/material.dart';
import 'package:logic_mathematics/cores/themes/app_colors.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ChatInputWidget extends StatefulWidget {
  final Function(String) onSend;
  final bool isLoading;
  final bool supportImages;

  const ChatInputWidget({
    super.key,
    required this.onSend,
    this.isLoading = false,
    this.supportImages = false,
  });

  @override
  State<ChatInputWidget> createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends State<ChatInputWidget> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _hasText = _controller.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_hasText && !widget.isLoading) {
      widget.onSend(_controller.text.trim());
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Color(0xFFF8F9FF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFFFB6C1).withOpacity(0.15),
            blurRadius: 15,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Input type indicator
            if (_hasText || widget.isLoading)
              Container(
                margin: EdgeInsets.only(bottom: 2.h),
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE1F5FE), Color(0xFFF0F8FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Color(0xFF4FC3F7).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.isLoading
                          ? Icons.hourglass_empty
                          : Icons.edit_note,
                      size: 4.w,
                      color: Color(0xFF4FC3F7),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      widget.isLoading
                          ? 'AI đang xử lý...'
                          : 'Đang soạn tin nhắn',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Color(0xFF4FC3F7),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            // Main input row
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (widget.supportImages)
                  Container(
                    margin: EdgeInsets.only(right: 3.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF81C784), Color(0xFFE8F5E8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.image,
                        color: Colors.green[700],
                        size: 5.w,
                      ),
                      onPressed: widget.isLoading
                          ? null
                          : () {
                              // Handle image selection
                              _showImageOptions(context);
                            },
                      tooltip: 'Thêm hình ảnh',
                    ),
                  ),
                Expanded(
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: 15.h, // Max height for multiline
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFF8F9FF), Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _hasText
                            ? AppColors.primaryDark.withOpacity(0.3)
                            : Colors.grey[300]!,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryDark.withOpacity(0.05),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _controller,
                      enabled: !widget.isLoading,
                      maxLines: null,
                      minLines: 1,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14.sp,
                        height: 1.4,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText: widget.isLoading
                            ? 'AI đang trả lời...'
                            : 'Nhập câu hỏi của bạn...',
                        hintStyle: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(
                              color: widget.isLoading
                                  ? Colors.orange[400]
                                  : Colors.grey[500],
                              fontSize: 14.sp,
                              fontStyle: widget.isLoading
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                            ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 2.h,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Container(
                  decoration: BoxDecoration(
                    gradient: _hasText && !widget.isLoading
                        ? LinearGradient(
                            colors: [Color(0xFFFFE4E1), Color(0xFFE6E6FA)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : LinearGradient(
                            colors: [Colors.grey[300]!, Colors.grey[200]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: _hasText && !widget.isLoading
                        ? [
                            BoxShadow(
                              color: Color(0xFFFFB6C1).withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                  child: IconButton(
                    icon: widget.isLoading
                        ? SizedBox(
                            width: 5.w,
                            height: 5.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primaryDark,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.send_rounded,
                            color: _hasText
                                ? AppColors.primaryDark
                                : Colors.grey[500],
                            size: 5.w,
                          ),
                    onPressed: _hasText && !widget.isLoading
                        ? _sendMessage
                        : null,
                    tooltip: _hasText
                        ? 'Gửi tin nhắn'
                        : 'Nhập nội dung trước khi gửi',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showImageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFF8F9FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          boxShadow: [
            BoxShadow(
              color: Color(0xFFFFB6C1).withOpacity(0.2),
              blurRadius: 15,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 15.w,
                height: 1.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                '📷 Thêm hình ảnh',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDark,
                ),
              ),
              SizedBox(height: 3.h),
              Row(
                children: [
                  Expanded(
                    child: _buildImageOption(
                      context,
                      icon: Icons.camera_alt,
                      title: 'Camera',
                      subtitle: 'Chụp ảnh mới',
                      color: Color(0xFF4FC3F7),
                      onTap: () {
                        Navigator.pop(context);
                        // Handle camera
                      },
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: _buildImageOption(
                      context,
                      icon: Icons.photo_library,
                      title: 'Thư viện',
                      subtitle: 'Chọn từ thư viện',
                      color: Color(0xFF81C784),
                      onTap: () {
                        Navigator.pop(context);
                        // Handle gallery
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: color, size: 6.w),
            ),
            SizedBox(height: 2.h),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color.withOpacity(0.7),
                fontSize: 11.sp,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
