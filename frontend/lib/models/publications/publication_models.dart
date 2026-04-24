// Utilidades para convertir JSON
import 'package:flexidrive/utils/json_utils.dart';

// Modelo de una publicacion de renta
// Cuando un arrendador publica su carro para rentar
class PublicationModel {
  // Constructor con datos basicos de la publicacion
  const PublicationModel({
    required this.id, // ID unico de la publicacion
    required this.userId, // ID del arrendador (dueño del carro)
    required this.vehicleId, // ID del carro que se renta
    required this.publishDate, // Fecha cuando se publico
    required this.active, // Esta activa la publicacion?
  });

  // ID de la publicacion
  final int id;
  // ID del usuario arrendador
  final int userId;
  // ID del vehiculo/carro
  final int vehicleId;
  // Fecha y hora de publicacion
  final DateTime publishDate;
  // true = visible para rentar, false = oculta
  final bool active;

  // Crea PublicationModel desde JSON
  factory PublicationModel.fromJson(Map<String, dynamic> json) {
    return PublicationModel(
      id: JsonUtils.asInt(json['publicacion_id']),
      userId: JsonUtils.asInt(json['usuario_id']),
      vehicleId: JsonUtils.asInt(json['vehiculo_id']),
      publishDate: JsonUtils.asDateTime(json['fecha_publicacion']),
      active: JsonUtils.asBool(json['activa']),
    );
  }

  // Convierte a JSON para guardar
  Map<String, dynamic> toJson() => {
        'publicacion_id': id,
        'usuario_id': userId,
        'vehiculo_id': vehicleId,
        'fecha_publicacion': publishDate.toIso8601String(),
        'activa': active,
      };
}

// Modelo de precios de una publicacion
// Guarda los precios por dia, semana, mes
class PublicationPriceModel {
  // Constructor con datos del precio
  const PublicationPriceModel({
    required this.id, // ID unico del precio
    required this.publicationId, // ID de la publicacion
    required this.periodTypeId, // 1=dia, 2=semana, 3=mes
    required this.price, // Valor del alquiler
  });

  // ID del precio
  final int id;
  // ID de la publicacion
  final int publicationId;
  // Tipo de periodo: 1=dia, 2=semana, 3=mes
  final int periodTypeId;
  // Precio en pesos colombianos
  final double price;

  // Crea PublicationPriceModel desde JSON
  factory PublicationPriceModel.fromJson(Map<String, dynamic> json) {
    return PublicationPriceModel(
      id: JsonUtils.asInt(json['precio_publicacion_id']),
      publicationId: JsonUtils.asInt(json['publicacion_id']),
      periodTypeId: JsonUtils.asInt(json['tipo_periodo_id']),
      price: JsonUtils.asDouble(json['precio']),
    );
  }

  // Convierte a JSON para guardar
  Map<String, dynamic> toJson() => {
        'precio_publicacion_id': id,
        'publicacion_id': publicationId,
        'tipo_periodo_id': periodTypeId,
        'precio': price,
      };
}

// Modelo de imagenes de una publicacion
// Guarda las fotos del carro
class PublicationImageModel {
  // Constructor con datos de la imagen
  const PublicationImageModel({
    required this.id, // ID unico de la imagen
    required this.publicationId, // ID de la publicacion
    required this.imageUrl, // URL de la imagen
    required this.order, // Orden de la imagen (1, 2, 3...)
    required this.isMain, // Es la imagen principal?
    required this.uploadDate, // Fecha cuando se subio
  });

  // ID de la imagen
  final int id;
  // ID de la publicacion
  final int publicationId;
  // Ruta de la imagen ej: "assets/carros/mazda3_1.jpg"
  final String imageUrl;
  // Orden de la imagen (para el carrusel)
  final int order;
  // true = es la foto principal del carrusel
  final bool isMain;
  // Fecha y hora de subida
  final DateTime uploadDate;

  // Crea PublicationImageModel desde JSON
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

  // Convierte a JSON para guardar
  Map<String, dynamic> toJson() => {
        'imagen_publicacion_id': id,
        'publicacion_id': publicationId,
        'url_imagen': imageUrl,
        'orden': order,
        'es_principal': isMain,
        'fecha_subida': uploadDate.toIso8601String(),
      };
}
