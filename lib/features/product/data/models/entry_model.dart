import 'package:altera/features/product/domain/entities/getEntryEntity/get_entry_entity.dart';

// 6. EntryModel actualizado
class EntryModel extends EntryEntity {
  EntryModel({
    required int id,
    required int idEntrada,
    required int idProducto,
    required int maquina,
    required String anchoAla,
    required String longitud,
    required String calibre,
    required String piezasPorPallet,
    required String camasPorTarima,
    required String bultosPorCama,
    required String piezasPorBulto,
    required String puntos,
    required String ordenCompra,
    required String observaciones,
    required TipoEntity tipo,
    required ProductEntity producto,
    required List<LogEntity> logs,
    required int totalPiezasPorPalletSurtidas,
  }) : super(
          id: id,
          idEntrada: idEntrada,
          idProducto: idProducto,
          maquina: maquina,
          anchoAla: anchoAla,
          longitud: longitud,
          calibre: calibre,
          piezasPorPallet: piezasPorPallet,
          camasPorTarima: camasPorTarima,
          bultosPorCama: bultosPorCama,
          piezasPorBulto: piezasPorBulto,
          puntos: puntos,
          ordenCompra: ordenCompra,
          observaciones: observaciones,
          tipo: tipo,
          producto: producto,
          logs: logs, 
          totalPiezasPorPalletSurtidas: totalPiezasPorPalletSurtidas,
        );

  factory EntryModel.fromJson(Map<String, dynamic> json) {
 
    List<LogEntity> logsList = [];
    if (json['logs'] != null && json['logs'] is List) {
      logsList = (json['logs'] as List).map((logJson) {
        return LogEntity(
          id: logJson['id'] ?? 0,
          idEntradaProducto: logJson['id_entrada_producto'] ?? 0,
          idUsuario: logJson['id_usuario'] ?? 0,
          idTipo: logJson['id_tipo'] ?? 0,
          fechaHora: logJson['fecha_hora']?.toString() ?? '',
          
          tipo: logJson['tipo'] != null 
            ? TipoEntity(
                id: logJson['tipo']['id'] ?? 0,
                tipo: logJson['tipo']['tipo'] ?? '',
              )
            : TipoEntity(id: 0, tipo: ''),
          usuario: logJson['usuario'] != null
            ? UsuarioEntity(
                id: logJson['usuario']['id'] ?? 0,
                nombre: logJson['usuario']['nombre'] ?? '',
                usuario: logJson['usuario']['usuario'] ?? '',
              )
            : UsuarioEntity(id: 0, nombre: '', usuario: ''),
        );
      }).toList();
    }

    return EntryModel(
      id: json['id'] ?? 0,
      idEntrada: json['id_entrada'] ?? 0,
      idProducto: json['id_producto'] ?? 0,
      maquina: json['maquina'] ?? 0,
      anchoAla: json['ancho_ala']?.toString() ?? '',
      longitud: json['longitud']?.toString() ?? '',
      calibre: json['calibre']?.toString() ?? '',
      piezasPorPallet: json['piezas_por_pallet']?.toString() ?? '',
      camasPorTarima: json['camas_por_tarima']?.toString() ?? '',
      bultosPorCama: json['bultos_por_cama']?.toString() ?? '',
      piezasPorBulto: json['piezas_por_bulto']?.toString() ?? '',
      puntos: json['puntos']?.toString() ?? '',
      ordenCompra: json['orden_compra']?.toString() ?? '',
      observaciones: json['observaciones']?.toString() ?? '',
      totalPiezasPorPalletSurtidas: json['total_piezas_por_pallet_surtidas'] ?? 0,
      tipo: json['tipo'] != null
        ? TipoEntity(
            id: json['tipo']['id'] ?? 0,
            tipo: json['tipo']['tipo'] ?? '',
          )
        : TipoEntity(id: 0, tipo: ''),
      producto: json['producto'] != null
        ? ProductEntity(
            id: json['producto']['id'] ?? 0,
            nombre: json['producto']['nombre'] ?? '',
            codigo: json['producto']['codigo'] ?? '',
          )
        : ProductEntity(id: 0, nombre: '', codigo: ''),
      logs: logsList, // NUEVA PROPIEDAD
    );
  }

  factory EntryModel.fromEntity(EntryEntity entity) {
    return EntryModel(
      id: entity.id,
      idEntrada: entity.idEntrada,
      idProducto: entity.idProducto,
      maquina: entity.maquina,
      anchoAla: entity.anchoAla,
      longitud: entity.longitud,
      calibre: entity.calibre,
      piezasPorPallet: entity.piezasPorPallet,
      camasPorTarima: entity.camasPorTarima,
      bultosPorCama: entity.bultosPorCama,
      piezasPorBulto: entity.piezasPorBulto,
      puntos: entity.puntos,
      ordenCompra: entity.ordenCompra,
      observaciones: entity.observaciones,
      totalPiezasPorPalletSurtidas: entity.totalPiezasPorPalletSurtidas,
      tipo: TipoEntity(
        id: entity.tipo.id,
        tipo: entity.tipo.tipo,
      ),
      producto: ProductEntity(
        id: entity.producto.id,
        nombre: entity.producto.nombre,
        codigo: entity.producto.codigo,
      ),
      logs: entity.logs, // NUEVA PROPIEDAD
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_entrada': idEntrada,
      'id_producto': idProducto,
      'maquina': maquina,
      'ancho_ala': anchoAla,
      'longitud': longitud,
      'calibre': calibre,
      'piezas_por_pallet': piezasPorPallet,
      'camas_por_tarima': camasPorTarima,
      'bultos_por_cama': bultosPorCama,
      'piezas_por_bulto': piezasPorBulto,
      'puntos': puntos,
      'orden_compra': ordenCompra,
      'observaciones': observaciones,
      'total_piezas_por_pallet_surtidas': totalPiezasPorPalletSurtidas,
      'tipo': {
        'id': tipo.id,
        'tipo': tipo.tipo,
      },
      'producto': {
        'id': producto.id,
        'nombre': producto.nombre,
        'codigo': producto.codigo,
      },
      'logs': logs.map((log) => {
        'id': log.id,
        'id_entrada_producto': log.idEntradaProducto,
        'id_usuario': log.idUsuario,
        'id_tipo': log.idTipo,
        'fecha_hora': log.fechaHora,
        'tipo': {
          'id': log.tipo.id,
          'tipo': log.tipo.tipo,
        },
        'usuario': {
          'id': log.usuario.id,
          'nombre': log.usuario.nombre,
          'usuario': log.usuario.usuario,
        },
      }).toList(),
    };
  }

  LogEntity? get ultimoLog => logs.isNotEmpty ? logs.last : null;
  
  String get estadoActual => ultimoLog?.tipo.tipo ?? 'Sin estado';
  
  String get ultimoUsuario => ultimoLog?.usuario.nombre ?? 'Desconocido';
  
  DateTime? get ultimaFechaHora {
    if (ultimoLog == null) return null;
    try {
      return DateTime.parse(ultimoLog!.fechaHora);
    } catch (e) {
      return null;
    }
  }
  
  List<LogEntity> get logsOrdenadosPorFecha {
    final sortedLogs = List<LogEntity>.from(logs);
    sortedLogs.sort((a, b) {
      try {
        final dateA = DateTime.parse(a.fechaHora);
        final dateB = DateTime.parse(b.fechaHora);
        return dateA.compareTo(dateB);
      } catch (e) {
        return 0;
      }
    });
    return sortedLogs;
  }
}