# 🚗 FlexiDrive

FlexiDrive es una aplicación móvil de alquiler de vehículos por horas, diseñada para ofrecer movilidad flexible, rápida y completamente digital.

A diferencia del modelo tradicional de renta por días, FlexiDrive permite pagar únicamente por el tiempo exacto de uso, optimizando costos y mejorando la experiencia del usuario.

# 🎯 Objetivo del Proyecto

Desarrollar una solución tecnológica que permita gestionar el alquiler de vehículos por horas, facilitando:

Reservas en tiempo real

Control de disponibilidad

Cálculo automático de tarifas

Gestión eficiente de la flota

# 🚀 Funcionalidades Principales
Usuario

Registro e inicio de sesión

Visualización de vehículos disponibles

Reserva por horas

Cálculo automático del costo total

Historial de alquileres

Cancelación de reservas

# 🛠 Administrador

Gestión de vehículos

Configuración de tarifa por hora

Control de disponibilidad

Supervisión de reservas

Gestión de usuarios

# 🏗️ Arquitectura del Sistema

Aplicación móvil (Frontend)

API / Backend

Base de datos

Sistema de autenticación

Módulo de cálculo de tarifas por hora

## 📚 Documentación Técnica

- Arquitectura hexagonal y reglas de capas:
  - `docs/HEXAGONAL_ARCHITECTURE.md`
- Inventario completo de clases del proyecto:
  - `docs/CLASS_INDEX.md`
- Guía de grabación y walkthrough técnico (guion + arquitectura + Provider + SharedPreferences):
  - `GUIA_VIDEO_FLEXIDRIVE.md`

# 🛠️ Tecnologías Utilizadas

Flutter

Dart

Git & GitHub

PostgreSQL / MongoDB

# 🐘 pgAdmin en Docker

Se agregó un contenedor de pgAdmin conectado a la misma red Docker del proyecto (`flexidrive_network`) para administrar PostgreSQL desde interfaz web.

## Variables de entorno

En tu archivo `.env` (raíz del proyecto), puedes definir:

PGADMIN_DEFAULT_EMAIL=admin@flexidrive.com
PGADMIN_DEFAULT_PASSWORD=admin123
PGADMIN_PORT=5050

Si no las defines, Docker Compose usa esos valores por defecto.

## Levantar servicios

Desde la raíz del proyecto:

```bash
docker compose up -d db pgadmin backend
```

## Acceso a pgAdmin

- URL: http://localhost:5050
- Email: valor de `PGADMIN_DEFAULT_EMAIL`
- Password: valor de `PGADMIN_DEFAULT_PASSWORD`

## Registrar servidor PostgreSQL en pgAdmin

Al iniciar sesión en pgAdmin, crea un servidor con estos datos:

- Name: FlexiDrive DB
- Hostname/address: db
- Port: 5432
- Maintenance database: valor de `POSTGRES_DB`
- Username: valor de `POSTGRES_USER`
- Password: valor de `POSTGRES_PASSWORD`

Usar `db` como host funciona porque pgAdmin y PostgreSQL están en la misma red Docker.

## 🌐 Frontend Flutter Web en Docker

Se agregó el contenedor `frontend` para ejecutar Flutter en modo web dentro de Docker y poder verlo desde el navegador.

### Levantar frontend + backend

```bash
docker compose up -d db backend frontend
```

### URL de acceso

- Frontend Web: http://localhost:3000
- Backend API: http://localhost:8000

### Probar vista móvil en navegador

1. Abrir `http://localhost:3000` en Chrome o Edge.
2. Presionar `F12` para abrir DevTools.
3. Activar el ícono de dispositivo móvil (Toggle device toolbar).
4. Elegir un modelo (iPhone, Pixel, etc.) para simular pantalla móvil.

## ✅ Checklist de producción

Antes de publicar, define estas variables en `.env`:

```bash
DJANGO_DEBUG=False
DJANGO_SECRET_KEY=<clave-larga-segura>
JWT_SIGNING_KEY=<clave-jwt-32+-caracteres>
DJANGO_ALLOWED_HOSTS=tu-dominio.com,api.tu-dominio.com
DJANGO_CSRF_TRUSTED_ORIGINS=https://tu-dominio.com,https://api.tu-dominio.com
FLEXIDRIVE_CORS_ALLOWED_ORIGINS=https://tu-dominio.com,https://app.tu-dominio.com
DJANGO_SECURE_SSL_REDIRECT=True
DJANGO_SESSION_COOKIE_SECURE=True
DJANGO_CSRF_COOKIE_SECURE=True
DJANGO_SECURE_HSTS_SECONDS=31536000
DJANGO_SECURE_HSTS_INCLUDE_SUBDOMAINS=True
DJANGO_SECURE_HSTS_PRELOAD=True
```

Levantar servicios en modo producción:

```bash
docker compose up -d --build db backend frontend
```

Si es una base de datos nueva, carga catálogos y datos base:

```bash
docker compose exec -T backend sh -lc "python manage.py shell < scripts/seed_demo_data.py"
```

Validación rápida:

```bash
curl http://localhost:8000/api/health
```
