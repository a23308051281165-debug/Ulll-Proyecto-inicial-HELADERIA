-- =============================================================
--  BASE DE DATOS: BD_heladeria
--  Proyecto    : Sistema de gestión para heladería
--  Entidades   : 10 (8 tablas principales + 2 tablas de relación M:N)
--  Motor       : MySQL 8.0+
-- =============================================================

-- -------------------------------------------------------------
-- Crear y seleccionar la base de datos
-- -------------------------------------------------------------
DROP DATABASE IF EXISTS BD_heladeria;
CREATE DATABASE BD_heladeria
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE BD_heladeria;

-- =============================================================
-- 1. SUCURSAL
--    Catálogo de tiendas / puntos de venta
-- =============================================================
CREATE TABLE SUCURSAL (
    id_sucursal   INT            NOT NULL AUTO_INCREMENT,
    nombre        VARCHAR(100)   NOT NULL,
    direccion     VARCHAR(255)   NOT NULL,
    telefono      VARCHAR(15)        NULL,
    activa        BOOLEAN        NOT NULL DEFAULT TRUE,
    CONSTRAINT pk_sucursal PRIMARY KEY (id_sucursal)
) ENGINE=InnoDB;

-- =============================================================
-- 2. PROVEEDOR
--    Empresas o personas que suministran ingredientes
-- =============================================================
CREATE TABLE PROVEEDOR (
    id_proveedor  INT            NOT NULL AUTO_INCREMENT,
    nombre        VARCHAR(120)   NOT NULL,
    contacto      VARCHAR(100)       NULL COMMENT 'Nombre del representante',
    telefono      VARCHAR(15)        NULL,
    email         VARCHAR(150)       NULL,
    direccion     VARCHAR(255)       NULL,
    CONSTRAINT pk_proveedor PRIMARY KEY (id_proveedor)
) ENGINE=InnoDB;

-- =============================================================
-- 3. CATEGORIA
--    Tipos de productos: cono, paleta, sundae, bebida, etc.
-- =============================================================
CREATE TABLE CATEGORIA (
    id_categoria  INT            NOT NULL AUTO_INCREMENT,
    nombre        VARCHAR(60)    NOT NULL,
    descripcion   VARCHAR(200)       NULL,
    CONSTRAINT pk_categoria PRIMARY KEY (id_categoria)
) ENGINE=InnoDB;

