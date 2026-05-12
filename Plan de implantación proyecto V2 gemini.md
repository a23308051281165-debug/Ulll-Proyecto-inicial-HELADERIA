Actúa como un Arquitecto Senior de Software especializado en Flutter Multiplatform, Firebase y Antigravity IDE.

Objetivo:
Desarrollar un SISTEMA DE GESTIÓN ADMINISTRATIVA PROFESIONAL para una HELADERÍA utilizando Flutter compatible con Android, Web, Windows e iOS.

El sistema debe estar basado en el siguiente modelo ERD empresarial:

# Entidades del sistema

1. Cliente
2. Empleado
3. Sucursal
4. Pedido
5. DetallePedido
6. Producto
7. Categoría
8. Ingrediente
9. Proveedor
10. ProductoIngrediente

El proyecto NO debe ser un CRUD simple.
Debe funcionar como una plataforma administrativa completa, moderna y escalable.

# Tecnologías obligatorias

- Flutter latest stable
- Dart
- Firebase Core
- Firebase Authentication
- Cloud Firestore
- Provider o Riverpod
- Material Design 3
- FlutterFire CLI

# Compatibilidad

- Android
- Web
- Windows
- iOS

# Objetivo general

Desarrollar un sistema de gestión integral para administrar:
- Ventas
- Productos
- Inventario
- Pedidos
- Ingredientes
- Proveedores
- Clientes
- Empleados
- Sucursales

# Sistema de autenticación

Implementar login profesional con:
- Email y contraseña
- Roles de usuario
- Persistencia de sesión
- Logout
- Validación de formularios
- Protección de rutas

# Roles

- Administrador
- Empleado
- Cajero

# Dashboard administrativo

Crear un panel moderno con:
- Total de ventas
- Pedidos del día
- Productos más vendidos
- Stock bajo
- Empleados activos
- Clientes registrados
- Estadísticas visuales
- Gráficas dinámicas
- Accesos rápidos

# Módulo Clientes

## Colección: clientes

Campos:
- id_cliente
- nombre
- email
- telefono

Funciones:
- Registrar clientes
- Buscar clientes
- Historial de pedidos
- Clientes frecuentes

# Módulo Sucursales

## Colección: sucursales

Campos:
- id_sucursal
- nombre
- direccion

Funciones:
- Gestión de sucursales
- Asociar empleados
- Asociar pedidos

# Módulo Empleados

## Colección: empleados

Campos:
- id_empleado
- id_sucursal
- nombre
- rol

Funciones:
- Gestión de empleados
- Control de roles
- Asociación a sucursales

# Módulo Categorías

## Colección: categorias

Campos:
- id_categoria
- nombre

Funciones:
- Clasificación de productos
- Filtros por categoría

# Módulo Productos

## Colección: productos

Campos:
- id_producto
- id_categoria
- nombre
- descripcion
- precio
- estado

Funciones:
- Gestión de productos
- Catálogo visual
- Activar/desactivar productos
- Búsqueda dinámica
- Asociación con ingredientes

# Módulo Ingredientes

## Colección: ingredientes

Campos:
- id_ingrediente
- id_proveedor
- nombre
- unidad
- stock

Funciones:
- Control de inventario
- Stock disponible
- Alertas de stock bajo

# Módulo Proveedores

## Colección: proveedores

Campos:
- id_proveedor
- nombre
- contacto

Funciones:
- Gestión de proveedores
- Asociación con ingredientes

# Relación ProductoIngrediente

## Colección: producto_ingrediente

Campos:
- id_producto
- id_ingrediente
- cantidad

Funciones:
- Relación entre productos e ingredientes
- Control de consumo
- Cálculo automático de inventario

# Módulo Pedidos

## Colección: pedidos

Campos:
- id_pedido
- id_cliente
- id_empleado
- id_sucursal
- fecha
- estado
- total

Funciones:
- Registrar pedidos
- Actualizar estados
- Calcular total automático
- Asociar cliente y empleado
- Historial de ventas

# Módulo DetallePedido

## Colección: detalle_pedido

Campos:
- id_detalle
- id_pedido
- id_producto
- cantidad
- precio_unitario

Funciones:
- Agregar productos a pedidos
- Calcular subtotales
- Mostrar ticket digital

# Arquitectura profesional

Organizar carpetas así:

lib/
 ├── main.dart
 ├── config/
 ├── core/
 ├── models/
 ├── services/
 ├── providers/
 ├── screens/
 │    ├── auth/
 │    ├── dashboard/
 │    ├── clientes/
 │    ├── empleados/
 │    ├── sucursales/
 │    ├── productos/
 │    ├── categorias/
 │    ├── ingredientes/
 │    ├── proveedores/
 │    ├── pedidos/
 │    └── reportes/
 ├── widgets/
 ├── routes/
 ├── themes/
 └── utils/

# Diseño UI/UX

Implementar:
- Material Design 3
- Responsive Design
- Sidebar para escritorio
- BottomNavigationBar móvil
- Cards modernas
- Tablas visuales
- FloatingActionButton
- Dashboard profesional
- Animaciones suaves

# Colores

Tema inspirado en heladería moderna:
- Rosa pastel
- Azul cielo
- Blanco
- Morado claro

# Librerías necesarias

Agregar:
- firebase_core
- firebase_auth
- cloud_firestore
- provider
- intl
- fluttertoast
- fl_chart
- cached_network_image

# Funciones avanzadas

Implementar:
- Búsquedas en tiempo real
- Filtros dinámicos
- Reportes
- Gráficas
- Validaciones
- Manejo de errores
- Estados vacíos
- Loading indicators
- Persistencia offline

# Firebase

Configurar:
- Firebase Authentication
- Firestore Database
- Reglas de seguridad
- Persistencia offline

# Firestore Rules

Permitir acceso únicamente a usuarios autenticados.

# Implementación profesional

ANTES de generar código:
1. Explicar arquitectura
2. Explicar flujo del sistema
3. Explicar estructura Firestore
4. Explicar navegación
5. Explicar relaciones entre entidades
6. Explicar manejo de estado
7. Explicar servicios

DESPUÉS:
- Generar código completo
- Archivos separados
- Código funcional
- Compatible con Antigravity IDE
- Sin pseudocódigo
- Sin omitir imports

# Resultado esperado

Un sistema empresarial profesional de gestión para heladería compatible con:
- Android
- Web
- Windows
- iOS

Con Firebase Authentication y Firestore completamente funcionales.
