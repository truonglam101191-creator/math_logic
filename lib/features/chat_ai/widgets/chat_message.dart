// import 'package:flutter/material.dart';
// import 'package:flutter_gemma/flutter_gemma.dart';
// import 'package:logic_mathematics/cores/themes/app_colors.dart';
// import 'package:responsive_sizer/responsive_sizer.dart';
// import 'package:flutter_markdown/flutter_markdown.dart';

// class ChatMessageWidget extends StatelessWidget {
//   const ChatMessageWidget({super.key, required this.message});

//   final Message message;

//   @override
//   Widget build(BuildContext context) {
//     // Handle system info messages differently
//     if (message.type == MessageType.systemInfo) {
//       return _buildSystemMessage(context);
//     }

//     return Container(
//       margin: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
//       child: Row(
//         mainAxisAlignment: message.isUser
//             ? MainAxisAlignment.end
//             : MainAxisAlignment.start,
//         children: <Widget>[
//           if (!message.isUser) _buildAvatar(),
//           if (!message.isUser) SizedBox(width: 3.w),
//           Expanded(
//             child: Container(
//               constraints: BoxConstraints(maxWidth: 70.w),
//               padding: EdgeInsets.all(4.w),
//               decoration: BoxDecoration(
//                 gradient: message.isUser
//                     ? LinearGradient(
//                         colors: [Color(0xFFFFE4E1), Color(0xFFE6E6FA)],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       )
//                     : LinearGradient(
//                         colors: [Colors.white, Color(0xFFF8F9FF)],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       ),
//                 borderRadius: BorderRadius.circular(20),
//                 boxShadow: [
//                   BoxShadow(
//                     color: message.isUser
//                         ? Color(0xFFFFB6C1).withOpacity(0.2)
//                         : Color(0xFFFFB6C1).withOpacity(0.15),
//                     blurRadius: 8,
//                     offset: Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Display image if available
//                   if (message.hasImage) ...[
//                     _buildImageWidget(context),
//                     if (message.text.isNotEmpty) const SizedBox(height: 8),
//                   ],

//                   // Display text
//                   if (message.text.isNotEmpty)
//                     MarkdownBody(
//                       data: message.text,
//                       styleSheet: MarkdownStyleSheet(
//                         p: TextStyle(
//                           color: message.isUser
//                               ? Color(0xFF2D3748)
//                               : Colors.black87,
//                           fontSize: 14.sp,
//                           height: 1.4,
//                         ),
//                         code: TextStyle(
//                           backgroundColor: Color(0xFFF7FAFC),
//                           color: Color(0xFF2D3748),
//                           fontFamily: 'monospace',
//                           fontSize: 13.sp,
//                         ),
//                         codeblockDecoration: BoxDecoration(
//                           color: Color(0xFFF7FAFC),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                     )
//                   else if (!message.hasImage)
//                     Center(
//                       child: Column(
//                         children: [
//                           SizedBox(
//                             width: 5.w,
//                             height: 5.w,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               valueColor: AlwaysStoppedAnimation<Color>(
//                                 Color(0xFF4FC3F7),
//                               ),
//                             ),
//                           ),
//                           SizedBox(height: 1.h),
//                           Text(
//                             '🤖 AI đang suy nghĩ...',
//                             style: TextStyle(
//                               color: Color(0xFF4FC3F7),
//                               fontSize: 12.sp,
//                               fontStyle: FontStyle.italic,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ),
//           if (message.isUser) SizedBox(width: 3.w),
//           if (message.isUser) _buildAvatar(),
//         ],
//       ),
//     );
//   }

