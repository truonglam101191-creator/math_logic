// import 'package:flutter_gemma/pigeon.g.dart';

// class OptionAiModel {
//   late final PreferredBackend preferredBackend;
//   late final String modelName;
//   late final String modelUrl;
//   late final String pathFile;

//   OptionAiModel({
//     required this.preferredBackend,
//     required this.modelName,
//     required this.modelUrl,
//     required this.pathFile,
//   });

//   factory OptionAiModel.fromMap(Map<String, dynamic> map) {
//     return OptionAiModel(
//       preferredBackend: PreferredBackend.values.firstWhere(
//         (e) => e.name == map['preferredBackend'],
//         orElse: () => PreferredBackend.gpu,
//       ),
//       modelName: map['modelName'] ?? '',
//       modelUrl: map['modelUrl'] ?? '',
//       pathFile: map['pathFile'] ?? '',
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'preferredBackend': preferredBackend.name,
//       'modelName': modelName,
//       'modelUrl': modelUrl,
//       'pathFile': pathFile,
//     };
//   }

//   OptionAiModel copyWith({
//     PreferredBackend? preferredBackend,
//     String? modelName,
//     String? modelUrl,
//     String? pathFile,
//   }) {
//     return OptionAiModel(
//       preferredBackend: preferredBackend ?? this.preferredBackend,
//       modelName: modelName ?? this.modelName,
//       modelUrl: modelUrl ?? this.modelUrl,
//       pathFile: pathFile ?? this.pathFile,
//     );
//   }
// }
