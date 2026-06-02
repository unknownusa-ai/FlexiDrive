-- ============================================================================
-- FlexiDrive - Modelo Relacional PostgreSQL
-- ============================================================================
-- Script completo con tablas de negocio principales
-- Nota: Autenticación y tokens se manejan fuera de la BD
-- ============================================================================

-- Crear extensiones necesarias
CREATE EXTENSION IF NOT EXISTS uuid-ossp;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ============================================================================
-- 1. TABLA: usuarios (Users)
-- ============================================================================
-- Almacena información base de usuarios del sistema
CREATE TABLE usuarios (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  nombre VARCHAR(255) NOT NULL,
  apellido VARCHAR(255) NOT NULL,
  telefono VARCHAR(20),
  documento_tipo VARCHAR(50) NOT NULL, -- 'CC', 'CE', 'PASAPORTE', etc.
  documento_numero VARCHAR(50) UNIQUE NOT NULL,
  fecha_nacimiento DATE,
  genero VARCHAR(20), -- 'M', 'F', 'OTRO'
  foto_perfil_url TEXT,
  es_arrendatario BOOLEAN DEFAULT FALSE, -- Puede arrendar vehículos
  es_propietario BOOLEAN DEFAULT FALSE, -- Puede publicar vehículos
  calificacion_promedio DECIMAL(3, 2) DEFAULT 0.0,
  total_resenas INTEGER DEFAULT 0,
  saldo_disponible DECIMAL(15, 2) DEFAULT 0.0,
  saldo_retirado DECIMAL(15, 2) DEFAULT 0.0,
  estado VARCHAR(50) DEFAULT 'activo', -- 'activo', 'suspendido', 'eliminado'
  fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  fecha_eliminacion TIMESTAMP
);

CREATE INDEX idx_usuarios_email ON usuarios(email);
CREATE INDEX idx_usuarios_documento ON usuarios(documento_numero);
CREATE INDEX idx_usuarios_es_arrendatario ON usuarios(es_arrendatario);
CREATE INDEX idx_usuarios_es_propietario ON usuarios(es_propietario);

