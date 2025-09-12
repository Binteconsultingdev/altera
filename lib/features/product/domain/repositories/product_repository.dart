
import 'package:altera/features/product/domain/entities/getEntryEntity/get_entry_entity.dart';
import 'package:altera/features/product/domain/entities/labelEntity/Label_entity.dart';
import 'package:altera/features/product/domain/entities/orders/orders_entity.dart';
import 'package:altera/features/product/domain/entities/orders/pending_orders_entity.dart';
import 'package:altera/features/product/domain/entities/poshProduct/posh_product_entity.dart';
import 'package:altera/features/product/domain/entities/product_entitie.dart';
import 'package:altera/features/product/domain/entities/surtir/surtir_entity.dart';

abstract class ProductRepository {

Future<void> surtir(List<SurtirEntity> poshProductList,String id);
Future<void> poshEntry(List<PoshProductEntity> poshProductList);
Future<void> poshExit(List<PoshProductEntity> poshProductList);

Future<List<EntryEntity>> getEntry(String idProducto);
Future<List<LabelEntity>> getLabels();
Future<List<PendingOrdersEntity>> getPendingorders({required String date});
 Future<OrdersEntity>  getorders({required int id});

}