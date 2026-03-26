import 'package:altera/common/constants/constants.dart';
import 'package:altera/common/errors/convert_message.dart';
import 'package:altera/common/settings/routes_names.dart';
import 'package:altera/common/theme/Theme_colors.dart';
import 'package:altera/features/product/domain/entities/orders/pending_orders_entity.dart';
import 'package:altera/features/product/domain/entities/orders/orders_entity.dart';
import 'package:altera/features/product/domain/entities/getEntryEntity/get_entry_entity.dart';
import 'package:altera/features/product/domain/entities/surtir/surtir_entity.dart';
import 'package:altera/features/product/domain/usecases/get_orders_usecase.dart';
import 'package:altera/features/product/domain/usecases/get_pendingorders_usecase.dart';
import 'package:altera/features/product/domain/usecases/get_producto_usecase.dart';
import 'package:altera/features/product/domain/usecases/surtir_productos_usecase.dart';
import 'package:altera/features/product/presentacion/controller/base_product_controller.dart';
import 'package:altera/features/product/presentacion/page/getproducto/entry_controller.dart';
import 'package:altera/framework/preferences_service.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class PendingOrdersController extends BaseProductController {
  final GetPendingordersUsecase getPendingOrdersUseCase;
  final GetOrdersUsecase getOrdersUsecase;
  final SurtirProductosUsecase surtirProductosUsecase;

  PendingOrdersController({
    required this.getPendingOrdersUseCase,
    required this.getOrdersUsecase,
    required GetProductoUsecase getProductoUsecase,
    required this.surtirProductosUsecase,
  }) : super(getProductoUsecase: getProductoUsecase);

  
  final RxList<PendingOrdersEntity> _pendingOrders = <PendingOrdersEntity>[].obs;
  final RxList<PendingOrdersEntity> _filteredOrders = <PendingOrdersEntity>[].obs;
  final RxBool _isLoadingOrders = false.obs;
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
  final RxBool _isProcessingSurtido = false.obs;
  final RxInt _currentOrderId = 0.obs;
  final Map<int, int> _piezasPorPalletOriginales = {};

  final Map<int, TextEditingController> _textControllers = {};

  
  List<PendingOrdersEntity> get pendingOrders => _pendingOrders;
  List<PendingOrdersEntity> get filteredOrders => _filteredOrders;
  bool get isLoadingOrders => _isLoadingOrders.value;
  String get errorMessage => _errorMessage.value;
  RxString get searchQuery => _searchQuery;
  DateTime get selectedDate => _selectedDate.value;
  TextEditingController get dateController => _dateController;
  OrdersEntity? get selectedOrder => _selectedOrder.value;
  bool get isLoadingOrderDetails => _isLoadingOrderDetails.value;
  String get orderDetailsError => _orderDetailsError.value;
  List<EntryEntity> get productosEscaneados => 
      _productosEscaneadosPorOrden[_currentOrderId.value] ?? [];
  bool get isProcessingSurtido => _isProcessingSurtido.value;
  int get totalOrders => _pendingOrders.length;
  int get filteredOrdersCount => _filteredOrders.length;

  
  @override
  String get storageKey => AppConstants.productosescaneados;

  @override
  String? validateProductForOperation(EntryEntity producto) {
    if (producto.tipo.id != 2) {
      return 'Papeleta no cumple con los requisitos ';
    }

    if (producto.sugerencias?.sugerencia_surtir == null ||
        producto.sugerencias!.sugerencia_surtir <= 0) {
      return 'La papeleta no cuenta con stock suficiente para surtir';
    }

    return null;
  }

  @override
  Future<void> guardarProductosEnRepositorio() async {
    throw UnimplementedError('Use procesarSurtido en su lugar');
  }


  @override
  void onInit() {
    _updateDateController();
    _cargarProductosEscaneadosGuardados();
    loadPendingOrders();
  }

  @override
  void onClose() {
    clearAllControllers();
    _dateController.dispose();
    _guardarProductosEscaneados();
    super.onClose();
  }

  @override
  Future<void> agregarProductoPorQR(String idStr) async {
    await _agregarProductoEscaneado(idStr);
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
  }

  void clearAllControllers() {
    for (var controller in _textControllers.values) {
      controller.dispose();
    }
    _textControllers.clear();
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


  Future<void> _guardarProductosEscaneados() async {
    try {
      final Map<String, dynamic> productosParaGuardar = {};

      for (var entry in _productosEscaneadosPorOrden.entries) {
        final orderId = entry.key.toString();
        final productos = entry.value;

        final productosJson = productos.map((producto) => entryEntityToJson(producto)).toList();
        productosParaGuardar[orderId] = productosJson;
      }

      final jsonString = jsonEncode(productosParaGuardar);
      await PreferencesUser().savePrefs(
        type: String,
        key: storageKey,
        value: jsonString
      );

      print('💾 Productos escaneados guardados en SharedPreferences');
    } catch (e) {
      print('❌ Error al guardar productos escaneados: $e');
    }
  }

  Future<void> _cargarProductosEscaneadosGuardados() async {
    try {
      final jsonString = await PreferencesUser().loadPrefs(
        type: String,
        key: storageKey
      );

      if (jsonString != null && jsonString.isNotEmpty) {
        final Map<String, dynamic> productosGuardados = jsonDecode(jsonString);

        _piezasPorPalletOriginales.clear();

        for (var entry in productosGuardados.entries) {
          final orderId = int.tryParse(entry.key);
          if (orderId != null) {
            final productosJson = entry.value as List<dynamic>;
            final productos = productosJson
                .map((json) => _entryEntityFromJsonWithOriginal(json))
                .toList();

            _productosEscaneadosPorOrden[orderId] = productos;
          }
        }

        print('📂 Productos escaneados cargados desde SharedPreferences');
        print('📊 Órdenes con productos: ${_productosEscaneadosPorOrden.keys.length}');
      }
    } catch (e) {
      print('❌ Error al cargar productos escaneados: $e');
    }
  }

  EntryEntity _entryEntityFromJsonWithOriginal(Map<String, dynamic> json) {
    final entryEntity = entryEntityFromJson(json)!;

    final int valorOriginal = json['piezas_por_pallet_original'] ?? 0;
    if (valorOriginal > 0) {
      _piezasPorPalletOriginales[entryEntity.id] = valorOriginal;
    }

    return entryEntity;
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
      _isLoadingOrders.value = true;
      _errorMessage.value = '';

      final dateString = formatDateForApi(_selectedDate.value);
      final orders = await getPendingOrdersUseCase.execute(date: dateString);

      _pendingOrders.value = orders;
      _filteredOrders.value = orders;

    } catch (e) {
      _errorMessage.value = cleanExceptionMessage(e);
      showErrorAlert('Error', cleanExceptionMessage(e));
      debugPrint('Error loading pending orders: $e');
    } finally {
      _isLoadingOrders.value = false;
    }
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
      print('📦 Productos escaneados: ${productosEscaneados.length}');

    } catch (e) {
      _orderDetailsError.value = cleanExceptionMessage(e);
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

  void clearError() {
    _errorMessage.value = '';
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


  Future<void> _agregarProductoEscaneado(String idStr) async {
    try {
      if (_currentOrderId.value == 0) {
        showErrorAlert('Error', 'No hay una orden seleccionada');
        return;
      }

      if (_selectedOrder.value == null) {
        showErrorAlert('Error', 'No se encontraron detalles de la orden');
        return;
      }

      int id = int.parse(idStr);
      print('🔍 Buscando producto para surtir con ID: $id');

      List<EntryEntity> productosDisponibles = await getProductoUsecase.execute(id.toString());

      if (productosDisponibles.isNotEmpty) {
        EntryEntity productoDisponible = productosDisponibles.first;

        String? errorMessage = validateProductForOperation(productoDisponible);
        if (errorMessage != null) {
          showErrorAlert('Papeleta no válida', errorMessage);
          return;
        }

        bool productoEstaEnOrden = _selectedOrder.value!.movimientos.any((movimiento) =>
          movimiento.producto.id == productoDisponible.producto?.id
        );

        if (!productoEstaEnOrden) {
          showErrorAlert('Producto no válido', 'Este producto no pertenece a la orden seleccionada');
          return;
        }

        List<EntryEntity> productosActuales = _productosEscaneadosPorOrden[_currentOrderId.value] ?? [];

        int index = productosActuales.indexWhere((p) => p.id == productoDisponible.id);
        if (index >= 0) {
          showErrorAlert('Ups', 'Producto ya escaneado en esta orden');
        } else {
          _guardarPiezasPorPalletOriginal(productoDisponible);

          productosActuales.add(productoDisponible);
          _productosEscaneadosPorOrden[_currentOrderId.value] = productosActuales;
          resetControllerForProduct(productoDisponible);

          _productosEscaneadosPorOrden.refresh();

          await _guardarProductosEscaneados();

          print('✅ Producto agregado. Total: ${productosActuales.length}');
        }
      } else {
        showErrorAlert('Ups', 'Producto no encontrado');
      }
    } catch (e) {
      print('❌ Error: $e');
      showErrorAlert('Ups', 'No se pudo procesar el producto');
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

    print('🗑️ Producto removido. Quedan: ${productosActuales.length}');
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

    print('🧹 Productos limpiados para orden ${_currentOrderId.value}');
  }

  void limpiarProductosEscaneadosDeOrden(int orderId) {
    _productosEscaneadosPorOrden[orderId] = <EntryEntity>[];
    _productosEscaneadosPorOrden.refresh();

    _guardarProductosEscaneados();

    print('🧹 Productos limpiados para orden $orderId');
  }

  void limpiarTodasLasOrdenes() {
    _productosEscaneadosPorOrden.clear();
    _productosEscaneadosPorOrden.refresh();
    _guardarProductosEscaneados();
    print('🧹 Todas las órdenes limpiadas');
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
        showErrorAlert('Lista vacía', 'No hay productos escaneados para surtir.');
        return;
      }

      if (_selectedOrder.value == null) {
        showErrorAlert('Error', 'No se encontraron detalles de la orden.');
        return;
      }

      for (EntryEntity producto in productosEscaneadosOrden) {
        int piezasEditadas = int.tryParse(producto.piezasPorPallet) ?? 0;

        if (piezasEditadas <= 0) {
          showErrorAlert('Valor inválido',
            'El producto ${producto.producto?.nombre ?? 'ID: ${producto.id}'} tiene un valor inválido: $piezasEditadas');
          return;
        }

        if (piezasEditadas > producto.sugerencias.sugerencia_surtir) {
          final int piezasPorPalletOriginal = getPiezasPorPalletOriginal(producto.id);
          final int totalPiezasPorPalletSurtidas = producto.summarystorage.surtimientos;

          showErrorAlert(
            'Cantidad excesiva',
            'No puedes surtir $piezasEditadas piezas.\n\n'
            'Total del pallet: $piezasPorPalletOriginal\n'
            'Ya surtidas: $totalPiezasPorPalletSurtidas\n'
            'Máximo permitido: ${producto.sugerencias.sugerencia_surtir}'
          );
          return;
        }
      }

      List<SurtirEntity> surtirList = productosEscaneadosOrden.map((producto) {
        int piezasEditadas = int.tryParse(producto.piezasPorPallet) ?? 0;
        return SurtirEntity(
          id: producto.id,
          piezas_por_pallet: piezasEditadas,
          id_producto: producto.idProducto,
        );
      }).toList();

      await surtirProductosUsecase.execute(surtirList, order.id.toString());
      showSuccessAlert('¡Éxito!', 'Surtido procesado correctamente');

      limpiarProductosEscaneadosDeOrden(order.id);
      await loadOrderDetails(order.id);
      await loadPendingOrders();

      notificarActualizacionLabels();
      Get.toNamed(RoutesNames.homePage, arguments: 2);
    } catch (e) {
      print('❌ Error al procesar surtido: $e');
      showErrorAlert('Error al procesar surtido', cleanExceptionMessage(e));
    } finally {
      _isProcessingSurtido.value = false;
    }
  }


  void actualizarPiezasPorPallet(EntryEntity producto, String nuevasPiezas) {
    try {
      if (_currentOrderId.value == 0) return;

      final int piezasEditadas = int.tryParse(nuevasPiezas) ?? 0;

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

        print('✅ Piezas actualizadas para ID ${producto.id}: $piezasEditadas');
      }
    } catch (e) {
      print('❌ Error al actualizar: $e');
      showErrorAlert('Error', 'No se pudo actualizar el valor');
    }
  }


  int getPiezasPorPalletOriginal(int productoId) {
    return _piezasPorPalletOriginales[productoId] ?? 0;
  }

  void _guardarPiezasPorPalletOriginal(EntryEntity producto) {
    if (!_piezasPorPalletOriginales.containsKey(producto.id)) {
      final int valorOriginal = int.tryParse(producto.piezasPorPallet) ?? 0;
      _piezasPorPalletOriginales[producto.id] = valorOriginal;
      print('💾 Guardado valor original para ${producto.id}: $valorOriginal');
    }
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

  int getTotalCantidadMovimientos() {
    if (_selectedOrder.value == null) return 0;
    return _selectedOrder.value!.movimientos.fold(0, (sum, movimiento) => sum + movimiento.cantidad);
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
}