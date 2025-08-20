import 'package:altera/common/widgets/curve_painter.dart';
import 'package:altera/common/widgets/custom_alert_type.dart';
import 'package:altera/features/product/presentacion/page/productos/producto_controller.dart';
import 'package:flutter/material.dart';
import 'package:altera/common/theme/Theme_colors.dart';
import 'package:altera/features/product/presentacion/page/productos/qr_scanner_widget.dart';
import 'package:altera/features/product/domain/entities/getEntryEntity/get_entry_entity.dart';
import 'dart:ui';
import 'package:get/get.dart';

class ProductosPage extends StatelessWidget {
  final ProductosController controller = Get.find<ProductosController>();
   
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: AdminColors.backgroundGradient,
            ),
          ),
          
          Positioned.fill(
            child: CustomPaint(
              painter: CurvePainter(),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  
                  _buildHeader(),
                  
                  SizedBox(height: 20),
                  
                  Expanded(
                    child: _buildCartList(),
                  ),
                  
                  _buildCartSummary(),
                  
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
          
          // Scanner overlay
          Obx(() {
            if (controller.isScanning.value) {
              return _buildScannerOverlay();
            }
            return SizedBox.shrink();
          }),

          // *** NUEVO: Manual Input Overlay ***
          Obx(() {
            if (controller.showingManualInput.value) {
              return _buildManualInputOverlay();
            }
            return SizedBox.shrink();
          }),
          
          // Product details overlay
          Obx(() {
            if (controller.showingProductDetails.value && controller.selectedProductForDetails.value != null) {
              return _buildProductDetailsOverlay();
            }
            return SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  // *** NUEVO: Widget para input manual ***
  Widget _buildManualInputOverlay() {
    return Positioned.fill(
      child: SafeArea(
        child: Stack(
          children: [
            // Fondo oscurecido
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
            
            // Modal de input
            Center(
              child: GestureDetector(
                onTap: () {}, // Evitar cerrar al tocar el contenido
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 30),
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AdminColors.backgroundGradient,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
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
                      // Header
                      Row(
                        children: [
                          Icon(
                            Icons.edit,
                            color: AdminColors.primaryColor,
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
                      
                      // Descripción
                      Text(
                        "Ingresa el ID del producto que deseas agregar a la entrada",
                        style: TextStyle(
                          color: AdminColors.textSecondaryColor,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      SizedBox(height: 24),
                      
                      // Campo de texto
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AdminColors.primaryColor.withOpacity(0.3),
                          ),
                        ),
                        child:TextField(
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
                                      !controller.isProcessingManualId.value) {
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
                      
                      // Botones
                      Row(
                        children: [
                          // Botón cancelar
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
                          
                          // Botón agregar
                          Expanded(
                            flex: 2,
                            child: Obx(() => ElevatedButton(
                              onPressed: controller.isProcessingManualId.value
                                  ? null
                                  : () {
                                      controller.procesarIdManual();
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AdminColors.primaryColor,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: controller.isProcessingManualId.value
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

  Widget _buildProductDetailsOverlay() {
    final producto = controller.selectedProductForDetails.value!;
    
    return Positioned.fill(
      child: SafeArea(
        child: Stack(
          children: [
            // Fondo oscurecido
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  controller.cerrarDetallesProducto();
                },
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              ),
            ),
            
            // Contenedor principal del modal
            Positioned(
              top: 50,
              left: 20,
              right: 20,
              bottom: 100,
              child: GestureDetector(
                onTap: () {}, // Evitar cerrar al tocar el contenido
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AdminColors.backgroundGradient,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Header del modal
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AdminColors.textPrimaryColor,
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "Detalles del Producto",
                                style: TextStyle(
                                  color: AdminColors.textPrimaryColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                controller.cerrarDetallesProducto();
                              },
                              icon: Icon(
                                Icons.close,
                                color: AdminColors.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Contenido del modal
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Información principal
                              _buildDetailCard(
                                title: "Información Principal",
                                icon: Icons.inventory,
                                children: [
                                  _buildDetailRow("Nombre", producto.producto?.nombre ?? 'N/A'),
                                  _buildDetailRow("Código", producto.producto?.codigo ?? 'N/A'),
                                  _buildDetailRow("ID Producto", producto.idProducto.toString()),
                                  _buildDetailRow("ID Sistema", producto.id.toString()),
                                ],
                              ),
                              
                              SizedBox(height: 16),
                              
                              // Especificaciones técnicas
                              _buildDetailCard(
                                title: "Especificaciones Técnicas",
                                icon: Icons.engineering,
                                children: [
                                  _buildDetailRow("Calibre", producto.calibre),
                                  _buildDetailRow("Longitud", producto.longitud),
                                  _buildDetailRow("Puntos", producto.puntos),
                                  _buildDetailRow("Ancho Ala", producto.anchoAla),
                                ],
                              ),
                              
                              SizedBox(height: 16),
                              
                              _buildDetailCard(
                                title: "Orden de Producción",
                                icon: Icons.factory,
                                children: [
                                  _buildDetailRow("Máquina", producto.maquina.toString()),
                                  _buildDetailRow("Bultos/Cama", producto.bultosPorCama),
                                  if (producto.ordenCompra.isNotEmpty)
                                    _buildDetailRow("Orden de Compra", producto.ordenCompra),
                                ],
                              ),
                              
                              SizedBox(height: 24),
                              
                              // Botón de eliminar
                              Container(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    showDeleteConfirmation(producto);
                                  },
                                  icon: Icon(Icons.delete),
                                  label: Text("ELIMINAR PRODUCTO"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AdminColors.errorColor,
                                    foregroundColor: AdminColors.colordCard,
                                    padding: EdgeInsets.symmetric(vertical: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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

  Widget _buildDetailCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de la tarjeta
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: AdminColors.primaryColor,
                  size: 20,
                ),
                SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: AdminColors.textPrimaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          
          // Contenido de la tarjeta
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: AdminColors.textSecondaryColor,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color: AdminColors.textPrimaryColor,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

void _showDelete(EntryEntity producto) {
    showCustomAlert(
      context: Get.context!,
      title: "Confirmar quitar de la lista",
      message: "¿Estás seguro de que deseas quitar este producto de la lista?",
      confirmText: "QUITAR",
      cancelText: "CANCELAR",
      type: CustomAlertType.error, 
      onConfirm: () {
        Get.back();
        controller.productosCarrito.remove(producto);
      },
      onCancel: () {
        Get.back();
      },
    );
  }

  void _showAdd() {
  showCustomAlert(
    context: Get.context!,
    title: "Confirmar entrada",
    message: "¿Deseas agregar estos productos?",
    confirmText: "AGREGAR",
    cancelText: "CANCELAR",
    type: CustomAlertType.success,
    onConfirm: () {
      Get.back();
      controller.guardarProductosEnRepositorio();
    },
    onCancel: () {
      Get.back();
    },
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
        controller.eliminarProductoDefinitivamente(producto);
      },
      onCancel: () {
        Get.back();
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lado izquierdo - Título
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Entrada de Productos",
                    style: TextStyle(
                      color: AdminColors.textPrimaryColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 28,
                      letterSpacing: 1.5,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Gestión de inventario de entrada",
                    style: TextStyle(
                      color: AdminColors.textSecondaryColor,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            // Contador de productos
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AdminColors.primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Obx(() => Text(
                "${controller.productosCarrito.length} productos",
                style: TextStyle(
                  color: AdminColors.primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              )),
            ),
          ],
        ),
        SizedBox(height: 10),
        Container(
          height: 3,
          width: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AdminColors.primaryColor,
                AdminColors.primaryColor.withOpacity(0.3),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ],
    );
  }

  Widget _buildCartList() {
    return Obx(() {
      if (controller.productosCarrito.isEmpty) {
        return _buildEmptyCart();
      }
      
      return ListView.builder(
        key: ValueKey('cart_list_${controller.productosCarrito.length}_${DateTime.now().millisecondsSinceEpoch}'),
        physics: BouncingScrollPhysics(),
        itemCount: controller.productosCarrito.length,
        itemBuilder: (context, index) {
          final producto = controller.productosCarrito[index];
          
          return _buildProductItem(
            producto, 
            key: ValueKey('product_${producto.idProducto}_${producto.id}_$index')
          );
        },
      );
    });
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
           'assets/truck.png', // Solo asset de entrada
            width: 80,
            height: 80,
            color: AdminColors.textSecondaryColor.withOpacity(0.5),
            ),
          
          SizedBox(height: 20),
          Text(
            "No hay productos en entrada",
            style: TextStyle(
              color: AdminColors.textPrimaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Escanea QR o agrega por ID",
            style: TextStyle(
              color: AdminColors.textSecondaryColor,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 30),
          
          // *** BOTONES ACTUALIZADOS ***
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Botón escanear QR
              ElevatedButton.icon(
                onPressed: () {
                  controller.iniciarEscaneoQR();
                },
                icon: Icon(Icons.qr_code_scanner),
                label: Text("ESCANEAR"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
              
              SizedBox(width: 12),
              
             
              ElevatedButton.icon(
                onPressed: () {
                  controller.mostrarInputManual();
                },
                icon: Icon(Icons.edit),
                label: Text("POR ID"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminColors.primaryColor.withOpacity(0.8),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(EntryEntity producto, {Key? key}) {
    return Container(
      key: key,
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          // Icono de producto con indicador de entrada
          Container(
            width: 100,
            height: 120,
            decoration: BoxDecoration(
              color: AdminColors.primaryColor.withOpacity(0.2),
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
                  size: 40,
                  color: AdminColors.textSecondaryColor.withOpacity(0.5),
                  ),
                  SizedBox(height: 4),
                 
                  Text(
                    'ID: ${producto.id}',
                    style: TextStyle(
                      color: AdminColors.textSecondaryColor,
                      fontSize: 8,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Información del producto
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre y código
                 Text(
                  "${producto.producto?.nombre ?? 'N/A'}",
                              style: TextStyle(
                                color: AdminColors.textPrimaryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                 fontStyle: FontStyle.italic,
                              ),
                            ),
                  SizedBox(height: 4),
                  Text(
                    "Código: ${producto.producto?.codigo ?? 'N/A'}",
                    style: TextStyle(
                      color: AdminColors.textSecondaryColor,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  
                  SizedBox(height: 8),
                ],
              ),
            ),
          ),
          
          // Botones de acción verticales
          Container(
            width: 50,
            height: 120,
            child: Column(
              children: [
                // Botón "Ver más"
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      controller.mostrarDetallesProducto(producto);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AdminColors.primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.visibility,
                              color: AdminColors.primaryColor,
                              size: 18,
                            ),
                            SizedBox(height: 2),
                            Text(
                              "Ver\nmás",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AdminColors.primaryColor,
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
                
                // Línea divisoria
                Container(
                  height: 1,
                  color: Colors.white.withOpacity(0.1),
                ),
                
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _showDelete(producto);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AdminColors.errorColor.withOpacity(0.2),
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.delete,
                              color: AdminColors.errorColor,
                              size: 18,
                            ),
                            SizedBox(height: 2),
                            Text(
                              "QUITAR.",
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
          ),
        ],
      ),
    );
  }

  Widget _buildCartSummary() {
   return Obx(() {
    if (controller.productosCarrito.isEmpty) {
      return SizedBox.shrink();
    }
    
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [            
          SizedBox(height: 12),
          
          Divider(
            color: Colors.white.withOpacity(0.1),
            thickness: 1,
          ),
          
          SizedBox(height: 20),
          
          // Fila con botones actualizados
          Row(
            children: [
              // Botón de escanear
              Expanded(
                flex: 1,
                child: ElevatedButton(
                  onPressed: () {
                    controller.iniciarEscaneoQR();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminColors.primaryColor,
                    foregroundColor: AdminColors.cardColor,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Icon(
                    Icons.qr_code_scanner,
                    size: 24,
                  ),
                ),
              ),
              
              SizedBox(width: 8),

              // *** NUEVO: Botón de input manual ***
              Expanded(
                flex: 1,
                child: ElevatedButton(
                  onPressed: () {
                    controller.mostrarInputManual();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminColors.primaryColor,
                    foregroundColor: AdminColors.cardColor,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Icon(
                    Icons.edit,
                    size: 24,
                  ),
                ),
              ),
              
              SizedBox(width: 12),
              
              // Botón de guardar entrada
              Expanded(
                flex: 3,
                child: Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () {
                          _showAdd();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: controller.isLoading.value
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
                            Text("GUARDANDO..."),
                          ],
                        )
                      : Text(
                          "GUARDAR ENTRADA",
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
    );
  });
  }

  Widget buildScannerButton() {
    return GestureDetector(
      onTap: () {
        controller.iniciarEscaneoQR();
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AdminColors.primaryColor,
              AdminColors.primaryColor.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AdminColors.primaryColor.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.qr_code_scanner,
          color: AdminColors.cardColor,
          size: 30,
        ),
      ),
    );
  }

  Widget _buildScannerOverlay() {
    return Positioned.fill(
      child: SafeArea(
        child: Stack(
          children: [
            // Fondo oscurecido
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
            
            // Widget del escáner
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {},
                child: QRScannerWidget(
                  controller: Get.find<ProductosController>(),
                  title: 'ESCANEAR PARA ENTRADA',
                  description: 'Escanea el código QR para agregar a entrada',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}