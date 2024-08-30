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

INSERT INTO clientes (nombre, id, edad, correo) VALUES ('Juan', 1, 20, 'juan@gmail.com');
INSERT INTO clientes (nombre, id, edad, correo) VALUES ('Santiago', 2, 22, 'santi@gmail.com');
INSERT INTO clientes (nombre, id, edad, correo) VALUES ('Elsa', 3, 45, 'elsa@gmail.com');

INSERT INTO productos (nombre, codigo, stock, valor_unitario) VALUES ('pollo', 1, 5, 20000);
INSERT INTO productos (nombre, codigo, stock, valor_unitario) VALUES ('carne', 2, 7, 18000);
INSERT INTO productos (nombre, codigo, stock, valor_unitario) VALUES ('arroz', 3, 22, 5000);

INSERT INTO facturas (id, fecha, cantidad, valor_total, pedido_estado, producto_id, cliente_id) VALUES (1, CAST('2020-10-29' AS date), 3, 60000, 'ENTREGADO', 1, 1);
INSERT INTO facturas (id, fecha, cantidad, valor_total, pedido_estado, producto_id, cliente_id) VALUES (2, CAST('2022-02-19' AS date), 3, 15000, 'BLOQUEADO', 3, 3);
INSERT INTO facturas (id, fecha, cantidad, valor_total, pedido_estado, producto_id, cliente_id) VALUES (3, CAST('2024-07-12' AS date), 1, 18000, 'PENDIENTE', 2, 2);


CREATE OR REPLACE PROCEDURE verificar_stock (
	p_producto_id INTEGER,
	p_cantidad_compra INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE 
	v_producto_stock INTEGER;
BEGIN

	SELECT stock INTO v_producto_stock FROM productos WHERE codigo = p_producto_id;
	
	IF v_producto_stock < p_cantidad_compra THEN
		RAISE NOTICE 'No existe suficiente stock';
	ELSE
		RAISE NOTICE 'Si existe suficiente stock';
	END IF;

END;
$$;

CALL verificar_stock(2, 8);
CALL verificar_stock(2, 6);



CREATE OR REPLACE PROCEDURE actualizar_estado_pedido (
	p_factura_id INTEGER,
	p_nuevo_estado VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE 
	p_viejo_estado VARCHAR;
BEGIN

	SELECT pedido_estado INTO p_viejo_estado FROM facturas WHERE id = p_factura_id;
	
	IF p_viejo_estado != 'ENTREGADO' THEN
		UPDATE facturas SET pedido_estado = p_nuevo_estado WHERE id = p_factura_id;
	ELSE
		RAISE NOTICE 'EL PEDIDO YA FUE ENTREGADO';
	END IF;

END;
$$;

CALL actualizar_estado_pedido(1, 'BLOQUEADO');
CALL actualizar_estado_pedido(3, 'ENTREGADO');