import 'package:altera/common/errors/api_errors.dart';
import 'package:altera/common/errors/convert_message.dart';
import 'package:altera/common/theme/Theme_colors.dart';
import 'package:altera/common/widgets/custom_alert_type.dart';
import 'package:altera/features/product/domain/usecases/add_exit_usecase.dart';
import 'package:altera/features/product/domain/usecases/delete_ballot_usecase.dart';
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

class ExitController extends GetxController {
  final PreferencesUser _prefsUser = PreferencesUser();
  final AddExitUsecase _exitUsecase;
  final GetProductoUsecase _getEntryUsecase;
  final DeleteBallotUsecase _deleteBallotUsecase;
  
  final RxList<EntryEntity> productosCarrito = <EntryEntity>[].obs;
  final RxList<EntryEntity> productosDisponibles = <EntryEntity>[].obs;
  final RxList<EntryEntity> filteredProducts = <EntryEntity>[].obs;
  
  final RxBool isLoading = false.obs;
  final RxBool isLoadingProducts = false.obs;
  final RxInt currentTab = 0.obs;
  final RxString searchQuery = ''.obs;

  Rx<MobileScannerController?> qrScannerController = Rx<MobileScannerController?>(null);
  RxBool isScanning = false.obs;
  RxBool isTorchOn = false.obs;

  String? _lastScannedQR;
  DateTime? _lastScanTime;
  final int _scanCooldownMs = 2000;
  final RxBool isSearchingToDelete = false.obs;
  final RxString searchToDeleteQuery = ''.obs;
  final RxList<EntryEntity> filteredProductsToDelete = <EntryEntity>[].obs;
  final TextEditingController searchToDeleteController = TextEditingController();

  final RxBool showingProductDetails = false.obs;
  final Rx<EntryEntity?> selectedProductForDetails = Rx<EntryEntity?>(null);

  final RxBool showingManualInput = false.obs;
  final TextEditingController manualIdController = TextEditingController();
  final RxBool isProcessingManualId = false.obs;

  ExitController({
    required AddExitUsecase exitUsecase,
    required GetProductoUsecase getEntryUsecase,
    required DeleteBallotUsecase deleteBallotUsecase,
  }) : _exitUsecase = exitUsecase,
       _getEntryUsecase = getEntryUsecase,
       _deleteBallotUsecase = deleteBallotUsecase;

  double get subtotal => productosCarrito.length.toDouble();
  double get total => subtotal;

  void mostrarInputManual() {
    showingManualInput.value = true;
    manualIdController.clear();
    print('📝 Mostrando input manual para ID');
  }

  void cerrarInputManual() {
    showingManualInput.value = false;
    manualIdController.clear();
    isProcessingManualId.value = false;
    print('❌ Cerrando input manual');
  }

  Future<void> procesarIdManual() async {
    String idTexto = manualIdController.text.trim();
    
    if (idTexto.isEmpty) {
      _showErrorAlert('Campo vacío', 'Por favor ingresa un ID');
      return;
    }

    try {
      int id = int.parse(idTexto);
      print('📝 Procesando ID manual: $id');
      
      isProcessingManualId.value = true;
      await _agregarProductoPorQR(id.toString());
    //  cerrarInputManual();
      
    } catch (e) {
      print('❌ Error al parsear ID manual: $e');
      _showErrorAlert('ID Inválido', 'El ID debe ser un número válido');
    } finally {
      isProcessingManualId.value = false;
    }
  }

  void mostrarDetallesProducto(EntryEntity producto) {
    selectedProductForDetails.value = producto;
    showingProductDetails.value = true;
    print('📋 Mostrando detalles del producto: ${producto.idProducto}');
  }

  void cerrarDetallesProducto() {
    showingProductDetails.value = false;
    selectedProductForDetails.value = null;
    print('❌ Cerrando detalles del producto');
  }

