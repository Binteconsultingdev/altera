import 'package:altera/common/constants/constants.dart';
import 'package:altera/common/errors/convert_message.dart';
import 'package:altera/common/settings/routes_names.dart';
import 'package:altera/features/product/domain/entities/orders/pending_orders_entity.dart';
import 'package:altera/features/product/domain/entities/orders/orders_entity.dart';
import 'package:altera/features/product/domain/entities/getEntryEntity/get_entry_entity.dart';
import 'package:altera/features/product/domain/entities/poshProduct/posh_product_entity.dart';
import 'package:altera/features/product/domain/entities/surtir/surtir_entity.dart';
import 'package:altera/features/product/domain/usecases/delete_ballot_usecase.dart';
import 'package:altera/features/product/domain/usecases/get_orders_usecase.dart';
import 'package:altera/features/product/domain/usecases/get_pendingorders_usecase.dart';
import 'package:altera/features/product/domain/usecases/get_producto_usecase.dart';
import 'package:altera/features/product/domain/usecases/surtir_productos_usecase.dart';
import 'package:altera/common/widgets/custom_alert_type.dart';
import 'package:altera/features/product/presentacion/page/getproducto/entry_controller.dart';
import 'package:altera/framework/preferences_service.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:convert'; 

class PendingOrdersController extends GetxController {
  final GetPendingordersUsecase getPendingOrdersUseCase;
  final GetOrdersUsecase getOrdersUsecase;
  final GetProductoUsecase getProductoUsecase;
  final SurtirProductosUsecase surtirProductosUsecase;
  final DeleteBallotUsecase deleteBallotUsecase; 

  PendingOrdersController({
    required this.getPendingOrdersUseCase, 
    required this.getOrdersUsecase,
    required this.getProductoUsecase,
    required this.surtirProductosUsecase,
    required this.deleteBallotUsecase,
  });

  final RxList<PendingOrdersEntity> _pendingOrders = <PendingOrdersEntity>[].obs;
  final RxList<PendingOrdersEntity> _filteredOrders = <PendingOrdersEntity>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxString _searchQuery = ''.obs;
  final Rx<DateTime> _selectedDate = DateTime(
  DateTime.now().year - 1,
  DateTime.now().month,
  DateTime.now().day
).obs;
  final TextEditingController _dateController = TextEditingController();

  final Rx<OrdersEntity?> _selectedOrder = Rx<OrdersEntity?>(null);
  final RxBool _isLoadingOrderDetails = false.obs;
  final RxString _orderDetailsError = ''.obs;

  final RxMap<int, List<EntryEntity>> _productosEscaneadosPorOrden = <int, List<EntryEntity>>{}.obs;
  final RxBool _isScanning = false.obs;
  final RxBool _isTorchOn = false.obs;
  final RxBool _isProcessingSurtido = false.obs;
  Rx<MobileScannerController?> qrScannerController = Rx<MobileScannerController?>(null);
  
  final RxInt _currentOrderId = 0.obs;
  
  String? _lastScannedQR;
  DateTime? _lastScanTime;
  final int _scanCooldownMs = 2000;

  List<PendingOrdersEntity> get pendingOrders => _pendingOrders;
  List<PendingOrdersEntity> get filteredOrders => _filteredOrders;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  String get searchQuery => _searchQuery.value;
  DateTime get selectedDate => _selectedDate.value;
  TextEditingController get dateController => _dateController;
  OrdersEntity? get selectedOrder => _selectedOrder.value;
  bool get isLoadingOrderDetails => _isLoadingOrderDetails.value;
  String get orderDetailsError => _orderDetailsError.value;
final Map<int, int> _piezasPorPalletOriginales = {};
  List<EntryEntity> get productosEscaneados => 
      _productosEscaneadosPorOrden[_currentOrderId.value] ?? [];
  
  bool get isScanning => _isScanning.value;
  bool get isTorchOn => _isTorchOn.value;
  bool get isProcessingSurtido => _isProcessingSurtido.value;

  int get totalOrders => _pendingOrders.length;
  int get filteredOrdersCount => _filteredOrders.length;
  final Map<int, TextEditingController> _textControllers = {};
 final RxBool _showingManualInput = false.obs;
  final TextEditingController _manualIdController = TextEditingController();
  final RxBool _isProcessingManualId = false.obs;
 bool get showingManualInput => _showingManualInput.value;
  TextEditingController get manualIdController => _manualIdController;
  bool get isProcessingManualId => _isProcessingManualId.value;