-- ============================================================================
-- 2. TABLA: direcciones (Addresses)
-- ============================================================================
-- Almacena direcciones de usuarios (múltiples por usuario)
CREATE TABLE direcciones (
  id SERIAL PRIMARY KEY,
  usuario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  tipo VARCHAR(50) NOT NULL, -- 'residencia', 'trabajo', 'otro'
  calle VARCHAR(255) NOT NULL,
  numero VARCHAR(50),
  apartamento VARCHAR(50),
  ciudad VARCHAR(100) NOT NULL,
  departamento VARCHAR(100) NOT NULL,
  codigo_postal VARCHAR(20),
  pais VARCHAR(100) DEFAULT 'Colombia',
  latitud DECIMAL(10, 8),
  longitud DECIMAL(11, 8),
  es_principal BOOLEAN DEFAULT FALSE,
  fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_direcciones_usuario_id ON direcciones(usuario_id);
CREATE INDEX idx_direcciones_tipo ON direcciones(tipo);

-- ============================================================================
-- 3. TABLA: vehiculos (Vehicles)
-- ============================================================================
-- Almacena información de vehículos publicados
CREATE TABLE vehiculos (
  id SERIAL PRIMARY KEY,
  propietario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  placa VARCHAR(20) UNIQUE NOT NULL,
  marca VARCHAR(100) NOT NULL,
  modelo VARCHAR(100) NOT NULL,
  anio INTEGER NOT NULL,
  tipo_vehiculo VARCHAR(50) NOT NULL, -- 'sedan', 'suv', 'camioneta', 'moto', etc.
  color VARCHAR(50),
  numero_puertas INTEGER,
  numero_asientos INTEGER,
  transmision VARCHAR(50), -- 'manual', 'automatica'
  combustible VARCHAR(50), -- 'gasolina', 'diesel', 'hibrido', 'electrico'
  cilindraje INTEGER,
  kilometraje INTEGER,
  numero_serie VARCHAR(100) UNIQUE,
  numero_motor VARCHAR(100) UNIQUE,
  foto_principal_url TEXT,
  descripcion TEXT,
  caracteristicas JSONB, -- aire acondicionado, bluetooth, gps, etc.
  estado_vehiculo VARCHAR(50) DEFAULT 'disponible', -- 'disponible', 'reservado', 'rentado', 'mantenimiento'
  estado_publicacion VARCHAR(50) DEFAULT 'activa', -- 'activa', 'pausada', 'eliminada'
  calificacion_promedio DECIMAL(3, 2) DEFAULT 0.0,
  total_resenas INTEGER DEFAULT 0,
  total_rentales INTEGER DEFAULT 0,
  fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_vehiculos_propietario_id ON vehiculos(propietario_id);
CREATE INDEX idx_vehiculos_placa ON vehiculos(placa);
CREATE INDEX idx_vehiculos_estado_vehiculo ON vehiculos(estado_vehiculo);
CREATE INDEX idx_vehiculos_estado_publicacion ON vehiculos(estado_publicacion);
CREATE INDEX idx_vehiculos_tipo ON vehiculos(tipo_vehiculo);

-- ============================================================================
-- 4. TABLA: fotos_vehiculos (Vehicle Photos)
-- ============================================================================
-- Almacena múltiples fotos por vehículo
CREATE TABLE fotos_vehiculos (
  id SERIAL PRIMARY KEY,
  vehiculo_id INTEGER NOT NULL REFERENCES vehiculos(id) ON DELETE CASCADE,
  url_foto TEXT NOT NULL,
  descripcion VARCHAR(255),
  orden INTEGER DEFAULT 0,
  fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_fotos_vehiculos_vehiculo_id ON fotos_vehiculos(vehiculo_id);

-- ============================================================================
-- 5. TABLA: publicaciones (Publications/Listings)
-- ============================================================================
-- Almacena tarifas y disponibilidad de vehículos
CREATE TABLE publicaciones (
  id SERIAL PRIMARY KEY,
  vehiculo_id INTEGER NOT NULL REFERENCES vehiculos(id) ON DELETE CASCADE,
  propietario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  titulo VARCHAR(255) NOT NULL,
  descripcion TEXT,
  tarifa_por_hora DECIMAL(10, 2) NOT NULL,
  tarifa_por_dia DECIMAL(10, 2),
  tarifa_por_semana DECIMAL(10, 2),
  tarifa_por_mes DECIMAL(10, 2),
  deposito_garantia DECIMAL(10, 2) DEFAULT 0.0,
  seguro_incluido BOOLEAN DEFAULT FALSE,
  combustible_incluido BOOLEAN DEFAULT FALSE,
  kilometraje_ilimitado BOOLEAN DEFAULT FALSE,
  limite_kilometraje_diario INTEGER,
  edad_minimo_conductor INTEGER DEFAULT 18,
  licencia_minima_antiguedad INTEGER DEFAULT 0, -- años
  permitir_viajes_fuera_ciudad BOOLEAN DEFAULT FALSE,
  permitir_viajes_fuera_pais BOOLEAN DEFAULT FALSE,
  reglas_adicionales TEXT,
  estado VARCHAR(50) DEFAULT 'activa', -- 'activa', 'pausada', 'eliminada'
  fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_publicaciones_vehiculo_id ON publicaciones(vehiculo_id);
CREATE INDEX idx_publicaciones_propietario_id ON publicaciones(propietario_id);
CREATE INDEX idx_publicaciones_estado ON publicaciones(estado);

-- ============================================================================
-- 6. TABLA: disponibilidad_calendario (Calendar Availability)
-- ============================================================================
-- Almacena disponibilidad por día para cada publicación
CREATE TABLE disponibilidad_calendario (
  id SERIAL PRIMARY KEY,
  publicacion_id INTEGER NOT NULL REFERENCES publicaciones(id) ON DELETE CASCADE,
  fecha DATE NOT NULL,
  disponible BOOLEAN DEFAULT TRUE,
  razon_no_disponible VARCHAR(255), -- 'mantenimiento', 'reservado', etc.
  fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(publicacion_id, fecha)
);

CREATE INDEX idx_disponibilidad_publicacion_id ON disponibilidad_calendario(publicacion_id);
CREATE INDEX idx_disponibilidad_fecha ON disponibilidad_calendario(fecha);

-- ============================================================================
-- 7. TABLA: reservas (Reservations)
-- ============================================================================
-- Almacena reservas de vehículos
CREATE TABLE reservas (
  id SERIAL PRIMARY KEY,
  publicacion_id INTEGER NOT NULL REFERENCES publicaciones(id) ON DELETE RESTRICT,
  arrendatario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE RESTRICT,
  propietario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE RESTRICT,
  fecha_inicio DATE NOT NULL,
  fecha_fin DATE NOT NULL,
  hora_inicio TIME DEFAULT '08:00:00',
  hora_fin TIME DEFAULT '18:00:00',
  duracion_horas INTEGER,
  duracion_dias INTEGER,
  tarifa_total DECIMAL(15, 2) NOT NULL,
  deposito_garantia DECIMAL(10, 2) DEFAULT 0.0,
  costo_seguro DECIMAL(10, 2) DEFAULT 0.0,
  descuento DECIMAL(10, 2) DEFAULT 0.0,
  monto_final DECIMAL(15, 2) NOT NULL,
  estado_reserva VARCHAR(50) DEFAULT 'pendiente', -- 'pendiente', 'confirmada', 'en_curso', 'completada', 'cancelada'
  motivo_cancelacion VARCHAR(255),
  fecha_cancelacion TIMESTAMP,
  ubicacion_recogida_id INTEGER REFERENCES direcciones(id),
  ubicacion_entrega_id INTEGER REFERENCES direcciones(id),
  notas_arrendatario TEXT,
  notas_propietario TEXT,
  fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_reservas_publicacion_id ON reservas(publicacion_id);
CREATE INDEX idx_reservas_arrendatario_id ON reservas(arrendatario_id);
CREATE INDEX idx_reservas_propietario_id ON reservas(propietario_id);
CREATE INDEX idx_reservas_estado_reserva ON reservas(estado_reserva);
CREATE INDEX idx_reservas_fecha_inicio ON reservas(fecha_inicio);

-- ============================================================================
-- 8. TABLA: pagos (Payments)
-- ============================================================================
-- Almacena información de pagos
CREATE TABLE pagos (
  id SERIAL PRIMARY KEY,
  reserva_id INTEGER NOT NULL REFERENCES reservas(id) ON DELETE CASCADE,
  usuario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  monto DECIMAL(15, 2) NOT NULL,
  tipo_pago VARCHAR(50) NOT NULL, -- 'tarjeta_credito', 'tarjeta_debito', 'transferencia', 'pse', 'billetera'
  metodo_pago_id INTEGER, -- referencia a tabla de métodos de pago
  referencia_externa VARCHAR(255), -- ID de transacción en pasarela de pago
  estado_pago VARCHAR(50) DEFAULT 'pendiente', -- 'pendiente', 'procesando', 'completado', 'fallido', 'reembolsado'
  fecha_pago TIMESTAMP,
  fecha_reembolso TIMESTAMP,
  descripcion TEXT,
  fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_pagos_reserva_id ON pagos(reserva_id);
CREATE INDEX idx_pagos_usuario_id ON pagos(usuario_id);
CREATE INDEX idx_pagos_estado_pago ON pagos(estado_pago);

-- ============================================================================
-- 9. TABLA: metodos_pago (Payment Methods)
-- ============================================================================
-- Almacena métodos de pago registrados por usuario
CREATE TABLE metodos_pago (
  id SERIAL PRIMARY KEY,
  usuario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  tipo_metodo VARCHAR(50) NOT NULL, -- 'tarjeta_credito', 'tarjeta_debito', 'cuenta_bancaria', 'billetera'
  nombre_metodo VARCHAR(255),
  ultimos_digitos VARCHAR(20), -- últimos 4 dígitos de tarjeta o cuenta
  fecha_vencimiento DATE, -- para tarjetas
  es_predeterminado BOOLEAN DEFAULT FALSE,
  estado VARCHAR(50) DEFAULT 'activo', -- 'activo', 'inactivo', 'expirado'
  fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_metodos_pago_usuario_id ON metodos_pago(usuario_id);

-- ============================================================================
-- 10. TABLA: resenas (Reviews)
-- ============================================================================
-- Almacena reseñas entre usuarios y de vehículos
CREATE TABLE resenas (
  id SERIAL PRIMARY KEY,
  reserva_id INTEGER NOT NULL REFERENCES reservas(id) ON DELETE CASCADE,
  autor_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  destinatario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  vehiculo_id INTEGER REFERENCES vehiculos(id) ON DELETE SET NULL,
  tipo_resena VARCHAR(50) NOT NULL, -- 'usuario', 'vehiculo'
  calificacion INTEGER NOT NULL CHECK (calificacion >= 1 AND calificacion <= 5),
  titulo VARCHAR(255),
  comentario TEXT,
  aspectos_positivos JSONB, -- array de aspectos positivos
  aspectos_negativos JSONB, -- array de aspectos negativos
  estado_resena VARCHAR(50) DEFAULT 'publicada', -- 'publicada', 'oculta', 'eliminada'
  fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_resenas_reserva_id ON resenas(reserva_id);
CREATE INDEX idx_resenas_autor_id ON resenas(autor_id);
CREATE INDEX idx_resenas_destinatario_id ON resenas(destinatario_id);
CREATE INDEX idx_resenas_vehiculo_id ON resenas(vehiculo_id);
CREATE INDEX idx_resenas_tipo ON resenas(tipo_resena);

-- ============================================================================
-- 11. TABLA: notificaciones (Notifications)
-- ============================================================================
-- Almacena notificaciones del sistema
CREATE TABLE notificaciones (
  id SERIAL PRIMARY KEY,
  usuario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  tipo_notificacion VARCHAR(100) NOT NULL, -- 'reserva_confirmada', 'pago_recibido', 'resena_recibida', etc.
  titulo VARCHAR(255) NOT NULL,
  mensaje TEXT NOT NULL,
  datos_adicionales JSONB, -- información contextual (reserva_id, usuario_id, etc.)
  leida BOOLEAN DEFAULT FALSE,
  fecha_lectura TIMESTAMP,
  enviada_email BOOLEAN DEFAULT FALSE,
  enviada_push BOOLEAN DEFAULT FALSE,
  fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_notificaciones_usuario_id ON notificaciones(usuario_id);
CREATE INDEX idx_notificaciones_tipo ON notificaciones(tipo_notificacion);
CREATE INDEX idx_notificaciones_leida ON notificaciones(leida);

-- ============================================================================
-- 12. TABLA: transacciones_saldo (Balance Transactions)
-- ============================================================================
-- Registro de movimientos de saldo de usuarios
CREATE TABLE transacciones_saldo (
  id SERIAL PRIMARY KEY,
  usuario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  tipo_transaccion VARCHAR(50) NOT NULL, -- 'deposito', 'retiro', 'pago_reserva', 'reembolso', 'comision'
  monto DECIMAL(15, 2) NOT NULL,
  saldo_anterior DECIMAL(15, 2),
  saldo_posterior DECIMAL(15, 2),
  referencia_id INTEGER, -- ID de reserva, pago, etc.
  descripcion TEXT,
  estado VARCHAR(50) DEFAULT 'completada', -- 'pendiente', 'completada', 'fallida'
  fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_transacciones_saldo_usuario_id ON transacciones_saldo(usuario_id);
CREATE INDEX idx_transacciones_saldo_tipo ON transacciones_saldo(tipo_transaccion);

-- ============================================================================
-- 13. TABLA: documentos_usuario (User Documents)
-- ============================================================================
-- Almacena documentos de verificación de usuarios
CREATE TABLE documentos_usuario (
  id SERIAL PRIMARY KEY,
  usuario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  tipo_documento VARCHAR(50) NOT NULL, -- 'licencia_conduccion', 'cedula', 'pasaporte', 'comprobante_domicilio'
  url_documento TEXT NOT NULL,
  estado_verificacion VARCHAR(50) DEFAULT 'pendiente', -- 'pendiente', 'verificado', 'rechazado'
  motivo_rechazo TEXT,
  fecha_vencimiento DATE,
  fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_documentos_usuario_usuario_id ON documentos_usuario(usuario_id);
CREATE INDEX idx_documentos_usuario_tipo ON documentos_usuario(tipo_documento);

-- ============================================================================
-- 14. TABLA: reportes (Reports/Issues)
-- ============================================================================
-- Almacena reportes de problemas o incidentes
CREATE TABLE reportes (
  id SERIAL PRIMARY KEY,
  usuario_reportante_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  usuario_reportado_id INTEGER REFERENCES usuarios(id) ON DELETE SET NULL,
  vehiculo_id INTEGER REFERENCES vehiculos(id) ON DELETE SET NULL,
  reserva_id INTEGER REFERENCES reservas(id) ON DELETE SET NULL,
  tipo_reporte VARCHAR(100) NOT NULL, -- 'comportamiento_inapropiado', 'daño_vehiculo', 'fraude', 'otro'
  titulo VARCHAR(255) NOT NULL,
  descripcion TEXT NOT NULL,
  evidencias JSONB, -- URLs de fotos, videos
  estado_reporte VARCHAR(50) DEFAULT 'abierto', -- 'abierto', 'en_investigacion', 'resuelto', 'cerrado'
  resolucion TEXT,
  fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_reportes_usuario_reportante_id ON reportes(usuario_reportante_id);
CREATE INDEX idx_reportes_usuario_reportado_id ON reportes(usuario_reportado_id);
CREATE INDEX idx_reportes_tipo ON reportes(tipo_reporte);
CREATE INDEX idx_reportes_estado ON reportes(estado_reporte);

-- ============================================================================
-- 15. TABLA: configuracion_usuario (User Settings)
-- ============================================================================
-- Almacena preferencias y configuraciones de usuario
CREATE TABLE configuracion_usuario (
  id SERIAL PRIMARY KEY,
  usuario_id INTEGER NOT NULL UNIQUE REFERENCES usuarios(id) ON DELETE CASCADE,
  modo_oscuro BOOLEAN DEFAULT FALSE,
  notificaciones_email BOOLEAN DEFAULT TRUE,
  notificaciones_push BOOLEAN DEFAULT TRUE,
  notificaciones_sms BOOLEAN DEFAULT FALSE,
  privacidad_perfil VARCHAR(50) DEFAULT 'publico', -- 'publico', 'privado', 'amigos'
  mostrar_calificacion BOOLEAN DEFAULT TRUE,
  mostrar_numero_telefonico BOOLEAN DEFAULT FALSE,
  permitir_contacto_directo BOOLEAN DEFAULT TRUE,
  idioma VARCHAR(10) DEFAULT 'es',
  moneda VARCHAR(10) DEFAULT 'COP',
  zona_horaria VARCHAR(100) DEFAULT 'America/Bogota',
  fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_configuracion_usuario_usuario_id ON configuracion_usuario(usuario_id);

-- ============================================================================
-- 16. TABLA: historial_cambios (Audit Log)
-- ============================================================================
-- Registro de cambios importantes en el sistema
CREATE TABLE historial_cambios (
  id SERIAL PRIMARY KEY,
  usuario_id INTEGER REFERENCES usuarios(id) ON DELETE SET NULL,
  tabla_afectada VARCHAR(100) NOT NULL,
  registro_id INTEGER,
  tipo_cambio VARCHAR(50) NOT NULL, -- 'INSERT', 'UPDATE', 'DELETE'
  datos_anteriores JSONB,
  datos_nuevos JSONB,
  razon_cambio VARCHAR(255),
  fecha_cambio TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_historial_cambios_usuario_id ON historial_cambios(usuario_id);
CREATE INDEX idx_historial_cambios_tabla ON historial_cambios(tabla_afectada);
CREATE INDEX idx_historial_cambios_fecha ON historial_cambios(fecha_cambio);

-- ============================================================================
-- VISTAS ÚTILES
-- ============================================================================

-- Vista: Resumen de usuario con estadísticas
CREATE OR REPLACE VIEW v_resumen_usuario AS
SELECT
  u.id,
  u.email,
  u.nombre,
  u.apellido,
  u.calificacion_promedio,
  u.total_resenas,
  u.saldo_disponible,
  COUNT(DISTINCT CASE WHEN v.es_propietario THEN v.id END) as total_vehiculos_publicados,
  COUNT(DISTINCT CASE WHEN r.arrendatario_id = u.id THEN r.id END) as total_reservas_como_arrendatario,
  COUNT(DISTINCT CASE WHEN r.propietario_id = u.id THEN r.id END) as total_reservas_como_propietario
FROM usuarios u
LEFT JOIN vehiculos v ON u.id = v.propietario_id
LEFT JOIN reservas r ON u.id = r.arrendatario_id OR u.id = r.propietario_id
WHERE u.estado = 'activo'
GROUP BY u.id, u.email, u.nombre, u.apellido, u.calificacion_promedio, u.total_resenas, u.saldo_disponible;

-- Vista: Vehículos disponibles con información de publicación
CREATE OR REPLACE VIEW v_vehiculos_disponibles AS
SELECT
  v.id,
  v.placa,
  v.marca,
  v.modelo,
  v.anio,
  v.tipo_vehiculo,
  v.calificacion_promedio,
  p.tarifa_por_hora,
  p.tarifa_por_dia,
  u.nombre as propietario_nombre,
  u.calificacion_promedio as propietario_calificacion,
  v.foto_principal_url
FROM vehiculos v
JOIN publicaciones p ON v.id = p.vehiculo_id
JOIN usuarios u ON v.propietario_id = u.id
WHERE v.estado_vehiculo = 'disponible'
  AND p.estado = 'activa'
  AND u.estado = 'activo'
ORDER BY v.calificacion_promedio DESC;

-- Vista: Reservas próximas por confirmar
CREATE OR REPLACE VIEW v_reservas_proximas AS
SELECT
  r.id,
  r.fecha_inicio,
  r.fecha_fin,
  r.monto_final,
  r.estado_reserva,
  u_arrendatario.nombre as arrendatario_nombre,
  u_propietario.nombre as propietario_nombre,
  v.marca,
  v.modelo,
  v.placa
FROM reservas r
JOIN usuarios u_arrendatario ON r.arrendatario_id = u_arrendatario.id
JOIN usuarios u_propietario ON r.propietario_id = u_propietario.id
JOIN publicaciones p ON r.publicacion_id = p.id
JOIN vehiculos v ON p.vehiculo_id = v.id
WHERE r.estado_reserva IN ('pendiente', 'confirmada')
  AND r.fecha_inicio >= CURRENT_DATE
ORDER BY r.fecha_inicio ASC;

-- ============================================================================
-- FUNCIONES ÚTILES
-- ============================================================================

-- Función: Actualizar calificación promedio de usuario
CREATE OR REPLACE FUNCTION actualizar_calificacion_usuario()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE usuarios
  SET calificacion_promedio = (
    SELECT AVG(calificacion)::DECIMAL(3, 2)
    FROM resenas
    WHERE destinatario_id = NEW.destinatario_id
      AND estado_resena = 'publicada'
  ),
  total_resenas = (
    SELECT COUNT(*)
    FROM resenas
    WHERE destinatario_id = NEW.destinatario_id
      AND estado_resena = 'publicada'
  )
  WHERE id = NEW.destinatario_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_actualizar_calificacion_usuario
AFTER INSERT OR UPDATE ON resenas
FOR EACH ROW
EXECUTE FUNCTION actualizar_calificacion_usuario();

-- Función: Actualizar calificación promedio de vehículo
CREATE OR REPLACE FUNCTION actualizar_calificacion_vehiculo()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE vehiculos
  SET calificacion_promedio = (
    SELECT AVG(calificacion)::DECIMAL(3, 2)
    FROM resenas
    WHERE vehiculo_id = NEW.vehiculo_id
      AND tipo_resena = 'vehiculo'
      AND estado_resena = 'publicada'
  ),
  total_resenas = (
    SELECT COUNT(*)
    FROM resenas
    WHERE vehiculo_id = NEW.vehiculo_id
      AND tipo_resena = 'vehiculo'
      AND estado_resena = 'publicada'
  )
  WHERE id = NEW.vehiculo_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_actualizar_calificacion_vehiculo
AFTER INSERT OR UPDATE ON resenas
FOR EACH ROW
WHEN (NEW.tipo_resena = 'vehiculo')
EXECUTE FUNCTION actualizar_calificacion_vehiculo();

-- ============================================================================
-- DATOS DE EJEMPLO (OPCIONAL)
-- ============================================================================

-- Insertar usuario de ejemplo
INSERT INTO usuarios (email, nombre, apellido, documento_tipo, documento_numero, es_arrendatario, es_propietario, estado)
VALUES ('usuario@example.com', 'Juan', 'Pérez', 'CC', '1234567890', TRUE, TRUE, 'activo');

-- Insertar dirección de ejemplo
INSERT INTO direcciones (usuario_id, tipo, calle, numero, ciudad, departamento, es_principal)
VALUES (1, 'residencia', 'Carrera 7', '45-23', 'Bogotá', 'Cundinamarca', TRUE);

-- Insertar vehículo de ejemplo
INSERT INTO vehiculos (propietario_id, placa, marca, modelo, anio, tipo_vehiculo, color, numero_puertas, numero_asientos, transmision, combustible, estado_vehiculo)
VALUES (1, 'ABC123', 'Toyota', 'Corolla', 2022, 'sedan', 'Blanco', 4, 5, 'automatica', 'gasolina', 'disponible');

-- Insertar publicación de ejemplo
INSERT INTO publicaciones (vehiculo_id, propietario_id, titulo, tarifa_por_hora, tarifa_por_dia, deposito_garantia)
VALUES (1, 1, 'Toyota Corolla 2022 - Perfecto para viajes', 50000.00, 300000.00, 500000.00);

-- ============================================================================
-- FIN DEL SCRIPT
-- ============================================================================
