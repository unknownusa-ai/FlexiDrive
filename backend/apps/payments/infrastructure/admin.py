from django.contrib import admin

from apps.payments.models import Bank, Card, CardBrand, PSE, PaymentMethod, PaymentMethodType, PersonType

admin.site.register(PaymentMethodType)
admin.site.register(Bank)
admin.site.register(CardBrand)
admin.site.register(PersonType)
admin.site.register(PaymentMethod)
admin.site.register(Card)
admin.site.register(PSE)
