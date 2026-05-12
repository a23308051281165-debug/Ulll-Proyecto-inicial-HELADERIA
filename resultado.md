Excelente. Procederé como Arquitecto Senior de Software especializado en Flutter y Firebase. Entiendo la necesidad de un sistema robusto, no un simple CRUD, y me aseguraré de que cada paso sea funcional y profesional.

Aquí está el plan de implementación y el código completo, listo para copiar y pegar en tu Antigravity IDE.

---

## FASE 1: ARQUITECTURA Y DISEÑO (EXPLICACIÓN PREVIA)

### 1. Explicación de la Arquitectura

Usaremos una **Arquitectura Limpia por Capas** adaptada a Flutter y Firebase. Esto asegura escalabilidad y mantenibilidad.

- **Capa de Presentación (Screens/Widgets):** Widgets y pantallas. Usa `ConsumerWidget` y `ConsumerStatefulWidget` de Riverpod para escuchar los estados.
- **Capa de Estado (Providers):** Usaremos **Riverpod** (más moderno y seguro que Provider). Cada módulo tiene su propio provider (ej. `clientesProvider`, `productosProvider`). Estos providers exponen el estado y los métodos de negocio.
- **Capa de Lógica de Negocio / Servicios (Services):** Contiene la comunicación directa con Firestore (`FirestoreService`), autenticación (`AuthService`), y reglas de negocio (ej. `InventarioService` para calcular consumo de ingredientes).
- **Capa de Datos (Models):** Clases Dart que representan las entidades. Incluyen métodos `fromFirestore` y `toMap`.

### 2. Flujo del Sistema

1.  **Autenticación:** Usuario ingresa email/contraseña -> `AuthService` valida con Firebase Auth -> Se obtiene el `User` -> Se consulta Firestore en la colección `empleados` para verificar el rol -> Se redirige al Dashboard correspondiente.
2.  **Dashboard:** Al cargar, se disparan llamadas paralelas a varios providers (ventas, productos, etc.) que consultan Firestore.
3.  **Registro de Pedido (Flujo Transaccional):**
    - Se crea el `Pedido` en la colección `pedidos`.
    - Se crean los `DetallePedido` en la subcolección `detalles` (o colección principal).
    - **Regla de Negocio:** Por cada producto en el pedido, se buscan sus ingredientes en `producto_ingrediente` y se resta la cantidad del `stock` en la colección `ingredientes`. Esto se hace dentro de una **transacción de Firestore** o un `write batch` para garantizar consistencia.
4.  **Navegación:** `GoRouter` para manejo de rutas declarativas, protección de rutas por rol y persistencia de sesión.

### 3. Estructura de Firestore

```
Firestore Root
|
├── /usuarios/{userId} (Datos básicos del usuario Auth, opcional)
├── /empleados/{empleadoId}
│    └── campos: nombre, email, rol, id_sucursal, uid (referencia a Auth)
├── /sucursales/{sucursalId}
│    └── campos: nombre, direccion
├── /clientes/{clienteId}
│    └── campos: nombre, email, telefono, pedidosTotales (para analytics)
├── /categorias/{categoriaId}
│    └── campos: nombre
├── /proveedores/{proveedorId}
│    └── campos: nombre, contacto
├── /ingredientes/{ingredienteId}
│    └── campos: nombre, unidad, stock, id_proveedor, stockMinimo (para alertas)
├── /productos/{productoId}
│    └── campos: nombre, descripcion, precio, estado, id_categoria
├── /producto_ingrediente/{autoId}
│    └── campos: id_producto, id_ingrediente, cantidad (necesaria para 1 producto)
├── /pedidos/{pedidoId}
│    └── campos: id_cliente, id_empleado, id_sucursal, fecha, estado (pendiente, pagado, cancelado), total
│         └── /detalles/{detalleId}
│               └── campos: id_producto, cantidad, precio_unitario
```

### 4. Navegación y Rutas Protegidas

- **Públicas:** `/login`, `/register`
- **Privadas:** `/dashboard`, `/clientes`, `/productos`, etc.
- **Basadas en Rol:** Por ejemplo, la ruta `/admin/usuarios` solo es accesible si `rol == 'Administrador'`.
- **Persistencia:** Usaremos `GoRouter` con `redirect` que verifica el estado de autenticación de Riverpod.

