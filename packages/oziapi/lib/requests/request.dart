import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:oziapi/domain/domain.dart';
import 'package:oziapi/domain/finalpoint.dart';
import 'package:oziapi/models/request_model.dart';
import 'package:oziapi/models/result_model.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class Request {
  final client = Dio()
    ..options = BaseOptions(
      baseUrl: '',
      validateStatus: (int? status) {
        return status != null;
      },
    )
    ..interceptors.add(PrettyDioLogger(requestBody: true, requestHeader: true));
  Request({String? applicationToken}) {
    tokenApp = applicationToken ?? tokenApp;
  }

  Map<String, dynamic> generateTimestampAndNonce() {
    final ts = DateTime.now().microsecondsSinceEpoch;
    final nonce = Random().nextInt(12);
    return {'ts': ts, 'nonce': nonce};
  }

  Map<String, String> generateHeaders(String endpoint, int ts, int nonce) {
    final baseSign = '$endpoint?$ts$nonce';
    final key = Hmac(sha256, utf8.encode(APP_SECRET));
    final signature = key.convert(utf8.encode(baseSign));
    final signatureString = base64.encode(signature.bytes);

    return {
      'Content-Type': 'application/json',
      "Authorization": "Bearer $APP_KEY",
      "Sign": signatureString,
    };
  }

  Future<ReponseData> sendMessageToChat(List<Message> messages,
      {String modelChat = 'gpt-3.5-turbo', String urlImage = ''}) async {
    final info = generateTimestampAndNonce();
    final headers =
        generateHeaders(FinalPointAPI.chattext, info['ts'], info['nonce']);
    if (urlImage.isNotEmpty) {
      messages.last.contents.add(
          ContentTypeMessage(content: messages.last.content, type: 'text'));
      messages.last.contents
          .add(ContentTypeMessage(content: urlImage, type: 'image_url'));
    }
    final reponse = await postFetch(
      newDomain:
          '$domainChatAI${FinalPointAPI.chattext}?ts=${info['ts']}&nonce=${info['nonce']}',
      options: Options(headers: headers),
      data: json.encode({
        'model': modelChat,
        'messages': messages
            .map((e) => {
                  'role': e.role,
                  'content': e.contents.isEmpty
                      ? e.content
                      : e.contents.map((el) => el.toJson()).toList()
                })
            .toList()
      }),
    );
    return ReponseData.fromJson(reponse.data);
  }

  Future<Response<dynamic>> sendCreateImage(
    String message, {
    String modelChat = 'dall-e-3',
    String sizeImage = '256x256',
  }) async {
    final info = generateTimestampAndNonce();
    final headers = generateHeaders(
        FinalPointAPI.chatCreateImage, info['ts'], info['nonce']);
    final reponse = await postFetch(
      newDomain:
          '$domainChatAI${FinalPointAPI.chatCreateImage}?ts=${info['ts']}&nonce=${info['nonce']}',
      options: Options(headers: headers),
      data: json.encode({
        'model': modelChat,
        'prompt': message,
        'n': 1,
        'size': sizeImage,
      }),
    );
    return reponse;
  }

  Future<Response> postFetch({
    String? newDomain,
    String endpoint = '',
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    void Function(int, int)? onReceiveProgress,
    void Function(int, int)? onSendProgress,
  }) async {
    try {
      final response = await client.post(
          newDomain != null && newDomain.isNotEmpty
              ? newDomain + endpoint
              : domain + endpoint,
          data: data,
          queryParameters: queryParameters,
          options: options,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress);
      return response;
    } on DioException catch (e) {
      return Response(
        statusCode: e.response?.statusCode ?? 400,
        statusMessage: e.message,
        data: e.response?.data,
        requestOptions: RequestOptions(
          path: endpoint,
          data: data,
        ),
      );
    }
  }
}
