import 'package:oziapi/models/messageerorr_model.dart';
import 'package:oziapi/ozi_api.dart';

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
