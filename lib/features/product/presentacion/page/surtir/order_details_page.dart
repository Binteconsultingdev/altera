import 'package:altera/common/theme/Theme_colors.dart';
import 'package:altera/common/widgets/custom_alert_type.dart';
import 'package:altera/common/widgets/labels_loading.dart';
import 'package:altera/features/product/presentacion/page/surtir/order_details_loading.dart';
import 'package:altera/features/product/presentacion/page/surtir/pending_orders_controller.dart';
import 'package:altera/common/widgets/qr_scanner_widget.dart';
import 'package:altera/features/user/presentacion/page/perfil/perfil_controller.dart';
import 'package:altera/features/user/presentacion/page/perfil/perfil_loading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:altera/features/product/domain/entities/orders/pending_orders_entity.dart' hide ClienteEntity;
import 'package:altera/features/product/domain/entities/orders/orders_entity.dart';
import 'package:altera/features/product/domain/entities/getEntryEntity/get_entry_entity.dart';
import 'dart:ui';

class OrderDetailsPage extends StatelessWidget {
  final PendingOrdersEntity order;
  final PendingOrdersController controller = Get.find<PendingOrdersController>();
     final PerfilController perfilController = Get.find<PerfilController>(); 

  OrderDetailsPage({Key? key, required this.order}) : super(key: key);

@override
Widget build(BuildContext context) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    controller.loadOrderDetails(order.id);
  });

  return Scaffold(
    backgroundColor: AdminColors.backgroundColor,
    appBar: AppBar(
      title: Text(
        'Orden ${order.serie}-${order.folio}',
        style: AdminColors.headingMedium,
      ),
      backgroundColor: AdminColors.accentColor,
      elevation: 0,
      iconTheme: IconThemeData(
        color: AdminColors.cardColor, 
      ),
      actions: [
  Obx(() => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ElevatedButton(
      onPressed: controller.isLoadingOrderDetails 
          ? null 
          : () {
              controller.iniciarEscaneoQR();
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: controller.isLoadingOrderDetails 
            ? AdminColors.cardColor.withOpacity(0.5) 
            : AdminColors.cardColor,
        foregroundColor: controller.isLoadingOrderDetails 
            ? AdminColors.colorAccionButtons.withOpacity(0.5) 
            : AdminColors.colorAccionButtons,
        padding: EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: controller.isLoadingOrderDetails ? 0 : 2,
      ),
      child: Icon(
        Icons.qr_code_scanner, 
        size: 20,
        color: controller.isLoadingOrderDetails 
            ? AdminColors.colorAccionButtons.withOpacity(0.3)
            : null,
      ),
    ),
  )),
  
  Obx(() => Padding(
    padding: const EdgeInsets.only(right: 16),
    child: ElevatedButton(
      onPressed: controller.isLoadingOrderDetails 
          ? null
          : () {
              controller.mostrarInputManual();
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: controller.isLoadingOrderDetails 
            ? AdminColors.cardColor.withOpacity(0.5) 
            : AdminColors.cardColor,
        foregroundColor: controller.isLoadingOrderDetails 
            ? AdminColors.colorAccionButtons.withOpacity(0.5) 
            : AdminColors.colorAccionButtons,
        padding: EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: controller.isLoadingOrderDetails ? 0 : 2,
      ),
      child: Icon(
        Icons.edit, 
        size: 20,
        color: controller.isLoadingOrderDetails 
            ? AdminColors.colorAccionButtons.withOpacity(0.3)
            : null,
      ),
    ),
  )),
],
    ),

    body: Obx(() => Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildOrderHeader(),
                    
                    _buildMainContent(),
                  ],
                ),
              ),
            ),
            
            _processAssortment(),
          ],
        ),
        
        if (controller.isScanning)
          _buildScannerOverlay(),
        if (controller.showingManualInput)
          _buildManualInputOverlay(),
      ],
    )),
  );
}
Widget _buildManualInputOverlay() {
  return Positioned.fill(
    child: SafeArea(
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                controller.cerrarInputManual();
              },
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            ),
          ),
          
          Center(
            child: GestureDetector(
              onTap: () {}, 
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 30),
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AdminColors.surfaceColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AdminColors.surfaceColor.withOpacity(0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.edit,
                          color: AdminColors.colorAccionButtons,
                          size: 28,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Escanear por ID",
                            style: TextStyle(
                              color: AdminColors.textPrimaryColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            controller.cerrarInputManual();
                          },
                          icon: Icon(
                            Icons.close,
                            color: AdminColors.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 20),
                    
                    Text(
                      "Ingresa el ID del producto que deseas surtir para la orden ${order.serie}-${order.folio}",
                      style: TextStyle(
                        color: AdminColors.textSecondaryColor,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    SizedBox(height: 24),
                    
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AdminColors.colorAccionButtons.withOpacity(0.3),
                        ),
                      ),
                      child: TextField(
                        controller: controller.manualIdController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          color: AdminColors.textPrimaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: "Ej: 12345",
                          hintStyle: TextStyle(
                            color: AdminColors.textSecondaryColor,
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                       onChanged: (value) {
                            if (value.trim().length >= 1 && RegExp(r'^\d+$').hasMatch(value.trim())) {
                              Future.delayed(Duration(milliseconds: 500), () {
                                if (controller.manualIdController.text.trim() == value.trim() && 
                                    !controller.isProcessingManualId) {
                                  controller.procesarIdManual();
                                }
                              });
                            }
                          },
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              controller.procesarIdManual();
                            }
                          },
                      ),
                    ),
                    
                    SizedBox(height: 24),
                    
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              controller.cerrarInputManual();
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              "CANCELAR",
                              style: TextStyle(
                                color: AdminColors.textSecondaryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        
                        SizedBox(width: 12),
                        
                        Expanded(
                          flex: 2,
                          child: Obx(() => ElevatedButton(
                            onPressed: controller.isProcessingManualId
                                ? null
                                : () {
                                    controller.procesarIdManual();
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AdminColors.colorAccionButtons,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: controller.isProcessingManualId
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Text("AGREGANDO..."),
                                    ],
                                  )
                                : Text(
                                    "AGREGAR",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                          )),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
Widget _buildOrderHeader() {
  return Container(
    padding: const EdgeInsets.all(AdminColors.paddingMedium),
    decoration: BoxDecoration(
      color: AdminColors.surfaceColor,
      boxShadow: [AdminColors.lightShadow],
    ),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Serie: ${order.serie} - Folio: ${order.folio}',
                    style: AdminColors.headingSmall,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Fecha: ${controller.formatDate(order.fecha)}',
                    style: AdminColors.subtitleMedium,
                  ),
                  SizedBox(height: 4),
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
                    '${order.pendientes} pendientes',
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
        
        SizedBox(height: 12),
        
        Obx(() {
          if (controller.selectedOrder != null && controller.selectedOrder!.cliente != null) {
            return Container(
              padding: const EdgeInsets.all(AdminColors.paddingMedium),
              margin: const EdgeInsets.only(bottom: 12),
          
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        color: AdminColors.primaryColor,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Información del Cliente',
                        style: AdminColors.headingSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: AdminColors.paddingSmall),
                  _buildDetailRow('Nombre:', controller.selectedOrder!.cliente.cliente),
                  _buildDetailRow('Código:', controller.selectedOrder!.cliente.codigo),
                ],
              ),
            );
          }
          return Container(
            padding: const EdgeInsets.all(AdminColors.paddingMedium),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: AdminColors.cardDecoration,
            child: Row(
              children: [
                Icon(
                  Icons.person,
                  color: AdminColors.primaryColor.withOpacity(0.5),
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'Cargando información del cliente...',
                  style: AdminColors.bodyMedium.copyWith(
                    color: AdminColors.textSecondaryColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          );
        }),
        
        Obx(() => Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AdminColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AdminColors.primaryColor.withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildTotalCard(
                      'Total Orden',
                      controller.formatearNumero(controller.getTotalCantidadMovimientos()),
                      'piezas',
                      Icons.inventory_2,
                      AdminColors.primaryColor,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildTotalCard(
                      'Escaneado',
                      controller.formatearNumero(controller.getTotalPiezasPorPalletEscaneados()),
                      'piezas',
                      Icons.inventory,
                      AdminColors.colorAccionButtons,
                    ),
                  ),
                ],
              ),
            ],
          ),
        )),
        
        
      ],
    ),
  );
}

