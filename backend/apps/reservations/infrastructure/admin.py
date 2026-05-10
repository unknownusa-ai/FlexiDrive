from django.contrib import admin

from apps.reservations.models import Reservation, ReservationStatus

admin.site.register(ReservationStatus)
admin.site.register(Reservation)
