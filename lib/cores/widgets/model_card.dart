// import 'package:flutter/material.dart';
// import 'package:flutter_gemma/pigeon.g.dart';
// import 'package:logic_mathematics/cores/db_storage/db_funtion.dart';
// import 'package:logic_mathematics/cores/models/ai_model.dart';
// import 'package:logic_mathematics/cores/models/option_ai_model.dart';
// import 'package:logic_mathematics/cores/services/model_download_service.dart';
// import 'package:logic_mathematics/l10n/l10n.dart';
// import 'package:logic_mathematics/main.dart';

// class ModelCard extends StatefulWidget {
//   final ModelAI model;
//   final bool isSelected;
//   final Function(PreferredBackend optionBackend)? onTap;
//   final Function(String path)? onDonedownload;
//   final bool isDonwload;

//   const ModelCard({
//     super.key,
//     required this.model,
//     this.isSelected = false,
//     this.onTap,
//     this.isDonwload = true,
//     this.onDonedownload,
//   });

//   @override
//   State<ModelCard> createState() => _ModelCardState();
// }

// class _ModelCardState extends State<ModelCard> {
//   final _isDownloading = ValueNotifier<bool>(false);

//   final _canceNotifier = ValueNotifier<bool>(false);

//   final _progressNotifier = ValueNotifier<double>(0.0);

//   final _backendNotifier = ValueNotifier<PreferredBackend>(
//     PreferredBackend.gpu,
//   );