//   Widget _buildImageWidget(BuildContext context) {
//     return GestureDetector(
//       onTap: () => _showImageDialog(context),
//       child: Container(
//         constraints: const BoxConstraints(maxWidth: 300, maxHeight: 200),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(8),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withValues(alpha: 0.3),
//               blurRadius: 4,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(8),
//           child: Image.memory(
//             message.imageBytes!,
//             fit: BoxFit.cover,
//             errorBuilder: (context, error, stackTrace) {
//               return Container(
//                 width: 200,
//                 height: 100,
//                 color: Colors.grey[300],
//                 child: const Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.error, color: Colors.red),
//                     SizedBox(height: 4),
//                     Text(
//                       'Image loading error',
//                       style: TextStyle(color: Colors.red, fontSize: 12),
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   void _showImageDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       barrierDismissible: true,
//       builder: (BuildContext context) {
//         return Dialog(
//           backgroundColor: Colors.transparent,
//           child: Stack(
//             children: [
//               // Full-size image
//               Center(
//                 child: InteractiveViewer(
//                   child: Image.memory(message.imageBytes!, fit: BoxFit.contain),
//                 ),
//               ),

//               // Close button
//               Positioned(
//                 top: 40,
//                 right: 20,
//                 child: IconButton(
//                   icon: const Icon(Icons.close, color: Colors.white, size: 30),
//                   onPressed: () => Navigator.of(context).pop(),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildSystemMessage(BuildContext context) {
//     IconData iconData;
//     Color iconColor;

//     // Determine icon based on message content
//     if (message.text.contains('Calling')) {
//       iconData = Icons.settings;
//       iconColor = Color(0xFF4FC3F7);
//     } else if (message.text.contains('Executing')) {
//       iconData = Icons.flash_on;
//       iconColor = Color(0xFFFFB74D);
//     } else if (message.text.contains('completed')) {
//       iconData = Icons.check_circle;
//       iconColor = Color(0xFF81C784);
//     } else if (message.text.contains('Generating')) {
//       iconData = Icons.psychology;
//       iconColor = Color(0xFFBA68C8);
//     } else {
//       iconData = Icons.info;
//       iconColor = Color(0xFF4FC3F7);
//     }

//     return Container(
//       margin: EdgeInsets.symmetric(vertical: 1.h),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: <Widget>[
//           SizedBox(width: 13.w), // Space for avatar alignment
//           Expanded(
//             child: Container(
//               constraints: BoxConstraints(maxWidth: 70.w),
//               padding: EdgeInsets.all(3.w),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [Color(0xFFE8F5E8), Color(0xFFE1F5FE)],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: BorderRadius.circular(15),
//                 boxShadow: [
//                   BoxShadow(
//                     color: iconColor.withOpacity(0.2),
//                     blurRadius: 8,
//                     offset: Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Container(
//                     padding: EdgeInsets.all(2.w),
//                     decoration: BoxDecoration(
//                       color: iconColor.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Icon(iconData, size: 4.w, color: iconColor),
//                   ),
//                   SizedBox(width: 3.w),
//                   Flexible(
//                     child: Text(
//                       message.text,
//                       style: TextStyle(
//                         fontSize: 13.sp,
//                         color: iconColor.withOpacity(0.8),
//                         fontStyle: FontStyle.italic,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAvatar() {
//     return Container(
//       width: 10.w,
//       height: 10.w,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: message.isUser
//               ? [Color(0xFFFFB6C1), Color(0xFFFFE4E1)]
//               : [Color(0xFF4FC3F7), Color(0xFFE1F5FE)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(25),
//         boxShadow: [
//           BoxShadow(
//             color: message.isUser
//                 ? Color(0xFFFFB6C1).withOpacity(0.3)
//                 : Color(0xFF4FC3F7).withOpacity(0.3),
//             blurRadius: 8,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Icon(
//         message.isUser ? Icons.person : Icons.smart_toy,
//         color: message.isUser ? Colors.pink[700] : Colors.blue[700],
//         size: 5.w,
//       ),
//     );
//   }

//   // Widget _circled(String image) => CircleAvatar(
//   //       backgroundColor: Colors.transparent,
//   //       foregroundImage: AssetImage(image),
//   //     );
// }
