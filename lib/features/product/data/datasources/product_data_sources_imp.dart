import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:altera/common/constants/constants.dart';
import 'package:altera/common/errors/api_errors.dart';
import 'package:altera/features/product/data/models/Label/label_model.dart';
import 'package:altera/features/product/data/models/entry_model.dart';
import 'package:altera/features/product/data/models/orders/orders_model.dart';
import 'package:altera/features/product/data/models/orders/pending_orders_model.dart';
import 'package:altera/features/product/data/models/poshProduct/posh_product_model.dart';
import 'package:altera/features/product/data/models/product_model.dart';
import 'package:altera/features/product/data/models/surtir/surtir_model.dart';
import 'package:altera/features/product/domain/entities/getEntryEntity/get_entry_entity.dart';
import 'package:altera/features/product/domain/entities/labelEntity/Label_entity.dart';
import 'package:altera/features/product/domain/entities/orders/orders_entity.dart';
import 'package:altera/features/product/domain/entities/orders/pending_orders_entity.dart';
import 'package:altera/features/product/domain/entities/poshProduct/posh_product_entity.dart';
import 'package:altera/features/product/domain/entities/product_entitie.dart';
import 'package:altera/features/product/domain/entities/surtir/surtir_entity.dart';
import 'package:altera/features/user/data/models/cliente_data_model.dart';
import 'package:altera/features/user/data/models/login_response.dart';
import 'package:altera/features/user/domain/entities/client_data_entitie.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProductDataSourcesImp {
    String defaultApiServer = AppConstants.serverBase;

Future<List<EntryEntity>> getEntry(String token, String idProducto) async {
  try {
    Uri url = Uri.parse('$defaultApiServer/entradas/producto/$idProducto');
    final response = await http.get(url, headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    });
    
    if (response.statusCode == 200) {
      final dataUTF8 = utf8.decode(response.bodyBytes);
      final responseDecode = jsonDecode(dataUTF8);
      
      if (responseDecode['data'] == null) {
        return [];
      }
      final data = responseDecode['data'];
      
      if (data is List) {
        debugPrint('Data es una lista con ${data} elementos');
        List<EntryEntity> items = data.map((e) => EntryModel.fromJson(e)).toList();
        return items;
      } else if (data is Map<String, dynamic>) {
        EntryEntity item = EntryModel.fromJson(data);  

        return [item];
      } else {
        debugPrint('Formato de data no reconocido: ${data.runtimeType}');
        return [];
      }
    }
    
    throw ApiExceptionCustom(response: response);
  } catch (e)  {
      if (e is SocketException || e is http.ClientException || e is TimeoutException) {

        throw Exception(convertMessageException(error: e));
      }
      print('signin Error detallado: $e');
      throw Exception('$e');
    }
}
Future<List<LabelEntity>> getLabels(String token) async {
  try {
    Uri url = Uri.parse('$defaultApiServer/usuarios/renew'); 
    final response = await http.get(url, headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    });
        
    if (response.statusCode == 200) {
      final dataUTF8 = utf8.decode(response.bodyBytes);
      final responseDecode = jsonDecode(dataUTF8);
            
      if (responseDecode['data'] == null) {
        return [];
      }
      
      final data = responseDecode['data'];
      
      if (data is Map<String, dynamic> && data['logs'] != null) {
        final logs = data['logs'];
        
        if (logs is List) {
          debugPrint('Logs encontrados: ${logs.length} elementos');
          List<LabelEntity> items = logs.map((e) => LabelModel.fromJson(e)).toList();
          return items;
        } else {
          debugPrint('Los logs no son una lista');
          return [];
        }
      } else {
        debugPrint('No se encontraron logs en la respuesta');
        return [];
      }
    }
        
    throw ApiExceptionCustom(response: response);
  } catch (e)  {
      if (e is SocketException || e is http.ClientException || e is TimeoutException) {

        throw Exception(convertMessageException(error: e));
      }
      print('signin Error detallado: $e');
      throw Exception('$e');
    }
}