//   late final ModelDownloadService _downloadService;

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     _downloadService = ModelDownloadService(
//       modelUrl: widget.model.url,
//       modelFilename: widget.model.name,
//       licenseUrl: widget.model.licenseUrl,
//     );
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     _isDownloading.dispose();
//     _canceNotifier.dispose();
//     _backendNotifier.dispose();
//   }

//   void _downloadModel() async {
//     final getToken = await serviceLocator
//         .get<DataBaseFuntion>()
//         .getTokenDownloadModel();
//     _isDownloading.value = true;
//     debugPrint('Selected backend: ${_backendNotifier.value.name}');
//     _downloadService.downloadModel(
//       token: getToken,
//       onProgress: (progress) {
//         _progressNotifier.value = progress;
//       },
//       cancelNotifier: _canceNotifier,
//       onComplete: () async {
//         // Save preferred backend to database

//         final pathFile = await _downloadService.getFilePath();
//         await serviceLocator
//             .get<DataBaseFuntion>()
//             .saveOptionAi(
//               OptionAiModel(
//                 modelName: widget.model.name,
//                 preferredBackend: _backendNotifier.value,
//                 modelUrl: widget.model.url,
//                 pathFile: pathFile,
//               ),
//             )
//             .then((value) {
//               if (widget.onDonedownload != null) {
//                 widget.onDonedownload!(pathFile);
//               }
//             });
//         if (mounted) {
//           setState(() {
//             _isDownloading.value = false;
//             _progressNotifier.value = 100.0;
//           });
//         }
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;

//     return InkWell(
//       onTap: widget.onTap != null
//           ? () => widget.onTap!(_backendNotifier.value)
//           : null,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         margin: const EdgeInsets.symmetric(vertical: 4),
//         decoration: BoxDecoration(
//           color: widget.isSelected
//               ? (isDark ? Colors.orange[800] : Colors.orange[100])
//               : (isDark ? const Color(0xFF232B3E) : Colors.grey[50]),
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(
//             color: widget.isSelected
//                 ? (isDark ? Colors.orange[600]! : Colors.orange[300]!)
//                 : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
//             width: widget.isSelected ? 2 : 1,
//           ),
//           boxShadow: widget.isSelected
//               ? [
//                   BoxShadow(
//                     color: (isDark ? Colors.orange[600]! : Colors.orange[300]!)
//                         .withOpacity(0.3),
//                     blurRadius: 8,
//                     offset: const Offset(0, 2),
//                   ),
//                 ]
//               : [],
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       widget.model.displayName,
//                       style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                         fontWeight: FontWeight.bold,
//                         color: widget.isSelected
//                             ? (isDark ? Colors.white : Colors.orange[800])
//                             : (isDark ? Colors.orange[200] : Colors.deepPurple),
//                         fontSize: 18,
//                       ),
//                     ),
//                   ),
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 8,
//                       vertical: 4,
//                     ),
//                     decoration: BoxDecoration(
//                       color: isDark ? Colors.grey[700] : Colors.grey[200],
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       widget.model.size,
//                       style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                         fontWeight: FontWeight.w500,
//                         color: isDark ? Colors.grey[300] : Colors.grey[600],
//                         fontSize: 12,
//                       ),
//                     ),
//                   ),
//                   if (widget.isSelected) ...[
//                     const SizedBox(width: 8),
//                     Icon(
//                       Icons.check_circle,
//                       color: isDark ? Colors.orange[400] : Colors.orange[600],
//                       size: 20,
//                     ),
//                   ],
//                 ],
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 widget.model.modelType.name,
//                 style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                   color: isDark ? Colors.grey[400] : Colors.grey[600],
//                   fontSize: 14,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               Wrap(
//                 spacing: 6,
//                 runSpacing: 4,
//                 children: [
//                   if (widget.model.supportImage)
//                     _buildFeatureChip('📷 ${context.l10n.multimodal}', isDark),
//                   if (widget.model.supportsFunctionCalls)
//                     _buildFeatureChip('⚡ ${context.l10n.function}', isDark),
//                   if (widget.model.isThinking)
//                     _buildFeatureChip('🧠 ${context.l10n.thinking}', isDark),
//                   _buildFeatureChip('🤖 ${context.l10n.chat}', isDark),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               // Backend selector
//               ValueListenableBuilder(
//                 valueListenable: _backendNotifier,
//                 builder: (context, backend, _) {
//                   return Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Backend:',
//                         style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                           fontWeight: FontWeight.w600,
//                           color: isDark
//                               ? Colors.orange[200]
//                               : Colors.deepPurple,
//                         ),
//                       ),
//                       const SizedBox(height: 6),
//                       ToggleButtons(
//                         isSelected: [
//                           backend == PreferredBackend.cpu,
//                           backend == PreferredBackend.gpu,
//                         ],
//                         onPressed: (index) {
//                           _backendNotifier.value = index == 0
//                               ? PreferredBackend.cpu
//                               : PreferredBackend.gpu;
//                         },
//                         borderRadius: BorderRadius.circular(12),
//                         borderColor: isDark
//                             ? Colors.grey[600]!
//                             : Colors.grey[400]!,
//                         selectedBorderColor: isDark
//                             ? Colors.orange[400]!
//                             : Colors.deepPurple,
//                         fillColor: isDark
//                             ? Colors.orange[700]!
//                             : Colors.deepPurple[100],
//                         selectedColor: isDark
//                             ? Colors.white
//                             : Colors.deepPurple[800],
//                         color: isDark ? Colors.orange[200] : Colors.deepPurple,
//                         constraints: const BoxConstraints(
//                           minHeight: 36,
//                           minWidth: 70,
//                         ),
//                         children: const [
//                           Padding(
//                             padding: EdgeInsets.symmetric(horizontal: 8),
//                             child: Text('CPU'),
//                           ),
//                           Padding(
//                             padding: EdgeInsets.symmetric(horizontal: 8),
//                             child: Text('GPU'),
//                           ),
//                         ],
//                       ),
//                     ],
//                   );
//                 },
//               ),
//               const SizedBox(height: 12),
//               if (widget.isDonwload)
//                 ValueListenableBuilder(
//                   valueListenable: _isDownloading,
//                   builder: (context, value, child) {
//                     return value
//                         ? ValueListenableBuilder(
//                             valueListenable: _progressNotifier,
//                             builder: (context, value, child) {
//                               return Column(
//                                 children: [
//                                   Text(
//                                     'Downloading: ${_progressNotifier.value.toStringAsFixed(0)}%',
//                                     style: TextStyle(
//                                       color: isDark
//                                           ? Colors.white
//                                           : Colors.black,
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   ),
//                                   Row(
//                                     children: [
//                                       Expanded(
//                                         child: LinearProgressIndicator(
//                                           value: _progressNotifier.value > 0.0
//                                               ? _progressNotifier.value / 100.0
//                                               : null,
//                                         ),
//                                       ),
//                                       TextButton(
//                                         onPressed: () {
//                                           _canceNotifier.value = true;
//                                           _isDownloading.value = false;
//                                           _progressNotifier.value = 0.0;
//                                         },
//                                         child: Text(context.l10n.cancel),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               );
//                             },
//                           )
//                         : TextButton(
//                             onPressed: _downloadModel,
//                             child: Text('Download Model'),
//                           );
//                   },
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildFeatureChip(String label, bool isDark) {
//     return Builder(
//       builder: (context) {
//         return Container(
//           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//           decoration: BoxDecoration(
//             color: isDark ? Colors.orange[900] : Colors.orange[50],
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(
//               color: isDark ? Colors.orange[700]! : Colors.orange[200]!,
//             ),
//           ),
//           child: Text(
//             label,
//             style: Theme.of(context).textTheme.bodySmall?.copyWith(
//               fontWeight: FontWeight.w500,
//               color: isDark ? Colors.orange[200] : Colors.orange[800],
//               fontSize: 12,
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
