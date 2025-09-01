import 'dart:convert';
import 'dart:io';
import 'package:altera/common/errors/convert_message.dart';
import 'package:altera/framework/preferences_service.dart';
import 'package:altera/features/user/domain/entities/client_data_entitie.dart';
import 'package:altera/features/user/domain/usecases/userdata_usecase.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PerfilController extends GetxController {
  final PreferencesUser _prefsUser = PreferencesUser();
  final UserdataUsecase userdataUsecase;

  PerfilController({required this.userdataUsecase});

  var isLoading = false.obs;
  var userData = Rxn<UserDataEntity>();
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final List<UserDataEntity> userList = await userdataUsecase.execute();
      
      if (userList.isNotEmpty) {
        userData.value = userList.first; 
      }
    } catch (e) {
            cleanExceptionMessage(e);

      errorMessage.value = cleanExceptionMessage(e);
      print('Error en loadUserData: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshUserData() async {
    await loadUserData();
  }

  void cerrarSesion() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Cerrar sesión'),
        content: Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('Sí, cerrar sesión'),
          ),
        ],
      ),
    );
    
    if (result == true) {
      await _prefsUser.removePreferences();
 
      Get.offAllNamed('/login');
    }
  }

  String get userName => userData.value?.nombre ?? 'Usuario';
  String get userEmail => userData.value?.correo ?? '';
  int get userId => userData.value?.id ?? 0;
  String get userToken => userData.value?.token ?? '';
  
  String get photo => userData.value?.photo ?? '';

  String get almacenNombre => userData.value?.almacen.nombre ?? '';
  String get userRole {
    final idRol = userData.value?.idRol;
    switch (idRol) {
      case 1:
        return 'Administración';
      case 2:
        return 'Aplicación';
      default:
        return 'Rol no definido';
    }
  }
}