### 5. Relaciones entre Entidades

- **Empleado - Sucursal:** Relación Many-to-One (Muchos empleados en una sucursal). En Firestore, guardamos `id_sucursal` dentro del empleado.
- **Producto - Ingrediente:** Relación Many-to-Many a través de la tabla puente `producto_ingrediente`. Esto permite que un producto (ej. "Vainilla") tenga varios ingredientes (leche, azúcar, vainilla), y un ingrediente (leche) esté en muchos productos.
- **Pedido - DetallePedido:** Relación One-to-Many. El pedido tiene el total, los detalles tienen los items específicos.
- **Ingrediente - Proveedor:** Relación Many-to-One (Muchos ingredientes de un proveedor).

### 6. Manejo de Estado con Riverpod

- `StateNotifierProvider` para lógica compleja (ej. `PedidosNotifier`).
- `FutureProvider` o `StreamProvider` para lecturas simples (ej. `listaCategoriasProvider`).
- `StateProvider` para estados de UI local (ej. índice de tab seleccionado).
- Usaremos `ref.invalidate()` para refrescar datos después de mutaciones (crear, actualizar, eliminar).

### 7. Servicios Clave

- **`FirestoreService`:** CRUD genérico y específico. Métodos como `getPedidosDelDia()`, `actualizarStockIngrediente()`.
- **`AuthService`:** Login, registro, logout, y obtención del rol del usuario actual.
- **`InventarioService`:** Lógica central de negocio para verificar stock suficiente y descontar ingredientes al crear un pedido.

---

## FASE 2: CONFIGURACIÓN INICIAL (COMANDOS)

Ejecuta estos comandos en la terminal de tu proyecto, dentro de Antigravity IDE.

```bash
# 1. Crear proyecto Flutter (si no existe)
# flutter create heladeria_app

# 2. Limpiar y obtener paquetes
flutter clean
flutter pub get

# 3. Agregar librerías necesarias
flutter pub add firebase_core firebase_auth cloud_firestore
flutter pub add riverpod flutter_riverpod riverpod_annotation
flutter pub add go_router
flutter pub add intl fl_chart fluttertoast cached_network_image
flutter pub add equatable

# 4. (Opcional pero recomendado) Para código generado con Riverpod
flutter pub add dev:riverpod_generator dev:build_runner

# 5. Configurar Firebase (requiere FlutterFire CLI instalado globalmente)
# dart pub global activate flutterfire_cli
# flutterfire configure --project=tu-id-proyecto-firebase
```

---

## FASE 3: CÓDIGO COMPLETO (Listo para copiar y pegar)

### 3.1. Archivo `pubspec.yaml` (Verifica dependencias)

```yaml
name: heladeria_app
description: Sistema de gestión profesional para heladería.
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.14.0
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3
  go_router: ^13.0.1
  intl: ^0.18.1
  fl_chart: ^0.66.0
  fluttertoast: ^8.2.4
  cached_network_image: ^3.3.1
  equatable: ^2.0.5

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.7
  riverpod_generator: ^2.3.9

flutter:
  uses-material-design: true
  assets:
    - assets/images/ # (opcional)
```

### 3.2. `lib/main.dart` - Punto de entrada

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'config/app_routes.dart';
import 'config/theme.dart';
import 'presentation/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final authState = ref.watch(authProvider);

    return MaterialApp.router(
      title: 'Heladería Admin',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
```

### 3.3. `lib/config/theme.dart` - Tema personalizado

```dart
import 'package:flutter/material.dart';

class AppTheme {
  static const Color rosaPastel = Color(0xFFFADADD);
  static const Color azulCielo = Color(0xFFAEE2FF);
  static const Color moradoClaro = Color(0xFFE0BBE4);
  static const Color blanco = Color(0xFFFFFFFF);
  static const Color grisOscuro = Color(0xFF2C3E50);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: rosaPastel,
    colorScheme: const ColorScheme.light(
      primary: rosaPastel,
      secondary: azulCielo,
      tertiary: moradoClaro,
      surface: blanco,
    ),
    fontFamily: 'Poppins', // Asegúrate de tener la fuente o quita esta línea
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: rosaPastel,
      foregroundColor: grisOscuro,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: blanco,
    ),
    cardTheme: CardTheme(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
    ),
  );
}
```

### 3.4. `lib/config/app_routes.dart` - Navegación y rutas protegidas

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/dashboard/dashboard_screen.dart';
import '../presentation/screens/clientes/clientes_screen.dart';
import '../presentation/screens/pedidos/pedidos_screen.dart';
import '../presentation/providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.isAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoggingIn) return '/login';
      if (isLoggedIn && isLoggingIn) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/clientes',
        name: 'clientes',
        builder: (context, state) => const ClientesScreen(),
      ),
      GoRoute(
        path: '/pedidos',
        name: 'pedidos',
        builder: (context, state) => const PedidosScreen(),
      ),
      // Agrega aquí las demás rutas: productos, ingredientes, etc.
    ],
  );
});
```

