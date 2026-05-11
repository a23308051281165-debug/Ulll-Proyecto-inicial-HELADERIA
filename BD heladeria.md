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

¿Quieres que profundice en alguna tabla, genere el script SQL de creación, o agreguemos entidades adicionales como `Descuentos`, `Inventario de sucursal` o `Métodos de pago`?
