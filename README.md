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

