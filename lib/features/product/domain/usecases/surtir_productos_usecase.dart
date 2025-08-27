import 'package:altera/features/product/domain/entities/poshProduct/posh_product_entity.dart';
import 'package:altera/features/product/domain/entities/product_entitie.dart';
import 'package:altera/features/product/domain/entities/surtir/surtir_entity.dart';
import 'package:altera/features/product/domain/repositories/product_repository.dart';

class SurtirProductosUsecase {
  final ProductRepository productRepository;

  SurtirProductosUsecase({required this.productRepository});

  Future<void> execute(List<SurtirEntity> productosASurtir, String id) async {
    await productRepository.surtir(productosASurtir, id);
  }
}
