import 'package:altera/features/product/domain/entities/orders/pending_orders_entity.dart';

class PendingOrdersModel extends PendingOrdersEntity {
  PendingOrdersModel({
    required super.id,
    required super.serie,
    required super.folio,
    required super.fecha,
    required super.id_cliente,
    required super.pendientes,
    required super.clienteEntity,
    required super.concepto
  });

  PendingOrdersModel.fromJson(Map<String, dynamic> json)
      : super(
          id: json['id'],
          serie: json['serie'],
          folio: json['folio'],
          fecha: json['fecha'],
          id_cliente: json['id_cliente'].toString(),
          pendientes: json['pendientes'].toString(),
          concepto: json['concepto']??'',
          clienteEntity: json['cliente']!= null ? ClienteEntity(
            id: json['cliente']['id']??'', 
            cliente: json['cliente']['cliente']??'', 
            codigo: json['cliente']['codigo']??''):ClienteEntity(id: 0, cliente: '', codigo: ''),
        );

  PendingOrdersModel.fromEntity(PendingOrdersEntity entity)
      : super(
          id: entity.id,
          serie: entity.serie,
          folio: entity.folio,
          fecha: entity.fecha,
          id_cliente: entity.id_cliente,
          pendientes: entity.pendientes,
          clienteEntity: ClienteEntity(id: entity.clienteEntity.id, cliente: entity.clienteEntity.cliente, codigo: entity.clienteEntity.codigo),
          concepto: entity.concepto
        );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serie': serie,
      'folio': folio,
      'fecha': fecha,
      'id_cliente':id_cliente,
      'pendientes': pendientes,
      'cliente': {
        'id':clienteEntity.id,
        'cliente':clienteEntity.cliente,
        'codigo':clienteEntity.codigo
      }
      ,'concepto':concepto
    };
  }

 }