actua como un administrador de base de datos: proyecto heladeria, que entidades se necesitan con su diagrama RED
Como DBA, aquí está el análisis de entidades para el proyecto heladería:

**Entidades principales:**

- `Cliente` — quien realiza el pedido
- `Pedido` — transacción de venta
- `Detalle_Pedido` — líneas del pedido (relación M:N entre pedido y producto)
- `Producto` — los helados y artículos del menú
- `Categoria` — tipo de producto (cono, paleta, sundae, bebida…)
- `Ingrediente` — materia prima
- `Producto_Ingrediente` — composición de cada producto
- `Empleado` — quien atiende o prepara
- `Proveedor` — quien suministra ingredientes
- `Sucursal` — si hay más de una tienda

Ahora el diagrama ERD:**Cardinalidades clave:**
<img width="834" height="726" alt="image" src="https://github.com/user-attachments/assets/deaff60e-7d54-403a-b8b7-fc6ce1a21508" />



- Un `Cliente` puede tener muchos `Pedidos`, pero cada pedido pertenece a uno solo.
- Un `Pedido` tiene uno o más `Detalle_Pedido` (no existe pedido vacío).
- La tabla `Detalle_Pedido` resuelve la relación M:N entre `Pedido` y `Producto`.
- `Producto_Ingrediente` resuelve M:N entre `Producto` e `Ingrediente`, guardando además la cantidad necesaria de cada ingrediente.
- Un `Empleado` pertenece a una `Sucursal`, y cada `Pedido` queda registrado tanto con el empleado que atendió como con la sucursal.

## Tablas
proporciona las entidades con sus atributos y tipo en forma de tabla para cada una de las entidades

<img width="1440" height="3378" alt="image" src="https://github.com/user-attachments/assets/a6e59ca1-d59e-4567-8f84-233e1ca0acdd" />

Algunas decisiones de diseño que vale la pena destacar:

`precio_unitario` en `DETALLE_PEDIDO` se guarda de forma independiente al precio del producto, porque el precio puede cambiar con el tiempo y el pedido histórico debe conservar el valor original de la venta.

`PRODUCTO_INGREDIENTE` tiene una llave primaria compuesta `(id_producto, id_ingrediente)` — no necesita un campo `id` propio ya que la combinación de las dos FK es siempre única.

`stock_minimo` en `INGREDIENTE` permite implementar alertas de reposición sin lógica adicional: basta comparar `stock_actual < stock_minimo`.
