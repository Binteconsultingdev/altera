import 'package:altera/common/errors/api_errors.dart';
import 'package:altera/common/errors/convert_message.dart';
import 'package:altera/common/theme/Theme_colors.dart';
import 'package:altera/common/widgets/custom_alert_type.dart';
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

class ProductosController extends BaseProductController {
  final AddEntryUsecase addEntryUsecase;

  ProductosController({
    required this.addEntryUsecase,
    required GetProductoUsecase getEntryUsecase,
  }) : super(getProductoUsecase: getEntryUsecase);

  @override
  String get storageKey => AppConstants.catalogstoragekey;

  @override
  String? validateProductForOperation(EntryEntity producto) {
    int tipoId = producto.tipo?.id ?? 0;

    switch (tipoId) {
      case 2:
        return 'Papeleta corresponde a salida o surtido, no aplica para entrada';
      case 3:
        return 'Papeleta no cumple con los requisitos para entrada';
      case 4:
        return 'Papeleta eliminada - No disponible';
    }

    if (producto.sugerencias?.sugerencia_entrada == null ||
        producto.sugerencias!.sugerencia_entrada <= 0) {
      return 'La papeleta no cuenta con stock suficiente para entrada';
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
      
      // Validación de productos
      List<EntryEntity> productosInvalidos = [];
      for (EntryEntity producto in productosCarrito) {
        String? error = validateProductForOperation(producto);
        if (error != null) {
          productosInvalidos.add(producto);
        }
      }
      
      if (productosInvalidos.isNotEmpty) {
        String productosRechazados = productosInvalidos
            .map((p) => "Producto #${p.idProducto} (Tipo: ${p.tipo?.tipo ?? 'Desconocido'})")
            .join("\n");
        showErrorAlert(
          'Productos no válidos',
          'Los siguientes productos no pueden ser procesados:\n\n$productosRechazados'
        );
        return;
      }
      
      List<PoshProductEntity> productos = productosCarrito
          .map((entry) => PoshProductEntity(id: entry.id))
          .toList();
      
      await addEntryUsecase.execute(productos);
      showSuccessAlert('¡Éxito!', 'Productos de entrada guardados correctamente');
      notificarActualizacionLabels();
      limpiarCarrito();
    } catch (e) {
      print('Error: $e');
      showErrorAlert('Ups', 'No se pudieron guardar los productos: ${cleanExceptionMessage(e)}');
    } finally {
      isLoading.value = false;
    }
  }
}