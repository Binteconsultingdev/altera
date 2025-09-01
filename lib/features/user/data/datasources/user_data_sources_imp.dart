import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:altera/common/constants/constants.dart';
import 'package:altera/common/errors/api_errors.dart';
import 'package:altera/features/user/data/models/cliente_data_model.dart';
import 'package:altera/features/user/data/models/login_response.dart';
import 'package:altera/features/user/domain/entities/client_data_entitie.dart';
import 'package:http/http.dart' as http;

class UserDataSourcesImp {
    String defaultApiServer = AppConstants.serverBase;




 
 
  Future<LoginResponse> signin(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$defaultApiServer/usuarios/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'correo': email,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final loginResponse = LoginResponse.fromJson(responseData);
        return loginResponse;

      } else {
        final apiException = ApiExceptionCustom(response: response);
        apiException.validateMesage();     
        throw Exception(apiException.message);
      }
    } catch (e) {
      if (e is SocketException || e is http.ClientException || e is TimeoutException) {

        throw Exception(convertMessageException(error: e));
      }
      print('signin Error detallado: $e');
      throw Exception('$e');
    }
  }

@override
Future<List<UserDataEntity>> userData(String token) async {
  try {
    final response = await http.get(
      Uri.parse('$defaultApiServer/usuarios/renew'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );
    

    if (response.statusCode == 200) {
      
      final dynamic jsonData = json.decode(utf8.decode(response.bodyBytes));      

    if (jsonData is Map<String, dynamic>) {
      if (jsonData.containsKey('data')) {
        final data = jsonData['data'];

        return [UserDataModel.fromJson(data)];
      } else {
        throw Exception('La respuesta no contiene el campo "data"');
      }
    }
    else if (jsonData is List<dynamic>) {
        final List<UserDataEntity> results = [];
        for (var item in jsonData) {
          try {
            results.add(UserDataModel.fromJson(item));
          } catch (e) {
          }
        }
        return results;
      } else {
        throw Exception('Formato de respuesta inesperado del servidor');
      }
    } else {
      final apiException = ApiExceptionCustom(response: response);
      apiException.validateMesage();
                  
      throw Exception(apiException.message);
    }
  } catch (e) {
    if (e is SocketException || e is http.ClientException || e is TimeoutException) {

        throw Exception(convertMessageException(error: e));
      }
      throw Exception('$e');
  }
}
}