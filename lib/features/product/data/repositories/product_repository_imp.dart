

import 'package:altera/common/services/auth_service.dart';
import 'package:altera/features/product/data/datasources/product_data_sources_imp.dart';
import 'package:altera/features/product/domain/entities/getEntryEntity/get_entry_entity.dart';
import 'package:altera/features/product/domain/entities/labelEntity/Label_entity.dart';
import 'package:altera/features/product/domain/entities/orders/orders_entity.dart';
import 'package:altera/features/product/domain/entities/orders/pending_orders_entity.dart';
import 'package:altera/features/product/domain/entities/poshProduct/posh_product_entity.dart';
import 'package:altera/features/product/domain/entities/product_entitie.dart';
import 'package:altera/features/product/domain/entities/surtir/surtir_entity.dart';
import 'package:altera/features/product/domain/repositories/product_repository.dart';

class ProductRepositoryImp  implements ProductRepository{
    final ProductDataSourcesImp productSourcesImp;
    final AuthService authService = AuthService();

  ProductRepositoryImp({
    required this.productSourcesImp,
  });
 
  @override
  Future<List<EntryEntity>> getEntry(String idProducto) async {
    final session = await authService.getToken();
     if (session == null) {
        throw Exception('No hay sesión activa. El usuario debe iniciar sesión.');
      }
    return await productSourcesImp.getEntry(session, idProducto);
  }

  @override
  Future<void> poshEntry(List<PoshProductEntity> poshProductList)async {
   final session = await authService.getToken();
     if (session == null) {
        throw Exception('No hay sesión activa. El usuario debe iniciar sesión.');
      }
      
    return productSourcesImp.addEntry(poshProductList, session);
  }

  @override
  Future<void> surtir(List<SurtirEntity> poshProductList, String id) async {
    final session = await authService.getToken();
     if (session == null) {
        throw Exception('No hay sesión activa. El usuario debe iniciar sesión.');
      }
    return productSourcesImp.surtir(poshProductList, session,id);
  }


  @override
  Future<void> deleteBallot(List<PoshProductEntity> poshProductList) async {
    final Session = await authService.getToken();
    if (Session == null){
      throw Exception('No hay sesión activa. El usuario debe iniciar sesión.');
    }
    return productSourcesImp.deleteBallot(poshProductList, Session);
  }
  
  @override
  Future<List<LabelEntity>> getLabels() async {
 final Session = await authService.getToken();
    if (Session == null){
      throw Exception('No hay sesión activa. El usuario debe iniciar sesión.');
    }
    return await productSourcesImp.getLabels(Session);
  }
  
  @override
  Future<List<PendingOrdersEntity>> getPendingorders({required String date}) async {
     final Session = await authService.getToken();

     if (Session == null){
      throw Exception('No hay sesión activa. El usuario debe iniciar sesión.');
    }
    return await productSourcesImp.getPendingorders(token: Session, date: date);
  }
  
  @override
   Future<OrdersEntity> getorders({required int id}) async {
    final Session = await authService.getToken();

     if (Session == null){
      throw Exception('No hay sesión activa. El usuario debe iniciar sesión.');
    }
    return await productSourcesImp.getorders(token: Session, id: id);
  }
  
  @override
  Future<void> poshExit(List<PoshProductEntity> poshProductList) async {
    final Session = await authService.getToken();

     if (Session == null){
      throw Exception('No hay sesión activa. El usuario debe iniciar sesión.');
    }
    return await productSourcesImp.addExit(poshProductList, Session);
  }}