// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:flutter_gemma/flutter_gemma.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:image_picker/image_picker.dart';
// import 'package:logic_mathematics/cores/themes/app_colors.dart';
// import 'package:responsive_sizer/responsive_sizer.dart';

// class ChatInputField extends StatefulWidget {
//   final ValueChanged<Message> handleSubmitted;
//   final bool supportsImages;

//   const ChatInputField({
//     super.key,
//     required this.handleSubmitted,
//     this.supportsImages = false,
//   });

//   @override
//   ChatInputFieldState createState() => ChatInputFieldState();
// }

// class ChatInputFieldState extends State<ChatInputField> {
//   final TextEditingController _textController = TextEditingController();
//   final ImagePicker _picker = ImagePicker();
//   Uint8List? _selectedImageBytes;
//   String? _selectedImageName;

//   void _handleSubmitted(String text) {
//     if (text.trim().isEmpty && _selectedImageBytes == null) return;

//     final message = _selectedImageBytes != null
//         ? Message.withImage(
//             text: text.trim(),
//             imageBytes: _selectedImageBytes!,
//             isUser: true,
//           )
//         : Message.text(text: text.trim(), isUser: true);

//     widget.handleSubmitted(message);
//     _textController.clear();
//     _clearImage();
//   }

//   void _clearImage() {
//     setState(() {
//       _selectedImageBytes = null;
//       _selectedImageName = null;
//     });
//   }

//   Future<void> _pickImage() async {
//     final scaffoldMessenger = ScaffoldMessenger.of(context);
//     if (kIsWeb) {
//       // Show modern snackbar for web
//       scaffoldMessenger.showSnackBar(
//         SnackBar(
//           content: Container(
//             padding: EdgeInsets.symmetric(vertical: 1.h),
//             child: Row(
//               children: [
//                 Container(
//                   padding: EdgeInsets.all(2.w),
//                   decoration: BoxDecoration(
//                     color: Colors.orange[100],
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Icon(Icons.web, color: Colors.orange[700], size: 4.w),
//                 ),
//                 SizedBox(width: 3.w),
//                 Expanded(
//                   child: Text(
//                     'Tính năng chọn ảnh chưa hỗ trợ trên web',
//                     style: TextStyle(
//                       fontSize: 14.sp,
//                       color: Colors.white,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           backgroundColor: Colors.orange[600],
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           behavior: SnackBarBehavior.floating,
//           margin: EdgeInsets.all(16),
//           duration: Duration(seconds: 2),
//         ),
//       );
//       return;
//     }

//     try {
//       final pickedFile = await _picker.pickImage(
//         source: ImageSource.gallery,
//         maxWidth: 1024,
//         maxHeight: 1024,
//         imageQuality: 85,
//       );

//       if (pickedFile != null) {
//         final bytes = await pickedFile.readAsBytes();
//         setState(() {
//           _selectedImageBytes = bytes;
//           _selectedImageName = pickedFile.name;
//         });

//         // Show success message
//         scaffoldMessenger.showSnackBar(
//           SnackBar(
//             content: Row(
//               children: [
//                 Text('✅', style: TextStyle(fontSize: 20)),
//                 SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     'Đã thêm hình ảnh thành công',
//                     style: TextStyle(
//                       fontWeight: FontWeight.w500,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             backgroundColor: Color(0xFF81C784),
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             margin: EdgeInsets.all(16),
//             duration: Duration(seconds: 2),
//           ),
//         );
//       }
//     } catch (e) {
//       scaffoldMessenger.showSnackBar(
//         SnackBar(
//           content: Row(
//             children: [
//               Text('❌', style: TextStyle(fontSize: 20)),
//               SizedBox(width: 8),
//               Expanded(
//                 child: Text(
//                   'Lỗi khi chọn ảnh: $e',
//                   style: TextStyle(
//                     fontWeight: FontWeight.w500,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           backgroundColor: Colors.red[600],
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           margin: EdgeInsets.all(16),
//           duration: Duration(seconds: 2),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(4.w),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Colors.white, Color(0xFFF8F9FF)],
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Color(0xFFFFB6C1).withOpacity(0.15),
//             blurRadius: 15,
//             offset: Offset(0, -5),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // Selected image preview
//           if (_selectedImageBytes != null) _buildImagePreview(),
//           if (_selectedImageBytes != null) SizedBox(height: 2.h),

