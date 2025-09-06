import 'package:altera/common/settings/routes_names.dart';
import 'package:altera/common/theme/Theme_colors.dart';
import 'package:altera/common/widgets/labels_loading.dart';
import 'package:altera/features/product/presentacion/page/surtir/pending_orders_controller.dart';
import 'package:altera/common/widgets/qr_scanner_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:altera/features/product/domain/entities/orders/pending_orders_entity.dart' hide ClienteEntity;
import 'package:altera/features/product/domain/entities/orders/orders_entity.dart';
import 'package:altera/features/product/domain/entities/getEntryEntity/get_entry_entity.dart';
import 'dart:ui';

class PendingOrdersScreen extends StatelessWidget {

  final PendingOrdersController controller = Get.find<PendingOrdersController>();
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AdminColors.backgroundColor,
     
      body: Column(
        children: [
          _buildSearchBar(controller),
          Expanded(
            child: Obx(() {
              if (controller.isLoading) {
                return LabelsLoading();
              }
              
              if (controller.errorMessage.isNotEmpty) {
                return _buildErrorWidget(controller);
              }
              
              if (controller.filteredOrders.isEmpty) {
                return _buildEmptyWidget();
              }
              
              return _buildOrdersList(controller);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(PendingOrdersController controller) {
    return Container(
      padding: const EdgeInsets.all(AdminColors.paddingMedium),
      color: AdminColors.surfaceColor,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.dateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Fecha de consulta',
                    hintText: 'Selecciona una fecha',
                    prefixIcon: Icon(
                      Icons.calendar_today,
                      color: AdminColors.primaryColor,
                    ),
                    
                    filled: true,
                    fillColor: AdminColors.backgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: AdminColors.smallBorderRadius,
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AdminColors.paddingMedium,
                      vertical: AdminColors.paddingSmall,
                    ),
                  ),
                  onTap: () => controller.selectDate(Get.context!),
                ),
              ),
              const SizedBox(width: AdminColors.paddingSmall),
              Container(
                decoration: BoxDecoration(
                  color: AdminColors.primaryColor,
                  borderRadius: AdminColors.smallBorderRadius,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                  onPressed: controller.loadPendingOrders,
                  tooltip: 'Buscar órdenes',
                ),
              ),
            ],
          ),
          const SizedBox(height: AdminColors.paddingMedium),
          TextField(
            onChanged: controller.searchOrders,
            decoration: InputDecoration(
              hintText: 'Buscar por serie, folio, cliente...',
              prefixIcon: Icon(
                Icons.search,
                color: AdminColors.textSecondaryColor,
              ),
              suffixIcon: Obx(() {
                if (controller.searchQuery.isNotEmpty) {
                  return IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: controller.clearSearch,
                  );
                }
                return const SizedBox.shrink();
              }),
              filled: true,
              fillColor: AdminColors.backgroundColor,
              border: OutlineInputBorder(
                borderRadius: AdminColors.smallBorderRadius,
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AdminColors.paddingMedium,
                vertical: AdminColors.paddingSmall,
              ),
            ),
          ),
          const SizedBox(height: AdminColors.paddingSmall),
          
        ],
      ),
    );
  }



  Widget _buildErrorWidget(PendingOrdersController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AdminColors.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AdminColors.errorColor,
            ),
            const SizedBox(height: AdminColors.paddingMedium),
            Text(
              'Error al cargar datos',
              style: AdminColors.headingSmall,
            ),
            const SizedBox(height: AdminColors.paddingSmall),
            Text(
              controller.errorMessage,
              style: AdminColors.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AdminColors.paddingLarge),
            AdminColors.createPrimaryButton(
              text: 'Reintentar',
              onPressed: () {
                controller.clearError();
                controller.loadPendingOrders();
              },
              isFullWidth: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: AdminColors.textSecondaryColor,
          ),
          const SizedBox(height: AdminColors.paddingMedium),
          Text(
            'No hay órdenes pendientes',
            style: AdminColors.headingSmall,
          ),
          const SizedBox(height: AdminColors.paddingSmall),
          Text(
            'No se encontraron órdenes que coincidan con tu búsqueda',
            style: AdminColors.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(PendingOrdersController controller) {
    return RefreshIndicator(
      onRefresh: controller.refreshOrders,
      color: AdminColors.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(AdminColors.paddingMedium),
        itemCount: controller.filteredOrders.length,
        itemBuilder: (context, index) {
          final order = controller.filteredOrders[index];
          return _buildOrderCard(order, controller);
        },
      ),
    );
  }

  Widget _buildOrderCard(PendingOrdersEntity order, PendingOrdersController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: AdminColors.paddingMedium),
      decoration: AdminColors.cardDecoration,
      child: InkWell(
        onTap: () =>  Get.toNamed(RoutesNames.orderDetails, arguments: order),
        borderRadius: AdminColors.mediumBorderRadius,
        child: Padding(
          padding: const EdgeInsets.all(AdminColors.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Serie: ${order.serie} - Folio: ${order.folio}',
                          style: AdminColors.headingSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Fecha: ${controller.formatDate(order.fecha)}',
                          style: AdminColors.subtitleMedium,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AdminColors.paddingSmall,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: controller.getPendingColor(order.pendientes).withOpacity(0.1),
                      borderRadius: AdminColors.smallBorderRadius,
                      border: Border.all(
                        color: controller.getPendingColor(order.pendientes),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.pending_actions,
                          size: 16,
                          color: controller.getPendingColor(order.pendientes),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          order.pendientes,
                          style: TextStyle(
                            color: controller.getPendingColor(order.pendientes),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AdminColors.paddingSmall),
              Container(
                padding: const EdgeInsets.all(AdminColors.paddingSmall),
                decoration: BoxDecoration(
                  color: AdminColors.backgroundColor,
                  borderRadius: AdminColors.smallBorderRadius,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 20,
                      color: AdminColors.primaryColor,
                    ),
                    const SizedBox(width: AdminColors.paddingSmall),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.clienteEntity.cliente,
                            style: AdminColors.bodyLarge,
                          ),
                          Text(
                            'Código: ${order.clienteEntity.codigo}',
                            style: AdminColors.bodySmall,
                          ),
                           Text(
                            '${order.concepto}',
                            style: AdminColors.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOrderDetails(PendingOrdersEntity order) {
    controller.loadOrderDetails(order.id);
    
    Get.bottomSheet(
      Obx(() => Stack(
        children: [
          Container(
            height: Get.height * 0.8,
            padding: const EdgeInsets.all(AdminColors.paddingLarge),
            decoration: BoxDecoration(
              color: AdminColors.surfaceColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AdminColors.largeRadius),
                topRight: Radius.circular(AdminColors.largeRadius),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AdminColors.textSecondaryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AdminColors.paddingMedium),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Detalles de la Orden',
                      style: AdminColors.headingMedium,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        controller.iniciarEscaneoQR();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AdminColors.colorAccionButtons,
                        foregroundColor: AdminColors.cardColor,
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.qr_code_scanner, size: 20),
                          
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AdminColors.paddingMedium),
                
                
                Expanded(
                  child: Obx(() {
                    if (controller.isLoadingOrderDetails) {
                      return _buildOrderDetailsLoading();
                    }
                    
                    if (controller.orderDetailsError.isNotEmpty) {
                      return _buildOrderDetailsError(controller);
                    }
                    
                    if (controller.selectedOrder != null) {
                      return _buildOrderDetailsContent(controller.selectedOrder!, controller, order);
                    }
                    
                    return const Center(child: Text('No hay detalles disponibles'));
                  }),
                ),
                
                const SizedBox(height: AdminColors.paddingMedium),
                
              ],
            ),
          ),
          
          if (controller.isScanning)
            _buildScannerOverlay(),
        ],
      )),
      isScrollControlled: true,
    );
  }

  
  Widget _buildScannerOverlay() {
    return Positioned.fill(
      child: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  controller.detenerEscaneoQR();
                },
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              ),
            ),
            
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {},
                child: QRScannerWidget(
  controller: Get.find<PendingOrdersController>(),
  title: 'ESCANEAR PARA SURTIR',
  description: 'Escanea el código QR del producto para surtir',
)
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetailsLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AdminColors.primaryColor,
          ),
          const SizedBox(height: AdminColors.paddingMedium),
          Text(
            'Cargando detalles...',
            style: AdminColors.subtitleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetailsError(PendingOrdersController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: AdminColors.errorColor,
          ),
          const SizedBox(height: AdminColors.paddingMedium),
          Text(
            'Error al cargar detalles',
            style: AdminColors.headingSmall,
          ),
          const SizedBox(height: AdminColors.paddingSmall),
          Text(
            controller.orderDetailsError,
            style: AdminColors.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AdminColors.paddingLarge),
          TextButton(
            onPressed: () => controller.loadOrderDetails(controller.selectedOrder?.id ?? 0),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetailsContent(OrdersEntity order, PendingOrdersController controller, PendingOrdersEntity pendingOrder) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
             if (controller.productosEscaneados.isNotEmpty) ...[
            _buildProductosEscaneadosList(controller),
            const SizedBox(height: AdminColors.paddingLarge),
          ],
          
          _buildClientInfo(order.cliente),
          
          const SizedBox(height: AdminColors.paddingLarge),
          
       
          _buildMovimientosList(order.movimientos, controller),
        ],
      ),
    );
  }

  Widget _buildProductosEscaneadosList(PendingOrdersController controller) {
    return Container(
      padding: const EdgeInsets.all(AdminColors.paddingMedium),
      decoration: AdminColors.cardDecoration.copyWith(
        color: AdminColors.colorAccionButtons.withOpacity(0.05),
        border: Border.all(
          color: AdminColors.colorAccionButtons.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Productos Escaneados (${controller.productosEscaneados.length})',
            style: AdminColors.headingSmall.copyWith(
              color: AdminColors.colorAccionButtons,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientInfo(ClienteEntity cliente) {
    return Container(
      padding: const EdgeInsets.all(AdminColors.paddingMedium),
      decoration: AdminColors.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información del Cliente',
            style: AdminColors.headingSmall,
          ),
          const SizedBox(height: AdminColors.paddingSmall),
          _buildDetailRow('Nombre:', cliente.cliente),
          _buildDetailRow('Código:', cliente.codigo),
        ],
      ),
    );
  }

  Widget _buildMovimientosList(List<MovimientoEntity> movimientos, PendingOrdersController controller) {
    return Container(
      padding: const EdgeInsets.all(AdminColors.paddingMedium),
      decoration: AdminColors.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Productos (${movimientos.length})',
                style: AdminColors.headingSmall,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AdminColors.paddingSmall,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AdminColors.primaryColor.withOpacity(0.1),
                  borderRadius: AdminColors.smallBorderRadius,
                ),
                child: Text(
                  'Total: ${controller.formatPrice(movimientos.fold(0.0, (sum, mov) => sum + mov.total))}',
                  style: TextStyle(
                    color: AdminColors.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AdminColors.paddingMedium),
          
          ...movimientos.map((movimiento) => _buildMovimientoCard(movimiento, controller)).toList(),
        ],
      ),
    );
  }

  Widget _buildMovimientoCard(MovimientoEntity movimiento, PendingOrdersController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: AdminColors.paddingSmall),
      padding: const EdgeInsets.all(AdminColors.paddingMedium),
      decoration: BoxDecoration(
        color: AdminColors.backgroundColor,
        borderRadius: AdminColors.smallBorderRadius,
        border: Border.all(
          color: AdminColors.backgroundColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movimiento.producto.nombre,
                      style: AdminColors.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Código: ${movimiento.producto.codigo}',
                      style: AdminColors.bodySmall,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AdminColors.paddingSmall,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: movimiento.pendientes > 0 
                      ? Colors.orange.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
                  borderRadius: AdminColors.smallBorderRadius,
                  border: Border.all(
                    color: movimiento.pendientes > 0 
                        ? Colors.orange
                        : Colors.green,
                    width: 1,
                  ),
                ),
                child: Text(
                  '${movimiento.pendientes} pendientes',
                  style: TextStyle(
                    color: movimiento.pendientes > 0 
                        ? Colors.orange
                        : Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AdminColors.paddingSmall),
          
          Row(
            children: [
              Expanded(
                child: _buildMovimientoDetail('Cantidad', '${movimiento.cantidad} ${movimiento.unidad.abreviatura}'),
              ),
              Expanded(
                child: _buildMovimientoDetail('Precio', controller.formatPrice(movimiento.precio)),
              ),
            ],
          ),
          
          const SizedBox(height: AdminColors.paddingSmall),
          
          Row(
            children: [
              Expanded(
                child: _buildMovimientoDetail('Unidad', movimiento.unidad.nombre),
              ),
              Expanded(
                child: _buildMovimientoDetail('Total', controller.formatPrice(movimiento.total)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMovimientoDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AdminColors.bodySmall.copyWith(
            color: AdminColors.textSecondaryColor,
          ),
        ),
        Text(
          value,
          style: AdminColors.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AdminColors.subtitleMedium,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AdminColors.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}