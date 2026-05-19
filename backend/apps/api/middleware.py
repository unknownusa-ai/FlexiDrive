import os


class DevCorsMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response
        raw_origins = os.getenv('FLEXIDRIVE_CORS_ALLOWED_ORIGINS', '*')
        self._allow_all = raw_origins.strip() == '*'
        self._allowed_origins = {
            item.strip()
            for item in raw_origins.split(',')
            if item.strip()
        }

    def __call__(self, request):
        if request.method == "OPTIONS":
            from django.http import HttpResponse

            response = HttpResponse()
        else:
            response = self.get_response(request)

        origin = request.headers.get('Origin')
        if self._allow_all:
            response["Access-Control-Allow-Origin"] = "*"
        elif origin and origin in self._allowed_origins:
            response["Access-Control-Allow-Origin"] = origin
            response["Vary"] = "Origin"

        response["Access-Control-Allow-Methods"] = "GET, POST, PUT, PATCH, DELETE, OPTIONS"
        response["Access-Control-Allow-Headers"] = "Authorization, Content-Type"
        return response
