import 'package:flexidrive/utils/json_utils.dart';

class LandlordDocumentModel {
  const LandlordDocumentModel({
    required this.id,
    required this.userId,
    required this.documentTypeId,
    required this.verificationStatusId,
    required this.documentUrl,
    required this.uploadDate,
    this.verificationDate,
    this.observations,
  });

  final int id;
  final int userId;
  final int documentTypeId;
  final int verificationStatusId;
  final String documentUrl;
  final DateTime uploadDate;
  final DateTime? verificationDate;
  final String? observations;

  factory LandlordDocumentModel.fromJson(Map<String, dynamic> json) {
    return LandlordDocumentModel(
      id: JsonUtils.asInt(json['documento_arrendador_id']),
      userId: JsonUtils.asInt(json['usuario_id']),
      documentTypeId: JsonUtils.asInt(json['tipo_documento_arrendador_id']),
      verificationStatusId: JsonUtils.asInt(
        json['estado_verificacion_documento_id'],
      ),
      documentUrl: JsonUtils.asString(json['url_documento']),
      uploadDate: JsonUtils.asDateTime(json['fecha_subida']),
      verificationDate: JsonUtils.asDateTimeNullable(json['fecha_verificacion']),
      observations: json['observaciones'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'documento_arrendador_id': id,
    'usuario_id': userId,
    'tipo_documento_arrendador_id': documentTypeId,
    'estado_verificacion_documento_id': verificationStatusId,
    'url_documento': documentUrl,
    'fecha_subida': uploadDate.toIso8601String(),
    'fecha_verificacion': verificationDate?.toIso8601String(),
    'observaciones': observations,
  };
}
