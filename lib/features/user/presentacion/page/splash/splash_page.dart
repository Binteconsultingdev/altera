import 'package:altera/common/theme/Theme_colors.dart';
import 'package:altera/common/widgets/rounded_logo_widget.dart';
import 'package:altera/features/user/presentacion/page/splash/splash_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  final SplashController controller = Get.find<SplashController>();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
    final screenSize = MediaQuery.of(Get.context!).size;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AdminColors.backgroundGradient,
        ),
        child: Stack(
          children: [
            ...List.generate(20, (index) {
              return Positioned(
                left: (index * 30) % size.width,
                top: (index * 45) % size.height,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
              );
            }),
            
            Center(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          
                       Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Center(
                child: RoundedLogoWidget(
                  height: 120,
                  width: screenSize.width * 0.6,
                  borderRadius: 8.0,
                  fit: BoxFit.contain, 
                ),
              ),
            ),

                          
                          
                         
                          
                          const SizedBox(height: 20),
                          
                          Container(
                            width: 60,
                            height: 5,
                            decoration: BoxDecoration(
                              color:AdminColors.colorAccionButtons,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          Text(
                            'Desarrollado por BCG',
                            style: TextStyle(
                              color: AdminColors.colorAccionButtons,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                            ),
                          ),
                          Image.asset('assets/Binte-logo.png',
                          width: 80,
                          ),
                          const SizedBox(height: 60),
                          
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AdminColors.colorAccionButtons,
                              ),
                              strokeWidth: 3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
           
          ],
        ),
      ),
    );
  }
}