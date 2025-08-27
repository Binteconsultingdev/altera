import 'package:altera/common/widgets/rounded_logo_widget.dart';
import 'package:altera/features/user/presentacion/page/login/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:altera/common/theme/Theme_colors.dart';
import 'package:get/get.dart';
import 'dart:ui';

class LoginPage extends StatelessWidget {
  final LoginController controller = Get.find<LoginController>();

  LoginPage({Key? key}) : super(key: key);
  final screenSize = MediaQuery.of(Get.context!).size;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AdminColors.primaryColor.withOpacity(0.8),
                  AdminColors.secondaryColor.withOpacity(0.6),
                ],
              ),
            ),
          ),
          
          _buildSimplePattern(),
          
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: screenSize.height * 0.08),
                    
                    _buildSimpleLogo(),
                    
                    SizedBox(height: screenSize.height * 0.06),
                    
                    _buildLoginForm(),
                    
                    SizedBox(height: 30),
                    
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          
          Obx(() {
            if (controller.isLoading.value) {
              return _buildLoadingOverlay();
            } else {
              return const SizedBox.shrink();
            }
          }),
        ],
      ),
    );
  }

  Widget _buildSimplePattern() {
    return Stack(
      children: [
        Positioned(
          top: -screenSize.width * 0.2,
          right: -screenSize.width * 0.2,
          child: Container(
            width: screenSize.width * 0.7,
            height: screenSize.width * 0.7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AdminColors.accentColor.withOpacity(0.2),
            ),
          ),
        ),
        Positioned(
          bottom: -screenSize.width * 0.4,
          left: -screenSize.width * 0.2,
          child: Container(
            width: screenSize.width * 0.8,
            height: screenSize.width * 0.8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AdminColors.primaryColor.withOpacity(0.15),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleLogo() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AdminColors.shadowColor,
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: RoundedLogoWidget(
            height: 100,
            width: screenSize.width * 0.4,
            borderRadius: 16.0,
            fit: BoxFit.contain,
          ),
        ),
        
        SizedBox(height: 25),
        
        Text(
          'Bienvenido',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: AdminColors.textLightColor,
            letterSpacing: 1.0,
          ),
          textAlign: TextAlign.center,
        ),
        
        SizedBox(height: 10),
        
        Text(
          'Inicia sesión para continuar',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AdminColors.textLightColor.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Container(
      decoration: BoxDecoration(
        color: AdminColors.surfaceColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AdminColors.shadowColor,
            blurRadius: 15,
            spreadRadius: 0,
            offset: Offset(0, 5),
          ),
        ],
      ),
      padding: EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInputField(
            icon: Icons.email_outlined,
            label: 'Correo electrónico',
            controller: controller.emailController,
            keyboardType: TextInputType.emailAddress,
            focusNode: controller.emailFocusNode,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => FocusScope.of(Get.context!).requestFocus(controller.passwordFocusNode),
          ),
          
          SizedBox(height: 20),
          
          Obx(() => _buildInputField(
            icon: Icons.lock_outline,
            label: 'Contraseña',
            controller: controller.passwordController,
            obscureText: !controller.showPassword.value,
            focusNode: controller.passwordFocusNode,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => controller.onLoginTap(),
            suffixIcon: IconButton(
              icon: Icon(
                controller.showPassword.value ? Icons.visibility_off : Icons.visibility,
                color: AdminColors.textSecondaryColor.withOpacity(0.6),
                size: 20,
              ),
              onPressed: () => controller.togglePasswordVisibility(),
            ),
          )),
          
          SizedBox(height: 8),
          
          
          SizedBox(height: 25),
          
          _buildGradientButton(
            text: 'INICIAR SESIÓN',
            onPressed: () => controller.onLoginTap(),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    FocusNode? focusNode,
    TextInputAction? textInputAction,
    Function(String)? onSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: TextStyle(
              color: AdminColors.textPrimaryColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AdminColors.shadowColor,
                blurRadius: 4,
                spreadRadius: 0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            focusNode: focusNode,
            textInputAction: textInputAction,
            onSubmitted: onSubmitted,
            style: TextStyle(
              color: AdminColors.textPrimaryColor,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              border: InputBorder.none,
              hintText: 'Ingrese su $label',
              hintStyle: TextStyle(
                color: AdminColors.textSecondaryColor.withOpacity(0.5),
                fontSize: 14,
              ),
              prefixIcon: Icon(
                icon,
                color: AdminColors.primaryColor,
                size: 20,
              ),
              suffixIcon: suffixIcon,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGradientButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AdminColors.primaryColor,
            AdminColors.accentColor,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AdminColors.primaryColor.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onPressed,
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

 

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(30),
            width: screenSize.width * 0.7,
            decoration: BoxDecoration(
              color: AdminColors.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AdminColors.shadowColor,
                  blurRadius: 15,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 45,
                  height: 45,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AdminColors.primaryColor),
                    strokeWidth: 2.5,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Verificando credenciales...',
                  style: TextStyle(
                    color: AdminColors.textPrimaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}