from django.db import models


class UserSession(models.Model):
	id = models.AutoField(primary_key=True, db_column='sesion_usuario_id')
	user = models.ForeignKey(
		'accounts.User',
		on_delete=models.CASCADE,
		related_name='user_sessions',
		db_column='usuario_id',
	)
	device = models.CharField(max_length=255, verbose_name='dispositivo')
	operating_system = models.CharField(max_length=120, verbose_name='sistema_operativo')
	ip_address = models.CharField(max_length=64, verbose_name='direccion_ip')
	start_date = models.DateTimeField(verbose_name='fecha_inicio')
	is_active = models.BooleanField(default=True, verbose_name='activa')
	ended_at = models.DateTimeField(blank=True, null=True)
	created_at = models.DateTimeField(auto_now_add=True)
	updated_at = models.DateTimeField(auto_now=True)

	class Meta:
		db_table = 'sesion_usuario'
		verbose_name = 'Sesion de usuario'
		verbose_name_plural = 'Sesiones de usuario'

	def __str__(self):
		return f'Sesion {self.id} - {self.user.full_name}'


class LoginAttempt(models.Model):
	id = models.AutoField(primary_key=True)
	user = models.ForeignKey(
		'accounts.User',
		on_delete=models.CASCADE,
		related_name='login_attempts',
		db_column='usuario_id',
	)
	email = models.EmailField(max_length=254)
	ip_address = models.CharField(max_length=64)
	user_agent = models.CharField(max_length=255, blank=True, null=True)
	was_successful = models.BooleanField(default=False)
	attempted_at = models.DateTimeField(auto_now_add=True)
	created_at = models.DateTimeField(auto_now_add=True)
	updated_at = models.DateTimeField(auto_now=True)

	class Meta:
		db_table = 'login_attempt'
		verbose_name = 'Intento de inicio de sesion'
		verbose_name_plural = 'Intentos de inicio de sesion'

	def __str__(self):
		return f'Intento {self.id} - {self.email}'


class RefreshToken(models.Model):
	id = models.AutoField(primary_key=True)
	user = models.ForeignKey(
		'accounts.User',
		on_delete=models.CASCADE,
		related_name='refresh_tokens',
		db_column='usuario_id',
	)
	session = models.ForeignKey(
		'security.UserSession',
		on_delete=models.CASCADE,
		related_name='refresh_tokens',
		blank=True,
		null=True,
	)
	token = models.CharField(max_length=512)
	is_revoked = models.BooleanField(default=False)
	expires_at = models.DateTimeField()
	last_used_at = models.DateTimeField(blank=True, null=True)
	created_at = models.DateTimeField(auto_now_add=True)
	updated_at = models.DateTimeField(auto_now=True)

	class Meta:
		db_table = 'refresh_token'
		verbose_name = 'Refresh token'
		verbose_name_plural = 'Refresh tokens'

	def __str__(self):
		return f'Refresh token {self.id} - {self.user.email}'
