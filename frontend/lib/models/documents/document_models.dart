// Utilidades para convertir JSON
import 'package:flexidrive/utils/json_utils.dart';

// Modelo de documentos del arrendador
// Almacena información sobre documentos de verificación subidos por los arrendadores
class LandlordDocumentModel {
  // Constructor con todos los datos del documento
  const LandlordDocumentModel({
    required this.id, // ID único del documento
    required this.userId, // ID del arrendador que subió el documento
    required this.documentTypeId, // Tipo de documento (licencia, cédula, etc)
    required this.verificationStatusId, // Estado de verificación (pendiente, aprobado, rechazado)
    required this.documentUrl, // URL del archivo del documento
    required this.uploadDate, // Fecha en que se subió el documento
    this.verificationDate, // Fecha de verificación (opcional)
    this.observations, // Comentarios de la verificación (opcional)
  });

  // ID en la base de datos
  final int id;
  // ID del usuario arrendador
  final int userId;
  // ID del tipo de documento
  final int documentTypeId;
  // ID del estado de verificación
  final int verificationStatusId;
  // URL del documento en el servidor
  final String documentUrl;
  // Fecha de subida del documento
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
      verificationDate:
          JsonUtils.asDateTimeNullable(json['fecha_verificacion']),
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
