ALTER USER TALLER7 quota unlimited ON USERS;


CREATE TABLE clientes (
	id NUMBER NOT NULL PRIMARY KEY,
	nombre VARCHAR(250),
	edad NUMBER,
	correo VARCHAR(250)
);
CREATE TABLE productos (
	codigo NUMBER NOT NULL PRIMARY KEY,
	nombre VARCHAR(250),
	stock NUMBER,
	valor_unitario NUMERIC
);
CREATE TABLE facturas (
	id NUMBER NOT NULL PRIMARY KEY,
	fecha DATE,
	cantidad NUMBER,
	valor_total NUMBER,
	pedido_estado VARCHAR(250),
	producto_id NUMBER,
	cliente_id NUMBER,
	foreign key (producto_id) references productos(codigo),
	foreign key (cliente_id) references clientes(id)
);

INSERT INTO clientes (nombre, id, edad, correo) VALUES ('Juan', 1, 20, 'juan@gmail.com');
INSERT INTO clientes (nombre, id, edad, correo) VALUES ('Santiago', 2, 22, 'santi@gmail.com');
INSERT INTO clientes (nombre, id, edad, correo) VALUES ('Elsa', 3, 45, 'elsa@gmail.com');

INSERT INTO productos (nombre, codigo, stock, valor_unitario) VALUES ('pollo', 1, 5, 20000);
INSERT INTO productos (nombre, codigo, stock, valor_unitario) VALUES ('carne', 2, 7, 18000);
INSERT INTO productos (nombre, codigo, stock, valor_unitario) VALUES ('arroz', 3, 22, 5000);

INSERT INTO facturas (id, cantidad, valor_total, pedido_estado, producto_id, cliente_id) VALUES (1, 3, 60000, 'ENTREGADO', 1, 1);
INSERT INTO facturas (id, cantidad, valor_total, pedido_estado, producto_id, cliente_id) VALUES (2, 3, 15000, 'BLOQUEADO', 3, 3);
INSERT INTO facturas (id, cantidad, valor_total, pedido_estado, producto_id, cliente_id) VALUES (3, 1, 18000, 'PENDIENTE', 2, 2);


CREATE OR REPLACE PROCEDURE VERIFICAR_STOCK(
	p_producto_id IN NUMBER,
	p_cantidad_compra IN NUMBER)
IS 
	v_producto_stock NUMBER;
BEGIN
	SELECT stock INTO v_producto_stock FROM productos WHERE codigo = p_producto_id;
	
	IF v_producto_stock >= p_cantidad_compra THEN
		DBMS_OUTPUT.PUT_LINE('Si existe suficiente stock');

	ELSE
		DBMS_OUTPUT.PUT_LINE('No existe suficiente stock');

	END IF;
END;


CALL TALLER7.VERIFICAR_STOCK(123, 500);