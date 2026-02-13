// import 'package:flutter/material.dart';
// import 'package:flutter_gemma/core/chat.dart';
// import 'package:flutter_gemma/core/message.dart';
// import 'package:flutter_gemma/core/model_response.dart';
// import 'package:flutter_gemma/core/tool.dart';
// import 'package:flutter_gemma/flutter_gemma_interface.dart';
// import 'package:logic_mathematics/cores/extentions/shared.dart';
// import 'package:logic_mathematics/features/chat_ai/widgets/chat_widget.dart';
// import 'package:logic_mathematics/features/chat_ai/widgets/loading_widget.dart';

// class ChatScreen extends StatefulWidget {
//   const ChatScreen({super.key});
//   @override
//   ChatScreenState createState() => ChatScreenState();
// }

// class ChatScreenState extends State<ChatScreen> {
//   final _gemma = FlutterGemmaPlugin.instance;
//   InferenceChat? chat;
//   final _messages = <Message>[];
//   bool _isModelInitialized = false;
//   bool _isStreaming = false; // Track streaming state
//   String? _error;
//   Color _backgroundColor = Color(0xFFF8F9FF); // Same as SettingPage
//   String _appTitle = '🤖 Chat AI'; // Modern title

//   bool _useSyncMode = false;

//   // Define the tools
//   final List<Tool> _tools = [
//     const Tool(
//       name: 'change_app_title',
//       description:
//           'Changes the title of the app in the AppBar. Provide a new title text.',
//       parameters: {
//         'type': 'object',
//         'properties': {
//           'title': {
//             'type': 'string',
//             'description': 'The new title text to display in the AppBar',
//           },
//         },
//         'required': ['title'],
//       },
//     ),
//     const Tool(
//       name: 'change_background_color',
//       description:
//           "Changes the background color of the app. The color should be a standard web color name like 'red', 'blue', 'green', 'yellow', 'purple', or 'orange'.",
//       parameters: {
//         'type': 'object',
//         'properties': {
//           'color': {'type': 'string', 'description': 'The color name'},
//         },
//         'required': ['color'],
//       },
//     ),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _initializeModel();
//   }

//   @override
//   void dispose() {
//     _isModelInitialized = false; // Reset model flag
//     super.dispose();
//   }

//   Future<void> _initializeModel() async {
//     if (_isModelInitialized || !Shared.instance.isInitializedModelAI) {
//       return;
//     }

//     try {
//       await _gemma.modelManager.ensureModelReady(
//         Shared.instance.modelAI!.filename,
//         Shared.instance.modelAI!.url,
//       );

//       Shared.instance.modelChat ??= await _gemma.createModel(
//         modelType: Shared.instance.modelAI!.modelType,
//         fileType: Shared.instance.modelAI!.fileType, // Pass fileType from model
//         preferredBackend: Shared.instance.modelAI!.preferredBackend,
//         maxTokens: Shared.instance.modelAI!.maxTokens,
//         supportImage:
//             Shared.instance.modelAI!.supportImage, // Pass image support
//         maxNumImages: Shared
//             .instance
//             .modelAI!
//             .maxNumImages, // Maximum 4 images for multimodal models
//       );

//       chat = await Shared.instance.modelChat!.createChat(
//         temperature: Shared.instance.modelAI!.temperature,
//         randomSeed: 1,
//         topK: Shared.instance.modelAI!.topK,
//         topP: Shared.instance.modelAI!.topP,
//         tokenBuffer: 256,
//         supportImage:
//             Shared.instance.modelAI!.supportImage, // Image support in chat
//         supportsFunctionCalls: Shared
//             .instance
//             .modelAI!
//             .supportsFunctionCalls, // Function calls support from model
//         tools: _tools, // Pass the tools to the chat
//         isThinking:
//             Shared.instance.modelAI!.isThinking, // Pass isThinking from model
//         modelType:
//             Shared.instance.modelAI!.modelType, // Pass modelType from model
//       );

