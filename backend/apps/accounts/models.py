from django.db import models


class IdentificationType(models.Model):
	id = models.AutoField(primary_key=True, db_column='tipo_identificacion_id')
	name = models.CharField(max_length=120, verbose_name='nombre')
	description = models.CharField(max_length=255, blank=True, null=True, verbose_name='descripcion')
	created_at = models.DateTimeField(auto_now_add=True)
	updated_at = models.DateTimeField(auto_now=True)

	class Meta:
		db_table = 'tipo_identificacion'
		verbose_name = 'Tipo de identificacion'
		verbose_name_plural = 'Tipos de identificacion'

	def __str__(self):
		return self.name


class UserType(models.Model):
	id = models.AutoField(primary_key=True, db_column='tipo_usuario_id')
	name = models.CharField(max_length=120, verbose_name='nombre')
	description = models.CharField(max_length=255, blank=True, null=True, verbose_name='descripcion')
	created_at = models.DateTimeField(auto_now_add=True)
	updated_at = models.DateTimeField(auto_now=True)

	class Meta:
		db_table = 'tipo_usuario'
		verbose_name = 'Tipo de usuario'
		verbose_name_plural = 'Tipos de usuario'

	def __str__(self):
		return self.name


class User(models.Model):
	AUTH_PROVIDER_LOCAL = 'local'
	AUTH_PROVIDER_GOOGLE = 'google'
	AUTH_PROVIDER_CHOICES = [
		(AUTH_PROVIDER_LOCAL, 'Local'),
		(AUTH_PROVIDER_GOOGLE, 'Google'),
	]

	id = models.AutoField(primary_key=True, db_column='usuario_id')
	identification_type = models.ForeignKey(
		'accounts.IdentificationType',
		on_delete=models.CASCADE,
		related_name='users',
		db_column='tipo_identificacion_id',
	)
	identification_number = models.CharField(max_length=50, verbose_name='numero_identificacion')
	user_type = models.ForeignKey(
		'accounts.UserType',
		on_delete=models.CASCADE,
		related_name='users',
		db_column='tipo_usuario_id',
	)
	full_name = models.CharField(max_length=180, verbose_name='nombre_completo')
	email = models.EmailField(max_length=254, unique=True, verbose_name='correo')
	phone = models.CharField(max_length=40, verbose_name='telefono')
	password_hash = models.CharField(max_length=255, verbose_name='contrasena_hash')
	can_publish = models.BooleanField(default=False, verbose_name='puede_publicar')

	profile_photo = models.FileField(upload_to='profiles/photos/', blank=True, null=True)
	address = models.CharField(max_length=255, blank=True, null=True)
	city = models.CharField(max_length=120, blank=True, null=True)
	country = models.CharField(max_length=120, blank=True, null=True)
	date_of_birth = models.DateField(blank=True, null=True)

	last_login = models.DateTimeField(blank=True, null=True)
	is_active = models.BooleanField(default=True)
	is_verified = models.BooleanField(default=False)
	email_verified = models.BooleanField(default=False)
	failed_login_attempts = models.IntegerField(default=0)
	account_locked_until = models.DateTimeField(blank=True, null=True)

	google_id = models.CharField(max_length=255, blank=True, null=True)
	auth_provider = models.CharField(max_length=20, choices=AUTH_PROVIDER_CHOICES, default=AUTH_PROVIDER_LOCAL)
	provider_uid = models.CharField(max_length=255, blank=True, null=True)

	created_at = models.DateTimeField(auto_now_add=True)
	updated_at = models.DateTimeField(auto_now=True)

	class Meta:
		db_table = 'usuarios'
		verbose_name = 'Usuario'
		verbose_name_plural = 'Usuarios'

	def __str__(self):
		return f'{self.full_name} ({self.email})'


class UserPreference(models.Model):
	id = models.AutoField(primary_key=True, db_column='preferencia_usuario_id')
	user = models.ForeignKey(
		'accounts.User',
		on_delete=models.CASCADE,
		related_name='preferences',
		db_column='usuario_id',
	)
	dark_mode = models.BooleanField(default=False, verbose_name='modo_oscuro')
	language = models.CharField(max_length=20, verbose_name='idioma')
	created_at = models.DateTimeField(auto_now_add=True)
	updated_at = models.DateTimeField(auto_now=True)

	class Meta:
		db_table = 'preferencia_usuario'
		verbose_name = 'Preferencia de usuario'
		verbose_name_plural = 'Preferencias de usuario'

	def __str__(self):
		return f'Preferencias de {self.user.full_name}'


class UserSecurity(models.Model):
	id = models.AutoField(primary_key=True, db_column='seguridad_usuario_id')
	user = models.ForeignKey(
		'accounts.User',
		on_delete=models.CASCADE,
		related_name='security_profiles',
		db_column='usuario_id',
	)
	two_factor_verification = models.BooleanField(default=False, verbose_name='verificacion_dos_pasos')
	biometric_access = models.BooleanField(default=False, verbose_name='acceso_biometrico')
	created_at = models.DateTimeField(auto_now_add=True)
	updated_at = models.DateTimeField(auto_now=True)

	class Meta:
		db_table = 'seguridad_usuario'
		verbose_name = 'Seguridad de usuario'
		verbose_name_plural = 'Seguridad de usuarios'

	def __str__(self):
		return f'Seguridad de {self.user.full_name}'
