from django.contrib import admin
from .models import Reservation, ReservationStatus

admin.site.register(ReservationStatus)
admin.site.register(Reservation)
