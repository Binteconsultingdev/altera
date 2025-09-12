
import 'package:altera/common/routes/router.dart';
import 'package:altera/common/services/auth_service.dart';
import 'package:altera/common/settings/routes_names.dart';
import 'package:altera/common/theme/Theme_colors.dart';
import 'package:altera/features/product/presentacion/page/exit/exit_controller.dart';
import 'package:altera/features/product/presentacion/page/getproducto/entry_controller.dart';
import 'package:altera/features/product/presentacion/page/productos/producto_controller.dart';
import 'package:altera/features/product/presentacion/page/surtir/pending_orders_controller.dart';
import 'package:altera/features/user/presentacion/page/login/login_controller.dart';
import 'package:altera/features/user/presentacion/page/perfil/perfil_controller.dart';
import 'package:altera/features/user/presentacion/page/splash/splash_controller.dart';
import 'package:altera/usecase_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

UsecaseConfig usecaseConfig = UsecaseConfig();

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AdminColors.themeData, 
      initialBinding: BindingsBuilder(() {
        Get.put(AuthService(), permanent: true);
        Get.put(usecaseConfig.signinUsecase!, permanent: true);
        Get.put(usecaseConfig.userdataUsecase!, permanent: true);
        Get.put(usecaseConfig.addEntryUsecase!,permanent: true) ;
        Get.put(usecaseConfig.getProductoUsecase!,permanent: true) ;
        Get.put(usecaseConfig.surtirProductosUsecase!,permanent: true) ;
     
        Get.put(usecaseConfig.getLabelsUsecase!,permanent: true);
        Get.put(usecaseConfig.getPendingordersUsecase!,permanent: true);
        Get.put(usecaseConfig.getOrdersUsecase!,permanent: true);
        Get.put(usecaseConfig.getProductoUsecase!,permanent: true);
        Get.put(usecaseConfig.addExitUsecase!,permanent: true);

        Get.put(SplashController(userdataUsecase: Get.find(),) );
        Get.lazyPut(() => LoginController(signinUsecase: Get.find()), fenix: true);
        Get.lazyPut(()=>ProductosController(addEntryUsecase:  Get.find(), getEntryUsecase: Get.find()),fenix: true,);
        Get.lazyPut(()=>PerfilController(userdataUsecase: Get.find()),fenix: true);
        Get.lazyPut(() => LabelController(getLabelsUsecase: Get.find()), fenix: true);
        Get.lazyPut(()=>PendingOrdersController(getPendingOrdersUseCase:Get.find(), getOrdersUsecase: Get.find(), getProductoUsecase: Get.find(), surtirProductosUsecase: Get.find(), ),fenix: true);
        Get.lazyPut(()=>ExitController(exitUsecase: Get.find(), getEntryUsecase: Get.find(),),fenix: true);
      }),
      
      initialRoute: RoutesNames.splashPage, 
      getPages: AppPages.routes, 
      unknownRoute: AppPages.unknownRoute, 
    );
  }
}