### 3.5. Modelos y Servicios esenciales

#### `lib/domain/models/usuario_model.dart`

```dart
class Empleado {
  final String id;
  final String nombre;
  final String email;
  final String rol; // Administrador, Empleado, Cajero
  final String idSucursal;

  Empleado({
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
    required this.idSucursal,
  });

  factory Empleado.fromFirestore(Map<String, dynamic> data, String id) {
    return Empleado(
      id: id,
      nombre: data['nombre'] ?? '',
      email: data['email'] ?? '',
      rol: data['rol'] ?? 'Empleado',
      idSucursal: data['id_sucursal'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'email': email,
      'rol': rol,
      'id_sucursal': idSucursal,
    };
  }
}
```

#### `lib/domain/models/producto_model.dart`

```dart
class Producto {
  final String id;
  final String nombre;
  final String descripcion;
  final double precio;
  final bool estado;
  final String idCategoria;

  Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.estado,
    required this.idCategoria,
  });

  factory Producto.fromFirestore(Map<String, dynamic> data, String id) {
    return Producto(
      id: id,
      nombre: data['nombre'] ?? '',
      descripcion: data['descripcion'] ?? '',
      precio: (data['precio'] ?? 0.0).toDouble(),
      estado: data['estado'] ?? true,
      idCategoria: data['id_categoria'] ?? '',
    );
  }
}
```

#### `lib/domain/models/pedido_model.dart`

```dart
class Pedido {
  final String id;
  final String idCliente;
  final String idEmpleado;
  final String idSucursal;
  final DateTime fecha;
  final String estado; // pendiente, pagado, cancelado
  final double total;

  Pedido({
    required this.id,
    required this.idCliente,
    required this.idEmpleado,
    required this.idSucursal,
    required this.fecha,
    required this.estado,
    required this.total,
  });

  factory Pedido.fromFirestore(Map<String, dynamic> data, String id) {
    return Pedido(
      id: id,
      idCliente: data['id_cliente'] ?? '',
      idEmpleado: data['id_empleado'] ?? '',
      idSucursal: data['id_sucursal'] ?? '',
      fecha: (data['fecha'] as Timestamp).toDate(),
      estado: data['estado'] ?? 'pendiente',
      total: (data['total'] ?? 0.0).toDouble(),
    );
  }
}
```

