// import 'package:flutter/material.dart';
// import 'package:flutter_gemma/pigeon.g.dart';
// import 'package:logic_mathematics/cores/db_storage/db_funtion.dart';
// import 'package:logic_mathematics/cores/models/ai_model.dart';
// import 'package:logic_mathematics/cores/models/option_ai_model.dart';
// import 'package:logic_mathematics/cores/widgets/model_card.dart';
// import 'package:logic_mathematics/l10n/l10n.dart';
// import 'package:logic_mathematics/cores/themes/app_colors.dart';
// import 'package:logic_mathematics/main.dart';

// enum SortType {
//   defaultOrder('Default'),
//   alphabetical('Alphabetical'),
//   size('Size');

//   const SortType(this.displayName);
//   final String displayName;
// }

// class SelectModleChatAiBottomsheet extends StatefulWidget {
//   const SelectModleChatAiBottomsheet({super.key});

//   @override
//   State<SelectModleChatAiBottomsheet> createState() =>
//       _SelectModleChatAiBottomsheetState();
// }

// class _SelectModleChatAiBottomsheetState
//     extends State<SelectModleChatAiBottomsheet> {
//   SortType selectedSort = SortType.defaultOrder;
//   bool showFilters = false;

//   final List<OptionAiModel> _downloadedModels = [];

//   // Filter states
//   bool filterMultimodal = false;
//   bool filterFunctionCalls = false;
//   bool filterThinking = false;
//   String modelSelected = '';

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
//     switch (selectedSort) {
//       case SortType.alphabetical:
//         return [...models]
//           ..sort((a, b) => a.displayName.compareTo(b.displayName));
//       case SortType.size:
//         return [...models]
//           ..sort((a, b) => _sizeToMB(a.size).compareTo(_sizeToMB(b.size)));
//       case SortType.defaultOrder:
//         return models; // Keep original order
//     }
//   }

//   List<ModelAI> _filterModels(List<ModelAI> models) {
//     return models.where((model) {
//       // Feature filters
//       if (filterMultimodal && !model.supportImage) return false;
//       if (filterFunctionCalls && !model.supportsFunctionCalls) return false;
//       if (filterThinking && !model.isThinking) return false;

//       return true;
//     }).toList();
//   }

//   void _clearFilters() {
//     setState(() {
//       filterMultimodal = false;
//       filterFunctionCalls = false;
//       filterThinking = false;
//     });
//   }

