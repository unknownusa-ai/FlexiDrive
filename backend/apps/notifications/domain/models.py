from django.db import models


class NotificationCategory(models.Model):
	id = models.AutoField(primary_key=True, db_column='categoria_notificacion_id')
	name = models.CharField(max_length=120, verbose_name='nombre')
	description = models.CharField(max_length=255, blank=True, null=True, verbose_name='descripcion')
	created_at = models.DateTimeField(auto_now_add=True)
	updated_at = models.DateTimeField(auto_now=True)

	class Meta:
		db_table = 'categoria_notificacion'
		verbose_name = 'Categoria de notificacion'
		verbose_name_plural = 'Categorias de notificacion'

	def __str__(self):
		return self.name


class Notification(models.Model):
	STATUS_UNREAD = 'no_leida'
	STATUS_READ = 'leida'
	STATUS_CHOICES = [
		(STATUS_UNREAD, 'No leida'),
		(STATUS_READ, 'Leida'),
	]

	id = models.AutoField(primary_key=True, db_column='notificacion_id')
	user = models.ForeignKey(
		'accounts.User',
		on_delete=models.CASCADE,
		related_name='notifications',
		db_column='usuario_id',
	)
	category = models.ForeignKey(
		'notifications.NotificationCategory',
		on_delete=models.CASCADE,
		related_name='notifications',
		db_column='categoria_notificacion_id',
	)
	subject = models.CharField(max_length=255, verbose_name='asunto')
	description = models.CharField(max_length=255, verbose_name='descripcion')
	status = models.CharField(max_length=20, choices=STATUS_CHOICES, default=STATUS_UNREAD, verbose_name='estado')
	sent_at = models.DateTimeField(verbose_name='fecha_envio')
	created_at = models.DateTimeField(auto_now_add=True)
	updated_at = models.DateTimeField(auto_now=True)

	class Meta:
		db_table = 'notificacion'
		verbose_name = 'Notificacion'
		verbose_name_plural = 'Notificaciones'

	def __str__(self):
		return f'Notificacion {self.id} - {self.subject}'
