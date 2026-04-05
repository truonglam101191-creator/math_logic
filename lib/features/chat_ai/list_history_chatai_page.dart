import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logic_mathematics/cores/db_storage/db_funtion.dart';
import 'package:logic_mathematics/cores/extentions/shared.dart';
import 'package:logic_mathematics/cores/models/groupchatai_model.dart';
import 'package:logic_mathematics/cores/themes/app_colors.dart';
import 'package:logic_mathematics/features/chat_ai/history_chatai_page.dart';
import 'package:logic_mathematics/features/game_core/widgets/animated_background.dart';
import 'package:logic_mathematics/features/home/widgets/animated_scale_button.dart';
import 'package:logic_mathematics/l10n/arb/app_localizations.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ListHistoryChataiPage extends StatefulWidget {
  const ListHistoryChataiPage({super.key});

  @override
  State<ListHistoryChataiPage> createState() => _ListHistoryChataiPageState();
}

class _ListHistoryChataiPageState extends State<ListHistoryChataiPage> {
  final DataBaseFuntion _dbFunction = DataBaseFuntion();
  List<ChatGroup> _chatGroups = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Shared.instance.startBackgroundModelDownload();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    setState(() => _isLoading = true);
    final list = await _dbFunction.getListChatAi();
    setState(() {
      _chatGroups = list;
      _isLoading = false;
    });
  }

  Future<void> _deleteChat(String idGroup) async {
    final success = await _dbFunction.deleteChatAi(idGroup);
    if (success) {
      _loadChatHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: const AnimatedBackground(
            backgroundColor: Color(0xFFF3FFF3),
            particleColor: Color(0xFF22C55E), // Light green floating particles
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.white.withOpacity(0.4),
            elevation: 0,
            centerTitle: true,
            leading: Container(
              margin: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryDark.withOpacity(0.08),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: AppColors.primaryDark),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            title: Text(
              AppLocalizations.of(context).chatHistory,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDark,
              ),
            ),
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _chatGroups.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  padding: EdgeInsets.all(16),
                  itemCount: _chatGroups.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final chat = _chatGroups[index];
                    return _buildChatItem(chat);
                  },
                ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HistoryChataiPage(),
                ),
              ).then((_) => _loadChatHistory());
            },
            backgroundColor: AppColors.primaryDark,
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text(
              AppLocalizations.of(context).newChat,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryDark.withOpacity(0.1),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: AppColors.primaryDark,
            ),
          ),
          SizedBox(height: 24),
          Text(
            AppLocalizations.of(context).noModelsDownloaded,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(ChatGroup chat) {
    String previewText = '';
    if (chat.listchat.isNotEmpty) {
      previewText = chat.listchat.last.content;
      if (previewText.length > 50) {
        previewText = '${previewText.substring(0, 50)}...';
      }
    } else {
      previewText = '...';
    }

    final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(chat.updated);

    return AnimatedScaleButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HistoryChataiPage(chatGroup: chat),
          ),
        ).then((_) => _loadChatHistory());
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
            BoxShadow(color: Colors.white, blurRadius: 0, offset: Offset(0, 0)),
          ],
          border: Border.all(color: Colors.white),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF22C55E), const Color(0xFF16A34A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.psychology, color: Colors.white, size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          chat.namegroup.isNotEmpty
                              ? chat.namegroup
                              : AppLocalizations.of(context).defaultChatTitle,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    previewText,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.black54,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red[300]),
              onPressed: () {
                _showDeleteConfirm(context, chat.idGroup);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, String idGroup) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          AppLocalizations.of(context).deleteChatTitle,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(AppLocalizations.of(context).deleteChatConfirmContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context).cancel,
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              _deleteChat(idGroup);
            },
            child: Text(
              AppLocalizations.of(context).deleteAction,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
