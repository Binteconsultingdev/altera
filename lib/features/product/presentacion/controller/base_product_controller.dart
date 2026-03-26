import 'package:altera/common/constants/constants.dart';
import 'package:altera/common/errors/convert_message.dart';
import 'package:altera/common/theme/Theme_colors.dart';
import 'package:altera/common/widgets/custom_alert_type.dart';
import 'package:altera/features/product/domain/entities/getEntryEntity/get_entry_entity.dart';
import 'package:altera/features/product/domain/entities/product_entitie.dart';
import 'package:altera/features/product/domain/usecases/get_producto_usecase.dart';
import 'package:altera/features/product/presentacion/page/getproducto/entry_controller.dart';
import 'package:altera/framework/preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:convert';

abstract class BaseProductController extends GetxController {
  final PreferencesUser _prefsUser = PreferencesUser();
  final GetProductoUsecase getProductoUsecase;
  
  // Estado compartido
  final RxList<EntryEntity> productosCarrito = <EntryEntity>[].obs;
  final RxList<EntryEntity> productosDisponibles = <EntryEntity>[].obs;
  final RxList<EntryEntity> filteredProducts = <EntryEntity>[].obs;
  
  final RxBool isLoading = false.obs;
  final RxBool isLoadingProducts = false.obs;
  final RxInt currentTab = 0.obs;
  final RxString searchQuery = ''.obs;

  // Scanner QR - Variables privadas con getters públicos
  Rx<MobileScannerController?> qrScannerController = Rx<MobileScannerController?>(null);
  final RxBool _isScanning = false.obs;
  final RxBool _isTorchOn = false.obs;

  String? _lastScannedQR;
  DateTime? _lastScanTime;
  final int _scanCooldownMs = 2000;

  // Búsqueda para eliminar
  final RxBool isSearchingToDelete = false.obs;
  final RxString searchToDeleteQuery = ''.obs;
  final RxList<EntryEntity> filteredProductsToDelete = <EntryEntity>[].obs;
  final TextEditingController searchToDeleteController = TextEditingController();

  // Detalles de producto - Variables privadas con getters públicos
  final RxBool _showingProductDetails = false.obs;
  final Rx<EntryEntity?> _selectedProductForDetails = Rx<EntryEntity?>(null);

  // Input manual - Variables privadas con getters públicos
  final RxBool _showingManualInput = false.obs;
  final TextEditingController manualIdController = TextEditingController();
  final RxBool _isProcessingManualId = false.obs;

  // ==================== GETTERS PÚBLICOS ====================
  
  bool get isScanning => _isScanning.value;
  bool get isTorchOn => _isTorchOn.value;
  bool get showingProductDetails => _showingProductDetails.value;
  EntryEntity? get selectedProductForDetails => _selectedProductForDetails.value;
  bool get showingManualInput => _showingManualInput.value;
  bool get isProcessingManualId => _isProcessingManualId.value;

  BaseProductController({
    required this.getProductoUsecase,
  });

  // Métodos abstractos que cada hijo debe implementar
  String get storageKey;
  String? validateProductForOperation(EntryEntity producto);
  Future<void> guardarProductosEnRepositorio();

  double get subtotal => productosCarrito.length.toDouble();
  double get total => subtotal;

