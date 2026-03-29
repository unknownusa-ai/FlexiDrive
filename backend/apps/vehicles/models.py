from django.db import models


class VehicleCategory(models.Model):
	id = models.AutoField(primary_key=True, db_column='categoria_vehiculo_id')
	name = models.CharField(max_length=120, verbose_name='nombre')
	description = models.CharField(max_length=255, blank=True, null=True, verbose_name='descripcion')
	created_at = models.DateTimeField(auto_now_add=True)
	updated_at = models.DateTimeField(auto_now=True)

	class Meta:
		db_table = 'categoria_vehiculo'
		verbose_name = 'Categoria de vehiculo'
		verbose_name_plural = 'Categorias de vehiculo'

	def __str__(self):
		return self.name


class Vehicle(models.Model):
	id = models.AutoField(primary_key=True, db_column='vehiculo_id')
	category = models.ForeignKey(
		'vehicles.VehicleCategory',
		on_delete=models.CASCADE,
		related_name='vehicles',
		db_column='categoria_vehiculo_id',
	)
	line = models.CharField(max_length=120, verbose_name='linea')
	model_year = models.IntegerField(verbose_name='modelo')
	color = models.CharField(max_length=60, verbose_name='color')
	seats = models.IntegerField(verbose_name='asientos')
	transmission_type = models.CharField(max_length=60, verbose_name='tipo_transmision')
	air_conditioning = models.BooleanField(default=False, verbose_name='aire_acondicionado')
	fuel_type = models.CharField(max_length=60, verbose_name='tipo_combustible')
	description = models.CharField(max_length=255, blank=True, null=True, verbose_name='descripcion')
	created_at = models.DateTimeField(auto_now_add=True)
	updated_at = models.DateTimeField(auto_now=True)

	class Meta:
		db_table = 'vehiculo'
		verbose_name = 'Vehiculo'
		verbose_name_plural = 'Vehiculos'

	def __str__(self):
		return f'{self.line} {self.model_year}'
