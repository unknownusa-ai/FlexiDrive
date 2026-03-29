from django.db import models


class Opinion(models.Model):
	id = models.AutoField(primary_key=True, db_column='opinion_id')
	rating = models.IntegerField(verbose_name='calificacion')
	description = models.CharField(max_length=255, blank=True, null=True, verbose_name='descripcion')
	created_at = models.DateTimeField(auto_now_add=True)
	updated_at = models.DateTimeField(auto_now=True)

	class Meta:
		db_table = 'opinion'
		verbose_name = 'Opinion'
		verbose_name_plural = 'Opiniones'

	def __str__(self):
		return f'Opinion {self.id} - {self.rating}'


class Review(models.Model):
	id = models.AutoField(primary_key=True, db_column='resena_id')
	user = models.ForeignKey(
		'accounts.User',
		on_delete=models.CASCADE,
		related_name='reviews',
		db_column='usuario_id',
	)
	publication = models.ForeignKey(
		'publications.Publication',
		on_delete=models.CASCADE,
		related_name='reviews',
		db_column='publicacion_id',
	)
	opinion = models.ForeignKey(
		'reviews.Opinion',
		on_delete=models.CASCADE,
		related_name='reviews',
		db_column='opinion_id',
	)
	review_date = models.DateTimeField(verbose_name='fecha')
	created_at = models.DateTimeField(auto_now_add=True)
	updated_at = models.DateTimeField(auto_now=True)

	class Meta:
		db_table = 'resena'
		verbose_name = 'Resena'
		verbose_name_plural = 'Resenas'

	def __str__(self):
		return f'Resena {self.id}'
