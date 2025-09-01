
import 'package:altera/common/services/auth_service.dart';
import 'package:altera/features/user/data/datasources/user_data_sources_imp.dart';
import 'package:altera/features/user/data/models/login_response.dart';
import 'package:altera/features/user/domain/entities/client_data_entitie.dart';
import 'package:altera/features/user/domain/repositories/user_repository.dart';

class UserRepositoryImp  implements UserRepository{
    final UserDataSourcesImp userDataSourcesImp;
    final AuthService authService = AuthService();

  UserRepositoryImp({
    required this.userDataSourcesImp,
  });
  @override

  Future<LoginResponse> signin(String email, String password) async {
    return await userDataSourcesImp.signin(email, password);
  }
  Future<List<UserDataEntity>> userData() async {
      final token = await authService.getToken();
    
    if (token == null) {
      throw Exception('No hay sesión activa. El usuario debe iniciar sesión.');
    }

    return await userDataSourcesImp.userData(token);
  }
}