  @override
  void onInit() {
    super.onInit();
    _updateDateController();
    _cargarProductosEscaneadosGuardados();
    loadPendingOrders();
  }
  TextEditingController getControllerForProduct(EntryEntity producto) {
    if (!_textControllers.containsKey(producto.id)) {
      _textControllers[producto.id] = TextEditingController(
        text: producto.piezasPorPallet.toString()
      );
    }
    return _textControllers[producto.id]!;
  }
 void clearController(int productId) {
    if (_textControllers.containsKey(productId)) {
      _textControllers[productId]?.dispose();
      _textControllers.remove(productId);
    }
  }   void clearAllControllers() {
    for (var controller in _textControllers.values) {
      controller.dispose();
    }
    _textControllers.clear();
  }
   @override
  void onClose() {
    clearAllControllers();
    _dateController.dispose();
    _manualIdController.dispose(); 
    _guardarProductosEscaneados();
    if (qrScannerController.value != null) {
      qrScannerController.value!.dispose();
    }
    super.onClose();
  }
    PoshProductEntity _entryEntityToPoshProductEntity(EntryEntity entry) {
    return PoshProductEntity(
      id: entry.id,
    );
  }
Future<void> eliminarPapeleta(EntryEntity producto) async {
    try {
      _isProcessingSurtido.value = true; 
      
      PoshProductEntity poshProduct = _entryEntityToPoshProductEntity(producto);
      List<PoshProductEntity> productosAEliminar = [poshProduct];
      await deleteBallotUsecase.execute(productosAEliminar);
      
      _showSuccessAlert('¡Eliminado!', 'La papeleta ha sido eliminada permanentemente');
      
      if (_currentOrderId.value != 0) {
        removerProductoEscaneado(producto);
      }
      
      if (_selectedOrder.value != null) {
        await loadOrderDetails(_selectedOrder.value!.id);
        
      }
      _notificarActualizacionLabels();
      print('✅ Papeleta eliminada exitosamente');
      
    } catch (e) {
      print('❌ Error al eliminar papeleta: $e');
      String cleanMessage = cleanExceptionMessage(e);
      _showErrorAlert('Error al eliminar', cleanMessage);
    } finally {
      _isProcessingSurtido.value = false;
    }
  }


  Future<void> _guardarProductosEscaneados() async {
  try {
    final Map<String, dynamic> productosParaGuardar = {};
    
    for (var entry in _productosEscaneadosPorOrden.entries) {
      final orderId = entry.key.toString();
      final productos = entry.value;
      
      final productosJson = productos.map((producto) => _entryEntityToJson(producto)).toList();
      productosParaGuardar[orderId] = productosJson;
    }
    
    final jsonString = jsonEncode(productosParaGuardar);
    PreferencesUser().savePrefs(
      type: String, 
      key: AppConstants.productosescaneados, 
      value: jsonString
    );
    
    print('💾 Productos escaneados guardados con valores originales en SharedPreferences');
    print('📊 Valores originales actuales: $_piezasPorPalletOriginales');
  } catch (e) {
    print('❌ Error al guardar productos escaneados: $e');
  }
}


  Future<void> _cargarProductosEscaneadosGuardados() async {
  try {
    final jsonString = await PreferencesUser().loadPrefs(
      type: String, 
      key: AppConstants.productosescaneados
    );
    
    if (jsonString != null && jsonString.isNotEmpty) {
      final Map<String, dynamic> productosGuardados = jsonDecode(jsonString);
      
      _piezasPorPalletOriginales.clear();
      
      for (var entry in productosGuardados.entries) {
        final orderId = int.tryParse(entry.key);
        if (orderId != null) {
          final productosJson = entry.value as List<dynamic>;
          final productos = productosJson
              .map((json) => _entryEntityFromJson(json)) 
              .toList();
          
          _productosEscaneadosPorOrden[orderId] = productos;
        }
      }
      
      print('📂 Productos escaneados cargados desde SharedPreferences');
      print('📊 Órdenes con productos: ${_productosEscaneadosPorOrden.keys.length}');
      print('📊 Valores originales restaurados: $_piezasPorPalletOriginales');
    }
  } catch (e) {
    print('❌ Error al cargar productos escaneados: $e');
  }
}

