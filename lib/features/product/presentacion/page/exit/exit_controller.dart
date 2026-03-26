import 'package:altera/common/errors/api_errors.dart';
import 'package:altera/common/errors/convert_message.dart';
import 'package:altera/common/theme/Theme_colors.dart';
import 'package:altera/common/widgets/custom_alert_type.dart';
import 'package:altera/features/product/domain/usecases/add_exit_usecase.dart';
import 'package:altera/features/product/domain/usecases/delete_ballot_usecase.dart';
import 'package:altera/features/product/presentacion/controller/base_product_controller.dart';
import 'package:altera/features/product/presentacion/page/getproducto/entry_controller.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:convert';
import 'package:altera/framework/preferences_service.dart';
import 'package:altera/common/constants/constants.dart';
import 'package:altera/features/product/domain/entities/product_entitie.dart';
import 'package:altera/features/product/domain/entities/getEntryEntity/get_entry_entity.dart';
import 'package:altera/features/product/domain/entities/poshProduct/posh_product_entity.dart';
import 'package:altera/features/product/domain/usecases/add_entry_usecase.dart';
import 'package:altera/features/product/domain/usecases/get_producto_usecase.dart';
class ExitController extends BaseProductController {
  final AddExitUsecase exitUsecase;
  ExitController({
    required this.exitUsecase,
    required GetProductoUsecase getEntryUsecase,
  }) :super(getProductoUsecase: getEntryUsecase);

  @override
  String get storageKey => AppConstants.cataexittoragekey;

  @override
  String? validateProductForOperation(EntryEntity producto) {
    int tipoId = producto.tipo?.id ?? 0;
    
    switch (tipoId) {
      case 5:
        return 'Ya se le dio salida a la papeleta';
      case 1:
        return 'Papeleta es de tipo entrada';
      case 3:
        return 'Papeleta no cumple con los requisitos para salida';
      case 4:
        return 'Papeleta eliminada - No disponible';
    }

    if (producto.sugerencias?.sugerencia_surtir == null ||
        producto.sugerencias!.sugerencia_surtir <= 0) {
      return 'La papeleta no cuenta con stock suficiente para salida';
    }

    return null;
  }

  @override
  Future<void> guardarProductosEnRepositorio() async {
    try {
      isLoading.value = true;
      if (productosCarrito.isEmpty) {
        showErrorAlert('Lista vacía', 'No hay productos para guardar.');
        return;
      }
      
      List<PoshProductEntity> productos = productosCarrito
          .map((entry) => PoshProductEntity(id: entry.id))
          .toList();
      
      await exitUsecase.execute(productos);
      showSuccessAlert('¡Éxito!', 'Productos de salida guardados correctamente');
      notificarActualizacionLabels();
      limpiarCarrito();
    } catch (e) {
      showErrorAlert('Ups', cleanExceptionMessage(e));
    } finally {
      isLoading.value = false;
    }
  }
}