Widget _buildTotalCard(String titulo, String valor, String unidad, IconData icono, Color color) {
  return Container(
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: color.withOpacity(0.3),
      ),
    ),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icono,
              color: color,
              size: 16,
            ),
            SizedBox(width: 6),
            Text(
              titulo,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          valor,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(
          unidad,
          style: TextStyle(
            color: color.withOpacity(0.8),
            fontSize: 10,
          ),
        ),
      ],
    ),
  );
}

  Widget _buildMainContent() {
  return Obx(() {
    if (controller.isLoadingOrderDetails) {
      return OrderDetailsLoading();
    }
    
    if (controller.orderDetailsError.isNotEmpty) {
      return _buildOrderDetailsError();
    }
    
    if (controller.selectedOrder != null) {
      return _buildOrderDetailsContent();
    }
    
    return Container(
      padding: EdgeInsets.all(AdminColors.paddingMedium),
      child: Center(child: Text('No hay detalles disponibles')),
    );
  });
}


Widget _buildOrderDetailsContent() {
  return Padding(
    padding: EdgeInsets.all(AdminColors.paddingMedium),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (controller.productosEscaneados.isNotEmpty) ...[
          _buildProductosEscaneadosList(),
          const SizedBox(height: AdminColors.paddingLarge),
        ],
        
        
        const SizedBox(height: AdminColors.paddingLarge),
        
        _buildMovimientosList(controller.selectedOrder!.movimientos),
      ],
    ),
  );
}

  Widget _buildProductosEscaneadosList() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: 

              Text(
                'Productos Escaneados (${controller.productosEscaneados.length})',
                style: AdminColors.headingSmall.copyWith(
                  color: AdminColors.colorAccionButtons,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ),
              TextButton.icon(
                onPressed: () {
                  _showProductosEscaneadosModal();
                },
                icon: Icon(
                  Icons.visibility,
                  color: AdminColors.colorAccionButtons,
                  size: 16,
                ),
                label: Text(
                  'VER PRODUCTOS',
                  style: TextStyle(
                    color: AdminColors.colorAccionButtons,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Productos listos para surtir. Toca "VER PRODUCTOS" para ver el detalle.',
            style: AdminColors.bodySmall.copyWith(
              color: AdminColors.textSecondaryColor,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  void _showProductosEscaneadosModal() {
  Get.bottomSheet(
    Obx(() => Container(
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
              Flexible(
                child: Text(
                'Productos Escaneados (${controller.productosEscaneados.length})',
                  style: TextStyle(
                    color: AdminColors.textSecondaryColor,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1, 
                  softWrap: false,
                ),
              ),

        
              if (controller.productosEscaneados.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _showConfirmClearAllDialog();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AdminColors.errorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AdminColors.errorColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.clear_all,
                          size: 16,
                          color: AdminColors.errorColor,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Limpiar todo',
                          style: TextStyle(
                            color: AdminColors.errorColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: AdminColors.paddingMedium),
          
          if (controller.productosEscaneados.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.qr_code_scanner,
                      size: 64,
                      color: AdminColors.textSecondaryColor.withOpacity(0.5),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No hay productos escaneados',
                      style: TextStyle(
                        color: AdminColors.textSecondaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Escanea códigos QR para agregar productos',
                      style: TextStyle(
                        color: AdminColors.textSecondaryColor.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: controller.productosEscaneados.length,
                itemBuilder: (context, index) {
                  final producto = controller.productosEscaneados[index];
                  return _buildProductoEscaneadoItem(producto, index);
                },
              ),
            ),
          
          if (controller.productosEscaneados.isNotEmpty)
            Container(
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: AdminColors.colorAccionButtons.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AdminColors.colorAccionButtons.withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Resumen de Escaneo',
                    style: TextStyle(
                      color: AdminColors.colorAccionButtons,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildResumenItem(
                        'Productos',
                        '${controller.productosEscaneados.length}',
                        Icons.inventory_2,
                      ),
                      _buildResumenItem(
                        'Total Piezas',
                        '${controller.getTotalPiezasPorPalletEscaneados()}',
                        Icons.apps,
                      ),
                    ],
                  ),
                ],
              ),
            ),_buildFooter()
        ],
      ),
    )),
    isScrollControlled: true,
  );
}

void showDeleteConfirmation(EntryEntity producto) {
    showCustomAlert(
      context: Get.context!,
      title: "Confirmar eliminación",
      message: "¿Está seguro de desechar esta papeleta? No podrá volver a escanearla",
      confirmText: "ELIMINAR",
      cancelText: "CANCELAR",
      type: CustomAlertType.error, 
      onConfirm: () {
        Get.back();
        controller.eliminarPapeleta(producto);
      },
      onCancel: () {
        Get.back();
      },
    );
  }

  
Widget _buildProductoEscaneadoItem(EntryEntity producto, int index) {
  
  final TextEditingController piezasController = controller.getControllerForProduct(producto);
   final int piezasPorPalletOriginal = controller.getPiezasPorPalletOriginal(producto.id);
  
  if (piezasController.text.isEmpty || piezasController.text == "0") {
    piezasController.text =producto.sugerencias.sugerencia_surtir.toString();
    piezasController.selection = TextSelection.fromPosition(
      TextPosition(offset: piezasController.text.length)
    );
  }
  
  
  return Container(
    margin: EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.06),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: Colors.white.withOpacity(0.1),
      ),
    ),
    child: Column(
      children: [
        Row(
          children: [
            Container(
              width: 80,
              height: 120,
              decoration: BoxDecoration(
                color: AdminColors.colorAccionButtons.withOpacity(0.2),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.qr_code_2,
                      size: 30,
                      color: AdminColors.colorAccionButtons,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'ID: ${producto.id}',
                      style: TextStyle(
                        color: AdminColors.colorAccionButtons,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '#${index + 1}',
                      style: TextStyle(
                        color: AdminColors.colorAccionButtons.withOpacity(0.7),
                        fontSize: 7,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${producto.producto?.nombre ?? 'N/A'}",
                      style: TextStyle(
                        color: AdminColors.textPrimaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    SizedBox(height: 4),
                    
                    Text(
                      "Código: ${producto.producto?.codigo ?? 'N/A'}",
                      style: TextStyle(
                        color: AdminColors.textSecondaryColor,
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    SizedBox(height: 4),
                    
                    Text(
                      "Calibre: ${producto.calibre}",
                      style: TextStyle(
                        color: AdminColors.colorAccionButtons,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    
                    Row(
                      children: [
                        Text(
                          "Piezas/Pallet: ",
                          style: TextStyle(
                            color: AdminColors.textSecondaryColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 28,
                            child: TextFormField(
                              controller: piezasController,
                              keyboardType: TextInputType.number,
                              style: TextStyle(
                                color: AdminColors.textPrimaryColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AdminColors.colorAccionButtons.withOpacity(0.1),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide(
                                    color: AdminColors.colorAccionButtons.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide(
                                    color: AdminColors.colorAccionButtons.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide(
                                    color: AdminColors.colorAccionButtons,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                isDense: true,
                                hintText: "Max:${producto.sugerencias.sugerencia_surtir}",
                                hintStyle: TextStyle(
                                  color: AdminColors.textSecondaryColor.withOpacity(0.6),
                                  fontSize: 9,
                                ),
                              ),
                              onChanged: (value) {
                                final numero = int.tryParse(value);
                                if (numero != null && numero > 0 && numero <= producto.sugerencias.sugerencia_surtir) {
                                  controller.actualizarPiezasPorPallet(producto, value);
                                }
                              },
                              onFieldSubmitted: (value) {
                                controller.actualizarPiezasPorPallet(producto, value);
                              },
                              onEditingComplete: () {
                                final value = piezasController.text;
                                controller.actualizarPiezasPorPallet(producto, value);
                              },
                              onTapOutside: (event) {
                                final value = piezasController.text;
                                controller.actualizarPiezasPorPallet(producto, value);
                                FocusScope.of(Get.context!).unfocus();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    
       SizedBox(height: 2),
        Text(
                      "Total: $piezasPorPalletOriginal | Surtidas:  ${producto.summarystorage.surtimientos} | Faltan: ${producto.sugerencias.sugerencia_surtir}",
                      style: TextStyle(
                        color: AdminColors.textSecondaryColor.withOpacity(0.8),
                        fontSize: 8,
                        fontStyle: FontStyle.italic,
                      ),
      ),
                  ],
                ),
              ),
            ),
            
            Container(
  width: 50,
  height: 120,
  child: Column(
    children: [
      if (producto.tipo?.id != 1) ...[
        Expanded(
          child: GestureDetector(
            onTap: () {
              showDeleteConfirmation(producto); 
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.3),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(16),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.delete_forever,
                      color: Colors.red[700],
                      size: 18,
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Eliminar",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.red[700],
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        Container(
          height: 1,
          color: Colors.white.withOpacity(0.1),
        ),
      ],
      
      Expanded(
        flex: producto.tipo?.id == 1 ? 2 : 1,
        child: GestureDetector(
          onTap: () {
            _showConfirmDeleteDialog(producto);
          },
          child: Container(
            decoration: BoxDecoration(
              color: AdminColors.errorColor.withOpacity(0.2),
              borderRadius: BorderRadius.only(
                topRight: producto.tipo?.id == 1 ? Radius.circular(16) : Radius.zero,
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.remove_shopping_cart,
                    color: AdminColors.errorColor,
                    size: 18,
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Quitar",
                    style: TextStyle(
                      color: AdminColors.errorColor,
                      fontSize: 8,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  ),
)
          ],
        ),
        
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AdminColors.colorAccionButtons.withOpacity(0.05),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Row(
            children: [
              _buildInfoChip("Orden: ${producto.ordenCompra}"),
              SizedBox(width: 8),
              _buildInfoChip("Máquina: ${producto.maquina}"),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AdminColors.colorAccionButtons.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "${producto.longitud} x ${producto.anchoAla}",
                  style: TextStyle(
                    color: AdminColors.colorAccionButtons,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildInfoChip(String text) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: AdminColors.textSecondaryColor.withOpacity(0.1),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      text,
      style: TextStyle(
        color: AdminColors.textSecondaryColor,
        fontSize: 8,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}

Widget _buildResumenItem(String label, String value, IconData icon) {
  return Column(
    children: [
      Icon(
        icon,
        color: AdminColors.colorAccionButtons,
        size: 20,
      ),
      SizedBox(height: 4),
      Text(
        value,
        style: TextStyle(
          color: AdminColors.colorAccionButtons,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      Text(
        label,
        style: TextStyle(
          color: AdminColors.textSecondaryColor,
          fontSize: 10,
        ),
      ),
    ],
  );
}
void _showConfirmDeleteDialog(EntryEntity producto) {
  showCustomAlert(
    context: Get.context!,
    type: CustomAlertType.warning,
    title: 'Confirmar quitar de la lista',
    message: '¿Estás seguro de que deseas quitar este producto de la lista?\n\n'
             'Producto: ${producto.producto?.nombre ?? 'N/A'}\n'
             'Código: ${producto.producto?.codigo ?? 'N/A'}\n'
             'ID: ${producto.id}',
    confirmText: 'Quitar',
    cancelText: 'Cancelar',
    onConfirm: () {
      Navigator.of(Get.context!).pop();
      controller.removerProductoEscaneado(producto);
    },
    onCancel: () {
      Navigator.of(Get.context!).pop(); 
    },
  );
}
void _showConfirmClearAllDialog() {
  showCustomAlert(
    context: Get.context!,
    type: CustomAlertType.error, 
    title: 'Limpiar todo',
    message: '¿Estás seguro de que deseas quitar TODOS los productos escaneados de esta orden?\n\n'
             'Se eliminarán ${controller.productosEscaneados.length} productos',
    confirmText: 'Limpiar todo',
    cancelText: 'Cancelar',
    onConfirm: () {
      Navigator.of(Get.context!).pop();
      controller.limpiarProductosEscaneados();
    },
    onCancel: () {
      Navigator.of(Get.context!).pop(); 
    },
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
                  controller: controller,
                  title: 'ESCANEAR PARA SURTIR',
                  description: 'Escanea el código QR del producto para surtir',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _showAdd(PendingOrdersEntity order) {
  showCustomAlert(
    context: Get.context!,
  title: "Confirmar Surtimieno - ${perfilController.almacenNombre}",
    message: "¿Deseas agregar estos productos?",
    confirmText: "AGREGAR",
    cancelText: "CANCELAR",
    type: CustomAlertType.success,
    onConfirm: () {
      Get.back();
      controller.procesarSurtido(order);
    },
    onCancel: () {
      Get.back();
    },
  );
}
  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.all(AdminColors.paddingMedium),
      decoration: BoxDecoration(
        color: AdminColors.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
     child: Obx(() {
  if (controller.productosEscaneados.isNotEmpty) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Obx(() => ElevatedButton(
            onPressed: controller.isProcessingSurtido 
                ? null 
                : () {
                  //  controller.procesarSurtido(order);
                   _showAdd(order);
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: controller.isProcessingSurtido 
                  ? AdminColors.colorAccionButtons.withOpacity(0.6)
                  : AdminColors.colorAccionButtons,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: controller.isProcessingSurtido ? 0 : 2,
            ),
            child: controller.isProcessingSurtido
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        "PROCESANDO SURTIDO...",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  )
                : Text(
                    "PROCESAR SURTIDO",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          )),
        ),
      ],
    );
  }
  return SizedBox.shrink();
}),
    );
  }
  
Widget _processAssortment() {
  return Container(
    padding: EdgeInsets.only(
      left: AdminColors.paddingMedium,
      right: AdminColors.paddingMedium,
      top: AdminColors.paddingMedium,
      bottom: AdminColors.paddingMedium + MediaQuery.of(Get.context!).padding.bottom,
    ),
    decoration: BoxDecoration(
      color: AdminColors.surfaceColor,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 4,
          offset: Offset(0, -2),
        ),
      ],
    ),
    child: Obx(() {
      if (controller.productosEscaneados.isNotEmpty) {
        return Row(
          children: [
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () {
                 _showProductosEscaneadosModal();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminColors.colorAccionButtons,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text("PROCESAR SURTIDO"),
              ),
            ),
          ],
        );
      }
      return SizedBox.shrink();
    }),
  );
}


  Widget _buildOrderDetailsError() {
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
            'Error de Conexión',
            style: AdminColors.headingSmall,
          ),
          const SizedBox(height: AdminColors.paddingSmall),
          Text(
            controller.orderDetailsError,
            style: AdminColors.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AdminColors.paddingLarge),
          ElevatedButton(
            onPressed: () => controller.loadOrderDetails(order.id),
            child: Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildMovimientosList(List<MovimientoEntity> movimientos) {
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
             
            ],
          ),
          const SizedBox(height: AdminColors.paddingMedium),
          
          ...movimientos.map((movimiento) => _buildMovimientoCard(movimiento)).toList(),
        ],
      ),
    );
  }

  Widget _buildMovimientoCard(MovimientoEntity movimiento) {
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
                    const SizedBox(height: 4),
                    
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
               child: _buildMovimientoDetail('Unidad', movimiento.unidad.nombre),
              ),
            ],
          ),
          
          const SizedBox(height: AdminColors.paddingSmall),
          
          
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