from django.db import models


class OwnerDocumentType(models.Model):
	id = models.AutoField(primary_key=True, db_column='tipo_documento_arrendador_id')
	name = models.CharField(max_length=120, verbose_name='nombre')
	description = models.CharField(max_length=255, blank=True, null=True, verbose_name='descripcion')
	created_at = models.DateTimeField(auto_now_add=True)
	updated_at = models.DateTimeField(auto_now=True)

	class Meta:
		db_table = 'tipo_documento_arrendador'
		verbose_name = 'Tipo de documento de arrendador'
		verbose_name_plural = 'Tipos de documento de arrendador'

	def __str__(self):
		return self.name


class DocumentVerificationStatus(models.Model):
	id = models.AutoField(primary_key=True, db_column='estado_verificacion_documento_id')
	name = models.CharField(max_length=120, verbose_name='nombre')
	description = models.CharField(max_length=255, blank=True, null=True, verbose_name='descripcion')
	created_at = models.DateTimeField(auto_now_add=True)
	updated_at = models.DateTimeField(auto_now=True)

	class Meta:
		db_table = 'estado_verificacion_documento'
		verbose_name = 'Estado de verificacion de documento'
		verbose_name_plural = 'Estados de verificacion de documento'

	def __str__(self):
		return self.name


class OwnerDocument(models.Model):
	id = models.AutoField(primary_key=True, db_column='documento_arrendador_id')
	user = models.ForeignKey(
		'accounts.User',
		on_delete=models.CASCADE,
		related_name='owner_documents',
		db_column='usuario_id',
	)
	owner_document_type = models.ForeignKey(
		'documents.OwnerDocumentType',
		on_delete=models.CASCADE,
		related_name='owner_documents',
		db_column='tipo_documento_arrendador_id',
	)
	verification_status = models.ForeignKey(
		'documents.DocumentVerificationStatus',
		on_delete=models.CASCADE,
		related_name='owner_documents',
		db_column='estado_verificacion_documento_id',
	)
	document_file = models.FileField(upload_to='documents/owners/', verbose_name='url_documento')
	upload_date = models.DateTimeField(verbose_name='fecha_subida')
	verification_date = models.DateTimeField(blank=True, null=True, verbose_name='fecha_verificacion')
	observations = models.CharField(max_length=255, blank=True, null=True, verbose_name='observaciones')

	file_size = models.IntegerField(default=0)
	file_type = models.CharField(max_length=100)
	uploaded_by = models.ForeignKey(
		'accounts.User',
		on_delete=models.CASCADE,
		related_name='uploaded_owner_documents',
	)
	verification_notes = models.CharField(max_length=255, blank=True, null=True)
	verified_by_admin = models.ForeignKey(
		'accounts.User',
		on_delete=models.CASCADE,
		related_name='verified_owner_documents',
		blank=True,
		null=True,
	)
	verified_at = models.DateTimeField(blank=True, null=True)

	created_at = models.DateTimeField(auto_now_add=True)
	updated_at = models.DateTimeField(auto_now=True)

	class Meta:
		db_table = 'documento_arrendador'
		verbose_name = 'Documento de arrendador'
		verbose_name_plural = 'Documentos de arrendador'

	def __str__(self):
		return f'Documento {self.id} - {self.user.full_name}'
