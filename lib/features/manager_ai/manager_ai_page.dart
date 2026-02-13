// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:logic_mathematics/cores/db_storage/db_funtion.dart';
// import 'package:logic_mathematics/cores/models/ai_model.dart';
// import 'package:logic_mathematics/cores/models/option_ai_model.dart';
// import 'package:logic_mathematics/cores/widgets/model_card.dart';
// import 'package:logic_mathematics/l10n/l10n.dart';
// import 'package:logic_mathematics/cores/themes/app_colors.dart';
// import 'package:logic_mathematics/main.dart';
// import 'package:responsive_sizer/responsive_sizer.dart';

// enum SortType {
//   defaultOrder('Default'),
//   alphabetical('Alphabetical'),
//   size('Size'),
//   lastUsed('Last Used'),
//   downloadDate('Download Date');

//   const SortType(this.displayName);
//   final String displayName;
// }

// enum ModelViewType { all, downloaded, available }

// class ManagerAiPage extends StatefulWidget {
//   const ManagerAiPage({super.key});

//   @override
//   State<ManagerAiPage> createState() => _ManagerAiPageState();
// }

// class _ManagerAiPageState extends State<ManagerAiPage> {
//   final List<OptionAiModel> _downloadedModels = [];
//   double _totalStorageUsed = 0.0;
//   final double _maxStorage = 10240; // 10GB in MB

//   String selectedModepath = '';

//   final _strameBuildItem = StreamController.broadcast();

//   @override
//   void initState() {
//     super.initState();
//     _loadDownloadedModels();
//   }

//   @override
//   void dispose() {
//     _strameBuildItem.close();
//     super.dispose();
//   }

//   Future<void> _loadDownloadedModels() async {
//     final models = await serviceLocator.get<DataBaseFuntion>().getOptionAi();
//     selectedModepath = await serviceLocator
//         .get<DataBaseFuntion>()
//         .getPathModelChatAi();
//     if (mounted) {
//       setState(() {
//         _downloadedModels.clear();
//         _downloadedModels.addAll(models);
//         _calculateStorageUsed();
//       });
//     }
//   }

//   void _calculateStorageUsed() {
//     double totalSize = 0.0;
//     for (final downloadedModel in _downloadedModels) {
//       final modelAI = ModelAI.values.firstWhere(
//         (model) => model.name == downloadedModel.modelName,
//         orElse: () => ModelAI.values.first,
//       );
//       totalSize += _sizeToMB(modelAI.size);
//     }
//     _totalStorageUsed = totalSize;
//   }

//   double _sizeToMB(String size) {
//     final numStr = size.replaceAll(RegExp(r'[^0-9.]'), '');
//     final num = double.tryParse(numStr) ?? 0;

//     if (size.toUpperCase().contains('GB')) {
//       return num * 1024;
//     } else if (size.toUpperCase().contains('TB')) {
//       return num * 1024 * 1024;
//     }
//     return num;
//   }

//   List<ModelAI> _sortModels(List<ModelAI> models) {
//     // Simple default sort - alphabetical
//     return [...models]..sort((a, b) => a.displayName.compareTo(b.displayName));
//   }

//   List<ModelAI> _filterModels(List<ModelAI> models) {
//     // Simple filter - return all models
//     return models;
//   }

//   List<ModelAI> _getModelsForView(ModelViewType viewType) {
//     List<ModelAI> models = [];

//     switch (viewType) {
//       case ModelViewType.downloaded:
//         // Show all downloaded models
//         models = ModelAI.values
//             .where(
//               (model) => _downloadedModels.any(
//                 (downloaded) => downloaded.modelName == model.name,
//               ),
//             )
//             .toList();
//         break;
//       case ModelViewType.available:
//         // Show models that are NOT downloaded yet
//         models = ModelAI.values
//             .where(
//               (model) => !_downloadedModels.any(
//                 (downloaded) => downloaded.modelName == model.name,
//               ),
//             )
//             .toList();
//         break;
//       case ModelViewType.all:
//         // Show all models (both downloaded and available)
//         models = ModelAI.values.toList();
//         break;
//     }