//       setState(() {
//         _isModelInitialized = true;
//         _error = null;
//       });
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _error = 'Failed to initialize model: ${e.toString()}';
//           _isModelInitialized = false;
//         });
//       }
//       rethrow;
//     }
//   }

//   // Helper method to handle function calls with system messages (async version)
//   Future<void> _handleFunctionCall(FunctionCallResponse functionCall) async {
//     // Set streaming state and show "Calling function..." in one setState
//     setState(() {
//       _isStreaming = true;
//       _messages.add(
//         Message.systemInfo(
//           text:
//               "🔧 Calling: ${functionCall.name}(${functionCall.args.entries.map((e) => '${e.key}: "${e.value}"').join(', ')})",
//         ),
//       );
//     });

//     // Small delay to show the calling message
//     await Future.delayed(const Duration(milliseconds: 300));

//     // 2. Show "Executing function"
//     setState(() {
//       _messages.add(Message.systemInfo(text: "⚡ Executing function"));
//     });

//     final toolResponse = await _executeTool(functionCall);

//     // 3. Show "Function completed"
//     setState(() {
//       _messages.add(
//         Message.systemInfo(
//           text: "✅ Function completed: ${toolResponse['message'] ?? 'Success'}",
//         ),
//       );
//     });

//     // Small delay to show completion
//     await Future.delayed(const Duration(milliseconds: 300));

//     // Send tool response back to the model
//     final toolMessage = Message.toolResponse(
//       toolName: functionCall.name,
//       response: toolResponse,
//     );
//     await chat?.addQuery(toolMessage);

//     // TEMPORARILY use sync response for debugging

//     final response = await chat!.generateChatResponse();

//     if (response is TextResponse) {
//       final accumulatedResponse = response.token;

//       setState(() {
//         _messages.add(Message.text(text: accumulatedResponse));
//       });
//     } else if (response is FunctionCallResponse) {}

//     // Reset streaming state when done
//     setState(() {
//       _isStreaming = false;
//     });
//   }

//   // Main gemma response handler - processes responses from GemmaInputField
//   Future<void> _handleGemmaResponse(ModelResponse response) async {
//     if (response is FunctionCallResponse) {
//       await _handleFunctionCall(response);
//     } else if (response is TextResponse) {
//       // DEBUG: Track what text we're receiving from GemmaInputField
//       setState(() {
//         _messages.add(Message.text(text: response.token));
//         _isStreaming = false;
//       });
//     } else {}
//   }

//   // Function to execute tools
//   Future<Map<String, dynamic>> _executeTool(
//     FunctionCallResponse functionCall,
//   ) async {
//     if (functionCall.name == 'change_app_title') {
//       final newTitle = functionCall.args['title'] as String?;
//       if (newTitle != null && newTitle.isNotEmpty) {
//         setState(() {
//           _appTitle = newTitle;
//         });
//         return {
//           'status': 'success',
//           'message': 'App title changed to "$newTitle"',
//         };
//       } else {
//         return {'error': 'Title cannot be empty'};
//       }
//     }
//     if (functionCall.name == 'change_background_color') {
//       final colorName = functionCall.args['color']?.toLowerCase();
//       final colorMap = {
//         'red': Colors.red,
//         'blue': Colors.blue,
//         'green': Colors.green,
//         'yellow': Colors.yellow,
//         'purple': Colors.purple,
//         'orange': Colors.orange,
//       };
//       if (colorMap.containsKey(colorName)) {
//         setState(() {
//           _backgroundColor = colorMap[colorName]!;
//         });
//         return {
//           'status': 'success',
//           'message': 'Background color changed to $colorName',
//         };
//       } else {
//         return {
//           'error': 'Color not supported',
//           'available_colors': colorMap.keys.toList(),
//         };
//       }
//     }
//     if (functionCall.name == 'show_alert') {
//       final title = functionCall.args['title'] as String? ?? 'Alert';
//       final message =
//           functionCall.args['message'] as String? ?? 'No message provided';
//       final buttonText = functionCall.args['button_text'] as String? ?? 'OK';