  @override
  void onInit() async {
    super.onInit();
    await _initializePreferences();
    await cargarProductosGuardados();
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

  Future<void> _initializePreferences() async {
    try {
      if (!_prefsUser.isInitialized) {
        print('🔧 Inicializando SharedPreferences...');
        await _prefsUser.initiPrefs();
        print('✅ SharedPreferences inicializadas');
      }
    } catch (e) {
      print('❌ Error al inicializar preferencias: $e');
    }
  }

  // ==================== MÉTODOS DE INPUT MANUAL ====================
  
  void mostrarInputManual() {
    _showingManualInput.value = true;
    manualIdController.clear();
    print('📝 Mostrando input manual para ID');
  }

  void cerrarInputManual() {
    _showingManualInput.value = false;
    manualIdController.clear();
    _isProcessingManualId.value = false;
    print('❌ Cerrando input manual');
  }

  Future<void> procesarIdManual() async {
    String idTexto = manualIdController.text.trim();
    
    if (idTexto.isEmpty) {
      showErrorAlert('Campo vacío', 'Por favor ingresa un ID');
      return;
    }

    try {
      int id = int.parse(idTexto);
      print('📝 Procesando ID manual: $id');
      
      _isProcessingManualId.value = true;
      await agregarProductoPorQR(id.toString());
    } catch (e) {
      print('❌ Error al parsear ID manual: $e');
      showErrorAlert('ID Inválido', 'El ID debe ser un número válido');
    } finally {
      _isProcessingManualId.value = false;
    }
  }

  // ==================== MÉTODOS DE DETALLES ====================
  
  void mostrarDetallesProducto(EntryEntity producto) {
    _selectedProductForDetails.value = producto;
    _showingProductDetails.value = true;
    print('📋 Mostrando detalles del producto: ${producto.idProducto}');
  }

  void cerrarDetallesProducto() {
    _showingProductDetails.value = false;
    _selectedProductForDetails.value = null;
    print('❌ Cerrando detalles del producto');
  }

  // ==================== MÉTODOS DE BÚSQUEDA ====================
  
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

  // ==================== MÉTODOS DE SCANNER QR ====================
  
  void iniciarEscaneoQR() {
    _isScanning.value = true;
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
    _isScanning.value = false;
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
      _isTorchOn.value = !_isTorchOn.value;
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
      await agregarProductoPorQR(id.toString());
      detenerEscaneoQR();
    } catch (e) {
      print('❌ Error al parsear QR: $e');
      showErrorAlert('QR Inválido', 'El código QR debe contener solo números');
    }
  }

  // ==================== MÉTODOS DE PERSISTENCIA ====================
  