//     // Apply filtering then sorting
//     models = _filterModels(models);
//     models = _sortModels(models);
//     return models;
//   }

//   String _getModelsWord(int count) {
//     if (count == 1) {
//       return context.l10n.model;
//     } else {
//       return context.l10n.models;
//     }
//   }

//   Widget _buildSection({
//     required String title,
//     required List<Widget> children,
//   }) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 3.h),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             margin: EdgeInsets.only(left: 4.w, bottom: 2.h),
//             padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Color(0xFFFFE4E1), Color(0xFFE6E6FA)],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: [
//                 BoxShadow(
//                   color: Color(0xFFFFB6C1).withOpacity(0.3),
//                   blurRadius: 8,
//                   offset: Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Text(
//               '✨ $title',
//               style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                 fontSize: 16.sp,
//                 fontWeight: FontWeight.w600,
//                 color: AppColors.primaryDark,
//               ),
//             ),
//           ),
//           Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: [
//                 BoxShadow(
//                   color: Color(0xFFFFB6C1).withOpacity(0.15),
//                   blurRadius: 15,
//                   offset: Offset(0, 5),
//                 ),
//               ],
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(20),
//               child: Column(children: children),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStorageIndicator() {
//     final usagePercentage = _totalStorageUsed / _maxStorage;

//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: EdgeInsets.all(3.w),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       Color(0xFF4FC3F7).withOpacity(0.2),
//                       Color(0xFF4FC3F7).withOpacity(0.1),
//                     ],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Color(0xFF4FC3F7).withOpacity(0.3),
//                       blurRadius: 8,
//                       offset: Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Icon(Icons.storage, color: Color(0xFF4FC3F7), size: 6.w),
//               ),
//               SizedBox(width: 4.w),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Storage Used',
//                       style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                         fontSize: 16.sp,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     Text(
//                       '${(_totalStorageUsed / 1024).toStringAsFixed(2)} GB / ${(_maxStorage / 1024).toStringAsFixed(0)} GB',
//                       style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                         fontSize: 13.sp,
//                         height: 1.2,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 2.h),
//           LinearProgressIndicator(
//             value: usagePercentage.clamp(0.0, 1.0),
//             backgroundColor: Color(0xFFE2E8F0),
//             valueColor: AlwaysStoppedAnimation<Color>(
//               usagePercentage > 0.8 ? Colors.red : Color(0xFF4FC3F7),
//             ),
//           ),
//           SizedBox(height: 1.h),
//           Text(
//             '${_downloadedModels.length} ${_getModelsWord(_downloadedModels.length)} downloaded',
//             style: Theme.of(context).textTheme.bodySmall?.copyWith(
//               color: Color(0xFF9CA3AF),
//               fontSize: 12.sp,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDownloadedModelsList() {
//     final downloadedModels = _getModelsForView(ModelViewType.downloaded);

