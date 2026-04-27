import 'package:altera/common/theme/Theme_colors.dart';
import 'package:altera/common/widgets/curve_painter.dart';
import 'package:altera/features/user/presentacion/page/perfil/perfil_controller.dart';
import 'package:altera/features/user/presentacion/page/perfil/perfil_loading.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart'; 

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({
    super.key,
  });

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {

  bool isNotifications = false;
  
  PerfilController get controller => Get.find<PerfilController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Scaffold(
          body: PerfilLoading(),
        );
      }

      if (controller.errorMessage.value.isNotEmpty) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: AdminColors.backgroundGradient,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AdminColors.textSecondaryColor,
                  ),
                  SizedBox(height: 16),
                  Text(
                    controller.errorMessage.value,
                    style: TextStyle(
                      color: AdminColors.textSecondaryColor,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.refreshUserData(),
                    child: Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      return Stack(
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
            child: RefreshIndicator(
              onRefresh: () => controller.refreshUserData(),
              color: AdminColors.colorAccionButtons,
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 30),
                      
                      _buildProfileHeader(),
                      
                      SizedBox(height: 30),
                      
                      _buildPersonalInfo(),
                      
                      SizedBox(height: 40),
                      
                      _buildSettings(),
                      
                      SizedBox(height: 40),
                      
                      
                      SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildProfileHeader() {
    final Color textColor = AdminColors.textPrimaryColor;
    final Color accentColor = AdminColors.colorAccionButtons;
    
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 5,
                offset: Offset(0, 10),
              ),
            ],
          ),
            child: CircleAvatar(
            radius: 75,
            backgroundColor: Colors.transparent,
            child: ClipOval(
              child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: accentColor.withOpacity(0.5),
                  width: 4,
                ),
                ),
                child: ClipOval(
                child: (controller.photo != null && controller.photo!.isNotEmpty)
                  ? Image.network(
                    controller.photo!,
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                    )
                  : Container(
                    width: 150,
                    height: 150,
                    color: Colors.grey[800],
                    child: Icon(
                      Icons.person,
                      size: 80,
                      color: Colors.grey[600],
                    ),
                    ),
                ),
              ),
              ),
            ),
            ),
          ),
        
        SizedBox(height: 20),
        
        Obx(() => Text(
          controller.userName,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w700,
            fontSize: 22,
            letterSpacing: 2,
            fontFamily: 'Roboto',
          ),
        )),
        
        SizedBox(height: 10),
        
        Obx(() => controller.userEmail.isNotEmpty 
          ? Text(
              '${controller.userEmail}',
              style: TextStyle(
                color: AdminColors.textSecondaryColor,
                fontWeight: FontWeight.w400,
                fontSize: 14,
                fontFamily: 'Roboto',
              ),
            )
          : SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildPersonalInfo() {
    final Color textColor = AdminColors.textPrimaryColor;
    final Color secondaryColor = AdminColors.textSecondaryColor;
    final Color accentColor = AdminColors.colorAccionButtons;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.person_outline,
              color: accentColor,
              size: 20,
            ),
            SizedBox(width: 10),
            Flexible(
              child:
            Text(
              "INFORMACIÓN PERSONAL",
              style: TextStyle(
                color: accentColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                letterSpacing: 1.5,
                fontFamily: 'Roboto',
                
              ),
              overflow: TextOverflow.ellipsis,
                 maxLines: 1
            ),
            )
          ],
        ),
        
        SizedBox(height: 20),
        
        Obx(() => Column(
          children: [
            _buildInfoItem(Icons.badge_outlined, "Nombre completo", controller.userName),
            _buildInfoItem(Icons.person_outline, "Usuario", controller.userData.value?.usuario ?? 'N/A'),
            _buildInfoItem(Icons.email_outlined, "Correo", controller.userEmail),
            _buildInfoItem(Icons.admin_panel_settings_outlined, "Rol", controller.userRole),
            _buildInfoItem(Icons.warehouse, "Almacén", controller.almacenNombre),
_buildPrivacyItem(),
          ],
        )),
      ],
    );
  }
Widget _buildPrivacyItem() {
  final Color textColor = AdminColors.textPrimaryColor;
  final Color secondaryColor = AdminColors.textSecondaryColor;
  final Color iconBgColor = Colors.white.withOpacity(0.1);

  return GestureDetector(
    onTap: () async {
      final Uri url = Uri.parse('https://binteconsulting.com/altera/aviso-de-privacidad.html');
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    },
    child: Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.privacy_tip_outlined,
              color: textColor,
              size: 20,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Legal",
                  style: TextStyle(
                    color: secondaryColor,
                    fontSize: 12,
                    fontFamily: 'Roboto',
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Aviso de privacidad",
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    fontFamily: 'Roboto',
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.open_in_new,
            color: secondaryColor,
            size: 16,
          ),
        ],
      ),
    ),
  );
}
  Widget _buildInfoItem(IconData icon, String label, String value) {
    final Color textColor = AdminColors.textPrimaryColor;
    final Color secondaryColor = AdminColors.textSecondaryColor;
    final Color iconBgColor = Colors.white.withOpacity(0.1);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: textColor,
              size: 20,
            ),
          ),
          
          SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: secondaryColor,
                    fontSize: 12,
                    fontFamily: 'Roboto',
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    fontFamily: 'Roboto',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettings() {
    final Color textColor = AdminColors.textPrimaryColor;
    final Color secondaryColor = AdminColors.textSecondaryColor;
    final Color accentColor = AdminColors.colorAccionButtons;
    final Color bgColor = Colors.white.withOpacity(0.1);
    final Color borderColor = Colors.white.withOpacity(0.2);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
       Row(
  children: [
    Icon(
      Icons.settings_outlined,
      color: accentColor,
      size: 20,
    ),
    SizedBox(width: 10),

    Expanded(
      child: Text(
        "CONFIGURACIÓN",
        style: TextStyle(
          color: accentColor,
          fontWeight: FontWeight.w600,
          fontSize: 14,
          letterSpacing: 1.5,
          fontFamily: 'Roboto',
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    ),
  ],
),

        SizedBox(height: 20),
        
        GestureDetector(
  onTap: () => controller.cerrarSesion(),
  child: Container(
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: borderColor),
    ),
    child: Row(
      children: [
        Icon(
          Icons.logout_outlined,
          color: textColor,
          size: 22,
        ),
        SizedBox(width: 16),

        Expanded(
          child: Text(
            "Cerrar sesión",
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 16,
              fontFamily: 'Roboto',
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    ),
  ),
),

      ],
    );
  }
}