  void _setCurrentOrderId(int orderId) {
    _currentOrderId.value = orderId;
    print('🔄 Orden actual establecida: $orderId');
    
    if (!_productosEscaneadosPorOrden.containsKey(orderId)) {
      _productosEscaneadosPorOrden[orderId] = <EntryEntity>[];
    }
    
    _productosEscaneadosPorOrden.refresh();
  }

  void _updateDateController() {
    _dateController.text = formatDateForInput(_selectedDate.value);
  }

  String formatDateForInput(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String formatDateForApi(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  void changeSelectedDate(DateTime date) {
    _selectedDate.value = date;
    _updateDateController();
    loadPendingOrders();
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF3F72AF),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF2C3E50),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate.value) {
      changeSelectedDate(picked);
    }
  }

  void setToday() {
    changeSelectedDate(DateTime.now());
  }

  Future<void> loadPendingOrders() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      
      final dateString = formatDateForApi(_selectedDate.value);
      final orders = await getPendingOrdersUseCase.execute(date: dateString);
      
      _pendingOrders.value = orders;
      _filteredOrders.value = orders;
      
    } catch (e) {
      
      _errorMessage.value = cleanExceptionMessage(e);
      debugPrint('Error loading pending orders: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  void searchOrders(String query) {
    _searchQuery.value = query;
    
    if (query.isEmpty) {
      _filteredOrders.value = _pendingOrders;
    } else {
      final filteredList = _pendingOrders.where((order) {
        final searchTerm = query.toLowerCase();
        return order.serie.toLowerCase().contains(searchTerm) ||
               order.folio.toString().contains(searchTerm) ||
               order.clienteEntity.cliente.toLowerCase().contains(searchTerm) ||
               order.clienteEntity.codigo.toLowerCase().contains(searchTerm) ||
               order.fecha.toLowerCase().contains(searchTerm);
      }).toList();
      
      _filteredOrders.value = filteredList;
    }
  }

  void clearSearch() {
    _searchQuery.value = '';
    _filteredOrders.value = _pendingOrders;
  }

  Future<void> refreshOrders() async {
    await loadPendingOrders();
  }

  void filterByClient(String clientCode) {
    if (clientCode.isEmpty) {
      _filteredOrders.value = _pendingOrders;
    } else {
      final filteredList = _pendingOrders.where((order) {
        return order.clienteEntity.codigo == clientCode;
      }).toList();
      
      _filteredOrders.value = filteredList;
    }
  }

  void sortByDate({bool ascending = true}) {
    final sortedList = List<PendingOrdersEntity>.from(_filteredOrders);
    sortedList.sort((a, b) {
      final dateA = DateTime.tryParse(a.fecha) ?? DateTime.now();
      final dateB = DateTime.tryParse(b.fecha) ?? DateTime.now();
      return ascending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
    });
    _filteredOrders.value = sortedList;
  }

  void sortByFolio({bool ascending = true}) {
    final sortedList = List<PendingOrdersEntity>.from(_filteredOrders);
    sortedList.sort((a, b) {
      return ascending ? a.folio.compareTo(b.folio) : b.folio.compareTo(a.folio);
    });
    _filteredOrders.value = sortedList;
  }

  Color getPendingColor(String pendientes) {
    final count = int.tryParse(pendientes) ?? 0;
    if (count == 0) return Colors.green;
    if (count <= 5) return Colors.orange;
    return Colors.red;
  }

  String formatDate(String fecha) {
    try {
      final date = DateTime.parse(fecha);
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    } catch (e) {
      return fecha;
    }
  }

  void clearError() {
    _errorMessage.value = '';
  }

  Future<void> loadOrderDetails(int orderId) async {
    try {
      _isLoadingOrderDetails.value = true;
      _orderDetailsError.value = '';
      _selectedOrder.value = null;
      
      _setCurrentOrderId(orderId);
      
      final orderDetails = await getOrdersUsecase.execute(id: orderId);
      _selectedOrder.value = orderDetails;
      
      print('📋 Detalles de orden cargados para ID: $orderId');
      print('📦 Productos escaneados para esta orden: ${productosEscaneados.length}');
      
    } catch (e) {

      _orderDetailsError.value = '${cleanExceptionMessage(e)}';
      debugPrint('Error loading order details: $e');
    } finally {
      _isLoadingOrderDetails.value = false;
    }
  }

  void clearOrderDetails() {
    _selectedOrder.value = null;
    _orderDetailsError.value = '';
    _isLoadingOrderDetails.value = false;
    _currentOrderId.value = 0;
  }

  double calculateOrderTotal(OrdersEntity order) {
    return order.movimientos.fold(0.0, (sum, movimiento) => sum + movimiento.total);
  }

  int getTotalPendientes(OrdersEntity order) {
    return order.movimientos.fold(0, (sum, movimiento) => sum + movimiento.pendientes);
  }

  String formatPrice(double price) {
    return '\$${price.toStringAsFixed(2)}';
  }

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
      print('🔍 QR Data detectado para surtir: "$qrData"');
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
      print('🔍 ID parseado para surtir: $id');
      await _agregarProductoEscaneado(id.toString());
      detenerEscaneoQR();
    } catch (e) {
      print('❌ Error al parsear QR para surtir: $e');
      _showErrorAlert('QR Inválido', 'El código QR debe contener solo números');
    }
  }
