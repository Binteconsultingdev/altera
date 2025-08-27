import 'package:altera/common/theme/Theme_colors.dart';
import 'package:altera/features/product/presentacion/page/getproducto/entry_controller.dart';
import 'package:altera/common/widgets/labels_loading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:altera/features/product/domain/entities/getEntryEntity/get_entry_entity.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:altera/features/product/domain/entities/labelEntity/Label_entity.dart';

class LabelScreen extends StatelessWidget {
  const LabelScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final LabelController controller = Get.find<LabelController>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Gestión de Etiquetas',
          style: AdminColors.headingMedium.copyWith(
            color: AdminColors.textPrimaryColor,
          ),
        ),
       
      ),
      body: Padding(
        padding: const EdgeInsets.all(AdminColors.paddingMedium),
        child: Column(
          children: [
           
            Expanded(
              child: _buildLabelsList(controller),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildLabelsList(LabelController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
  return const LabelsLoading();
}

      if (controller.hasError.value) {
        return Center(
          child: Container(
            padding: const EdgeInsets.all(AdminColors.paddingLarge),
            decoration: AdminColors.cardDecoration,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  color: AdminColors.errorColor,
                  size: 48,
                ),
                const SizedBox(height: AdminColors.paddingMedium),
                Text(
                  'Error al cargar las etiquetas',
                  style: AdminColors.headingSmall.copyWith(
                    color: AdminColors.errorColor,
                  ),
                ),
                const SizedBox(height: AdminColors.paddingSmall),
                Text(
                  controller.errorMessage.value,
                  style: AdminColors.bodyMedium.copyWith(
                    color: AdminColors.textSecondaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AdminColors.paddingMedium),
                ElevatedButton(
                  onPressed: () => controller.refreshLabels(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminColors.primaryColor,
                    foregroundColor: AdminColors.textLightColor,
                  ),
                  child: Text(
                    'Reintentar',
                    style: AdminColors.buttonText,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      if (controller.filteredLabels.isEmpty) {
        return Center(
          child: Container(
            padding: const EdgeInsets.all(AdminColors.paddingLarge),
            decoration: AdminColors.cardDecoration,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.label_outline,
                  color: AdminColors.textSecondaryColor,
                  size: 48,
                ),
                const SizedBox(height: AdminColors.paddingMedium),
                Text(
                  'No se encontraron etiquetas',
                  style: AdminColors.headingSmall.copyWith(
                    color: AdminColors.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: AdminColors.paddingSmall),
                Text(
                  'Intenta ajustar los filtros de búsqueda',
                  style: AdminColors.bodyMedium.copyWith(
                    color: AdminColors.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return ListView.builder(
        itemCount: controller.filteredLabels.length,
        itemBuilder: (context, index) {
          final label = controller.filteredLabels[index];
          return _buildLabelCard(label, controller);
        },
      );
    });
  }
Widget _buildLabelCard(LabelEntity label, LabelController controller) {
  Color typeColor = _getTypeColor(label.tipo.tipo);
  
  return Container(
    margin: const EdgeInsets.only(bottom: AdminColors.paddingMedium),
    decoration: AdminColors.cardDecoration,
    child: InkWell(
      borderRadius: AdminColors.mediumBorderRadius,
      child: Padding(
        padding: const EdgeInsets.all(AdminColors.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: AdminColors.smallBorderRadius,
                    border: Border.all(color: typeColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    label.tipo.tipo,
                    style: AdminColors.bodySmall.copyWith(
                      color: typeColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                if ((label.piezasPorPallet ?? 0) > 0) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AdminColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          color: AdminColors.primaryColor,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 120),
                          child: Text(
                            '${label.piezasPorPallet}',
                            style: AdminColors.bodySmall.copyWith(
                              color: AdminColors.primaryColor,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
               ConstrainedBox(
  constraints: BoxConstraints(maxWidth: 80),
  child: Text(
    '#${label.id}',
    style: AdminColors.bodySmall.copyWith(
      color: AdminColors.textSecondaryColor,
      fontWeight: FontWeight.w500,
    ),
    overflow: TextOverflow.ellipsis,
    maxLines: 1,
    textAlign: TextAlign.end,
  ),
),
              ],
            ),
            const SizedBox(height: AdminColors.paddingSmall),
            
            Text(
              label.producto,
              style: AdminColors.headingSmall.copyWith(
                color: AdminColors.textPrimaryColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AdminColors.paddingSmall),
            Row(
              children: [
                Icon(
                  Icons.warehouse,
                  color: AdminColors.textSecondaryColor,
                  size: 16,
                ),
                const SizedBox(width: 4),
               Flexible(
                child: Text(
                  label.almacen.nombre ?? '',
                  style: AdminColors.bodyMedium.copyWith(
                    color: AdminColors.textSecondaryColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1, 
                ),
              ),

               
                
              ],
            ),
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: AdminColors.textSecondaryColor,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Flexible(child:  Text(
                  label.usuario.nombre,
                  style: AdminColors.bodyMedium.copyWith(
                    color: AdminColors.textSecondaryColor,
                    overflow: TextOverflow.ellipsis
                  ),
                ),),
               
                const SizedBox(width: AdminColors.paddingMedium),
                Icon(
                  Icons.access_time,
                  color: AdminColors.textSecondaryColor,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    controller.formatDateTime(label.fechaHora),
                    style: AdminColors.bodyMedium.copyWith(
                      color: AdminColors.textSecondaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
Color _getTypeColor(String tipo) {
  String normalizedTipo = tipo.toLowerCase().trim();
  
  switch (normalizedTipo) {
    case 'papeleta':
    case 'papeleta creada':
      return Color(0xFF4F46E5); 
    
    case 'entrada':
      return AdminColors.successColor;
    
    case 'Transferencia Pendiente':
      return AdminColors.errorColor;
    
    case 'surtimiento':
    case 'surtir':
      return Color(0xFF1D4ED8);
    
    case 'eliminación':
    case 'eliminacion':
      return Color(0xFF374151);
    
    case 'cancelada':
    case 'cancelado':
      return Color(0xFFB91C1C);
    
    case 'etiqueta creada':
      return AdminColors.infoColor;
    
    default:
      return AdminColors.primaryColor;
  }
}
}