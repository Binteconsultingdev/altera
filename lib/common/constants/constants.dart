import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static String serverBase = dotenv.env['API_BASE'].toString();

    static const String catalogstoragekey = "productos_catalogo";
    static const String cataexittoragekey = "cata_exittorage_key";

  static  String codigoQr = 'codigoQr';
  static const String accesos = "accesos";
  static const String modeStorageKey = 'productos_mode_key';
  static const String productosescaneados = 'productos_escaneados_por_orden';

  
}