void resetControllerForProduct(EntryEntity producto) {
  if (_textControllers.containsKey(producto.id)) {
    final controller = _textControllers[producto.id]!;
    controller.text = producto.sugerencias.sugerencia_surtir.toString();
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length)
    );
  }
}

  Future<void> _agregarProductoEscaneado(String idStr) async {
  try {
    if (_currentOrderId.value == 0) {
      _showErrorAlert('Error', 'No hay una orden seleccionada');
      return;
    }

    if (_selectedOrder.value == null) {
      _showErrorAlert('Error', 'No se encontraron detalles de la orden');
      return;
    }

    int id = int.parse(idStr);
    print('🔍 Buscando producto para surtir con ID: $id (Orden: ${_currentOrderId.value})');
    
    List<EntryEntity> productosDisponibles = await getProductoUsecase.execute(id.toString());
    print('🔍 Productos encontrados para surtir: ${productosDisponibles.length}');
    
    if (productosDisponibles.isNotEmpty) {
      EntryEntity productoDisponible = productosDisponibles.first;
      print('🔍 Producto encontrado para surtir - ID: ${productoDisponible.id}');
      
      if (productoDisponible.tipo.id != 2) {
        print('❌ Papeleta no cumple con los requisitos - Tipo: ${productoDisponible.tipo.id} (se requiere tipo 2)');
        _showErrorAlert('Papeleta no válida', 'Papeleta no cumple con los requisitos');
        return;
      }
      
      final int piezasPorPalletTotal = int.tryParse(productoDisponible.piezasPorPallet) ?? 0;
      final int totalPiezasPorPalletSurtidas = productoDisponible.summarystorage.salidas ?? 0;
     if (productoDisponible.sugerencias?.sugerencia_surtir != null &&
    productoDisponible.sugerencias!.sugerencia_surtir <= 0) {
  _showErrorAlert('Sin stock', 'La papeleta no cuenta con stock suficiente para surtir.');
  return;
}

      
      bool productoEstaEnOrden = _selectedOrder.value!.movimientos.any((movimiento) => 
        movimiento.producto.id == productoDisponible.producto?.id
      );
      
      if (!productoEstaEnOrden) {
        print('❌ Producto no pertenece a esta orden - Producto ID: ${productoDisponible.producto?.id}');
        print('📋 Productos válidos en la orden: ${_selectedOrder.value!.movimientos.map((m) => m.producto.id).toList()}');
        _showErrorAlert('Producto no válido', 'Este producto no pertenece a la orden seleccionada');
        return;
      }
      
      List<EntryEntity> productosActuales = _productosEscaneadosPorOrden[_currentOrderId.value] ?? [];
      
      int index = productosActuales.indexWhere((p) => p.id == productoDisponible.id);
      if (index >= 0) {
        _showErrorAlert('Ups', 'Producto ya escaneado en esta orden');
      } else {
        _guardarPiezasPorPalletOriginal(productoDisponible);
        
        productosActuales.add(productoDisponible);
        _productosEscaneadosPorOrden[_currentOrderId.value] = productosActuales;
        resetControllerForProduct(productoDisponible);

        _productosEscaneadosPorOrden.refresh();
        
        await _guardarProductosEscaneados();
        
        print('✅ Producto agregado para surtir en orden ${_currentOrderId.value}. Total escaneados: ${productosActuales.length}');
        
        final int piezasFaltantes = piezasPorPalletTotal - totalPiezasPorPalletSurtidas;
        print('📊 Papeleta agregada - Faltan $piezasFaltantes piezas de $piezasPorPalletTotal');
      }
    } else {
      print('❌ No se encontraron productos para surtir con ID: $id');
      _showErrorAlert('Ups', 'Producto no encontrado');
    }
  } catch (e) {
    print('❌ Error al procesar el producto para surtir: $e');
    _showErrorAlert('Ups', 'No se pudo procesar el producto $e');
  }
}


 void removerProductoEscaneado(EntryEntity producto) {
  if (_currentOrderId.value == 0) return;
  
  List<EntryEntity> productosActuales = _productosEscaneadosPorOrden[_currentOrderId.value] ?? [];
  productosActuales.remove(producto);
  _productosEscaneadosPorOrden[_currentOrderId.value] = productosActuales;
  _productosEscaneadosPorOrden.refresh();
  
  _piezasPorPalletOriginales.remove(producto.id);
  
  _guardarProductosEscaneados();
  
  print('🗑️ Producto removido de orden ${_currentOrderId.value}. Quedan: ${productosActuales.length}');
}