  @override
  void onInit() async {
    super.onInit();
     await _initializePreferences();
    await cargarProductosGuardados();
  }
 Future<void> _initializePreferences() async {
    try {
      if (!_prefsUser.isInitialized) {
        print('🔧 Inicializando SharedPreferences...');
        await _prefsUser.initiPrefs();
        print('✅ SharedPreferences inicializadas en ProductosController');
      }
    } catch (e) {
      print('❌ Error al inicializar preferencias: $e');
    }
  }
  void searchProducts(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredProducts.assignAll(productosDisponibles);
    } else {
      filteredProducts.assignAll(
        productosDisponibles.where((producto) =>
          producto.idProducto.toString().contains(query) ||
          producto.calibre.toLowerCase().contains(query.toLowerCase()) ||
          producto.longitud.toLowerCase().contains(query.toLowerCase()) ||
          producto.anchoAla.toLowerCase().contains(query.toLowerCase()) ||
          producto.ordenCompra.toLowerCase().contains(query.toLowerCase())
        ).toList()
      );
    }
  }

  void addProductToCart(EntryEntity producto) {
  if (_validarPiezasPorPallet(producto)) {
    _showErrorAlert(
      'Sin piezas disponibles', 
      'No quedan piezas por pallet para dar salida.\n\n'
      'Piezas surtidas: ${producto.summarystorage.salidas}\n'
      'Piezas por pallet: ${producto.piezasPorPallet}'
    );
    return;
  }
  
  String? errorMessage = _validateProductForEntry(producto);
  if (errorMessage != null) {
    _showErrorAlert('Producto no válido', errorMessage);
    return;
  }
  
  int index = productosCarrito.indexWhere((p) => p.id == producto.id);
  if (index >= 0) {
    _showErrorAlert('Ups', 'Producto ya agregado');
  } else {
    productosCarrito.add(producto);
    productosCarrito.refresh();
    guardarProductos();
  }
}

  String? _validateProductForEntry(EntryEntity producto) {
    int tipoId = producto.tipo?.id ?? 0;
    switch (tipoId) {
      case 5:
        return 'Ya se le dio salida a la papeleta';
      case 1:
        return 'papeleta es de tipo entrada';
      case 3:
        return 'Papeleta no cumple con los requisitos para salida';
      case 4:
        return 'Papeleta eliminada - No disponible';
     
    }

     if (producto.sugerencias?.sugerencia_surtir != null &&
    producto.sugerencias!.sugerencia_surtir <= 0) {
   return 'Sin stock la papeleta no cuenta con stock suficiente para salida';

}
     
    return null;
  }

  Future<void> cargarProductosGuardados() async {
    try {
      print('🔍 Cargando productos de salida desde storage');
      
      if (!_prefsUser.isInitialized) {
        await _initializePreferences();
      }

      final String? productosJson = await _prefsUser.loadPrefs(
        type: String,
        key: AppConstants.cataexittoragekey,
      );

      if (productosJson != null && productosJson.isNotEmpty && productosJson != 'null') {
        try {
          final List<dynamic> productosData = jsonDecode(productosJson);
          final List<EntryEntity> productos = productosData
              .map((item) => _entryEntityFromJson(item))
              .where((producto) => producto != null) 
              .cast<EntryEntity>()
              .toList();
          
          productosCarrito.clear();
          productosCarrito.addAll(productos);
          productosCarrito.refresh();
          
          print('✅ Productos de salida cargados: ${productos.length}');
          print('✅ IDs cargados: ${productos.map((p) => p.idProducto).toList()}');
        } catch (jsonError) {
          print('❌ Error al parsear JSON de productos: $jsonError');
          await _prefsUser.clearOnePreference(key: AppConstants.cataexittoragekey);
          productosCarrito.clear();
        }
      } else {
        productosCarrito.clear();
        print('ℹ️ No hay productos de salida guardados (JSON: "$productosJson")');
      }
    } catch (e) {
      print('❌ Error al cargar productos guardados: $e');
      productosCarrito.clear();
      
      try {
        await _prefsUser.clearOnePreference(key: AppConstants.cataexittoragekey);
      } catch (clearError) {
        print('❌ Error al limpiar datos corruptos: $clearError');
      }
    }
  }

 Future<void> guardarProductos() async {
    try {
      print('💾 Guardando ${productosCarrito.length} productos de salida');
      
      if (!_prefsUser.isInitialized) {
        await _initializePreferences();
      }

      if (productosCarrito.isEmpty) {
        await _prefsUser.savePrefs(
          type: String,
          key: AppConstants.cataexittoragekey,
          value: '[]',
        );
        print('✅ Lista vacía guardada exitosamente');
        return;
      }

      final List<Map<String, dynamic>> productosData = productosCarrito
          .map((p) => _entryEntityToJson(p))
          .where((json) => json != null) 
          .cast<Map<String, dynamic>>()
          .toList();

      if (productosData.isNotEmpty) {
        final String productosJson = jsonEncode(productosData);
        await _prefsUser.savePrefs(
          type: String,
          key: AppConstants.cataexittoragekey,
          value: productosJson,
        );
        print('✅ Productos de salida guardados exitosamente');
      } else {
        print('⚠️ No hay datos válidos para guardar');
      }
    } catch (e) {
      print('❌ Error al guardar productos: $e');
    }
  }
   Map<String, dynamic>? _entryEntityToJson(EntryEntity entry) {
    try {
      return {
        'id': entry.id,
        'id_entrada': entry.idEntrada,
        'id_producto': entry.idProducto,
        'maquina': entry.maquina,
        'ancho_ala': entry.anchoAla,
        'longitud': entry.longitud,
        'calibre': entry.calibre,
        'piezas_por_pallet': entry.piezasPorPallet,
        'camas_por_tarima': entry.camasPorTarima,
        'bultos_por_cama': entry.bultosPorCama,
        'piezas_por_bulto': entry.piezasPorBulto,
        'puntos': entry.puntos,
        'orden_compra': entry.ordenCompra,
        'observaciones': entry.observaciones,
        'tipo': {
          'id': entry.tipo?.id ?? 0,
          'tipo': entry.tipo?.tipo ?? '',
        },
        'producto': {
          'id': entry.producto?.id ?? 0,
          'nombre': entry.producto?.nombre ?? '',
          'codigo': entry.producto?.codigo ?? '',
        },
      };
    } catch (e) {
      print('❌ Error al serializar EntryEntity: $e');
      return null;
    }
  }

  EntryEntity? _entryEntityFromJson(Map<String, dynamic> json) {
    try {
      return EntryEntity(
        id: json['id'] ?? 0,
        idEntrada: json['id_entrada'] ?? 0,
        idProducto: json['id_producto'] ?? 0,
        maquina: json['maquina'] ?? 0,
        anchoAla: json['ancho_ala'] ?? '',
        longitud: json['longitud'] ?? '',
        calibre: json['calibre'] ?? '',
        piezasPorPallet: json['piezas_por_pallet'] ?? '',    
        camasPorTarima: json['camas_por_tarima'] ?? '',     
        bultosPorCama: json['bultos_por_cama'] ?? '',        
        piezasPorBulto: json['piezas_por_bulto'] ?? '',    
        puntos: json['puntos'] ?? '',
        ordenCompra: json['orden_compra'] ?? '',            
        observaciones: json['observaciones'] ?? '',

        tipo: json['tipo'] != null && json['tipo'] is Map<String, dynamic>
            ? TipoEntity(
                id: json['tipo']['id'] ?? 0,
                tipo: json['tipo']['tipo'] ?? '',
              )
            : TipoEntity(id: 0, tipo: 'Desconocido'),
        sugerencias: json['sugerencias'] != null && json['sugerencias'] is Map<String, dynamic>
            ? Sugerencias(
                sugerencia_entrada: json['sugerencias']['sugerencia_entrada'] ?? '',
                sugerencia_surtir: json['sugerencias']['sugerencia_surtir'] ?? '',
              )
            : Sugerencias(sugerencia_entrada: 0, sugerencia_surtir: 0),
        summarystorage: json['resumen_mi_almacen'] != null && json['resumen_mi_almacen'] is Map<String, dynamic>
            ? Summarystorage(
                entradas: json['resumen_mi_almacen']['entradas'] ?? 0,
                surtimientos: json['resumen_mi_almacen']['surtimientos'] ?? 0,
                eliminaciones: json['resumen_mi_almacen']['eliminaciones'] ?? 0,
                salidas: json['resumen_mi_almacen']['salidas'] ?? 0,
                cancelaciones: json['resumen_mi_almacen']['cancelaciones'] ?? 0,
                stock_en_mi_almacen: json['resumen_mi_almacen']['stock_en_mi_almacen'] ?? 0,
              )
            : Summarystorage(entradas: 0, surtimientos: 0, eliminaciones: 0, salidas: 0, cancelaciones: 0, stock_en_mi_almacen: 0),
        producto: json['producto'] != null && json['producto'] is Map<String, dynamic>
            ? ProductEntity(
                id: json['producto']['id'] ?? 0,
                nombre: json['producto']['nombre'] ?? '',
                codigo: json['producto']['codigo'] ?? '',
              )
            : ProductEntity(id: 0, nombre: '', codigo: ''), 
        logs: [],
      );
    } catch (e) {
      print('❌ Error al deserializar EntryEntity: $e');
      return null;
    }
  }