//     if (downloadedModels.isEmpty) {
//       return Container(
//         padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
//         child: Column(
//           children: [
//             Icon(Icons.cloud_download, size: 15.w, color: Color(0xFF9CA3AF)),
//             SizedBox(height: 2.h),
//             Text(
//               'No models downloaded yet',
//               style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                 color: Color(0xFF9CA3AF),
//                 fontSize: 16.sp,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             SizedBox(height: 1.h),
//             Text(
//               'Download models to use AI features',
//               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                 color: Color(0xFF9CA3AF),
//                 fontSize: 13.sp,
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     return Column(
//       children: downloadedModels.map((model) {
//         final isDownloaded = _downloadedModels.any(
//           (downloaded) => downloaded.modelName == model.name,
//         );

//         return Padding(
//           padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
//           child: StreamBuilder(
//             stream: _strameBuildItem.stream,
//             builder: (context, asyncSnapshot) {
//               return ModelCard(
//                 model: model,
//                 isSelected: selectedModepath.contains(model.name),
//                 isDonwload: !isDownloaded,
//                 onTap: (val) async {
//                   if (!isDownloaded) return;
//                   selectedModepath = _downloadedModels
//                       .where((element) => element.modelName == model.name)
//                       .first
//                       .pathFile;
//                   _strameBuildItem.add(null);
//                   serviceLocator.get<DataBaseFuntion>().savePathModelChatAi(
//                     selectedModepath,
//                   );
//                 },
//                 onDonedownload: (val) {
//                   _loadDownloadedModels();
//                 },
//               );
//             },
//           ),
//         );
//       }).toList(),
//     );
//   }

//   Widget _buildAvailableModelsList() {
//     final availableModels = _getModelsForView(ModelViewType.available);

//     if (availableModels.isEmpty) {
//       return Container(
//         padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
//         child: Column(
//           children: [
//             Icon(Icons.check_circle, size: 15.w, color: Color(0xFF81C784)),
//             SizedBox(height: 2.h),
//             Text(
//               'All available models downloaded!',
//               style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                 color: Color(0xFF81C784),
//                 fontSize: 16.sp,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             SizedBox(height: 1.h),
//             Text(
//               'You have downloaded all available models',
//               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                 color: Color(0xFF9CA3AF),
//                 fontSize: 13.sp,
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     return Column(
//       children: [
//         // Header showing count
//         Container(
//           padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
//           child: Row(
//             children: [
//               Icon(Icons.cloud_download, color: Color(0xFF4FC3F7), size: 5.w),
//               SizedBox(width: 3.w),
//               Text(
//                 '${availableModels.length} ${_getModelsWord(availableModels.length)} available to download',
//                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                   color: Color(0xFF4FC3F7),
//                   fontSize: 14.sp,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         // Models list
//         ...availableModels.map((model) {
//           final isDownloaded = _downloadedModels.any(
//             (downloaded) => downloaded.modelName == model.name,
//           );

//           return Padding(
//             padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
//             child: StreamBuilder(
//               stream: _strameBuildItem.stream,
//               builder: (context, asyncSnapshot) {
//                 return ModelCard(
//                   model: model,
//                   isSelected: false,
//                   isDonwload: !isDownloaded,
//                   onTap: (val) async {
//                     // Available models can't be selected, only downloaded
//                   },
//                   onDonedownload: (val) {
//                     _loadDownloadedModels();
//                   },
//                 );
//               },
//             ),
//           );
//         }).toList(),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFFF8F9FF), // Same as SettingPage
//       appBar: AppBar(
//         title: Text(
//           context.l10n.aiModelManager,
//           style: TextStyle(
//             fontSize: 20.sp,
//             fontWeight: FontWeight.w700,
//             color: AppColors.primaryDark,
//           ),
//         ),
//         centerTitle: true,
//         scrolledUnderElevation: 0,
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: Container(
//           margin: EdgeInsets.all(2.w),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//             boxShadow: [
//               BoxShadow(
//                 color: AppColors.primaryDark.withOpacity(0.1),
//                 blurRadius: 8,
//                 offset: Offset(0, 2),
//               ),
//             ],
//           ),
//           child: IconButton(
//             icon: Icon(
//               Icons.arrow_back_ios_rounded,
//               color: AppColors.primaryDark,
//             ),
//             onPressed: () => Navigator.pop(context),
//           ),
//         ),
//         actions: [
//           Container(
//             margin: EdgeInsets.all(2.w),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: [
//                 BoxShadow(
//                   color: AppColors.primaryDark.withOpacity(0.1),
//                   blurRadius: 8,
//                   offset: Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: IconButton(
//               icon: Icon(Icons.refresh, color: AppColors.primaryDark),
//               onPressed: _loadDownloadedModels,
//               tooltip: context.l10n.refreshModels,
//             ),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: SingleChildScrollView(
//               padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Storage Info Section
//                   _buildSection(
//                     title: context.l10n.storageUsed,
//                     children: [_buildStorageIndicator()],
//                   ),

//                   SizedBox(height: 2.h),

//                   // Downloaded Models Section
//                   _buildSection(
//                     title: context.l10n.downloadedModels,
//                     children: [_buildDownloadedModelsList()],
//                   ),

//                   SizedBox(height: 2.h),

//                   // Available Models Section
//                   _buildSection(
//                     title: context.l10n.availableModels,
//                     children: [_buildAvailableModelsList()],
//                   ),

//                   SizedBox(height: 4.h),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
