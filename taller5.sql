CREATE TABLE clientes (
	id INTEGER NOT NULL PRIMARY KEY,
	nombre VARCHAR,
	edad INTEGER,
	correo VARCHAR
);
CREATE TABLE productos (
	codigo INTEGER NOT NULL PRIMARY KEY,
	nombre VARCHAR,
	stock INTEGER,
	valor_unitario NUMERIC
);
CREATE TABLE facturas (
	id INTEGER NOT NULL PRIMARY KEY,
	fecha DATE,
	cantidad INTEGER,
	valor_total INTEGER,
	pedido_estado VARCHAR,
	producto_id INTEGER,
	cliente_id INTEGER,
	foreign key (producto_id) references productos(codigo),
	foreign key (cliente_id) references clientes(id)
);
CREATE TABLE auditoria (
	id INTEGER NOT NULL PRIMARY KEY,
	fecha_inicio DATE,
	fecha_final DATE,
	factura_id INTEGER,
	pedido_estado VARCHAR
);

INSERT INTO clientes (nombre, id, edad, correo) VALUES ('Juan', 1, 20, 'juan@gmail.com');
INSERT INTO clientes (nombre, id, edad, correo) VALUES ('Santiago', 2, 22, 'santi@gmail.com');
INSERT INTO clientes (nombre, id, edad, correo) VALUES ('Elsa', 3, 45, 'elsa@gmail.com');

INSERT INTO productos (nombre, codigo, stock, valor_unitario) VALUES ('pollo', 1, 5, 20000);
INSERT INTO productos (nombre, codigo, stock, valor_unitario) VALUES ('carne', 2, 7, 18000);
INSERT INTO productos (nombre, codigo, stock, valor_unitario) VALUES ('arroz', 3, 22, 5000);

INSERT INTO facturas (id, fecha, cantidad, valor_total, pedido_estado, producto_id, cliente_id) VALUES (1, CAST('2020-10-29' AS date), 3, 60000, 'ENTREGADO', 1, 1);
INSERT INTO facturas (id, fecha, cantidad, valor_total, pedido_estado, producto_id, cliente_id) VALUES (2, CAST('2022-02-19' AS date), 3, 15000, 'BLOQUEADO', 3, 3);
INSERT INTO facturas (id, fecha, cantidad, valor_total, pedido_estado, producto_id, cliente_id) VALUES (3, CAST('2024-07-12' AS date), 1, 18000, 'PENDIENTE', 2, 2);


CREATE OR REPLACE PROCEDURE obtener_total_stock ()
LANGUAGE plpgsql
AS $$
DECLARE 
	v_total_stock INTEGER :=0;
	v_stock_actual INTEGER;
	v_nombre_producto VARCHAR;
BEGIN
	
	FOR v_nombre_producto, v_stock_actual IN SELECT nombre, stock FROM productos LOOP
		RAISE NOTICE 'el nombre del producto es: %', v_nombre_producto;
		RAISE NOTICE 'el stock actual del producto es: %', v_stock_actual;
		v_total_stock = v_total_stock + v_stock_actual;
	END LOOP;

	RAISE NOTICE 'el stock total es de: %', v_total_stock;

END;
$$;

CALL obtener_total_stock();

CREATE OR REPLACE PROCEDURE generar_auditoria(
	p_fecha_inicio DATE,
	p_fecha_final DATE
)
LANGUAGE plpgsql
AS $$
DECLARE 
	v_id_counter INTEGER :=0;
	v_factura_id INTEGER;
	v_factura_fecha DATE;
	v_factura_estado_pedido VARCHAR;
BEGIN
	FOR v_factura_id, v_factura_fecha, v_factura_estado_pedido IN SELECT id, fecha, pedido_estado FROM facturas LOOP
		IF v_factura_fecha >= p_fecha_inicio AND v_factura_fecha <= p_fecha_final THEN
			INSERT INTO auditoria (id, fecha_inicio, fecha_final, factura_id, pedido_estado) VALUES (v_id_counter, p_fecha_inicio, p_fecha_final, v_factura_id, v_factura_estado_pedido);
			v_id_counter = v_id_counter + 1;
		END IF;
	END LOOP;
END;
$$;


CALL generar_auditoria(CAST('2020-10-28' AS date), CAST('2022-02-20' AS date)); 


CREATE OR REPLACE PROCEDURE simular_ventas_mes()
LANGUAGE plpgsql
AS $$
DECLARE 
	dia INTEGER :=1;
	id_cliente INTEGER;
	cantidad_vendida INTEGER;
	producto_vendido INTEGER;
	producto_precio NUMERIC;
	valor_total INTEGER;
	factura_id INTEGER :=10;
BEGIN
	WHILE dia <= 30 LOOP
		FOR id_cliente IN SELECT id FROM clientes LOOP
			cantidad_vendida = floor(random() * 20 + 1);
			producto_vendido = floor(random() * 2 + 1);

			SELECT valor_unitario INTO producto_precio FROM productos WHERE codigo = producto_vendido;
			
			valor_total = cantidad_vendida * producto_precio;
			INSERT INTO facturas (id, fecha, cantidad, valor_total, pedido_estado, producto_id, cliente_id) VALUES (factura_id, CURRENT_DATE, cantidad_vendida, valor_total, 'PENDIENTE', producto_vendido, id_cliente);
			factura_id = factura_id + 1;
		END LOOP;
		dia = dia + 1;
	END LOOP;
END;
$$;

CALL simular_ventas_mes();

