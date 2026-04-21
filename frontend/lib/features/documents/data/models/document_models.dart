import '../../../shared/utils/json_utils.dart';
import '../../domain/entities/document_entities.dart';

class LandlordDocumentModel extends LandlordDocument {
  const LandlordDocumentModel({
    required super.id,
    required super.userId,
    required super.documentTypeId,
    required super.verificationStatusId,
    required super.documentUrl,
    required super.uploadDate,
    super.verificationDate,
    super.observations,
  });

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
