import 'package:altera/common/widgets/curve_painter.dart';
import 'package:altera/features/page/home/home_controller.dart';
import 'package:altera/common/theme/Theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'dart:ui';

class HomePage extends StatelessWidget {
  final int? initialIndex; 
  
  const HomePage({Key? key, this.initialIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(
      HomeController(initialIndex: initialIndex ?? 0),
      permanent: false,
    );
    
    return Scaffold(
      backgroundColor: AdminColors.colorFondo,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(
          backgroundColor: AdminColors.colorHoverRow, 
          elevation: 0,
        ),
      ),
      body: Obx(() => Stack(
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
          Center(
            child: controller.pages[controller.selectedIndex.value],
          ),
        ],
      )),
      bottomNavigationBar: _buildConvexBottomBar(controller),
    );
  }

  Widget _buildConvexBottomBar(HomeController controller) {
  final Color activeColor = AdminColors.colorHoverRow;
  final Color backgroundColor = AdminColors.colornavbar;
  final Color tabIconColor = AdminColors.textSecondaryColor;
  final Color selectedTabColor = AdminColors.colordCard;
  
  final List<String> labels = [
    'Inicio',
    'Entrada',
    'Surtir',
    'Salida',
    'Perfil'
  ];
  
  return Obx(() => ConvexAppBar(
    style: TabStyle.react,
    items: List.generate(labels.length, (index) {
      return TabItem(
        icon: controller.getTabIcon(
          index,
          size: index == controller.selectedIndex.value ? 26.0 : 22.0,
          color: index == controller.selectedIndex.value ? activeColor : tabIconColor,
        ),
        title: labels[index],
      );
    }),
    backgroundColor: backgroundColor,
    activeColor: activeColor,
    color: tabIconColor,
    height: 65,
    top: -25,
    curveSize: 100,
    initialActiveIndex: controller.selectedIndex.value,
    onTap: (int index) {
      controller.changePage(index);
      print('🔄 Tab seleccionado: $index (${labels[index]})');
    },
    elevation: 8,
    gradient: LinearGradient(
      colors: [
        selectedTabColor,
        selectedTabColor.withOpacity(0.8),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  ));
}
}