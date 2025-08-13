class LabelEntity {
  final int id;
  final int idEntrada;
  final int idProducto;
  final String producto;
  final int idEntradaProducto;
  final int idUsuario;
  final int idTipo;
  final DateTime fechaHora;
  final int piezasPorPallet;
  final TipoEntity tipo;
  final UsuarioEntity usuario;
  final AlmacenEntity almacen;
  LabelEntity({
    required this.id,
    required this.idEntrada,
    required this.idProducto,
    required this.producto,
    required this.idEntradaProducto,
    required this.idUsuario,
    required this.idTipo,
    required this.fechaHora,
    required this.tipo,
    required this.usuario,
    required this.piezasPorPallet,
    required this.almacen,
  });

}


class AlmacenEntity {
  int? id;
  String? codigo;
  String? nombre;

  AlmacenEntity({
    this.id,
    this.codigo,
    this.nombre,
  });
}
class TipoEntity {
  final int id;
  final String tipo;

  TipoEntity({
    required this.id,
    required this.tipo,
  });

}

class UsuarioEntity {
  final int id;
  final String nombre;
  final String usuario;

  UsuarioEntity({
    required this.id,
    required this.nombre,
    required this.usuario,
  });

}