//   String _getModelsWord(int count) {
//     if (count == 1) {
//       return context.l10n.model;
//     } else {
//       return context.l10n.models;
//     }
//   }

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       serviceLocator.get<DataBaseFuntion>().getOptionAi().then((value) {
//         if (mounted) {
//           setState(() {
//             _downloadedModels.addAll(value);
//           });
//         }
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final mainColor = AppColors.primaryDark;
//     final accentColor = AppColors.accentDark;
//     var models = ModelAI.values;

//     // Apply filtering then sorting
//     models = _filterModels(models);
//     models = _sortModels(models);

//     return Container(
//       decoration: BoxDecoration(
//         color: theme.scaffoldBackgroundColor,
//         borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
//         boxShadow: [
//           BoxShadow(
//             color: theme.scaffoldBackgroundColor.withOpacity(0.1),
//             blurRadius: 16,
//             offset: const Offset(0, -4),
//           ),
//         ],
//       ),
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       child: Column(
//         children: [
//           // Handle bar
//           Container(
//             width: 40,
//             height: 4,
//             margin: const EdgeInsets.only(bottom: 16),
//             decoration: BoxDecoration(
//               color: accentColor.withOpacity(0.4),
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),
//           // Title
//           Text(
//             context.l10n.selectAIModel,
//             style: theme.textTheme.titleMedium?.copyWith(
//               fontWeight: FontWeight.bold,
//               color: mainColor,
//             ),
//           ),
//           const SizedBox(height: 16),
//           // Filters section
//           Container(
//             margin: const EdgeInsets.only(bottom: 12.0),
//             child: Column(
//               children: [
//                 // Filter header
//                 InkWell(
//                   borderRadius: BorderRadius.circular(8),
//                   onTap: () {
//                     setState(() {
//                       showFilters = !showFilters;
//                     });
//                   },
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(vertical: 8.0),
//                     child: Row(
//                       children: [
//                         Icon(
//                           showFilters
//                               ? Icons.filter_list
//                               : Icons.filter_list_outlined,
//                           color: accentColor,
//                         ),
//                         const SizedBox(width: 8),
//                         Text(
//                           context.l10n.filters,
//                           style: theme.textTheme.titleSmall?.copyWith(
//                             fontWeight: FontWeight.w600,
//                             color: mainColor,
//                           ),
//                         ),
//                         const Spacer(),
//                         Icon(
//                           showFilters ? Icons.expand_less : Icons.expand_more,
//                           color: accentColor,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 // Filter options
//                 AnimatedContainer(
//                   duration: const Duration(milliseconds: 200),
//                   height: showFilters ? null : 0,
//                   child: showFilters
//                       ? Container(
//                           padding: const EdgeInsets.all(12.0),
//                           decoration: BoxDecoration(
//                             color: theme.cardColor,
//                             borderRadius: BorderRadius.circular(8.0),
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 '${context.l10n.features}:',
//                                 style: theme.textTheme.bodyMedium?.copyWith(
//                                   fontWeight: FontWeight.w500,
//                                   color: mainColor,
//                                 ),
//                               ),
//                               const SizedBox(height: 8),
//                               Wrap(
//                                 spacing: 8,
//                                 children: [
//                                   FilterChip(
//                                     label: Text(
//                                       context.l10n.multimodal,
//                                       style: theme.textTheme.bodySmall
//                                           ?.copyWith(
//                                             color: filterMultimodal
//                                                 ? Colors.white
//                                                 : mainColor,
//                                           ),
//                                     ),
//                                     selected: filterMultimodal,
//                                     onSelected: (bool selected) {
//                                       setState(() {
//                                         filterMultimodal = selected;
//                                       });
//                                     },
//                                     selectedColor: accentColor,
//                                     backgroundColor: theme.cardColor,
//                                   ),
//                                   FilterChip(
//                                     label: Text(
//                                       context.l10n.functionCalls,
//                                       style: theme.textTheme.bodySmall
//                                           ?.copyWith(
//                                             color: filterFunctionCalls
//                                                 ? Colors.white
//                                                 : mainColor,
//                                           ),
//                                     ),
//                                     selected: filterFunctionCalls,
//                                     onSelected: (bool selected) {
//                                       setState(() {
//                                         filterFunctionCalls = selected;
//                                       });
//                                     },
//                                     selectedColor: accentColor,
//                                     backgroundColor: theme.cardColor,
//                                   ),
//                                   FilterChip(
//                                     label: Text(
//                                       context.l10n.thinking,
//                                       style: theme.textTheme.bodySmall
//                                           ?.copyWith(
//                                             color: filterThinking
//                                                 ? Colors.white
//                                                 : mainColor,
//                                           ),
//                                     ),
//                                     selected: filterThinking,
//                                     onSelected: (bool selected) {
//                                       setState(() {
//                                         filterThinking = selected;
//                                       });
//                                     },
//                                     selectedColor: accentColor,
//                                     backgroundColor: theme.cardColor,
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 12),
//                               Center(
//                                 child: TextButton(
//                                   onPressed: _clearFilters,
//                                   child: Text(
//                                     context.l10n.clearFilters,
//                                     style: theme.textTheme.bodyMedium?.copyWith(
//                                       color: accentColor,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         )
//                       : null,
//                 ),
//               ],
//             ),
//           ),
//           // Sort selector
//           Container(
//             margin: const EdgeInsets.only(bottom: 12.0),
//             child: Row(
//               children: [
//                 Text(
//                   '${context.l10n.sort}:',
//                   style: theme.textTheme.titleSmall?.copyWith(
//                     fontWeight: FontWeight.w600,
//                     color: mainColor,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: DropdownButton<SortType>(
//                     value: selectedSort,
//                     isExpanded: true,
//                     dropdownColor: Theme.of(context).cardTheme.color,
//                     style: theme.textTheme.bodyMedium?.copyWith(
//                       color: mainColor,
//                     ),
//                     icon: Icon(Icons.arrow_drop_down, color: accentColor),
//                     items: SortType.values.map((type) {
//                       return DropdownMenuItem<SortType>(
//                         value: type,
//                         child: Text(
//                           type.displayName,
//                           style: theme.textTheme.bodyMedium,
//                         ),
//                       );
//                     }).toList(),
//                     onChanged: (SortType? newValue) {
//                       if (newValue != null) {
//                         setState(() {
//                           selectedSort = newValue;
//                         });
//                       }
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // Results counter
//           Container(
//             margin: const EdgeInsets.only(bottom: 8.0),
//             child: Text(
//               '${context.l10n.showing} ${models.length} ${_getModelsWord(models.length)}',
//               style: theme.textTheme.bodySmall?.copyWith(
//                 color: accentColor.withOpacity(0.7),
//               ),
//             ),
//           ),
//           // Models list
//           Expanded(
//             child: ListView.builder(
//               itemCount: models.length,
//               itemBuilder: (context, index) {
//                 final model = models[index];
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 4.0),
//                   child: ModelCard(
//                     model: model,
//                     isDonwload: _downloadedModels.every(
//                       (element) => element.modelName != model.name,
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