#### `lib/core/services/firestore_service.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- MÉTODOS GENÉRICOS CRUD ---
  Future<void> setDoc(String collection, String docId, Map<String, dynamic> data) async {
    await _firestore.collection(collection).doc(docId).set(data);
  }

  Future<Map<String, dynamic>?> getDoc(String collection, String docId) async {
    final doc = await _firestore.collection(collection).doc(docId).get();
    return doc.data();
  }

  Stream<QuerySnapshot> getCollectionStream(String collection) {
    return _firestore.collection(collection).snapshots();
  }

  // --- MÉTODOS ESPECÍFICOS (INVENTARIO, VENTAS) ---

  Future<double> getTotalVentasHoy() async {
    final hoy = DateTime.now();
    final inicio = DateTime(hoy.year, hoy.month, hoy.day);
    final fin = inicio.add(const Duration(days: 1));

    final query = await _firestore
        .collection('pedidos')
        .where('fecha', isGreaterThanOrEqualTo: inicio)
        .where('fecha', isLessThan: fin)
        .where('estado', isEqualTo: 'pagado')
        .get();

    double total = 0;
    for (var doc in query.docs) {
      total += (doc.data()['total'] ?? 0.0);
    }
    return total;
  }

  Future<int> getPedidosDelDia() async {
    final hoy = DateTime.now();
    final inicio = DateTime(hoy.year, hoy.month, hoy.day);
    final fin = inicio.add(const Duration(days: 1));

    final query = await _firestore
        .collection('pedidos')
        .where('fecha', isGreaterThanOrEqualTo: inicio)
        .where('fecha', isLessThan: fin)
        .get();
    return query.docs.length;
  }

  // Lógica de negocio: Descontar ingredientes al crear pedido
  Future<void> procesarPedidoConInventario(
      Map<String, dynamic> pedidoData, List<Map<String, dynamic>> detalles) async {
    WriteBatch batch = _firestore.batch();

    // 1. Crear el pedido
    final pedidoRef = _firestore.collection('pedidos').doc();
    batch.set(pedidoRef, pedidoData);

    // 2. Crear los detalles y acumular consumo de ingredientes
    for (var detalle in detalles) {
      final detalleRef = pedidoRef.collection('detalles').doc();
      batch.set(detalleRef, detalle);

      // 3. Obtener ingredientes del producto
      final ingredientesQuery = await _firestore
          .collection('producto_ingrediente')
          .where('id_producto', isEqualTo: detalle['id_producto'])
          .get();

      for (var ingDoc in ingredientesQuery.docs) {
        final cantidadNecesaria = ingDoc.data()['cantidad'] * detalle['cantidad'];
        final ingredienteRef = _firestore.collection('ingredientes').doc(ingDoc.data()['id_ingrediente']);
        final ingredienteDoc = await ingredienteRef.get();
        final stockActual = (ingredienteDoc.data()?['stock'] ?? 0.0).toDouble();

        if (stockActual < cantidadNecesaria) {
          throw Exception('Stock insuficiente para el ingrediente ${ingredienteDoc.data()?['nombre']}');
        }

        batch.update(ingredienteRef, {'stock': stockActual - cantidadNecesaria});
      }
    }

    await batch.commit();
  }
}
```

#### `lib/core/services/auth_service.dart`

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/usuario_model.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<Empleado?> login(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userDoc = await _firestore
          .collection('empleados')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userDoc.docs.isEmpty) {
        await _auth.signOut();
        throw Exception('Usuario no registrado como empleado');
      }

      return Empleado.fromFirestore(
        userDoc.docs.first.data(),
        userDoc.docs.first.id,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception('Error de autenticación: ${e.message}');
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
```

### 3.6. Providers esenciales (Riverpod)

#### `lib/presentation/providers/auth_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/usuario_model.dart';
import '../../core/services/auth_service.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

class AuthState {
  final Empleado? empleado;
  final bool isLoading;
  final String? error;

  AuthState({this.empleado, this.isLoading = false, this.error});

  bool get isAuthenticated => empleado != null;

