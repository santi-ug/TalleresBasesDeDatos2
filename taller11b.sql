ALTER USER TALLER11B quota unlimited ON USERS;

CREATE TABLE clientes (
	id NUMBER NOT NULL PRIMARY KEY,
	nombre VARCHAR2(255),
	edad NUMBER,
	correo VARCHAR2(255)
);

CREATE TABLE productos (
	codigo NUMBER NOT NULL PRIMARY KEY,
	nombre VARCHAR2(255),
	stock NUMBER,
	valor_unitario NUMBER
);

CREATE TABLE facturas (
	id NUMBER NOT NULL PRIMARY KEY,
	fecha DATE,
	cantidad NUMBER,
	valor_total NUMBER,
	pedido_estado VARCHAR2(255),
	producto_id NUMBER,
	cliente_id NUMBER,
	FOREIGN KEY (producto_id) REFERENCES productos(codigo),
	FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

CREATE TABLE auditoria (
	id NUMBER NOT NULL PRIMARY KEY,
	fecha_inicio DATE,
	fecha_final DATE,
	factura_id NUMBER,
	pedido_estado VARCHAR2(255)
);

INSERT INTO clientes (nombre, id, edad, correo) VALUES ('Juan', 1, 20, 'juan@gmail.com');
INSERT INTO clientes (nombre, id, edad, correo) VALUES ('Santiago', 2, 22, 'santi@gmail.com');
INSERT INTO clientes (nombre, id, edad, correo) VALUES ('Elsa', 3, 45, 'elsa@gmail.com');

INSERT INTO productos (nombre, codigo, stock, valor_unitario) VALUES ('pollo', 1, 5, 20000);
INSERT INTO productos (nombre, codigo, stock, valor_unitario) VALUES ('carne', 2, 7, 18000);
INSERT INTO productos (nombre, codigo, stock, valor_unitario) VALUES ('arroz', 3, 22, 5000);

INSERT INTO facturas (id, fecha, cantidad, valor_total, pedido_estado, producto_id, cliente_id) VALUES (1, TO_DATE('2020-10-29', 'YYYY-MM-DD'), 3, 60000, 'ENTREGADO', 1, 1);
INSERT INTO facturas (id, fecha, cantidad, valor_total, pedido_estado, producto_id, cliente_id) VALUES (2, TO_DATE('2022-02-19', 'YYYY-MM-DD'), 3, 15000, 'BLOQUEADO', 3, 3);
INSERT INTO facturas (id, fecha, cantidad, valor_total, pedido_estado, producto_id, cliente_id) VALUES (3, TO_DATE('2024-07-12', 'YYYY-MM-DD'), 1, 18000, 'PENDIENTE', 2, 2);

CREATE OR REPLACE PROCEDURE obtener_total_stock IS
	v_total_stock NUMBER := 0;
	v_stock_actual NUMBER;
	v_nombre_producto VARCHAR2(255);
BEGIN
	FOR rec IN (SELECT nombre, stock FROM productos) LOOP
		DBMS_OUTPUT.PUT_LINE('el nombre del producto es: ' || rec.nombre);
		DBMS_OUTPUT.PUT_LINE('el stock actual del producto es: ' || rec.stock);
		v_total_stock := v_total_stock + rec.stock;
	END LOOP;

	DBMS_OUTPUT.PUT_LINE('el stock total es de: ' || v_total_stock);
END;
/

BEGIN
	obtener_total_stock;
END;
/

CREATE OR REPLACE PROCEDURE generar_auditoria(
	p_fecha_inicio DATE,
	p_fecha_final DATE
) IS
	v_id_counter NUMBER := 0;
BEGIN
	FOR rec IN (SELECT id, fecha, pedido_estado FROM facturas) LOOP
		IF rec.fecha >= p_fecha_inicio AND rec.fecha <= p_fecha_final THEN
			INSERT INTO auditoria (id, fecha_inicio, fecha_final, factura_id, pedido_estado) 
			VALUES (v_id_counter, p_fecha_inicio, p_fecha_final, rec.id, rec.pedido_estado);
			v_id_counter := v_id_counter + 1;
		END IF;
	END LOOP;
END;
/

BEGIN
	generar_auditoria(TO_DATE('2020-10-28', 'YYYY-MM-DD'), TO_DATE('2022-02-20', 'YYYY-MM-DD'));
END;
/

CREATE OR REPLACE PROCEDURE simular_ventas_mes IS
	dia NUMBER := 1;
	id_cliente NUMBER;
	cantidad_vendida NUMBER;
	producto_vendido NUMBER;
	producto_precio NUMBER;
	valor_total NUMBER;
	factura_id NUMBER := 10;
BEGIN
	WHILE dia <= 30 LOOP
		FOR rec IN (SELECT id FROM clientes) LOOP
			cantidad_vendida := FLOOR(DBMS_RANDOM.VALUE(1, 21));
			producto_vendido := FLOOR(DBMS_RANDOM.VALUE(1, 3));

			SELECT valor_unitario INTO producto_precio FROM productos WHERE codigo = producto_vendido;
			
			valor_total := cantidad_vendida * producto_precio;
			INSERT INTO facturas (id, fecha, cantidad, valor_total, pedido_estado, producto_id, cliente_id) 
			VALUES (factura_id, SYSDATE, cantidad_vendida, valor_total, 'PENDIENTE', producto_vendido, rec.id);
			factura_id := factura_id + 1;
		END LOOP;
		dia := dia + 1;
	END LOOP;
END;
/

BEGIN
	simular_ventas_mes;
END;
/
