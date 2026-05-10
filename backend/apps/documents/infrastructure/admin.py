from django.contrib import admin

from apps.documents.models import DocumentVerificationStatus, OwnerDocument, OwnerDocumentType

admin.site.register(OwnerDocumentType)
admin.site.register(DocumentVerificationStatus)
admin.site.register(OwnerDocument)
