import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logic_mathematics/cores/db_storage/db_funtion.dart';
import 'package:logic_mathematics/cores/themes/app_colors.dart';
import 'package:logic_mathematics/features/in_app/in_app_product_page.dart';
import 'package:logic_mathematics/l10n/l10n.dart';
import 'package:logic_mathematics/main.dart';
import 'package:oziapi/models/request_model.dart';
import 'package:oziapi/ozi_api.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
// removed flutter_gemma_interface.dart
import 'package:flutter_gemma/core/message.dart' as gemma_message;
import 'package:flutter_gemma/core/model_response.dart' as gemma_response;
import 'package:logic_mathematics/cores/extentions/messagingservice.dart';
import 'package:logic_mathematics/cores/services/gemma_service.dart';
import 'package:logic_mathematics/cores/extentions/shared.dart';

class InputchataiWidget extends StatefulWidget {
  const InputchataiWidget({
    super.key,
    this.autofocus = false,
    this.focusNode,
    this.onFieldSubmitted,
    this.listMessager,
    this.onSendMessage,
    this.onresultMessage,
    this.indexFunction = 0,
    this.onCreate,
  });

  final FocusNode? focusNode;

  final void Function(String val)? onFieldSubmitted;

  final List<Message>? listMessager;

  final bool autofocus;

  final int indexFunction;

  final Function(Message val, bool isImgae)? onSendMessage;
  final Function(Message val, bool isImgae)? onresultMessage;

  final Function(InputchataiWidgetState controller)? onCreate;

  @override
  // ignore: no_logic_in_create_state
  State<InputchataiWidget> createState() {
    final controller = InputchataiWidgetState();
    onCreate?.call(controller);
    return controller;
  }
}

class InputchataiWidgetState extends State<InputchataiWidget> {
  final paddingButton = 5.0;

  final wightContentButton = 20.0;

  bool isSendMessager = false;

  final controller = TextEditingController();

  final List<Message> listMessager = [];

  String pathFile = '';

  bool oneRun = true;

  bool _isListening = false;

  final node = FocusNode();

  void actionTakePhoto() {
    serviceLocator<ImagePicker>().pickImage(source: ImageSource.camera).then((
      value,
    ) {
      if (value != null) {
        setState(() {
          pathFile = value.path;
        });
      }
    });
  }