  Future<void> cargarProductosGuardados() async {
    try {
      print('🔍 Cargando productos desde storage');
      
      if (!_prefsUser.isInitialized) {
        await _initializePreferences();
      }

      final String? productosJson = await _prefsUser.loadPrefs(
        type: String,
        key: storageKey,
      );

      if (productosJson != null && productosJson.isNotEmpty && productosJson != 'null') {
        try {
          final List<dynamic> productosData = jsonDecode(productosJson);
          final List<EntryEntity> productos = productosData
              .map((item) => entryEntityFromJson(item))
              .where((producto) => producto != null)
              .cast<EntryEntity>()
              .toList();
          
          productosCarrito.clear();
          productosCarrito.addAll(productos);
          productosCarrito.refresh();
          
          print('✅ Productos cargados: ${productos.length}');
        } catch (jsonError) {
          print('❌ Error al parsear JSON: $jsonError');
          await _prefsUser.clearOnePreference(key: storageKey);
          productosCarrito.clear();
        }
      } else {
        productosCarrito.clear();
        print('ℹ️ No hay productos guardados');
      }
    } catch (e) {
      print('❌ Error al cargar productos: $e');
      productosCarrito.clear();
      
      try {
        await _prefsUser.clearOnePreference(key: storageKey);
      } catch (clearError) {
        print('❌ Error al limpiar datos: $clearError');
      }
    }
  }
 /*Future<void> cargarProductosGuardados() async {
  try {
    print('🔍 Cargando productos desde storage');
    
    if (!_prefsUser.isInitialized) {
      await _initializePreferences();
    }

    final String? productosJson = await _prefsUser.loadPrefs(
      type: String,
      key: storageKey,
    );

    if (productosJson != null && productosJson.isNotEmpty && productosJson != 'null') {
      try {
        final List<dynamic> productosData = jsonDecode(productosJson);
        final List<EntryEntity> productos = productosData
            .map((item) => entryEntityFromJson(item))
            .where((producto) => producto != null)
            .cast<EntryEntity>()
            .toList();
        
        // ⭐ NUEVA VALIDACIÓN: Verificar cada producto con la API
        List<EntryEntity> productosValidos = [];
        List<EntryEntity> productosInvalidos = [];
        
        for (EntryEntity productoLocal in productos) {
          try {
            // Consultar el producto actualizado desde la API
            List<EntryEntity> productosActualizados = await getProductoUsecase.execute(
              productoLocal.idProducto.toString()
            );
            
            if (productosActualizados.isNotEmpty) {
              EntryEntity productoActualizado = productosActualizados.first;
              
              // Validar con los datos actualizados
              String? errorValidacion = validateProductForOperation(productoActualizado);
              
              if (errorValidacion == null) {
                // Producto válido: usar datos actualizados
                productosValidos.add(productoActualizado);
                print('✅ Producto ${productoActualizado.idProducto} válido y actualizado');
              } else {
                // Producto inválido
                productosInvalidos.add(productoLocal);
                print('⚠️ Producto ${productoLocal.idProducto} no válido: $errorValidacion');
              }
            } else {
              // Producto no encontrado en API
              productosInvalidos.add(productoLocal);
              print('⚠️ Producto ${productoLocal.idProducto} no encontrado en API');
            }
          } catch (e) {
            // Error al consultar este producto específico
            print('❌ Error al validar producto ${productoLocal.idProducto}: $e');
            productosInvalidos.add(productoLocal);
          }
        }
        
        // Actualizar carrito solo con productos válidos
        productosCarrito.clear();
        productosCarrito.addAll(productosValidos);
        productosCarrito.refresh();
        
        // Guardar lista limpia
        await guardarProductos();
        
        print('✅ Productos válidos cargados: ${productosValidos.length}');
        
        // Notificar al usuario si hubo productos eliminados
        if (productosInvalidos.isNotEmpty) {
          print('⚠️ Productos inválidos eliminados: ${productosInvalidos.length}');
         
        }
        
      } catch (jsonError) {
        print('❌ Error al parsear JSON: $jsonError');
        await _prefsUser.clearOnePreference(key: storageKey);
        productosCarrito.clear();
      }
    } else {
      productosCarrito.clear();
      print('ℹ️ No hay productos guardados');
    }
  } catch (e) {
    print('❌ Error al cargar productos: $e');
    productosCarrito.clear();
    
    try {
      await _prefsUser.clearOnePreference(key: storageKey);
    } catch (clearError) {
      print('❌ Error al limpiar datos: $clearError');
    }
  }
} */
  Future<void> guardarProductos() async {
    try {
      print('💾 Guardando ${productosCarrito.length} productos');
      
      if (!_prefsUser.isInitialized) {
        await _initializePreferences();
      }

      if (productosCarrito.isEmpty) {
        await _prefsUser.savePrefs(
          type: String,
          key: storageKey,
          value: '[]',
        );
        print('✅ Lista vacía guardada');
        return;
      }

      final List<Map<String, dynamic>> productosData = productosCarrito
          .map((p) => entryEntityToJson(p))
          .where((json) => json != null)
          .cast<Map<String, dynamic>>()
          .toList();

      if (productosData.isNotEmpty) {
        final String productosJson = jsonEncode(productosData);
        await _prefsUser.savePrefs(
          type: String,
          key: storageKey,
          value: productosJson,
        );
        print('✅ Productos guardados exitosamente');
      }
    } catch (e) {
      print('❌ Error al guardar productos: $e');
    }
  }

  // ==================== SERIALIZACIÓN ====================
  
