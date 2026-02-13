import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

String domain = 'https://base.oziny.io';
String tokenApp = '66d7f308aa679fcef703faed';

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

  Future<ResultModel> verifyApplePayment({
    required String tokenLogin,
    required String transactionReceipt,
  }) async {
    final requestBody = {'transactionReceipt': transactionReceipt};

    final result = await postFetch(
      newDomain: 'https://store.oziny.io',
      options: Options(headers: {'Authorization': 'Bearer $tokenLogin'}),
      endpoint: '/v1/payments/verify/apple-receipt',
      data: requestBody,
    );
    return ResultModel.formJson(result);
  }
}

class ResultModel extends MessageerorrModel {
  late final dynamic data;

  ResultModel({
    super.errorCode,
    super.message,
    this.data,
  });
  factory ResultModel.formJson(Response<dynamic> response) {
    try {
      if (response.data != null) {
        final responseData = response.data;

        if (responseData.containsKey('code') &&
            responseData.containsKey('data')) {
          return ResultModel(
            errorCode: responseData['code'] ?? 0,
            message: responseData['message'] ?? '',
            data: responseData['data'],
          );
        } else {
          final error = response.data['error'];
          if (error is List && error.isNotEmpty) {
            return ResultModel(
              errorCode: response.data['code'] ?? 404,
              message: error.join('\n'),
              data: null,
            );
          } else {
            return ResultModel(
              errorCode: response.data['code'] ?? 404,
              message: response.data['message'] ?? 'Unexpected response format',
              data: null,
            );
          }
        }
      } else {
        return ResultModel(
          errorCode: response.statusCode ?? 500,
          message: 'Response or response data is null',
          data: null,
        );
      }
    } catch (e) {
      return ResultModel(
        errorCode: 500,
        message: 'Error parsing response',
        data: e.toString(),
      );
    }
  }
}

abstract class MessageerorrModel {
  late String message;
  late int errorCode;
  MessageerorrModel({this.errorCode = 500, this.message = ''});
}
