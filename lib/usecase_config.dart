
import 'package:altera/features/product/data/datasources/product_data_sources_imp.dart';
import 'package:altera/features/product/data/repositories/product_repository_imp.dart';
import 'package:altera/features/product/domain/usecases/add_entry_usecase.dart';
import 'package:altera/features/product/domain/usecases/add_exit_usecase.dart';
import 'package:altera/features/product/domain/usecases/surtir_productos_usecase.dart';
import 'package:altera/features/product/domain/usecases/delete_ballot_usecase.dart';
import 'package:altera/features/product/domain/usecases/get_labels_usecase.dart';
import 'package:altera/features/product/domain/usecases/get_orders_usecase.dart';
import 'package:altera/features/product/domain/usecases/get_pendingorders_usecase.dart';
import 'package:altera/features/product/domain/usecases/get_producto_usecase.dart';
import 'package:altera/features/user/data/datasources/user_data_sources_imp.dart';
import 'package:altera/features/user/data/repositories/user_repository_imp.dart';
import 'package:altera/features/user/domain/usecases/signin_usecase.dart';
import 'package:altera/features/user/domain/usecases/userdata_usecase.dart';

class UsecaseConfig {
  UserDataSourcesImp? userDataSourcesImp;
  UserRepositoryImp? userRepositoryImp;
  SigninUsecase? signinUsecase;
  UserdataUsecase? userdataUsecase;


  //product
  ProductDataSourcesImp?productDataSourcesImp;
  ProductRepositoryImp?productRepositoryImp;
  AddEntryUsecase?addEntryUsecase;
  AddExitUsecase?addExitUsecase;
  SurtirProductosUsecase? surtirProductosUsecase;
  
  GetProductoUsecase? getProductoUsecase;
  DeleteBallotUsecase? deleteBallotUsecase;
  GetLabelsUsecase? getLabelsUsecase;
  GetPendingordersUsecase?getPendingordersUsecase;
  GetOrdersUsecase? getOrdersUsecase;
  UsecaseConfig(){
    userDataSourcesImp = UserDataSourcesImp();
    userRepositoryImp = UserRepositoryImp(userDataSourcesImp: userDataSourcesImp!);
    signinUsecase = SigninUsecase(userRepository: userRepositoryImp!);
    userdataUsecase = UserdataUsecase(userRepository: userRepositoryImp!);

    productDataSourcesImp=ProductDataSourcesImp();
    productRepositoryImp=ProductRepositoryImp(productSourcesImp: productDataSourcesImp!);
    addEntryUsecase=AddEntryUsecase(productRepository: productRepositoryImp!);
    addExitUsecase=AddExitUsecase(productRepository: productRepositoryImp!);
    getProductoUsecase=GetProductoUsecase(repository: productRepositoryImp!);
    surtirProductosUsecase=SurtirProductosUsecase(productRepository: productRepositoryImp!);
    deleteBallotUsecase=DeleteBallotUsecase(productRepository: productRepositoryImp!);
    getLabelsUsecase=GetLabelsUsecase(repository: productRepositoryImp!);
    getPendingordersUsecase=GetPendingordersUsecase(repository: productRepositoryImp!);
    getOrdersUsecase = GetOrdersUsecase(productRepository: productRepositoryImp!);
    
    }
}