from django.db import models


class ReservationStatus(models.Model):
	id = models.AutoField(primary_key=True, db_column='estado_reserva_id')
	name = models.CharField(max_length=120, verbose_name='nombre')
	description = models.CharField(max_length=255, blank=True, null=True, verbose_name='descripcion')
	created_at = models.DateTimeField(auto_now_add=True)
	updated_at = models.DateTimeField(auto_now=True)

	class Meta:
		db_table = 'estado_reserva'
		verbose_name = 'Estado de reserva'
		verbose_name_plural = 'Estados de reserva'

	def __str__(self):
		return self.name


class Reservation(models.Model):
	id = models.AutoField(primary_key=True, db_column='reserva_id')
	reservation_code = models.CharField(max_length=100, verbose_name='codigo_reserva')
	user = models.ForeignKey(
		'accounts.User',
		on_delete=models.CASCADE,
		related_name='reservations',
		db_column='usuario_id',
	)
	publication = models.ForeignKey(
		'publications.Publication',
		on_delete=models.CASCADE,
		related_name='reservations',
		db_column='publicacion_id',
	)
	payment_method = models.ForeignKey(
		'payments.PaymentMethod',
		on_delete=models.CASCADE,
		related_name='reservations',
		db_column='metodo_pago_id',
	)
	period_type = models.ForeignKey(
		'publications.PeriodType',
		on_delete=models.CASCADE,
		related_name='reservations',
		db_column='tipo_periodo_id',
	)
	periods_quantity = models.IntegerField(verbose_name='cantidad_periodos')
	start_date = models.DateTimeField(verbose_name='fecha_inicio')
	end_date = models.DateTimeField(verbose_name='fecha_fin')
	pickup_location = models.CharField(max_length=255, verbose_name='ubicacion_recogida')
	return_location = models.CharField(max_length=255, verbose_name='ubicacion_entrega')
	total_value = models.DecimalField(max_digits=10, decimal_places=2, verbose_name='valor_total')
	status = models.ForeignKey(
		'reservations.ReservationStatus',
		on_delete=models.CASCADE,
		related_name='reservations',
		db_column='estado_reserva_id',
	)
	reservation_date = models.DateTimeField(verbose_name='fecha_reserva')
	created_at = models.DateTimeField(auto_now_add=True)
	updated_at = models.DateTimeField(auto_now=True)

	class Meta:
		db_table = 'reserva'
		verbose_name = 'Reserva'
		verbose_name_plural = 'Reservas'

	def __str__(self):
		return f'Reserva {self.reservation_code}'
