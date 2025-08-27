import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:altera/common/theme/Theme_colors.dart';
import 'package:altera/features/product/presentacion/page/productos/producto_controller.dart';
import 'package:altera/features/product/presentacion/page/surtir/pending_orders_controller.dart';
import 'package:altera/features/product/presentacion/page/exit/exit_controller.dart';  // Importar ExitController
import 'package:get/get.dart';

// Mixin común para los controladores que usan QR Scanner
mixin QRScannerMixin {
  Rx<MobileScannerController?> get qrScannerController;
  RxBool get isTorchOn;
  void onQRCodeDetected(String qrData);
  void detenerEscaneoQR();
  void iniciarEscaneoQR();
  void toggleTorch();
  void switchCamera();
}

class QRScannerWidget extends StatelessWidget {
  final dynamic controller;
  final String? title;
  final String? description;

  QRScannerWidget({
    this.controller,
    this.title,
    this.description,
  });

  dynamic get _controller {
    if (controller != null) return controller;
    
    // Intentar encontrar controladores en orden de prioridad
    try {
      return Get.find<ProductosController>();
    } catch (e) {
      try {
        return Get.find<ExitController>(); // Agregar búsqueda de ExitController
      } catch (e) {
        try {
          return Get.find<PendingOrdersController>();
        } catch (e) {
          throw Exception('No se encontró un controlador compatible');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scannerController = _controller;
    
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminColors.surfaceColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Mango para arrastrar
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: AdminColors.textSecondaryColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          SizedBox(height: 20),
          
          // Título y descripción dinámicos
          Text(
            _getTitle(scannerController, title),
            style: TextStyle(
              color: AdminColors.colorAccionButtons,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              letterSpacing: 1.5,
              fontFamily: 'Roboto',
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),
          Text(
            _getDescription(scannerController, description),
            style: TextStyle(
              color: AdminColors.textSecondaryColor,
              fontSize: 14,
              fontFamily: 'Roboto',
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          
          // Escáner QR
          Container(
            height: 300,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Scanner de fondo
                  Obx(() {
                    final scannerCtrl = _getQRScannerController(scannerController);
                    if (scannerCtrl == null || scannerCtrl.value == null) {
                      return Container(
                        color: Colors.black,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AdminColors.colorAccionButtons,
                          ),
                        ),
                      );
                    }
                    
                    return MobileScanner(
                      controller: scannerCtrl.value!,
                      onDetect: (capture) {
                        final List<Barcode> barcodes = capture.barcodes;
                        if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                          final qrData = barcodes.first.rawValue!;
                          scannerController.onQRCodeDetected(qrData);
                        }
                      },
                      errorBuilder: (context, error, child) {
                        return Container(
                          color: Colors.black,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.error,
                                  color: Colors.white,
                                  size: 64,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Error de cámara: ${error.errorCode}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    // Recrear el controller
                                    scannerController.detenerEscaneoQR();
                                    scannerController.iniciarEscaneoQR();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AdminColors.colorAccionButtons,
                                  ),
                                  child: Text('Reiniciar cámara'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }),
                  
                  // Overlay con marco de escaneo - color dinámico según tipo
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: _getFrameColor(scannerController), width: 2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  
                  // Marco de escaneo
                  Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  
                  // Línea de escaneo animada con color dinámico
                  ScannerAnimation(
                    width: 180,
                    color: _getScanLineColor(scannerController),
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 20),
          
          // Texto de instrucción adicional
          Text(
            'Coloca el código QR dentro del marco y mantén estable el dispositivo',
            style: TextStyle(
              color: AdminColors.textSecondaryColor,
              fontStyle: FontStyle.italic,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: 20),
          
          // Controles de cámara
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Botón para encender/apagar la linterna
              Expanded(
                child: Obx(() => ElevatedButton.icon(
                  onPressed: scannerController.toggleTorch,
                  icon: Icon(
                    _getTorchState(scannerController) ? Icons.flashlight_off : Icons.flashlight_on,
                    color: Colors.white,
                  ),
                  label: Text(_getTorchState(scannerController) ? 'Apagar' : 'Linterna'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getButtonColor(scannerController),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                )),
              ),
              
              const SizedBox(width: 12),
              
              // Botón para cambiar de cámara
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: scannerController.switchCamera,
                  icon: Icon(Icons.cameraswitch, color: Colors.white),
                  label: Text('Cambiar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getButtonColor(scannerController),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16),
          
          // Botón para cancelar el escaneo
          TextButton(
            onPressed: () {
              scannerController.detenerEscaneoQR();
            },
            child: Text(
              'CANCELAR ESCANEO',
              style: TextStyle(
                color: AdminColors.colorAccionButtons,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Método para obtener el título según el tipo de controller
  String _getTitle(dynamic controller, String? customTitle) {
    if (customTitle != null) return customTitle;
    
    if (controller is ExitController) {
      return 'ESCANEAR PARA SALIDA';
    } else if (controller is ProductosController) {
      return 'ESCANEAR PARA ENTRADA';
    } else if (controller is PendingOrdersController) {
      return 'ESCANEAR PEDIDO';
    }
    
    return 'ESCANEAR QR DE PRODUCTO';
  }

  // Método para obtener la descripción según el tipo de controller
  String _getDescription(dynamic controller, String? customDescription) {
    if (customDescription != null) return customDescription;
    
    if (controller is ExitController) {
      return 'Escanea el código QR para procesar la salida del producto';
    } else if (controller is ProductosController) {
      return 'Escanea el código QR para agregar el producto a entrada';
    } else if (controller is PendingOrdersController) {
      return 'Escanea el código QR del pedido';
    }
    
    return 'Escanea el código QR del producto';
  }

  // Método para obtener el color del marco según el tipo
  Color _getFrameColor(dynamic controller) {
   
    return AdminColors.primaryColor; // Color por defecto para entrada
  }

  // Método para obtener el color de la línea de escaneo
  Color _getScanLineColor(dynamic controller) {
   
    return AdminColors.colorAccionButtons; // Color por defecto
  }

  // Método para obtener el color de los botones
  Color _getButtonColor(dynamic controller) {
  
    return AdminColors.primaryColor; // Color por defecto
  }

  // Método auxiliar para obtener el estado de la linterna de forma segura
  bool _getTorchState(dynamic controller) {
    try {
      final torchValue = controller.isTorchOn;
      if (torchValue is RxBool) {
        return torchValue.value;
      } else if (torchValue is bool) {
        return torchValue;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Método auxiliar para obtener el scanner controller de forma segura
  Rx<MobileScannerController?>? _getQRScannerController(dynamic controller) {
    try {
      return controller.qrScannerController;
    } catch (e) {
      return null;
    }
  }
}

// Clase para animar la línea de escaneo
class ScannerAnimation extends StatefulWidget {
  final double width;
  final Color color;

  ScannerAnimation({required this.width, required this.color});

  @override
  _ScannerAnimationState createState() => _ScannerAnimationState();
}

class _ScannerAnimationState extends State<ScannerAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: -100, end: 100).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Positioned(
          top: 150 + _animation.value,
          child: Container(
            height: 2,
            width: widget.width,
            decoration: BoxDecoration(
              color: widget.color,
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.7),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}