void _notificarActualizacionLabels() {
  try {
    if (Get.isRegistered<LabelController>()) {
      final labelController = Get.find<LabelController>();
      print('📱 Notificando a LabelController para recargar datos...');
      
      Future.delayed(Duration(milliseconds: 500), () {
        labelController.loadLabels();
        print('✅ LabelController recargado exitosamente');
      });
    } else {
      print('ℹ️ LabelController no está registrado, no se puede notificar');
    }
  } catch (e) {
    print('❌ Error al notificar a LabelController: $e');
  }
}
  Future<void> guardarProductosEnRepositorio() async {
    try {
      isLoading.value = true;
      if (productosCarrito.isEmpty) {
        _showErrorAlert('Lista vacía', 'No hay productos para guardar.');
        isLoading.value = false;
        return;
      }
      
      List<EntryEntity> productosInvalidos = [];
      for (EntryEntity producto in productosCarrito) {
        String? error = _validateProductForEntry(producto);
        if (error != null) {
          productosInvalidos.add(producto);
        }
      }
      if (productosInvalidos.isNotEmpty) {
        String productosRechazados = productosInvalidos
            .map((p) => "Producto #${p.idProducto} (Tipo: ${p.tipo?.tipo ?? 'Desconocido'})")
            .join("\n");
        _showErrorAlert(
          'Productos no válidos', 
          'Los siguientes productos no pueden ser procesados para salida:\n\n$productosRechazados\n\nRevise los productos.'
        );
        isLoading.value = false;
        return;
      }
      
      List<PoshProductEntity> productos = productosCarrito
          .map((entry) => _entryEntityToPoshProductEntity(entry))
          .toList();
      
      await _exitUsecase.execute(productos);
      _showSuccessAlert('¡Éxito!', 'Productos de salida guardados correctamente');
      _notificarActualizacionLabels();
      limpiarCarrito();
    } catch (e) {
      print('Error al guardar productos en repositorio: $e');
      if (e is ApiExceptionCustom && e.failedProductIds != null && e.failedProductIds!.isNotEmpty) {
        await _handleServerValidationError(e);
      } else {
        _showErrorAlert('Ups', '${cleanExceptionMessage(e)}');
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _handleServerValidationError(ApiExceptionCustom error) async {
    List<int> failedIds = error.failedProductIds!;
    List<EntryEntity> productosProblematicos = productosCarrito
        .where((producto) => failedIds.contains(producto.id))
        .toList();
    print('🚨 Productos problemáticos encontrados: ${productosProblematicos.length}');
    if (productosProblematicos.isNotEmpty) {
      await showFailedProductsDialog(productosProblematicos, error.message);
    } else {
      _showErrorAlert('Error del servidor', error.message);
    }
  }

  Future<void> showFailedProductsDialog(List<EntryEntity> productosProblematicos, String serverMessage) async {
    showCustomAlert(
      context: Get.context!,
      title: "Productos rechazados",
      message: serverMessage,
      confirmText: "ELIMINAR PROBLEMÁTICOS",
      cancelText: "MANTENER PRODUCTOS",
      type: CustomAlertType.error,
      customWidget: Container(
        width: double.maxFinite,
        constraints: BoxConstraints(maxHeight: 300),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: productosProblematicos.length,
                itemBuilder: (context, index) {
                  final producto = productosProblematicos[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AdminColors.errorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AdminColors.errorColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: AdminColors.errorColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Producto #${producto.id}",
                                style: TextStyle(
                                  color: AdminColors.textPrimaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                "ID: ${producto.id} | Orden: ${producto.ordenCompra ?? 'N/A'}",
                                style: TextStyle(
                                  color: AdminColors.textSecondaryColor,
                                  fontSize: 10,
                                ),
                              ),
                              Text(
                                "Calibre: ${producto.calibre} | OC: ${producto.ordenCompra}",
                                style: TextStyle(
                                  color: AdminColors.textSecondaryColor,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminColors.errorColor,
                      minimumSize: const Size(0, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      for (EntryEntity producto in productosProblematicos) {
                        productosCarrito.remove(producto);
                      }
                      productosCarrito.refresh();
                      guardarProductos();
                      Get.back();
                      _showSuccessAlert(
                        'Productos eliminados',
                        '${productosProblematicos.length} productos problemáticos fueron eliminados del carrito.',
                      );
                    },
                    child: const Text(
                      "ELIMINAR PROBLEMÁTICOS",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      minimumSize: const Size(0, 40),
                      foregroundColor: AdminColors.textSecondaryColor,
                    ),
                    onPressed: () => Get.back(),
                    child: const Text(
                      "MANTENER PRODUCTOS",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      onConfirm: null,
      onCancel: null,
    );
  }

  PoshProductEntity _entryEntityToPoshProductEntity(EntryEntity entry) {
    return PoshProductEntity(
      id: entry.id,
    );
  }

  void removeProducto(EntryEntity producto) {
    productosCarrito.remove(producto);
    productosCarrito.refresh();
    guardarProductos();
    print('🗑️ Producto removido de la lista local. Quedan: ${productosCarrito.length} productos');
  }

  Future<void> eliminarProductoDefinitivamente(EntryEntity producto) async {
    try {
      isLoading.value = true;
      print('🗑️ Eliminando producto definitivamente con ID: ${producto.id}');
      PoshProductEntity poshProduct = _entryEntityToPoshProductEntity(producto);
      List<PoshProductEntity> productosAEliminar = [poshProduct];
      await _deleteBallotUsecase.execute(productosAEliminar);
      productosCarrito.remove(producto);
      productosCarrito.refresh();
      guardarProductos();
       _notificarActualizacionLabels();
      _showSuccessAlert(
        '¡Eliminado!', 
        'Producto eliminado definitivamente del sistema'
      );
    } catch (e) {
      print('❌ Error al eliminar producto definitivamente: $e');
      _showErrorAlert('No se puedo eliminar', 'La papeleta ya fue eliminada previamente');
    } finally {
      isLoading.value = false;
    }
  }

  void limpiarCarrito() {
    productosCarrito.clear();
    productosCarrito.refresh();
    
    Future.microtask(() async {
      await guardarProductos();
      print('🧹 Carrito de salida limpiado completamente');
    });
  }

  void iniciarEscaneoQR() {
    isScanning.value = true;
    _lastScannedQR = null;
    _lastScanTime = null;
    if (qrScannerController.value == null) {
      qrScannerController.value = MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        facing: CameraFacing.back,
        torchEnabled: false,
        formats: [BarcodeFormat.qrCode],
      );
    }
  }

  void detenerEscaneoQR() {
    isScanning.value = false;
    _lastScannedQR = null;
    _lastScanTime = null;
    if (qrScannerController.value != null) {
      qrScannerController.value!.dispose();
      qrScannerController.value = null;
    }
  }

  void toggleTorch() {
    if (qrScannerController.value != null) {
      qrScannerController.value!.toggleTorch();
      isTorchOn.value = !isTorchOn.value;
    }
  }
  
  void switchCamera() {
    if (qrScannerController.value != null) {
      qrScannerController.value!.switchCamera();
    }
  }

  void onQRCodeDetected(String qrData) async {
    try {
      print('🔍 QR Data detectado: "$qrData"');
      DateTime now = DateTime.now();
      if (_lastScannedQR == qrData && _lastScanTime != null) {
        int timeDiff = now.difference(_lastScanTime!).inMilliseconds;
        if (timeDiff < _scanCooldownMs) {
          print('⏰ QR duplicado ignorado (cooldown: ${timeDiff}ms)');
          return; 
        }
      }
      _lastScannedQR = qrData;
      _lastScanTime = now;
      int id = int.parse(qrData.trim());
      print('🔍 ID parseado: $id');
      await _agregarProductoPorQR(id.toString());
      detenerEscaneoQR();
    } catch (e) {
      print('❌ Error al parsear QR: $e');
      _showErrorAlert('QR Inválido', 'El código QR debe contener solo números');
    }
  }
  
Future<void> _agregarProductoPorQR(String idStr) async {
  try {
    if (isLoading.value) {
      print('⚠️ Ya se está procesando un QR, ignorando...');
      return;
    }
    isLoading.value = true;
    int id = int.parse(idStr);
    print('🔍 Llamando al caso de uso con ID: $id');
    List<EntryEntity> productosDisponibles = await _getEntryUsecase.execute(id.toString());
    print('🔍 Productos disponibles encontrados: ${productosDisponibles.length}');
    
    if (productosDisponibles.isNotEmpty) {
      EntryEntity productoDisponible = productosDisponibles.first;
      print('🔍 Producto encontrado - ID: ${productoDisponible.id}, Tipo: ${productoDisponible.tipo?.id}');
      
      
      
      String? errorMessage = _validateProductForEntry(productoDisponible);
      if (errorMessage != null) {
        _showErrorAlert('Producto no válido', '$errorMessage\n\nESTATUS: ${productoDisponible.tipo?.tipo}');
        return;
      }
      
      int index = productosCarrito.indexWhere((p) => p.id == productoDisponible.id);
      if (index >= 0) {
        _showErrorAlert('Ups', 'Producto ya agregado');
      } else {
        productosCarrito.add(productoDisponible);
        productosCarrito.refresh();
        print('🔍 Producto agregado al carrito. Total en carrito: ${productosCarrito.length}');
        await guardarProductos();
      }
    } else {
      print('❌ No se encontraron productos para ID: $id');
      _showErrorAlert('Ups', 'Producto no encontrado');
    }
  } catch (e) {
    print('❌ Error al procesar el producto: $e');
    _showErrorAlert('Ups', 'No se pudo procesar el producto');
  } finally {
    isLoading.value = false;
  }
}

bool _validarPiezasPorPallet(EntryEntity producto) {
  try {
    int totalSurtidas = producto.summarystorage.salidas ?? 0;
    int piezasPorPallet = int.tryParse(producto.piezasPorPallet.toString()) ?? 0;
    
    print('🔍 Validando piezas - Surtidas: $totalSurtidas, Por pallet: $piezasPorPallet');
    
    bool sinPiezasDisponibles = totalSurtidas >= piezasPorPallet;
    
    if (sinPiezasDisponibles) {
      print('⚠️ No quedan piezas disponibles para el producto ${producto.idProducto}');
    }
    
    return sinPiezasDisponibles;
  } catch (e) {
    print('❌ Error al validar piezas por pallet: $e');
    return false;
  }
}

  void _showErrorAlert(String title, String message, {VoidCallback? onDismiss}) {
    if (Get.context != null) {
      showCustomAlert(
        context: Get.context!,
        title: title,
        message: message,
        confirmText: 'Aceptar',
        type: CustomAlertType.error,
        onConfirm: onDismiss, 
      );
    }
  }

  @override
  void onClose() {
    searchToDeleteController.dispose();
    manualIdController.dispose(); 
    if (qrScannerController.value != null) {
      qrScannerController.value!.dispose();
    }
    super.onClose();
  }

  void iniciarBusquedaParaEliminar() {
    isSearchingToDelete.value = true;
    searchToDeleteQuery.value = '';
    searchToDeleteController.clear();
    filteredProductsToDelete.assignAll(productosCarrito);
  }

  void cerrarBusquedaParaEliminar() {
    isSearchingToDelete.value = false;
    searchToDeleteQuery.value = '';
    searchToDeleteController.clear();
    filteredProductsToDelete.clear();
  }

  void buscarProductosParaEliminar(String query) {
    searchToDeleteQuery.value = query;
    if (query.isEmpty) {
      filteredProductsToDelete.assignAll(productosCarrito);
    } else {
      filteredProductsToDelete.assignAll(
        productosCarrito.where((producto) =>
          producto.id.toString().contains(query)
        ).toList()
      );
    }
  }

  void eliminarProductoPorId(EntryEntity producto) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AdminColors.surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          "Confirmar eliminación",
          style: TextStyle(
            color: AdminColors.textPrimaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "¿Estás seguro de que deseas eliminar este producto?",
              style: TextStyle(
                color: AdminColors.textSecondaryColor,
              ),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AdminColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Producto #${producto.idProducto}",
                    style: TextStyle(
                      color: AdminColors.textPrimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Calibre: ${producto.calibre}",
                    style: TextStyle(
                      color: AdminColors.textSecondaryColor,
                      fontSize: 12,
                    ),
                  ),
                  if (producto.ordenCompra.isNotEmpty)
                    Text(
                      "OP: ${producto.ordenCompra}",
                      style: TextStyle(
                        color: AdminColors.textSecondaryColor,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              "CANCELAR",
              style: TextStyle(
                color: AdminColors.textSecondaryColor,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              removeProducto(producto);
              Get.back();
              cerrarBusquedaParaEliminar();
              _showSuccessAlert('¡Eliminado!', 'Producto eliminado correctamente');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.errorColor,
            ),
            child: Text(
              "ELIMINAR",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessAlert(String title, String message) {
    if (Get.context != null) {
      showCustomAlert(
        context: Get.context!,
        title: title,
        message: message,
        confirmText: 'Aceptar',
        type: CustomAlertType.success,
      );
    }
  }
}