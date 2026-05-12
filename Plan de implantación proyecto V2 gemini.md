# PROMPT V2 — BAD ICE CREAM
Actúa como un arquitecto senior de software especializado en Flutter, Dart y Firebase.  
Tu objetivo es ayudarme a diseñar y planificar profesionalmente una aplicación multiplataforma llamada “bad ice cream”, enfocada en administración de una heladeria, control de productos, empleados, clientes y sucursales.
La aplicación será desarrollada en Flutter utilizando antigrabity y Firebase en configuración estándar (NO producción), compatible con:
- Android
- Web
- Windows
- iOS
NO quiero código todavía.  
Primero necesito un plan de implementación completo, profesional y humano en formato Markdown.
La aplicación debe estar basada en la siguiente estructura lógica y entidades:
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


# Necesito que generes:
## 1. Descripción general del sistema
Explica de manera profesional y humana cómo funcionará bad ice cream y cuál es su objetivo principal.
## 2. Arquitectura del proyecto
Define:
- Arquitectura recomendada en Flutter
- Organización de carpetas
- Separación frontend/backend
- Manejo de estados
- Estructura escalable
- Buenas prácticas
## 3. Tecnologías necesarias
Explica:
- Flutter
- Dart
- Firebase
- Firestore
- Firebase Authentication
- Firebase Storage
- Provider
- Dependencias necesarias
- Herramientas de desarrollo
## 4. Diseño UI/UX
Describe:
- Estilo visual moderno
- Diseño responsive
- Navegación intuitiva
- Paleta de colores
- Experiencia de usuario
- Diseño para Android/Web/Desktop
## 5. Planeación del desarrollo
Quiero un procedimiento PASO A PASO y humano:
### Fase 1 — Configuración del entorno
### Fase 2 — Configuración de Firebase
### Fase 3 — Diseño de base de datos Firestore
### Fase 4 — Sistema de autenticación
### Fase 5 — Pantallas principales
### Fase 6 — CRUD de entidades
### Fase 7 — Gestión de transacciones
### Fase 8 — Facturación y presupuestos
### Fase 9 — Testing multiplataforma
### Fase 10 — Implantación estándar
Cada fase debe incluir:
- Objetivos
- Herramientas
- Qué se desarrollará
- Buenas prácticas
- Posibles problemas
- Soluciones recomendadas
## 6. Dependencias recomendadas
Genera una lista profesional de dependencias para pubspec.yaml y explica para qué sirve cada una.
## 7. Seguridad y autenticación
Explica:
- Login
- Registro
- Manejo de sesiones
- Seguridad básica en Firebase
- Reglas Firestore
- Roles de usuario
## 8. Flujo de navegación
Describe cómo navegará el usuario entre:
- Login
- Dashboard
- Cuentas
- Categorías
- Presupuestos
- Transacciones
- Facturas
- Perfil
## 9. Plan de implantación
Genera un plan profesional para desplegar la aplicación en modo estándar (NO producción).
Incluye:
- Configuración local
- Compilación
- APK
- Flutter Web
- Windows Desktop
- GitHub
- Control de versiones
## 10. Recomendaciones profesionales
Quiero recomendaciones reales como si fueras un desarrollador senior:
- Organización
- Escalabilidad
- Rendimiento
- Optimización
- UI/UX
- Firebase
- Firestore
- Arquitectura limpia
# IMPORTANTE
- NO generar código todavía
- TODO debe estar en Markdown
- Explica de manera clara, humana y profesional
- Usa lenguaje técnico pero entendible para estudiantes
- El resultado debe parecer un documento profesional de planificación de software
- No resumir
- Sé detallado