  Map<String, dynamic>? entryEntityToJson(EntryEntity entry) {
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
        'sugerencias': {
          'sugerencia_entrada': entry.sugerencias?.sugerencia_entrada ?? 0,
          'sugerencia_surtir': entry.sugerencias?.sugerencia_surtir ?? 0,
        },
        'resumen_mi_almacen': {
          'entradas': entry.summarystorage?.entradas ?? 0,
          'surtimientos': entry.summarystorage?.surtimientos ?? 0,
          'eliminaciones': entry.summarystorage?.eliminaciones ?? 0,
          'salidas': entry.summarystorage?.salidas ?? 0,
          'cancelaciones': entry.summarystorage?.cancelaciones ?? 0,
          'stock_en_mi_almacen': entry.summarystorage?.stock_en_mi_almacen ?? 0,
        },
      };
    } catch (e) {
      print('❌ Error al serializar: $e');
      return null;
    }
  }

  EntryEntity? entryEntityFromJson(Map<String, dynamic> json) {
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
        tipo: json['tipo'] != null
            ? TipoEntity(
                id: json['tipo']['id'] ?? 0,
                tipo: json['tipo']['tipo'] ?? '',
              )
            : TipoEntity(id: 0, tipo: 'Desconocido'),
        sugerencias: json['sugerencias'] != null
            ? Sugerencias(
                sugerencia_entrada: json['sugerencias']['sugerencia_entrada'] ?? 0,
                sugerencia_surtir: json['sugerencias']['sugerencia_surtir'] ?? 0,
              )
            : Sugerencias(sugerencia_entrada: 0, sugerencia_surtir: 0),
        summarystorage: json['resumen_mi_almacen'] != null
            ? Summarystorage(
                entradas: json['resumen_mi_almacen']['entradas'] ?? 0,
                surtimientos: json['resumen_mi_almacen']['surtimientos'] ?? 0,
                eliminaciones: json['resumen_mi_almacen']['eliminaciones'] ?? 0,
                salidas: json['resumen_mi_almacen']['salidas'] ?? 0,
                cancelaciones: json['resumen_mi_almacen']['cancelaciones'] ?? 0,
                stock_en_mi_almacen: json['resumen_mi_almacen']['stock_en_mi_almacen'] ?? 0,
              )
            : Summarystorage(entradas: 0, surtimientos: 0, eliminaciones: 0, salidas: 0, cancelaciones: 0, stock_en_mi_almacen: 0),
        producto: json['producto'] != null
            ? ProductEntity(
                id: json['producto']['id'] ?? 0,
                nombre: json['producto']['nombre'] ?? '',
                codigo: json['producto']['codigo'] ?? '',
              )
            : ProductEntity(id: 0, nombre: '', codigo: ''),
        logs: [],
      );
    } catch (e) {
      print('❌ Error al deserializar: $e');
      return null;
    }
  }

  // ==================== MÉTODOS DE CARRITO ====================
  
  Future<void> agregarProductoPorQR(String idStr) async {
    try {
      if (isLoading.value) return;
      
      isLoading.value = true;
      int id = int.parse(idStr);
      
      List<EntryEntity> productosDisponibles = await getProductoUsecase.execute(id.toString());
      
      if (productosDisponibles.isNotEmpty) {
        EntryEntity productoDisponible = productosDisponibles.first;
        
        String? errorMessage = validateProductForOperation(productoDisponible);
        if (errorMessage != null) {
          showErrorAlert('Producto no válido', '$errorMessage\n\nESTATUS: ${productoDisponible.tipo?.tipo}');
          return;
        }

        int index = productosCarrito.indexWhere((p) => p.id == productoDisponible.id);
        if (index >= 0) {
          showErrorAlert('Ups', 'Producto ya agregado');
        } else {
          productosCarrito.add(productoDisponible);
          productosCarrito.refresh();
          await guardarProductos();
          print('✅ Producto agregado. Total: ${productosCarrito.length}');
        }
      } else {
        showErrorAlert('Ups', 'Producto no encontrado');
      }
    } catch (e) {
      print('❌ Error: $e');
      showErrorAlert('Ups', 'No se pudo procesar el producto');
    } finally {
      isLoading.value = false;
    }
  }

  void removeProducto(EntryEntity producto) {
    productosCarrito.remove(producto);
    productosCarrito.refresh();
    guardarProductos();
    print('🗑️ Producto removido. Quedan: ${productosCarrito.length}');
  }

  void limpiarCarrito() {
    productosCarrito.clear();
    productosCarrito.refresh();
    
    Future.microtask(() async {
      await guardarProductos();
      print('🧹 Carrito limpiado');
    });
  }

  // ==================== NOTIFICACIONES ====================
  
  void notificarActualizacionLabels() {
    try {
      if (Get.isRegistered<LabelController>()) {
        final labelController = Get.find<LabelController>();
        Future.delayed(Duration(milliseconds: 500), () {
          labelController.loadLabels();
        });
      }
    } catch (e) {
      print('❌ Error al notificar LabelController: $e');
    }
  }

  // ==================== ALERTAS ====================
  
  void showErrorAlert(String title, String message, {VoidCallback? onDismiss}) {
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

  void showSuccessAlert(String title, String message) {
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