//           // Input field row
//           Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Color(0xFFF8F9FF), Colors.white],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(
//                 color:
//                     (_textController.text.isNotEmpty ||
//                         _selectedImageBytes != null)
//                     ? AppColors.primaryDark.withOpacity(0.3)
//                     : Colors.grey[300]!,
//                 width: 1.5,
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: AppColors.primaryDark.withOpacity(0.05),
//                   blurRadius: 8,
//                   offset: Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: <Widget>[
//                 // Add image button
//                 if (widget.supportsImages && !kIsWeb)
//                   Container(
//                     margin: EdgeInsets.all(1.w),
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: _selectedImageBytes != null
//                             ? [Color(0xFF4FC3F7), Color(0xFFE1F5FE)]
//                             : [Color(0xFF81C784), Color(0xFFE8F5E8)],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       ),
//                       borderRadius: BorderRadius.circular(12),
//                       boxShadow: [
//                         BoxShadow(
//                           color:
//                               (_selectedImageBytes != null
//                                       ? Color(0xFF4FC3F7)
//                                       : Color(0xFF81C784))
//                                   .withOpacity(0.3),
//                           blurRadius: 8,
//                           offset: Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: IconButton(
//                       icon: Icon(
//                         _selectedImageBytes != null
//                             ? Icons.image
//                             : Icons.add_photo_alternate,
//                         color: _selectedImageBytes != null
//                             ? Colors.blue[700]
//                             : Colors.green[700],
//                         size: 5.w,
//                       ),
//                       onPressed: _pickImage,
//                       tooltip: _selectedImageBytes != null
//                           ? 'Đổi hình ảnh'
//                           : 'Thêm hình ảnh',
//                     ),
//                   ),
//                 Flexible(
//                   child: TextField(
//                     controller: _textController,
//                     onSubmitted: _handleSubmitted,
//                     maxLines: null,
//                     keyboardType: TextInputType.multiline,
//                     textInputAction: TextInputAction.send,
//                     style: TextStyle(
//                       color: Colors.black87,
//                       fontSize: 14.sp,
//                       height: 1.4,
//                     ),
//                     decoration: InputDecoration(
//                       hintText: _selectedImageBytes != null
//                           ? 'Thêm mô tả cho hình ảnh...'
//                           : 'Nhập tin nhắn của bạn...',
//                       hintStyle: TextStyle(
//                         color: Colors.grey[500],
//                         fontSize: 14.sp,
//                       ),
//                       border: InputBorder.none,
//                       contentPadding: EdgeInsets.symmetric(
//                         horizontal: _selectedImageBytes != null ? 2.w : 4.w,
//                         vertical: 2.h,
//                       ),
//                     ),
//                     onChanged: (text) =>
//                         setState(() {}), // Trigger rebuild for border color
//                   ),
//                 ),

//                 // Send button
//                 Container(
//                   margin: EdgeInsets.all(1.w),
//                   decoration: BoxDecoration(
//                     gradient:
//                         (_textController.text.trim().isNotEmpty ||
//                             _selectedImageBytes != null)
//                         ? LinearGradient(
//                             colors: [Color(0xFFFFE4E1), Color(0xFFE6E6FA)],
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                           )
//                         : LinearGradient(
//                             colors: [Colors.grey[300]!, Colors.grey[200]!],
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                           ),
//                     borderRadius: BorderRadius.circular(12),
//                     boxShadow:
//                         (_textController.text.trim().isNotEmpty ||
//                             _selectedImageBytes != null)
//                         ? [
//                             BoxShadow(
//                               color: Color(0xFFFFB6C1).withOpacity(0.3),
//                               blurRadius: 8,
//                               offset: Offset(0, 2),
//                             ),
//                           ]
//                         : [],
//                   ),
//                   child: IconButton(
//                     icon: Icon(
//                       Icons.send_rounded,
//                       color:
//                           (_textController.text.trim().isNotEmpty ||
//                               _selectedImageBytes != null)
//                           ? AppColors.primaryDark
//                           : Colors.grey[500],
//                       size: 5.w,
//                     ),
//                     onPressed: () => _handleSubmitted(_textController.text),
//                     tooltip: 'Gửi tin nhắn',
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildImagePreview() {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
//       padding: EdgeInsets.all(3.w),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Color(0xFFE1F5FE), Color(0xFFF0F8FF)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: Color(0xFF4FC3F7).withOpacity(0.3), width: 1),
//         boxShadow: [
//           BoxShadow(
//             color: Color(0xFF4FC3F7).withOpacity(0.15),
//             blurRadius: 8,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           // Image preview
//           Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 4,
//                   offset: Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(12),
//               child: Image.memory(
//                 _selectedImageBytes!,
//                 width: 15.w,
//                 height: 15.w,
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//           SizedBox(width: 3.w),

//           // Image information
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Container(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 2.w,
//                         vertical: 0.5.h,
//                       ),
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: [
//                             Color(0xFF4FC3F7).withOpacity(0.2),
//                             Color(0xFF4FC3F7).withOpacity(0.1),
//                           ],
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                         ),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(
//                             Icons.image,
//                             size: 3.w,
//                             color: Color(0xFF4FC3F7),
//                           ),
//                           SizedBox(width: 1.w),
//                           Text(
//                             'Hình ảnh',
//                             style: TextStyle(
//                               color: Color(0xFF4FC3F7),
//                               fontSize: 11.sp,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 1.h),
//                 Text(
//                   _selectedImageName ?? 'Image',
//                   style: TextStyle(
//                     color: Color(0xFF2D3748),
//                     fontWeight: FontWeight.w500,
//                     fontSize: 13.sp,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 SizedBox(height: 0.5.h),
//                 Text(
//                   '${(_selectedImageBytes!.length / 1024).toStringAsFixed(1)} KB',
//                   style: TextStyle(color: Colors.grey[600], fontSize: 11.sp),
//                 ),
//               ],
//             ),
//           ),

//           // Delete button
//           Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Color(0xFFFFCDD2), Color(0xFFFFEBEE)],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(10),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.red.withOpacity(0.2),
//                   blurRadius: 4,
//                   offset: Offset(0, 1),
//                 ),
//               ],
//             ),
//             child: IconButton(
//               icon: Icon(
//                 Icons.close_rounded,
//                 color: Colors.red[600],
//                 size: 4.w,
//               ),
//               onPressed: _clearImage,
//               tooltip: 'Xóa hình ảnh',
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
