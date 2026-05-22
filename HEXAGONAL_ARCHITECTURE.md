# FlexiDrive - Arquitectura Hexagonal

## Objetivo
Este documento describe cómo está implementado el patrón hexagonal en FlexiDrive y qué reglas se deben mantener para evitar acoplamientos entre capas.

## Estructura por capas

### Backend (Django)
- `domain/`: contratos de negocio (ports) y modelos de dominio.
- `application/use_cases/`: orquesta reglas de negocio; depende solo de puertos de dominio.
- `infrastructure/`: implementaciones concretas (repositorios/servicios) que hablan con ORM/JWT/API.
- `presentation/`: adaptadores HTTP (views/serializers) que validan entrada y llaman casos de uso.

### Frontend (Flutter)
- `domain/`: entidades y puertos.
- `application/use_cases/`: lógica de coordinación de casos de uso; depende de puertos.
- `infrastructure/`: datasources y repositorios concretos.
- `presentation/`: widgets/pages que consumen casos de uso.

## Reglas de dependencia
- Presentación -> Aplicación -> Dominio.
- Infraestructura implementa puertos de Dominio.
- Aplicación no debe importar infraestructura.
- Presentación no debe importar datasources de infraestructura directamente.

## Ajustes aplicados en esta auditoría

### Backend
1. Se desacoplaron casos de uso de `accounts`, `api` y `vehicles` de `infrastructure.dependencies`.
2. La inyección de dependencias se movió al borde de presentación (`views`).
3. Se agregaron docstrings en casos de uso y adaptadores HTTP para clarificar responsabilidades.

### Frontend
1. Se eliminó el acceso directo desde presentación a `LocalAccountDb` en `PublicarVehiculoPage`; ahora usa `AccountAccessUseCase`.
2. Se introdujo `UserPreferencesRepositoryPort` + `UserPreferencesRepositoryImpl` para que `UserPreferencesUseCase` dependa de un puerto.
3. Se introdujo `VehicleCatalogRepositoryPort` + `VehicleCatalogRepositoryImpl` para que `VehicleCatalogUseCase` dependa de un puerto.
4. Se actualizó `InjectionContainer` como composition root, inyectando los nuevos puertos.

## Flujo de integración Frontend <-> Backend
1. La capa `presentation` de Flutter invoca casos de uso.
2. Casos de uso llaman puertos de dominio.
3. Repositorios/datasources de infraestructura consumen `ApiClient`.
4. Backend recibe en `presentation/views`, delega a `application/use_cases`.
5. Casos de uso backend usan puertos; infraestructura resuelve ORM/servicios.
6. Respuesta serializada retorna al frontend.

## Checklist de mantenimiento
- No introducir imports de `infrastructure` dentro de `application`.
- No introducir imports de `infrastructure/datasources` dentro de `presentation`.
- Cuando aparezca una nueva fuente de datos, crear/usar un puerto en `domain/ports`.
- Mantener la composición de dependencias en `InjectionContainer` (frontend) y `views`/dependencies (backend).
