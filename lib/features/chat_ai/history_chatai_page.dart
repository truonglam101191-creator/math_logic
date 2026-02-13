import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logic_mathematics/cores/configs/configs.dart';
import 'package:logic_mathematics/cores/extentions/messagingservice.dart';
import 'package:logic_mathematics/cores/extentions/shared.dart';
import 'package:logic_mathematics/cores/models/groupchatai_model.dart';
import 'package:logic_mathematics/cores/models/messager_upgrade_model.dart';
import 'package:logic_mathematics/cores/themes/app_colors.dart';
import 'package:logic_mathematics/cores/widgets/user_coin_widget.dart';
import 'package:logic_mathematics/features/chat_ai/widgets/inputchatai_widget.dart';
import 'package:logic_mathematics/features/home/widgets/animated_scale_button.dart';
import 'package:logic_mathematics/l10n/arb/app_localizations.dart';
import 'package:logic_mathematics/main.dart';
import 'package:oziapi/models/request_model.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class HistoryChataiPage extends StatefulWidget {
  const HistoryChataiPage({super.key, this.chatGroup, this.index = 0});

  final ChatGroup? chatGroup;
  final int index;

  @override
  State<HistoryChataiPage> createState() => _HistoryChataiPageState();
}

class _HistoryChataiPageState extends State<HistoryChataiPage> {
  final controller = TextEditingController();

  final focsunode = FocusNode();

  String name = '${Shared.instance.packageInfo.appName.split(':').first} Chat';

  bool isChanged = false;

  int indexCopy = 0;

  late final ChatGroup chatGroup;

  final messageCenter = serviceLocator.get<MessagingService>();

  final List<String> languagesSupport = [];

  final List<MessagerUpgradeModel> listMessages = [];

  late InputchataiWidgetState controlerInput;

  final _scrollController = ScrollController();

  final duration = const Duration(milliseconds: 300);

  void getListChat() {
    if (widget.chatGroup != null) {
      chatGroup = widget.chatGroup!;
      name = chatGroup.namegroup;
    } else {
      chatGroup = ChatGroup(
        idGroup: Configs.instance.generate(),
        namegroup: name,
        listchat: [],
        created: DateTime.now(),
        updated: DateTime.now(),
      );
    }

    if (widget.chatGroup != null) {
      for (var element in widget.chatGroup!.listchat) {
        listMessages.add(
          MessagerUpgradeModel(
            content: element.content,
            role: element.role,
            contents: element.contents,
            isImage: element.isImage,
          ),
        );
      }
    }
  }