-- =============================================================
-- 4. EMPLEADO
--    Personal que atiende o produce en cada sucursal
-- =============================================================
CREATE TABLE EMPLEADO (
    id_empleado   INT            NOT NULL AUTO_INCREMENT,
    id_sucursal   INT            NOT NULL,
    nombre        VARCHAR(100)   NOT NULL,
    apellido      VARCHAR(100)   NOT NULL,
    rol           ENUM('cajero','heladero','gerente','repartidor')
                                 NOT NULL DEFAULT 'cajero',
    fecha_ingreso DATE           NOT NULL,
    activo        BOOLEAN        NOT NULL DEFAULT TRUE,
    CONSTRAINT pk_empleado    PRIMARY KEY (id_empleado),
    CONSTRAINT fk_emp_suc     FOREIGN KEY (id_sucursal)
        REFERENCES SUCURSAL(id_sucursal)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- =============================================================
-- 5. CLIENTE
--    Personas que realizan pedidos
-- =============================================================
CREATE TABLE CLIENTE (
    id_cliente      INT            NOT NULL AUTO_INCREMENT,
    nombre          VARCHAR(100)   NOT NULL,
    email           VARCHAR(150)       NULL,
    telefono        VARCHAR(15)        NULL,
    fecha_registro  DATE           NOT NULL DEFAULT (CURRENT_DATE),
    CONSTRAINT pk_cliente  PRIMARY KEY (id_cliente),
    CONSTRAINT uq_cli_email UNIQUE (email)
) ENGINE=InnoDB;

-- =============================================================
-- 6. PRODUCTO
--    Helados y artículos disponibles en el menú
-- =============================================================
CREATE TABLE PRODUCTO (
    id_producto   INT            NOT NULL AUTO_INCREMENT,
    id_categoria  INT            NOT NULL,
    nombre        VARCHAR(100)   NOT NULL,
    descripcion   TEXT               NULL,
    precio        DECIMAL(8,2)   NOT NULL,
    estado        ENUM('activo','inactivo')
                                 NOT NULL DEFAULT 'activo',
    CONSTRAINT pk_producto    PRIMARY KEY (id_producto),
    CONSTRAINT fk_prod_cat    FOREIGN KEY (id_categoria)
        REFERENCES CATEGORIA(id_categoria)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- =============================================================
-- 7. INGREDIENTE
--    Materia prima usada en la elaboración de productos
-- =============================================================
CREATE TABLE INGREDIENTE (
    id_ingrediente  INT            NOT NULL AUTO_INCREMENT,
    id_proveedor    INT                NULL,
    nombre          VARCHAR(100)   NOT NULL,
    unidad_medida   VARCHAR(20)    NOT NULL COMMENT 'kg, lt, pza, etc.',
    stock_actual    DECIMAL(10,3)  NOT NULL DEFAULT 0,
    stock_minimo    DECIMAL(10,3)  NOT NULL DEFAULT 0
                                   COMMENT 'Umbral de alerta de reposición',
    CONSTRAINT pk_ingrediente PRIMARY KEY (id_ingrediente),
    CONSTRAINT fk_ing_prov    FOREIGN KEY (id_proveedor)
        REFERENCES PROVEEDOR(id_proveedor)
        ON UPDATE CASCADE
        ON DELETE SET NULL
) ENGINE=InnoDB;

-- =============================================================
-- 8. PEDIDO
--    Transacción de venta generada por un cliente
-- =============================================================
CREATE TABLE PEDIDO (
    id_pedido     INT            NOT NULL AUTO_INCREMENT,
    id_cliente    INT            NOT NULL,
    id_empleado   INT            NOT NULL,
    id_sucursal   INT            NOT NULL,
    fecha         DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado        ENUM('pendiente','en_preparacion','listo','entregado','cancelado')
                                 NOT NULL DEFAULT 'pendiente',
    total         DECIMAL(10,2)  NOT NULL DEFAULT 0.00
                                 COMMENT 'Se actualiza vía trigger o lógica de negocio',
    CONSTRAINT pk_pedido      PRIMARY KEY (id_pedido),
    CONSTRAINT fk_ped_cli     FOREIGN KEY (id_cliente)
        REFERENCES CLIENTE(id_cliente)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_ped_emp     FOREIGN KEY (id_empleado)
        REFERENCES EMPLEADO(id_empleado)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_ped_suc     FOREIGN KEY (id_sucursal)
        REFERENCES SUCURSAL(id_sucursal)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- =============================================================
-- 9. DETALLE_PEDIDO  [tabla de relación PEDIDO ↔ PRODUCTO]
--    Líneas de cada pedido con precio histórico
-- =============================================================
CREATE TABLE DETALLE_PEDIDO (
    id_detalle      INT            NOT NULL AUTO_INCREMENT,
    id_pedido       INT            NOT NULL,
    id_producto     INT            NOT NULL,
    cantidad        INT            NOT NULL CHECK (cantidad >= 1),
    precio_unitario DECIMAL(8,2)   NOT NULL
                                   COMMENT 'Precio vigente al momento de la venta',
    subtotal        DECIMAL(10,2)  NOT NULL
                                   COMMENT 'cantidad × precio_unitario',
    CONSTRAINT pk_detalle     PRIMARY KEY (id_detalle),
    CONSTRAINT fk_det_ped     FOREIGN KEY (id_pedido)
        REFERENCES PEDIDO(id_pedido)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_det_prod    FOREIGN KEY (id_producto)
        REFERENCES PRODUCTO(id_producto)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- =============================================================
-- 10. PRODUCTO_INGREDIENTE  [tabla de relación PRODUCTO ↔ INGREDIENTE]
--     Receta: cuánto de cada ingrediente lleva cada producto
-- =============================================================
CREATE TABLE PRODUCTO_INGREDIENTE (
    id_producto     INT            NOT NULL,
    id_ingrediente  INT            NOT NULL,
    cantidad        DECIMAL(8,3)   NOT NULL
                                   COMMENT 'Cantidad del ingrediente por porción del producto',
    CONSTRAINT pk_prod_ing    PRIMARY KEY (id_producto, id_ingrediente),
    CONSTRAINT fk_pi_prod     FOREIGN KEY (id_producto)
        REFERENCES PRODUCTO(id_producto)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_pi_ing      FOREIGN KEY (id_ingrediente)
        REFERENCES INGREDIENTE(id_ingrediente)
        ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- =============================================================
-- ÍNDICES ADICIONALES (mejoran el rendimiento en consultas frecuentes)
-- =============================================================
CREATE INDEX idx_pedido_cliente   ON PEDIDO (id_cliente);
CREATE INDEX idx_pedido_fecha     ON PEDIDO (fecha);
CREATE INDEX idx_detalle_pedido   ON DETALLE_PEDIDO (id_pedido);
CREATE INDEX idx_detalle_producto ON DETALLE_PEDIDO (id_producto);
CREATE INDEX idx_ingrediente_prov ON INGREDIENTE (id_proveedor);
CREATE INDEX idx_producto_cat     ON PRODUCTO (id_categoria);
CREATE INDEX idx_empleado_suc     ON EMPLEADO (id_sucursal);

-- =============================================================
-- DATOS DE PRUEBA
-- =============================================================

-- Sucursales
INSERT INTO SUCURSAL (nombre, direccion, telefono) VALUES
  ('Sucursal Centro',   'Av. Juárez 100, Centro',         '6561001001'),
  ('Sucursal Norte',    'Blvd. Independencia 450, Norte',  '6561001002');

-- Proveedores
INSERT INTO PROVEEDOR (nombre, contacto, telefono, email) VALUES
  ('Lácteos del Norte',  'Carlos Méndez', '6562001001', 'carlos@lacteosnorte.mx'),
  ('Frutas Frescas SA',  'Laura Ruiz',    '6562001002', 'laura@frutasfrescas.mx'),
  ('Distribuidora Fría', 'Pedro Salcedo', '6562001003', 'pedro@distrifria.mx');

-- Categorías
INSERT INTO CATEGORIA (nombre, descripcion) VALUES
  ('Cono',    'Helado servido en cono de galleta o azúcar'),
  ('Paleta',  'Paleta de hielo o cremosa'),
  ('Sundae',  'Copa de helado con toppings'),
  ('Bebida',  'Malteadas, licuados y bebidas frías');

-- Empleados
INSERT INTO EMPLEADO (id_sucursal, nombre, apellido, rol, fecha_ingreso) VALUES
  (1, 'Ana',    'Torres',   'gerente',   '2022-01-10'),
  (1, 'Luis',   'Ramos',    'cajero',    '2023-03-15'),
  (1, 'María',  'Flores',   'heladero',  '2023-05-20'),
  (2, 'Jorge',  'Pérez',    'gerente',   '2022-02-01'),
  (2, 'Sofía',  'Guzmán',   'cajero',    '2023-07-08');

-- Clientes
INSERT INTO CLIENTE (nombre, email, telefono) VALUES
  ('Juan García',      'juan.garcia@mail.com',   '6561110001'),
  ('Paola Herrera',    'paola.h@mail.com',        '6561110002'),
  ('Roberto Núñez',    NULL,                      '6561110003');

-- Productos
INSERT INTO PRODUCTO (id_categoria, nombre, descripcion, precio) VALUES
  (1, 'Cono de vainilla',       'Cono azúcar con 1 bola de vainilla',     35.00),
  (1, 'Cono de chocolate',      'Cono azúcar con 1 bola de chocolate',    35.00),
  (1, 'Cono doble fresa',       'Cono azúcar con 2 bolas de fresa',       50.00),
  (2, 'Paleta de mango',        'Paleta de hielo sabor mango natural',    20.00),
  (2, 'Paleta cremosa nuez',    'Paleta cremosa con nuez',                25.00),
  (3, 'Sundae clásico',         'Helado vainilla, chocolate, fresa',      70.00),
  (3, 'Sundae brownie',         'Sundae con brownie y cajeta',            85.00),
  (4, 'Malteada de vainilla',   'Malteada 400 ml',                        60.00),
  (4, 'Malteada de fresa',      'Malteada 400 ml sabor fresa',            60.00);

-- Ingredientes
INSERT INTO INGREDIENTE (id_proveedor, nombre, unidad_medida, stock_actual, stock_minimo) VALUES
  (1, 'Leche entera',        'lt',  50.000, 10.000),
  (1, 'Crema para batir',    'lt',  20.000,  5.000),
  (1, 'Base de helado vainilla', 'kg', 15.000, 3.000),
  (1, 'Base de helado chocolate','kg',12.000, 3.000),
  (2, 'Pulpa de fresa',      'kg',  10.000,  2.000),
  (2, 'Pulpa de mango',      'kg',   8.000,  2.000),
  (2, 'Nuez picada',         'kg',   3.000,  0.500),
  (3, 'Cono de azúcar',      'pza', 200.000, 50.000),
  (3, 'Palito de madera',    'pza', 300.000, 50.000),
  (1, 'Cajeta',              'kg',   5.000,  1.000);

-- Recetas (PRODUCTO_INGREDIENTE)
INSERT INTO PRODUCTO_INGREDIENTE (id_producto, id_ingrediente, cantidad) VALUES
  -- Cono de vainilla
  (1, 3, 0.100), (1, 8, 1.000),
  -- Cono de chocolate
  (2, 4, 0.100), (2, 8, 1.000),
  -- Cono doble fresa
  (3, 5, 0.080), (3, 1, 0.050), (3, 8, 1.000),
  -- Paleta de mango
  (4, 6, 0.100), (4, 9, 1.000),
  -- Paleta cremosa nuez
  (5, 3, 0.080), (5, 2, 0.030), (5, 7, 0.020), (5, 9, 1.000),
  -- Sundae clásico
  (6, 3, 0.080), (6, 4, 0.050), (6, 5, 0.050),
  -- Sundae brownie
  (7, 3, 0.100), (7, 10, 0.040),
  -- Malteada de vainilla
  (8, 1, 0.250), (8, 3, 0.120), (8, 2, 0.050),
  -- Malteada de fresa
  (9, 1, 0.250), (9, 5, 0.100), (9, 2, 0.050);

-- Pedidos
INSERT INTO PEDIDO (id_cliente, id_empleado, id_sucursal, fecha, estado, total) VALUES
  (1, 2, 1, '2025-05-01 10:30:00', 'entregado', 105.00),
  (2, 2, 1, '2025-05-01 11:15:00', 'entregado',  70.00),
  (3, 5, 2, '2025-05-02 14:00:00', 'entregado',  80.00),
  (1, 5, 2, '2025-05-03 09:45:00', 'cancelado',   0.00);

-- Detalles de pedidos
INSERT INTO DETALLE_PEDIDO (id_pedido, id_producto, cantidad, precio_unitario, subtotal) VALUES
  -- Pedido 1
  (1, 1, 1, 35.00,  35.00),
  (1, 6, 1, 70.00,  70.00),
  -- Pedido 2
  (2, 6, 1, 70.00,  70.00),
  -- Pedido 3
  (3, 8, 1, 60.00,  60.00),
  (3, 4, 1, 20.00,  20.00),
  -- Pedido 4 (cancelado, sin detalle)
  (4, 3, 0, 50.00,   0.00);

-- =============================================================
-- VISTAS ÚTILES
-- =============================================================

-- Resumen de ventas por producto
CREATE OR REPLACE VIEW v_ventas_por_producto AS
SELECT
    p.nombre                        AS producto,
    c.nombre                        AS categoria,
    SUM(d.cantidad)                 AS unidades_vendidas,
    SUM(d.subtotal)                 AS ingreso_total
FROM DETALLE_PEDIDO d
JOIN PRODUCTO  p ON p.id_producto  = d.id_producto
JOIN CATEGORIA c ON c.id_categoria = p.id_categoria
JOIN PEDIDO    pe ON pe.id_pedido  = d.id_pedido
WHERE pe.estado != 'cancelado'
GROUP BY p.id_producto, p.nombre, c.nombre;

-- Ingredientes con stock bajo
CREATE OR REPLACE VIEW v_stock_bajo AS
SELECT
    i.nombre          AS ingrediente,
    i.stock_actual,
    i.stock_minimo,
    i.unidad_medida,
    pr.nombre         AS proveedor
FROM INGREDIENTE i
LEFT JOIN PROVEEDOR pr ON pr.id_proveedor = i.id_proveedor
WHERE i.stock_actual < i.stock_minimo;

-- Pedidos completos con cliente y sucursal
CREATE OR REPLACE VIEW v_pedidos_completos AS
SELECT
    pe.id_pedido,
    pe.fecha,
    pe.estado,
    pe.total,
    CONCAT(cl.nombre)               AS cliente,
    CONCAT(em.nombre,' ',em.apellido) AS empleado,
    su.nombre                       AS sucursal
FROM PEDIDO pe
JOIN CLIENTE   cl ON cl.id_cliente  = pe.id_cliente
JOIN EMPLEADO  em ON em.id_empleado = pe.id_empleado
JOIN SUCURSAL  su ON su.id_sucursal  = pe.id_sucursal;

-- =============================================================
-- FIN DEL SCRIPT
-- =============================================================