Future<void> addExit(List<PoshProductEntity> poshProductList, String token) async {
  try {
    Uri url = Uri.parse('$defaultApiServer/entradas/salida/');
    
    List<Map<String, dynamic>> jsonList = poshProductList
        .map((entity) => PoshProductModel.fromEntity(entity).toJson())
        .toList();
    
    final response = await http.put(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(jsonList),
    );

    if (response.statusCode == 200) {
      final dataUTF8 = utf8.decode(response.bodyBytes);
      final responseDecode = jsonDecode(dataUTF8)['data'];
      return responseDecode;
    }

    ApiExceptionCustom exception = ApiExceptionCustom(response: response);
    exception.validateMesage(); 
    throw exception;
    
  } catch (e) {
     if (e is SocketException || e is http.ClientException || e is TimeoutException) {

        throw Exception(convertMessageException(error: e));
      }
      print('signin Error detallado: $e');
      throw Exception('$e');
  }
}
Future<void> addEntry(List<PoshProductEntity> poshProductList, String token) async {
  try {
    Uri url = Uri.parse('$defaultApiServer/entradas/entrada/');
    
    List<Map<String, dynamic>> jsonList = poshProductList
        .map((entity) => PoshProductModel.fromEntity(entity).toJson())
        .toList();
    
    final response = await http.put(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(jsonList),
    );

    if (response.statusCode == 200) {
      final dataUTF8 = utf8.decode(response.bodyBytes);
      final responseDecode = jsonDecode(dataUTF8)['data'];
      return responseDecode;
    }

    ApiExceptionCustom exception = ApiExceptionCustom(response: response);
    exception.validateMesage(); 
    throw exception;
    
  } catch (e) {
     if (e is SocketException || e is http.ClientException || e is TimeoutException) {

        throw Exception(convertMessageException(error: e));
      }
      print('signin Error detallado: $e');
      throw Exception('$e');
  }
}Future<void> surtir(List<SurtirEntity> poshProductList, String token, String id) async {
  try {
    Uri url = Uri.parse('$defaultApiServer/pedidos/surtir/$id');
    
    List<Map<String, dynamic>> jsonList = poshProductList
        .map((entity) => SurtirModel.fromEntity(entity).toJson())
        .toList();
    
    Map<String, dynamic> requestBody = {
      'entradas_productos': jsonList
    };
    
    final response = await http.put(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(requestBody), 
    );

    if (response.statusCode == 200) {
      final dataUTF8 = utf8.decode(response.bodyBytes);
      final responseDecode = jsonDecode(dataUTF8)['data'];
      return responseDecode;
    }

    print('❌ Error del servidor (${response.statusCode}): ${response.body}');
    
    // ✅ CAMBIO PRINCIPAL: Crear la excepción personalizada y validar el mensaje
    final apiException = ApiExceptionCustom(response: response);
    apiException.validateMesagepallet(); // ← Esto extrae el mensaje real del servidor
    
    throw Exception(apiException.message); // ← Ahora usa el mensaje validado
    
  } catch (e) {
      if (e is SocketException || e is http.ClientException || e is TimeoutException) {

        throw Exception(convertMessageException(error: e));
      }
      throw Exception('$e');
  }
}


Future<void> deleteBallot(List<PoshProductEntity> poshProductList, String token) async {
  try {
    Uri url = Uri.parse('$defaultApiServer/entradas/papeleta/eliminar');
    
    if (poshProductList.isEmpty) {
      throw Exception('No hay productos para eliminar');
    }
    
    Map<String, dynamic> jsonObject = {"id": poshProductList.first.id};
    
    print('🔍 JSON enviado (objeto simple): ${jsonEncode(jsonObject)}');
    
    final response = await http.put(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(jsonObject),
    );

    print('🔍 Status code recibido: ${response.statusCode}');
    print('🔍 Response body: ${response.body}');

    if (response.statusCode == 200) {
      final dataUTF8 = utf8.decode(response.bodyBytes);
      final responseDecode = jsonDecode(dataUTF8)['data'];
      return responseDecode;
    }

    ApiExceptionCustom exception = ApiExceptionCustom(response: response);
    exception.validateMesage(); 
    throw exception;
    
  } catch (e) {
      if (e is SocketException || e is http.ClientException || e is TimeoutException) {

        throw Exception(convertMessageException(error: e));
      }
      throw Exception('$e');
  }
}


 Future<List<PendingOrdersEntity >> getPendingorders({required String token,required String date}) async {
    try {
      Uri url = Uri.parse('$defaultApiServer/pedidos/pendientes').replace(
        queryParameters: {'inicio_fecha': date},
      );
      final response = await http.get(url, headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer  $token'
      });
      if (response.statusCode == 200) {
        final dataUTF8 = utf8.decode(response.bodyBytes);
        final responseDecode = jsonDecode(dataUTF8)['data'] as List;
        List<PendingOrdersEntity> items =
            responseDecode.map((e) => PendingOrdersModel.fromJson(e)).toList();

        return items;
      }
      throw ApiExceptionCustom(response: response);
    } catch (e) {
       if (e is SocketException || e is http.ClientException || e is TimeoutException) {

        throw Exception(convertMessageException(error: e));
      }
      throw Exception('$e');
    }
  }

 Future<OrdersEntity> getorders({required String token, required int id}) async {
  try {
    Uri url = Uri.parse('$defaultApiServer/pedidos/$id');
    final response = await http.get(url, headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    });
    print('token:getorders $token');
    if (response.statusCode == 200) {
      final dataUTF8 = utf8.decode(response.bodyBytes);
      final responseDecode = jsonDecode(dataUTF8);
      
      final orderData = responseDecode['data'];
      OrdersEntity order = OrdersModel.fromJson(orderData);
      
      return order;
    }
    
    throw ApiExceptionCustom(response: response);
  } catch (e) {
     if (e is SocketException || e is http.ClientException || e is TimeoutException) {

        throw Exception(convertMessageException(error: e));
      }
      throw Exception('$e');
  
  }
}
}