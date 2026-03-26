import 'package:altera/common/settings/routes_names.dart';
import 'package:altera/features/page/home/home_page.dart';
import 'package:altera/features/product/presentacion/page/surtir/order_details_page.dart';
import 'package:altera/features/user/presentacion/page/login/login_page.dart';
import 'package:altera/features/user/presentacion/page/splash/splash_page.dart';
import 'package:altera/features/product/domain/entities/orders/pending_orders_entity.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: RoutesNames.splashPage,
      page: () => SplashPage(),
    ),
    GetPage(
      name: RoutesNames.loginPage, 
      page: () => LoginPage(),
    ),
    GetPage(
      name: RoutesNames.homePage, 
      page: () {
        final int? initialIndex = Get.arguments as int?;
        return HomePage(initialIndex: initialIndex);
      },
    ),
    GetPage(
      name: RoutesNames.orderDetails, 
      page: () {
        final PendingOrdersEntity order = Get.arguments as PendingOrdersEntity;
        return OrderDetailsPage(order: order);
      }
    ),
  ];

  static final unknownRoute = GetPage(
    name: '/not-found',
    page: () => Scaffold(
      body: Center(
        child: Text('Ruta no encontrada'),
      ),
    ),
  );
}
