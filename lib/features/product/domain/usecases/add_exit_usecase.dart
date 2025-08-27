import 'package:altera/features/product/domain/entities/poshProduct/posh_product_entity.dart';
import 'package:altera/features/product/domain/entities/product_entitie.dart';
import 'package:altera/features/product/domain/repositories/product_repository.dart';

class AddExitUsecase {
  final ProductRepository productRepository;
  AddExitUsecase({required this.productRepository});
  Future<void> execute(List<PoshProductEntity> poshProductList) async {
    await productRepository.poshExit(poshProductList);
  }
}
