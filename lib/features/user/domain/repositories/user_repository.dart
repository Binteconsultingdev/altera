
import 'package:altera/features/user/data/models/login_response.dart';
import 'package:altera/features/user/domain/entities/client_data_entitie.dart';

abstract class UserRepository {
  Future<LoginResponse> signin(String email, String password);
  Future<List<UserDataEntity>> userData();
}