//       // Show the alert dialog
//       await showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text(title),
//             content: Text(message),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(),
//                 child: Text(buttonText),
//               ),
//             ],
//           );
//         },
//       );

//       return {
//         'status': 'success',
//         'message': 'Alert dialog shown with title "$title"',
//       };
//     }
//     return {'error': 'Tool not found'};
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _backgroundColor,
//       appBar: AppBar(
//         backgroundColor: _backgroundColor,
//         // leading: IconButton(
//         //   icon: const Icon(Icons.arrow_back),
//         //   onPressed: () {
//         //     Navigator.pushAndRemoveUntil(
//         //       context,
//         //       MaterialPageRoute<void>(
//         //         builder: (context) => const ModelSelectionScreen(),
//         //       ),
//         //       (route) => false,
//         //     );
//         //   },
//         // ),
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               _appTitle,
//               style: const TextStyle(fontSize: 18, color: Colors.black),
//               softWrap: true,
//               overflow: TextOverflow.ellipsis,
//               maxLines: 1,
//             ),
//             if (chat?.supportsImages == true)
//               const Text(
//                 'Image support enabled',
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.green,
//                   fontWeight: FontWeight.normal,
//                 ),
//               ),
//           ],
//         ),
//         actions: [
//           // Sync/Async toggle
//           Row(
//             children: [
//               const Text('Sync', style: TextStyle(fontSize: 12)),
//               Switch(
//                 value: _useSyncMode,
//                 onChanged: (value) {
//                   setState(() {
//                     _useSyncMode = value;
//                   });
//                 },
//                 activeColor: Colors.green,
//               ),
//             ],
//           ),
//           // Image support indicator
//           // if (chat?.supportsImages == true)
//           //   const Padding(
//           //     padding: EdgeInsets.only(right: 16.0),
//           //     child: Icon(Icons.image, color: Colors.green, size: 20),
//           //   ),
//         ],
//       ),
//       body: _isModelInitialized
//           ? Column(
//               children: [
//                 if (_error != null) _buildErrorBanner(_error!),
//                 if (chat?.supportsImages == true && _messages.isEmpty)
//                   _buildImageSupportInfo(),
//                 Expanded(
//                   child: ChatListWidget(
//                     chat: chat,
//                     useSyncMode: _useSyncMode,
//                     gemmaHandler: _handleGemmaResponse,
//                     messageHandler: (message) {
//                       // Handles all message additions to history
//                       setState(() {
//                         _error = null;
//                         _messages.add(message);
//                         // Set streaming to true when user sends message
//                         _isStreaming = true;
//                       });
//                     },
//                     errorHandler: (err) {
//                       setState(() {
//                         _error = err;
//                         _isStreaming = false; // Reset streaming on error
//                       });
//                     },
//                     messages: _messages,
//                     isProcessing: _isStreaming,
//                   ),
//                 ),
//               ],
//             )
//           : const LoadingWidget(message: 'Initializing model'),
//     );
//   }

//   Widget _buildErrorBanner(String errorMessage) {
//     return Container(
//       width: double.infinity,
//       color: Colors.red,
//       padding: const EdgeInsets.all(8.0),
//       child: Text(
//         errorMessage,
//         style: const TextStyle(color: Colors.white),
//         textAlign: TextAlign.center,
//       ),
//     );
//   }

//   Widget _buildImageSupportInfo() {
//     return Container(
//       margin: const EdgeInsets.all(16.0),
//       padding: const EdgeInsets.all(12.0),
//       decoration: BoxDecoration(
//         color: const Color(0xFF1a3a5c),
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
//       ),
//       child: Row(
//         children: [
//           const Icon(Icons.info_outline, color: Colors.green, size: 20),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Model supports images',
//                   style: TextStyle(
//                     color: Colors.green,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 Text(
//                   'Use the 📷 button to add images to your messages',
//                   style: TextStyle(
//                     color: Colors.white.withValues(alpha: 0.7),
//                     fontSize: 12,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
