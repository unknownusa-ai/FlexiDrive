from django.db import models


class PeriodType(models.Model):
	id = models.AutoField(primary_key=True, db_column='tipo_periodo_id')
	name = models.CharField(max_length=120, verbose_name='nombre')
	description = models.CharField(max_length=255, blank=True, null=True, verbose_name='descripcion')
	created_at = models.DateTimeField(auto_now_add=True)
	updated_at = models.DateTimeField(auto_now=True)

	class Meta:
		db_table = 'tipo_periodo'
		verbose_name = 'Tipo de periodo'
		verbose_name_plural = 'Tipos de periodo'

	def __str__(self):
		return self.name


class Publication(models.Model):
	id = models.AutoField(primary_key=True, db_column='publicacion_id')
	user = models.ForeignKey(
		'accounts.User',
		on_delete=models.CASCADE,
		related_name='publications',
		db_column='usuario_id',
	)
	vehicle = models.ForeignKey(
		'vehicles.Vehicle',
		on_delete=models.CASCADE,
		related_name='publications',
		db_column='vehiculo_id',
	)
	publication_date = models.DateTimeField(verbose_name='fecha_publicacion')
	is_active = models.BooleanField(default=True, verbose_name='activa')
	created_at = models.DateTimeField(auto_now_add=True)
	updated_at = models.DateTimeField(auto_now=True)

	class Meta:
		db_table = 'publicacion'
		verbose_name = 'Publicacion'
		verbose_name_plural = 'Publicaciones'

	def __str__(self):
		return f'Publicacion #{self.id} - {self.user.full_name}'


class PublicationPrice(models.Model):
	id = models.AutoField(primary_key=True, db_column='precio_publicacion_id')
	publication = models.ForeignKey(
		'publications.Publication',
		on_delete=models.CASCADE,
		related_name='prices',
		db_column='publicacion_id',
	)
	period_type = models.ForeignKey(
		'publications.PeriodType',
		on_delete=models.CASCADE,
		related_name='publication_prices',
		db_column='tipo_periodo_id',
	)
	price = models.DecimalField(max_digits=10, decimal_places=2, verbose_name='precio')
	created_at = models.DateTimeField(auto_now_add=True)
	updated_at = models.DateTimeField(auto_now=True)

	class Meta:
		db_table = 'precio_publicacion'
		verbose_name = 'Precio de publicacion'
		verbose_name_plural = 'Precios de publicacion'

	def __str__(self):
		return f'{self.publication_id} - {self.period_type.name}: {self.price}'


class PublicationImage(models.Model):
	id = models.AutoField(primary_key=True, db_column='imagen_publicacion_id')
	publication = models.ForeignKey(
		'publications.Publication',
		on_delete=models.CASCADE,
		related_name='images',
		db_column='publicacion_id',
	)
	image = models.FileField(upload_to='publications/images/', verbose_name='url_imagen')
	order = models.IntegerField(verbose_name='orden')
	is_main = models.BooleanField(default=False, verbose_name='es_principal')
	uploaded_at = models.DateTimeField(verbose_name='fecha_subida')
	created_at = models.DateTimeField(auto_now_add=True)
	updated_at = models.DateTimeField(auto_now=True)

	class Meta:
		db_table = 'imagen_publicacion'
		verbose_name = 'Imagen de publicacion'
		verbose_name_plural = 'Imagenes de publicacion'

	def __str__(self):
		return f'Imagen {self.id} de publicacion {self.publication_id}'