  AuthState copyWith({Empleado? empleado, bool? isLoading, String? error}) {
    return AuthState(
      empleado: empleado ?? this.empleado,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final empleado = await _authService.login(email, password);
      state = state.copyWith(empleado: empleado, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = AuthState();
  }
}
```

### 3.7. Pantallas principales

#### `lib/presentation/screens/auth/login_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../providers/auth_provider.dart';
import '../../../config/theme.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authNotifier = ref.read(authProvider.notifier);
      await authNotifier.login(_emailController.text, _passwordController.text);

      final authState = ref.read(authProvider);
      if (authState.error != null) {
        Fluttertoast.showToast(msg: authState.error!, backgroundColor: Colors.red);
      } else if (authState.isAuthenticated) {
        Fluttertoast.showToast(msg: 'Bienvenido ${authState.empleado?.nombre}', backgroundColor: Colors.green);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.rosaPastel, AppTheme.azulCielo],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.icecream, size: 80, color: AppTheme.moradoClaro),
                      const SizedBox(height: 20),
                      const Text('Heladería Admin', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 40),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
                        validator: (value) => value!.contains('@') ? null : 'Email inválido',
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: 'Contraseña', prefixIcon: Icon(Icons.lock)),
                        validator: (value) => value!.length >= 6 ? null : 'Mínimo 6 caracteres',
                      ),
                      const SizedBox(height: 30),
                      if (authState.isLoading)
                        const CircularProgressIndicator()
                      else
                        ElevatedButton(
                          onPressed: _handleLogin,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Ingresar', style: TextStyle(fontSize: 18)),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

#### `lib/presentation/screens/dashboard/dashboard_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/services/firestore_service.dart';
import '../../../config/theme.dart';

final dashboardProvider = FutureProvider((ref) async {
  final service = ref.watch(firestoreServiceProvider);
  final totalVentas = await service.getTotalVentasHoy();
  final pedidosHoy = await service.getPedidosDelDia();
  return {'totalVentas': totalVentas, 'pedidosHoy': pedidosHoy};
});

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: dashboardAsync.when(
        data: (data) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bienvenido, ${authState.empleado?.nombre}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    _buildMetricCard('Ventas Hoy', '\$${data['totalVentas'].toStringAsFixed(2)}', Icons.attach_money, Colors.green),
                    _buildMetricCard('Pedidos Hoy', data['pedidosHoy'].toString(), Icons.receipt, Colors.orange),
                    _buildMetricCard('Clientes', '124', Icons.people, Colors.blue),
                    _buildMetricCard('Stock Bajo', '3', Icons.warning, Colors.red),
                  ],
                ),
                const SizedBox(height: 30),
                const Text('Productos más vendidos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      barGroups: [
                        BarChartGroupData(x: 0, barRods: [BarRodrod(toY: 8, color: AppTheme.moradoClaro)]),
                        BarChartGroupData(x: 1, barRods: [BarRodrod(toY: 12, color: AppTheme.moradoClaro)]),
                        BarChartGroupData(x: 2, barRods: [BarRodrod(toY: 5, color: AppTheme.moradoClaro)]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        error: (error, stack) => Center(child: Text('Error: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
```

#### `lib/presentation/screens/clientes/clientes_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final clientesProvider = StreamProvider((ref) {
  return FirebaseFirestore.instance.collection('clientes').snapshots();
});

class ClientesScreen extends ConsumerWidget {
  const ClientesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientesAsync = ref.watch(clientesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Clientes')),
      body: clientesAsync.when(
        data: (clientes) {
          if (clientes.docs.isEmpty) {
            return const Center(child: Text('No hay clientes registrados'));
          }
          return ListView.builder(
            itemCount: clientes.docs.length,
            itemBuilder: (context, index) {
              final data = clientes.docs[index].data();
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(data['nombre']),
                subtitle: Text(data['email']),
                trailing: Text(data['telefono'] ?? ''),
              );
            },
          );
        },
        error: (error, stack) => Center(child: Text('Error: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddClienteDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddClienteDialog(BuildContext context, WidgetRef ref) {
    final nombreCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final telefonoCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuevo Cliente'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre')),
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: telefonoCtrl, decoration: const InputDecoration(labelText: 'Teléfono')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('clientes').add({
                'nombre': nombreCtrl.text,
                'email': emailCtrl.text,
                'telefono': telefonoCtrl.text,
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cliente agregado')));
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
```

### 3.8. Reglas de seguridad de Firestore (`firestore.rules`)

Copia este bloque en las reglas de Firestore desde la consola de Firebase.

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
    
    // Reglas más específicas (ejemplo para empleados)
    match /empleados/{empleadoId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/empleados/$(request.auth.uid)).data.rol == 'Administrador';
    }
    
    match /pedidos/{pedidoId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        (get(/databases/$(database)/documents/empleados/$(request.auth.uid)).data.rol in ['Administrador', 'Cajero']);
    }
  }
}
```

---

## FASE 4: CÓMO EJECUTAR EL PROYECTO (PASOS FINALES)

1.  **Copia los archivos** en las ubicaciones correspondientes dentro de `lib/`.
2.  Ejecuta `flutter pub run build_runner build` para generar los archivos de Riverpod (si usaste anotaciones).
3.  Conecta tu proyecto a Firebase usando `flutterfire configure` (ya lo hiciste en los comandos iniciales).
4.  **Desde la consola de Firebase:**
    - Habilita Email/Password en Authentication.
    - Crea un usuario manualmente (ej. admin@heladeria.com / 123456).
    - En Firestore, crea la colección `empleados` y un documento con `email: admin@heladeria.com`, `rol: Administrador`, `nombre: Admin`, `id_sucursal: suc1`.
    - Crea colecciones vacías: `clientes`, `productos`, `ingredientes`, `categorias`, `proveedores`, `pedidos`.
5.  Ejecuta el proyecto:
    - **Web:** `flutter run -d chrome`