  void actionSelectPhoto() {
    serviceLocator<ImagePicker>().pickImage(source: ImageSource.gallery).then((
      value,
    ) {
      if (value != null) {
        setState(() {
          pathFile = value.path;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.listMessager != null) {
      listMessager.addAll(widget.listMessager!);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image preview if selected
          if (pathFile.isNotEmpty) _buildImagePreview(),
          if (pathFile.isNotEmpty) SizedBox(height: 2.h),

          // Input row
          Row(
            children: [
              // Image selection button (green accent)
              Container(
                margin: EdgeInsets.all(1.w),
                decoration: BoxDecoration(
                  gradient: pathFile.isNotEmpty
                      ? LinearGradient(
                          colors: [Color(0xFF4FC3F7), Color(0xFFE1F5FE)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : LinearGradient(
                          colors: [Color(0xFFE8F6EA), Color(0xFFDFF7E8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color:
                          (pathFile.isNotEmpty
                                  ? Color(0xFF4FC3F7)
                                  : const Color(0xFF22C55E))
                              .withOpacity(0.12),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    pathFile.isNotEmpty
                        ? Icons.image
                        : Icons.add_photo_alternate,
                    color: pathFile.isNotEmpty
                        ? Colors.blue[700]
                        : const Color(0xFF166534),
                    size: 5.w,
                  ),
                  onPressed: () => _showImageOptions(context),
                  tooltip: pathFile.isNotEmpty
                      ? context.l10n.changeImage
                      : context.l10n.addImage,
                ),
              ),

              // Text input field
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: (controller.text.isNotEmpty || pathFile.isNotEmpty)
                          ? const Color(0xFFEAF7EB)
                          : Colors.grey[200]!,
                      width: 1.2,
                    ),
                  ),
                  child: TextField(
                    controller: controller,
                    maxLines: null,
                    autofocus: widget.autofocus,
                    focusNode: widget.focusNode,
                    style: TextStyle(color: Colors.black87, fontSize: 14.sp),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: pathFile.isNotEmpty
                          ? '${context.l10n.enterDiscriptionexplainImage}...'
                          : '${context.l10n.entarYourMessage}...',
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14.sp,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: pathFile.isNotEmpty ? 2.w : 4.w,
                        vertical: 14,
                      ),
                    ),
                    onChanged: (value) => setState(() {}),
                    onSubmitted: widget.onFieldSubmitted,
                  ),
                ),
              ),

              // Send button (green when enabled)
              Container(
                margin: EdgeInsets.all(1.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentDark,
                  boxShadow:
                      (controller.text.trim().isNotEmpty ||
                              pathFile.isNotEmpty) &&
                          !isSendMessager
                      ? [
                          BoxShadow(
                            color: const Color(0xFF22C55E).withOpacity(0.2),
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ]
                      : [],
                ),
                child: IconButton(
                  icon: isSendMessager
                      ? SizedBox(
                          width: 5.w,
                          height: 5.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              const Color(0xFF22C55E),
                            ),
                          ),
                        )
                      : Icon(
                          Icons.send_rounded,
                          color: Colors.black,
                          size: 5.w,
                        ),
                  onPressed: _handleSendMessage,
                  tooltip: context.l10n.sendMessage,
                  color:
                      (controller.text.trim().isNotEmpty ||
                              pathFile.isNotEmpty) &&
                          !isSendMessager
                      ? null
                      : null,
                  // wrap with colored circular background
                ),
                // colored background for active state
                // we use a Stack to layer a circular green bg behind the IconButton when active
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE1F5FE), Color(0xFFF0F8FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xFF4FC3F7).withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF4FC3F7).withOpacity(0.15),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image preview
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(pathFile),
                width: 15.w,
                height: 15.w,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 3.w),

          // Image information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.w,
                        vertical: 0.5.h,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF4FC3F7).withOpacity(0.2),
                            Color(0xFF4FC3F7).withOpacity(0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.image,
                            size: 3.w,
                            color: Color(0xFF4FC3F7),
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            context.l10n.image,
                            style: TextStyle(
                              color: Color(0xFF4FC3F7),
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                Text(
                  pathFile.split('/').last,
                  style: TextStyle(
                    color: Color(0xFF2D3748),
                    fontWeight: FontWeight.w500,
                    fontSize: 13.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 0.5.h),
                Text(
                  '${(File(pathFile).lengthSync() / 1024).toStringAsFixed(1)} KB',
                  style: TextStyle(color: Colors.grey[600], fontSize: 11.sp),
                ),
              ],
            ),
          ),

          // Delete button
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFCDD2), Color(0xFFFFEBEE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.2),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                Icons.close_rounded,
                color: Colors.red[600],
                size: 4.w,
              ),
              onPressed: () => setState(() => pathFile = ''),
              tooltip: context.l10n.removeImage,
            ),
          ),
        ],
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
                context.l10n.selectImageSource,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDark,
                ),
              ),
              SizedBox(height: 3.h),
              Row(
                children: [
                  Expanded(
                    child: _buildImageSourceOption(
                      icon: Icons.camera_alt,
                      title: context.l10n.camera,
                      subtitle: context.l10n.takeNewPhoto,
                      color: Color(0xFF4FC3F7),
                      onTap: () {
                        Navigator.pop(context);
                        actionTakePhoto();
                      },
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: _buildImageSourceOption(
                      icon: Icons.photo_library,
                      title: context.l10n.gallery,
                      subtitle: context.l10n.selectFromGallery,
                      color: Color(0xFF81C784),
                      onTap: () {
                        Navigator.pop(context);
                        actionSelectPhoto();
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

  Widget _buildImageSourceOption({
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
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              subtitle,
              style: TextStyle(color: color.withOpacity(0.7), fontSize: 11.sp),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showInsufficientCoinsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(4.w),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Color(0xFFF8F9FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFFFB6C1).withOpacity(0.2),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(6.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with coin icon
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFFFE4E1), Color(0xFFE6E6FA)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFFFFB6C1).withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange[700],
                          size: 6.w,
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          context.l10n.insufficientCoins,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryDark,
                              ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 4.h),

                  // Main content
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: Color(0xFFF8F9FF),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.orange[100]!, width: 1),
                    ),
                    child: Column(
                      children: [
                        // Warning message
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(2.w),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.orange.withOpacity(0.2),
                                    Colors.orange.withOpacity(0.1),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.monetization_on,
                                color: Colors.orange[700],
                                size: 5.w,
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    context.l10n.notEnoughCoins,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primaryDark,
                                        ),
                                  ),
                                  SizedBox(height: 0.5.h),
                                  Text(
                                    context.l10n.needCoinsToSend,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontSize: 12.sp,
                                          color: Colors.grey[600],
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 3.h),

                        // Description
                        Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue[50]!, Colors.indigo[50]!],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.blue[600],
                                    size: 4.w,
                                  ),
                                  SizedBox(width: 2.w),
                                  Text(
                                    context.l10n.information,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blue[700],
                                        ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 1.h),
                              Text(
                                context.l10n.rechargeCoinsMessage,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      fontSize: 12.sp,
                                      height: 1.4,
                                      color: Colors.blue[600],
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 4.h),

                  // Action buttons
                  Row(
                    children: [
                      // Close button
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.grey[200]!, Colors.grey[100]!],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(vertical: 2.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.close_rounded,
                                  color: Colors.grey[700],
                                  size: 5.w,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  context.l10n.cancel, // Using existing key
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: 3.w),

                      // Buy coins button
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF4ECDC4).withOpacity(0.3),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => InAppProductPage(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(vertical: 2.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shopping_cart_rounded,
                                  color: Colors.white,
                                  size: 5.w,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  context.l10n.buyCoins, // Using existing key
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleSendMessage() async {
    //triger check coin

    final coinUser = await serviceLocator.get<DataBaseFuntion>().getStar();

    if (coinUser < 5) {
      _showInsufficientCoinsDialog(context);
      return;
    }

    if ((controller.text.trim().isEmpty && pathFile.isEmpty) ||
        isSendMessager) {
      return;
    }

    setState(() {
      try {
        isSendMessager = true;
        if (widget.indexFunction == 2) {
          // Image generation logic
          listMessager.add(
            Message(role: 'user', content: controller.text, contents: []),
          );
          widget.onSendMessage?.call(
            listMessager.last,
            widget.indexFunction == 2,
          );
          final prompt = controller.text;
          controller.text = '';
          serviceLocator<Request>()
              .sendCreateImage(prompt, modelChat: 'dall-e-2')
              .then((value) {
                setState(() {
                  isSendMessager = false;
                  if (value.data['error'] != null) {
                    listMessager.add(
                      Message(
                        role: 'assistant',
                        content: value.data['error']['message'],
                        contents: [],
                      ),
                    );
                    widget.onresultMessage?.call(
                      listMessager.last,
                      widget.indexFunction == 2,
                    );
                  } else if (value.data['data'] != null) {
                    final listImage = List.from(value.data['data'])
                        .map(
                          (e) => ContentTypeMessage(
                            content: e['url'],
                            type: 'url_image',
                          ),
                        )
                        .toList();
                    listMessager.add(
                      Message(
                        role: 'assistant',
                        isImage: true,
                        content: '',
                        contents: listImage,
                      ),
                    );
                    widget.onresultMessage?.call(
                      listMessager.last,
                      widget.indexFunction == 2,
                    );
                  }
                });
              })
              .catchError((error) {
                setState(() {
                  isSendMessager = false;
                });
              });
        } else {
          // Chat message logic

          listMessager.add(
            Message(
              role: 'user',
              content: pathFile.isEmpty ? controller.text : '',
              timestamp: DateTime.now(),
              contents: pathFile.isEmpty
                  ? []
                  : [
                      ContentTypeMessage(
                        content: controller.text,
                        type: 'text',
                      ),
                      ContentTypeMessage(
                        content: base64Encode(File(pathFile).readAsBytesSync()),
                        type: 'image_url',
                      ),
                    ],
            ),
          );

          widget.onSendMessage?.call(
            listMessager.last,
            widget.indexFunction == 2,
          );

          // AI ROUTING FLOW: Try Offline Gemma first, fallback to Cloud (OziApi)
          if (Shared.instance.isInitializedModelAI &&
              Shared.instance.chat != null) {
            // LOCAL GENERATION (When initialized)
            final gemmaSvc = GemmaLocalService(Shared.instance.chat!);
            final gemmaMsg = gemma_message.Message(
              text: pathFile.isEmpty
                  ? controller.text.trim()
                  : controller.text.trim() + " [Image included]",
              isUser: true,
            );

            listMessager.add(
              Message(
                role: 'assistant',
                content: '',
                timestamp: DateTime.now(),
                contents: [],
              ),
            );
            final assIdx = listMessager.length - 1;
            controller.text = '';
            pathFile = '';

            gemmaSvc
                .processMessage(gemmaMsg, useSyncMode: false)
                .then((responseStream) {
                  responseStream.listen(
                    (response) {
                      if (response is gemma_response.TextResponse) {
                        setState(() {
                          listMessager[assIdx].content =
                              listMessager[assIdx].content + response.token;
                        });
                      }
                    },
                    onDone: () {
                      if (mounted) {
                        setState(() {
                          isSendMessager = false;
                        });
                        widget.onresultMessage?.call(
                          listMessager[assIdx],
                          widget.indexFunction == 2,
                        );
                      }
                    },
                    onError: (e) {
                      if (mounted) {
                        setState(() {
                          listMessager[assIdx].content =
                              '${listMessager[assIdx].content}\n(Lỗi AI: $e)';
                          isSendMessager = false;
                        });
                      }
                    },
                  );
                })
                .catchError((e) {
                  if (mounted) {
                    setState(() {
                      listMessager[assIdx].content = 'Lỗi khởi chạy AI: $e';
                      isSendMessager = false;
                    });
                    widget.onresultMessage?.call(
                      listMessager[assIdx],
                      widget.indexFunction == 2,
                    );
                  }
                });
          } else {
            // CLOUD FALLBACK (OziApi)
            serviceLocator<Request>()
                .sendMessageToChat(listMessager, modelChat: 'gpt-4o')
                .then((value) {
                  serviceLocator
                      .get<DataBaseFuntion>()
                      .saveStar(coinUser - 5)
                      .then((value) {
                        serviceLocator.get<MessagingService>().send(
                          channel: MessageChannel.startUserChanged,
                          parameter: '',
                        );
                      });
                  setState(() {
                    isSendMessager = false;
                    controller.text = '';
                    pathFile = '';
                    listMessager.add(value.choices.first.message);
                    widget.onresultMessage?.call(
                      listMessager.last,
                      widget.indexFunction == 2,
                    );
                  });
                })
                .catchError((error) {
                  setState(() {
                    isSendMessager = false;
                  });
                });
          }
        }
      } catch (e) {
        setState(() {
          isSendMessager = false;
        });
        print(e);
      }
    });
  }
}