  void checkCondition() async {
    await Future.delayed(const Duration(milliseconds: 300));

    switch (widget.index) {
      case 1:
        controlerInput.actionSelectPhoto();
        break;
      case 2:
        //controlerInput.actionSelectPhoto();
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(
      const Duration(milliseconds: 600),
    ).then((value) => focsunode.requestFocus());
    getListChat();

    checkCondition();
    if (widget.index > 0) {
      indexCopy = listMessages.every((element) => element.isImage)
          ? 2
          : widget.index;
    }
    _scrollDown();
  }

  @override
  void dispose() {
    super.dispose();
    SystemChannels.textInput.invokeMethod("TextInput.hide");

    if (isChanged) {
      chatGroup.listchat.clear();
      chatGroup.listchat.addAll(
        listMessages.map(
          (e) => Message(
            role: e.role,
            isImage: e.isImage,
            content: e.content,
            contents: e.contents,
          ),
        ),
      );
    }
  }

  void _scrollDown() {
    if (listMessages.isNotEmpty) {
      Future.delayed(duration).then((value) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: duration,
          curve: Curves.linear,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3FFF3),
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              'Người bạn AI',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDark,
              ),
            ),
            SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF22C55E).withOpacity(0.65),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Đang trực tuyến',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: AppColors.primaryDark.withOpacity(0.72),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white.withOpacity(0.7),
        elevation: 0,
        leading: Container(
          margin: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withOpacity(0.12),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.primaryDark),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          UserCoinWidget(),
          SizedBox(width: 5),
          Container(
            margin: EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryDark.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () {
                _showCoinInfoDialog(context);
              },
              icon: Icon(Icons.help_outline, color: AppColors.primaryDark),
              tooltip: AppLocalizations.of(context)!.coinInfoTooltip,
            ),
          ),
          SizedBox(width: 15),
        ],
      ),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    return Column(
      children: [
        // Messages area (empty state or list) is constrained inside Expanded
        Expanded(
          child: listMessages.isNotEmpty
              ? ListView.separated(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  itemBuilder: (BuildContext context, int index) =>
                      buildItemChat(listMessages[index]),
                  separatorBuilder: (BuildContext context, int index) =>
                      SizedBox(height: 2.h),
                  itemCount: listMessages.length,
                )
              : indexCopy == 2
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [],
                )
              : _buildEmptyState(),
        ),

        // Input section
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            border: Border(
              top: BorderSide(color: const Color(0xFFEAF7EB), width: 1),
            ),
          ),
          child: SafeArea(
            top: false,
            child: InputchataiWidget(
              focusNode: focsunode,
              indexFunction: indexCopy,
              onCreate: (controller) {
                controlerInput = controller;
              },
              onSendMessage: (val, isImgae) => setState(() {
                listMessages.add(
                  MessagerUpgradeModel(
                    content: val.content,
                    isImage: val.isImage,
                    role: val.role,
                    contents: val.contents,
                  ),
                );
              }),
              onresultMessage: (val, isImgae) => setState(() {
                isChanged = true;
                listMessages.add(
                  MessagerUpgradeModel(
                    content: val.content,
                    role: val.role,
                    contents: val.contents,
                    isImage: val.isImage,
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildItemChat(MessagerUpgradeModel item) {
    final isUser = item.role == 'user';

    return Container(
      margin: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isUser) _buildAvatar(false),
          if (!isUser) SizedBox(width: 3.w),

          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: 72.w),
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.6.h),
              decoration: BoxDecoration(
                gradient: isUser
                    ? LinearGradient(
                        colors: [
                          const Color(0xFF22C55E),
                          const Color(0xFF16A34A),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : LinearGradient(
                        colors: [Colors.white, const Color(0xFFF7FFF7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: isUser
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                        bottomLeft: Radius.circular(13),
                      )
                    : const BorderRadius.only(
                        topLeft: Radius.circular(3),
                        topRight: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(13),
                      ),
                boxShadow: [
                  BoxShadow(
                    color: isUser
                        ? const Color(0xFF22C55E).withOpacity(0.14)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ],
                border: !isUser
                    ? Border.all(color: const Color(0xFFEFFAF0), width: 1)
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text content
                  if (item.content.isNotEmpty || item.contents.isNotEmpty)
                    SelectableText(
                      item.contents.isNotEmpty
                          ? item.contents.first.content
                          : item.content,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14.sp,
                        height: 1.45,
                        color: isUser ? Colors.white : Colors.black87,
                        fontWeight: isUser ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),

                  // Image content
                  if (item.contents.length > 1 && !isUser)
                    Padding(
                      padding: EdgeInsets.only(top: 2.h),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          height: 150,
                          base64Decode(
                            item.contents.last.content.replaceAll(
                              Shared.instance.character,
                              '',
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Network image for AI generated images
                  if (item.isImage && !isUser)
                    Padding(
                      padding: EdgeInsets.only(top: 2.h),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          item.contents.first.content,
                          width: 60.w,
                          height: 250,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                  // Copy button for AI messages
                  if (!isUser && !item.isImage)
                    Padding(
                      padding: EdgeInsets.only(top: 2.h),
                      child: Row(
                        children: [
                          _buildActionButton(
                            icon: Icons.copy,
                            tooltip: AppLocalizations.of(context)!.copy,
                            color: const Color(0xFF4CAF50),
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: item.content),
                              ).then((value) {
                                Fluttertoast.showToast(
                                  msg: AppLocalizations.of(
                                    context,
                                  ).copiedToClipboard,
                                );
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          if (isUser) SizedBox(width: 3.w),
          if (isUser) _buildAvatar(true),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return AnimatedScaleButton(
      onPressed: onPressed,
      child: Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 4.w),
      ),
    );
  }

  Widget buildIconButton({String pathImage = '', void Function()? onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Icon(Icons.copy, size: 20),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 10.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE1F5FE), Color(0xFFF8F9FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF4FC3F7).withOpacity(0.2),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 20.w,
              color: Color(0xFF4FC3F7),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            AppLocalizations.of(context)!.startConversation,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            AppLocalizations.of(context)!.askMeAnything,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 14.sp,
              height: 1.4,
              color: AppColors.primaryDark.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isUser) {
    if (!isUser) {
      // bot avatar uses network image + green ring
      return Container(
        width: 10.w,
        height: 10.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: const DecorationImage(
            image: NetworkImage(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuAve5TMmCezlYiVQ2lMxFTBTVipTIAH9jafR0xhMo4Xa2R1r2LQkPeLMfcEGikcbswJuP6aLb8_zRNfXqa0exljT8t50xeIqW2Lx4ZQX4blaZ14KZvUkg8zkl4TlR8olK8k1Ex-aqF1oMAtMfDLFs3yvMGO4gz57MITM9hVpcK60VuPxt1s-vCiV15EIhUSNYWoaP-4EitcjuaTJX0LAKyDWsx4v9sZKRkqcOlvvTZjNjuDV1tsovJ5e2xugjNCuOvlN-SHAklTfw',
            ),
            fit: BoxFit.cover,
          ),
          border: Border.all(color: const Color(0xFF22C55E), width: 3.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF22C55E).withOpacity(0.14),
              blurRadius: 12,
              offset: Offset(0, 3),
            ),
          ],
        ),
      );
    }

    // user avatar (unchanged style but adjusted)
    return Container(
      width: 10.w,
      height: 10.w,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFD6E0), Color(0xFFFFEAF0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0xFFFFC1D3).withOpacity(0.28),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Icon(Icons.person, color: Colors.pink[700], size: 5.w),
    );
  }

  void _showCoinInfoDialog(BuildContext context) {
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
                          Icons.monetization_on,
                          color: Colors.amber[700],
                          size: 6.w,
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          AppLocalizations.of(context)!.coinInfo,
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
                      border: Border.all(color: Colors.blue[100]!, width: 1),
                    ),
                    child: Column(
                      children: [
                        // Cost info
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(2.w),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.amber.withOpacity(0.2),
                                    Colors.amber.withOpacity(0.1),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.chat_bubble_outline,
                                color: Colors.amber[700],
                                size: 5.w,
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.costPerChat,
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
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.monetization_on,
                                        color: Colors.amber[700],
                                        size: 4.w,
                                      ),
                                      SizedBox(width: 1.w),
                                      Text(
                                        AppLocalizations.of(context)!.fiveCoins,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.amber[700],
                                            ),
                                      ),
                                    ],
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
                                    AppLocalizations.of(context)!.note,
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
                                AppLocalizations.of(context)!.coinUsageNote,
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

                  // Close button
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF4FC3F7), Color(0xFFE1F5FE)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF4FC3F7).withOpacity(0.3),
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
                            Icons.check_circle_outline,
                            color: Colors.blue[700],
                            size: 5.w,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            AppLocalizations.of(context)!.understood,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