void limpiarProductosEscaneados() {
  if (_currentOrderId.value == 0) return;
  
  final productosActuales = _productosEscaneadosPorOrden[_currentOrderId.value] ?? [];
  
  for (var producto in productosActuales) {
    _piezasPorPalletOriginales.remove(producto.id);
  }
  
  _productosEscaneadosPorOrden[_currentOrderId.value] = <EntryEntity>[];
  _productosEscaneadosPorOrden.refresh();
  
  _guardarProductosEscaneados();
  
  print('🧹 Productos escaneados limpiados para orden ${_currentOrderId.value}');
}
  void limpiarProductosEscaneadosDeOrden(int orderId) {
    _productosEscaneadosPorOrden[orderId] = <EntryEntity>[];
    _productosEscaneadosPorOrden.refresh();
    
    _guardarProductosEscaneados();
    
    print('🧹 Productos escaneados limpiados para orden específica: $orderId');
  }

  List<EntryEntity> getProductosEscaneadosDeOrden(int orderId) {
    return _productosEscaneadosPorOrden[orderId] ?? [];
  }

  bool tieneProductosEscaneados(int orderId) {
    final productos = _productosEscaneadosPorOrden[orderId] ?? [];
    return productos.isNotEmpty;
  }

  int getConteoProductosEscaneados(int orderId) {
    final productos = _productosEscaneadosPorOrden[orderId] ?? [];
    return productos.length;
  }
  
  
  Future<void> procesarSurtido(PendingOrdersEntity order) async {
  try {
    _isProcessingSurtido.value = true;
    
    final productosEscaneadosOrden = _productosEscaneadosPorOrden[order.id] ?? [];
    
    if (productosEscaneadosOrden.isEmpty) {
      _showErrorAlert('Lista vacía', 'No hay productos escaneados para surtir en esta orden.');
      return;
    }
    
    if (_selectedOrder.value == null) {
      _showErrorAlert('Error', 'No se encontraron detalles de la orden.');
      return;
    }
    
    for (EntryEntity producto in productosEscaneadosOrden) {
      int piezasEditadas = int.tryParse(producto.piezasPorPallet) ?? 0;
      
      if (piezasEditadas <= 0) {
        _showErrorAlert('Valor inválido', 
          'El producto ${producto.producto?.nombre ?? 'ID: ${producto.id}'} tiene un valor inválido de piezas por pallet: $piezasEditadas');
        return;
      }
      
      final int piezasPorPalletOriginal = getPiezasPorPalletOriginal(producto.id);
      final int totalPiezasPorPalletSurtidas = producto.summarystorage.salidas;
      
      if (piezasEditadas > producto.sugerencias.sugerencia_surtir) {
        _showErrorAlert(
          'Cantidad excesiva', 
          'No puedes surtir ${piezasEditadas} piezas del producto "${producto.producto?.nombre ?? 'ID: ${producto.id}'}".\n\n'
          'Total del pallet: $piezasPorPalletOriginal\n'
          'Ya surtidas: $totalPiezasPorPalletSurtidas\n'
          'Máximo permitido: ${producto.sugerencias.sugerencia_surtir}\n\n'
          'Por favor ajusta la cantidad antes de continuar.'
        );
        return; 
      }
    }
    
    List<SurtirEntity> surtirList = [];
    
    for (EntryEntity producto in productosEscaneadosOrden) {
      int piezasEditadas = int.tryParse(producto.piezasPorPallet) ?? 0;
      
      SurtirEntity surtirEntity = SurtirEntity(
        id: producto.id,
        piezas_por_pallet: piezasEditadas,
        id_producto: producto.idProducto,
      );
      
      surtirList.add(surtirEntity);
      
      print('📦 Papeleta ID ${producto.id} - Producto ID ${producto.idProducto} (${producto.producto?.nombre}): piezas_por_pallet = $piezasEditadas');
    }
    
    print('📦 Enviando ${surtirList.length} productos al surtir con piezas_por_pallet validadas');
    
    await surtirProductosUsecase.execute(surtirList, order.id.toString());
    _showSuccessAlert('¡Éxito!', 'Surtido procesado correctamente');
    
    limpiarProductosEscaneadosDeOrden(order.id);
    await loadOrderDetails(order.id);
    await loadPendingOrders();

    _notificarActualizacionLabels();
    Get.toNamed(RoutesNames.homePage, arguments: 2);
  } catch (e) {
    print('❌ Error al procesar surtido: $e');
    
    String cleanMessage = cleanExceptionMessage(e);
    _showErrorAlert('Error al procesar surtido', cleanMessage);
    
  } finally {
    _isProcessingSurtido.value = false;
  }
}
  void _showErrorAlert(String title, String message) {
    if (Get.context != null) {
      showCustomAlert(
        context: Get.context!,
        title: title,
        message: message,
        confirmText: 'Aceptar',
        type: CustomAlertType.error,
      );
    }
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

  int getTotalCantidadMovimientos() {
    if (_selectedOrder.value == null) return 0;
    
    return _selectedOrder.value!.movimientos.fold(0, (sum, movimiento) {
      return sum + movimiento.cantidad;
    });
  }

  int getTotalPiezasPorPalletEscaneados() {
    final productosEscaneadosOrden = _productosEscaneadosPorOrden[_currentOrderId.value] ?? [];
    return productosEscaneadosOrden.fold(0, (sum, producto) {
      final piezas = int.tryParse(producto.piezasPorPallet) ?? 0;
      return sum + piezas;
    });
  }

  Map<String, int> getResumenTotales() {
    final productosEscaneadosOrden = _productosEscaneadosPorOrden[_currentOrderId.value] ?? [];
    return {
      'totalCantidadMovimientos': getTotalCantidadMovimientos(),
      'totalPiezasPalletEscaneados': getTotalPiezasPorPalletEscaneados(),
      'productosEscaneados': productosEscaneadosOrden.length,
      'movimientosOrden': _selectedOrder.value?.movimientos.length ?? 0,
    };
  }

  String formatearNumero(int numero) {
    final formatter = NumberFormat('#,###', 'en_US');
    return formatter.format(numero);
  }

  void actualizarPiezasPorPallet(EntryEntity producto, String nuevasPiezas) {
  try {
    if (_currentOrderId.value == 0) return;
    
    /* Validar las piezas antes de proceder
    if (!_validarPiezasPorPallet(producto, nuevasPiezas)) {
      final controller = getControllerForProduct(producto);
      controller.text = producto.piezasPorPallet;
      return;
    }*/
    
    final int piezasEditadas = int.tryParse(nuevasPiezas) ?? 0;
    final int piezasOriginales = int.tryParse(producto.piezasPorPallet) ?? 0;
    
    List<EntryEntity> productosActuales = _productosEscaneadosPorOrden[_currentOrderId.value] ?? [];
    
    final index = productosActuales.indexWhere((p) => p.id == producto.id);
    
    if (index != -1) {
      final productoActualizado = EntryEntity(
        id: producto.id,
        idEntrada: producto.idEntrada,
        idProducto: producto.idProducto,
        maquina: producto.maquina,
        anchoAla: producto.anchoAla,
        longitud: producto.longitud,
        calibre: producto.calibre,
        piezasPorPallet: piezasEditadas.toString(), 
        camasPorTarima: producto.camasPorTarima,
        bultosPorCama: producto.bultosPorCama,
        piezasPorBulto: producto.piezasPorBulto,
        puntos: producto.puntos,
        ordenCompra: producto.ordenCompra,
        observaciones: producto.observaciones,
        tipo: producto.tipo,
        sugerencias: producto.sugerencias,
        summarystorage: producto.summarystorage,
        producto: producto.producto,
        logs: producto.logs,
      );
      
      productosActuales[index] = productoActualizado;
      _productosEscaneadosPorOrden[_currentOrderId.value] = productosActuales;
      
      _guardarProductosEscaneados();
      
      print('✅ Piezas por pallet actualizadas para papeleta ID ${producto.id}: $piezasEditadas (original: $piezasOriginales)');
      print('📊 Nuevo total de piezas por pallet escaneadas: ${getTotalPiezasPorPalletEscaneados()}');
      
    }
  } catch (e) {
    print('❌ Error al actualizar piezas por pallet: $e');
    _showErrorAlert('Error', 'No se pudo actualizar el valor');
  }
}

  void limpiarTodasLasOrdenes() {
    
    _productosEscaneadosPorOrden.clear();
    _productosEscaneadosPorOrden.refresh();
    _guardarProductosEscaneados();
    print('🧹 Todas las órdenes con productos escaneados han sido limpiadas');
  }

  Map<String, dynamic> getEstadisticasGlobales() {
    int totalOrdenes = _productosEscaneadosPorOrden.length;
    int totalProductos = 0;
    int totalPiezas = 0;

    for (var productos in _productosEscaneadosPorOrden.values) {
      totalProductos += productos.length;
      for (var producto in productos) {
        totalPiezas += int.tryParse(producto.piezasPorPallet) ?? 0;
      }
    }

    return {
      'ordenesConProductos': totalOrdenes,
      'totalProductosEscaneados': totalProductos,
      'totalPiezasEscaneadas': totalPiezas,
      'promedioProductosPorOrden': totalOrdenes > 0 ? (totalProductos / totalOrdenes).toStringAsFixed(1) : '0',
    };
  }

  String exportarDatosEscaneados() {
    try {
      final Map<String, dynamic> datosExport = {
        'timestamp': DateTime.now().toIso8601String(),
        'totalOrdenes': _productosEscaneadosPorOrden.length,
        'datos': {},
      };

      for (var entry in _productosEscaneadosPorOrden.entries) {
        final orderId = entry.key.toString();
        final productos = entry.value;
        
        datosExport['datos'][orderId] = {
          'cantidadProductos': productos.length,
          'productos': productos.map((p) => _entryEntityToJson(p)).toList(),
        };
      }

      return jsonEncode(datosExport);
    } catch (e) {
      print('❌ Error al exportar datos: $e');
      return '';
    }
  }

  Future<bool> importarDatosEscaneados(String jsonData) async {
    try {
      final Map<String, dynamic> datosImport = jsonDecode(jsonData);
      final Map<String, dynamic> datos = datosImport['datos'] ?? {};

      _productosEscaneadosPorOrden.clear();

      for (var entry in datos.entries) {
        final orderId = int.tryParse(entry.key);
        if (orderId != null) {
          final datosOrden = entry.value;
          final productosJson = datosOrden['productos'] as List<dynamic>;
          final productos = productosJson
              .map((json) => _entryEntityFromJson(json))
              .toList();
          
          _productosEscaneadosPorOrden[orderId] = productos;
        }
      }

      _productosEscaneadosPorOrden.refresh();
      await _guardarProductosEscaneados();

      print('✅ Datos importados exitosamente');
      return true;
    } catch (e) {
      print('❌ Error al importar datos: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> validarIntegridadDatos() async {
    final resultado = <String, dynamic>{
      'esValido': true,
      'errores': <String>[],
      'advertencias': <String>[],
      'estadisticas': {},
    };

    try {
      int productosCorruptos = 0;
      int ordenesVacias = 0;

      for (var entry in _productosEscaneadosPorOrden.entries) {
        final orderId = entry.key;
        final productos = entry.value;

        if (productos.isEmpty) {
          ordenesVacias++;
          resultado['advertencias'].add('Orden $orderId no tiene productos escaneados');
          continue;
        }

        for (var producto in productos) {
          if (producto.id == 0 || 
              producto.idProducto == 0 || 
              producto.producto?.codigo.isEmpty == true) {
            productosCorruptos++;
            resultado['errores'].add('Producto corrupto en orden $orderId: ID=${producto.id}');
            resultado['esValido'] = false;
          }

          final piezas = int.tryParse(producto.piezasPorPallet);
          if (piezas == null || piezas < 0) {
            resultado['advertencias'].add('Valor inválido de piezas por pallet en orden $orderId: ${producto.piezasPorPallet}');
          }
        }
      }

      resultado['estadisticas'] = {
        'productosCorruptos': productosCorruptos,
        'ordenesVacias': ordenesVacias,
        'totalOrdenes': _productosEscaneadosPorOrden.length,
      };

    } catch (e) {
      resultado['esValido'] = false;
      resultado['errores'].add('Error durante la validación: $e');
    }

    return resultado;
  }

  Map<String, dynamic> _entryEntityToJson(EntryEntity entry) {
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
    'piezas_por_pallet_original': _piezasPorPalletOriginales[entry.id] ?? int.tryParse(entry.piezasPorPallet) ?? 0,
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
}

EntryEntity _entryEntityFromJson(Map<String, dynamic> json) {
  final entryEntity = EntryEntity(
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
  
  final int valorOriginal = json['piezas_por_pallet_original'] ?? 0;
  if (valorOriginal > 0) {
    _piezasPorPalletOriginales[entryEntity.id] = valorOriginal;
    print('🔄 Restaurado valor original para producto ${entryEntity.id}: $valorOriginal');
  }
  
  return entryEntity;
}
   void mostrarInputManual() {
    _showingManualInput.value = true;
    _manualIdController.clear();
    print('📝 Mostrando input manual para ID (surtir)');
  }
  void cerrarInputManual() {
    _showingManualInput.value = false;
    _manualIdController.clear();
    _isProcessingManualId.value = false;
    print('❌ Cerrando input manual (surtir)');
  }
  Future<void> procesarIdManual() async {
    String idTexto = _manualIdController.text.trim();
    
    if (idTexto.isEmpty) {
      _showErrorAlert('Campo vacío', 'Por favor ingresa un ID');
      return;
    }

    try {
      int id = int.parse(idTexto);
      print('📝 Procesando ID manual para surtir: $id');
      
      _isProcessingManualId.value = true;
      await _agregarProductoEscaneado(id.toString());
      
    } catch (e) {
      print('❌ Error al parsear ID manual para surtir: $e');
      _showErrorAlert('ID Inválido', 'El ID debe ser un número válido');
    } finally {
      _isProcessingManualId.value = false;
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
bool _validarPiezasPorPallet(EntryEntity producto, String nuevasPiezasStr) {
  try {
    final int nuevasPiezas = int.tryParse(nuevasPiezasStr) ?? 0;
    
    if (nuevasPiezas <= 0) {
      _showErrorAlert('Valor inválido', 'Las piezas por pallet deben ser mayor a 0');
      return false;
    }
   
    return true;
  } catch (e) {
    _showErrorAlert('Error', 'No se pudo procesar el valor ingresado');
    return false;
  }
}
int getPiezasPorPalletOriginal(int productoId) {
  return _piezasPorPalletOriginales[productoId] ?? 0;
}
void _guardarPiezasPorPalletOriginal(EntryEntity producto) {
  if (!_piezasPorPalletOriginales.containsKey(producto.id)) {
    final int valorOriginal = int.tryParse(producto.piezasPorPallet) ?? 0;
    _piezasPorPalletOriginales[producto.id] = valorOriginal;
    print('💾 Guardado valor original para producto ${producto.id}: $valorOriginal');
  }
}


}