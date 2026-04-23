import 'package:flexidrive/utils/json_utils.dart';

class PublicationModel {
  const PublicationModel({
    required this.id,
    required this.userId,
    required this.vehicleId,
    required this.publishDate,
    required this.active,
  });

  final int id;
  final int userId;
  final int vehicleId;
  final DateTime publishDate;
  final bool active;

  factory PublicationModel.fromJson(Map<String, dynamic> json) {
    return PublicationModel(
      id: JsonUtils.asInt(json['publicacion_id']),
      userId: JsonUtils.asInt(json['usuario_id']),
      vehicleId: JsonUtils.asInt(json['vehiculo_id']),
      publishDate: JsonUtils.asDateTime(json['fecha_publicacion']),
      active: JsonUtils.asBool(json['activa']),
    );
  }

  Map<String, dynamic> toJson() => {
    'publicacion_id': id,
    'usuario_id': userId,
    'vehiculo_id': vehicleId,
    'fecha_publicacion': publishDate.toIso8601String(),
    'activa': active,
  };
}

class PublicationPriceModel {
  const PublicationPriceModel({
    required this.id,
    required this.publicationId,
    required this.periodTypeId,
    required this.price,
  });

  final int id;
  final int publicationId;
  final int periodTypeId;
  final double price;

  factory PublicationPriceModel.fromJson(Map<String, dynamic> json) {
    return PublicationPriceModel(
      id: JsonUtils.asInt(json['precio_publicacion_id']),
      publicationId: JsonUtils.asInt(json['publicacion_id']),
      periodTypeId: JsonUtils.asInt(json['tipo_periodo_id']),
      price: JsonUtils.asDouble(json['precio']),
    );
  }

  Map<String, dynamic> toJson() => {
    'precio_publicacion_id': id,
    'publicacion_id': publicationId,
    'tipo_periodo_id': periodTypeId,
    'precio': price,
  };
}

class PublicationImageModel {
  const PublicationImageModel({
    required this.id,
    required this.publicationId,
    required this.imageUrl,
    required this.order,
    required this.isMain,
    required this.uploadDate,
  });

  final int id;
  final int publicationId;
  final String imageUrl;
  final int order;
  final bool isMain;
  final DateTime uploadDate;

  factory PublicationImageModel.fromJson(Map<String, dynamic> json) {
    return PublicationImageModel(
      id: JsonUtils.asInt(json['imagen_publicacion_id']),
      publicationId: JsonUtils.asInt(json['publicacion_id']),
      imageUrl: JsonUtils.asString(json['url_imagen']),
      order: JsonUtils.asInt(json['orden']),
      isMain: JsonUtils.asBool(json['es_principal']),
      uploadDate: JsonUtils.asDateTime(json['fecha_subida']),
    );
  }

  Map<String, dynamic> toJson() => {
    'imagen_publicacion_id': id,
    'publicacion_id': publicationId,
    'url_imagen': imageUrl,
    'orden': order,
    'es_principal': isMain,
    'fecha_subida': uploadDate.toIso8601String(),
  };
}
