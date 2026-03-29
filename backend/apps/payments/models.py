from django.db import models


class PaymentMethodType(models.Model):
	id = models.AutoField(primary_key=True, db_column='tipo_metodo_pago_id')
	name = models.CharField(max_length=120, verbose_name='nombre')
	description = models.CharField(max_length=255, blank=True, null=True, verbose_name='descripcion')
	created_at = models.DateTimeField(auto_now_add=True)
	updated_at = models.DateTimeField(auto_now=True)

	class Meta:
		db_table = 'tipo_metodo_pago'
		verbose_name = 'Tipo de metodo de pago'
		verbose_name_plural = 'Tipos de metodo de pago'

	def __str__(self):
		return self.name


class Bank(models.Model):
	id = models.AutoField(primary_key=True, db_column='banco_id')
	name = models.CharField(max_length=120, verbose_name='nombre')
	description = models.CharField(max_length=255, blank=True, null=True, verbose_name='descripcion')
	created_at = models.DateTimeField(auto_now_add=True)
	updated_at = models.DateTimeField(auto_now=True)

	class Meta:
		db_table = 'banco'
		verbose_name = 'Banco'
		verbose_name_plural = 'Bancos'

	def __str__(self):
		return self.name


class CardBrand(models.Model):
	id = models.AutoField(primary_key=True, db_column='marca_tarjeta_id')
	name = models.CharField(max_length=120, verbose_name='nombre')
	description = models.CharField(max_length=255, blank=True, null=True, verbose_name='descripcion')
	created_at = models.DateTimeField(auto_now_add=True)
	updated_at = models.DateTimeField(auto_now=True)

	class Meta:
		db_table = 'marca_tarjeta'
		verbose_name = 'Marca de tarjeta'
		verbose_name_plural = 'Marcas de tarjeta'

	def __str__(self):
		return self.name


class PersonType(models.Model):
	id = models.AutoField(primary_key=True, db_column='tipo_persona_id')
	name = models.CharField(max_length=120, verbose_name='nombre')
	description = models.CharField(max_length=255, blank=True, null=True, verbose_name='descripcion')
	created_at = models.DateTimeField(auto_now_add=True)
	updated_at = models.DateTimeField(auto_now=True)

	class Meta:
		db_table = 'tipo_persona'
		verbose_name = 'Tipo de persona'
		verbose_name_plural = 'Tipos de persona'

	def __str__(self):
		return self.name


class PaymentMethod(models.Model):
	id = models.AutoField(primary_key=True, db_column='metodo_pago_id')
	user = models.ForeignKey(
		'accounts.User',
		on_delete=models.CASCADE,
		related_name='payment_methods',
		db_column='usuario_id',
	)
	payment_method_type = models.ForeignKey(
		'payments.PaymentMethodType',
		on_delete=models.CASCADE,
		related_name='payment_methods',
		db_column='tipo_metodo_pago_id',
	)
	is_default = models.BooleanField(default=False, verbose_name='predeterminado')
	created_at = models.DateTimeField(auto_now_add=True)
	updated_at = models.DateTimeField(auto_now=True)

	class Meta:
		db_table = 'metodo_pago'
		verbose_name = 'Metodo de pago'
		verbose_name_plural = 'Metodos de pago'

	def __str__(self):
		return f'{self.user.full_name} - {self.payment_method_type.name}'


class Card(models.Model):
	id = models.AutoField(primary_key=True, db_column='tarjeta_id')
	payment_method = models.ForeignKey(
		'payments.PaymentMethod',
		on_delete=models.CASCADE,
		related_name='cards',
		db_column='metodo_pago_id',
	)
	card_brand = models.ForeignKey(
		'payments.CardBrand',
		on_delete=models.CASCADE,
		related_name='cards',
		db_column='marca_tarjeta_id',
	)
	last4 = models.CharField(max_length=4, verbose_name='ultimos_4_digitos')
	tokenized_card_reference = models.CharField(max_length=255, verbose_name='referencia_tokenizada')
	expiration_month = models.IntegerField(verbose_name='mes_expiracion')
	expiration_year = models.IntegerField(verbose_name='ano_expiracion')
	created_at = models.DateTimeField(auto_now_add=True)
	updated_at = models.DateTimeField(auto_now=True)

	class Meta:
		db_table = 'tarjeta'
		verbose_name = 'Tarjeta'
		verbose_name_plural = 'Tarjetas'

	def __str__(self):
		return f'{self.card_brand.name} ****{self.last4}'


class PSE(models.Model):
	id = models.AutoField(primary_key=True, db_column='pse_id')
	payment_method = models.ForeignKey(
		'payments.PaymentMethod',
		on_delete=models.CASCADE,
		related_name='pse_accounts',
		db_column='metodo_pago_id',
	)
	bank = models.ForeignKey(
		'payments.Bank',
		on_delete=models.CASCADE,
		related_name='pse_accounts',
		db_column='banco_id',
	)
	person_type = models.ForeignKey(
		'payments.PersonType',
		on_delete=models.CASCADE,
		related_name='pse_accounts',
		db_column='tipo_persona_id',
	)
	created_at = models.DateTimeField(auto_now_add=True)
	updated_at = models.DateTimeField(auto_now=True)

	class Meta:
		db_table = 'pse'
		verbose_name = 'Cuenta PSE'
		verbose_name_plural = 'Cuentas PSE'

	def __str__(self):
		return f'PSE {self.bank.name} - {self.payment_method.user.full_name}'
