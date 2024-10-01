ALTER USER TALLER11 quota unlimited ON USERS;

CREATE TABLE clientes (
  id NUMBER NOT NULL PRIMARY KEY,
  nombre VARCHAR2(50),
  edad NUMBER,
  correo VARCHAR2(100)
);

CREATE TABLE productos (
  codigo NUMBER NOT NULL PRIMARY KEY,
  nombre VARCHAR2(50),
  stock NUMBER,
  valor_unitario NUMBER
);

CREATE TABLE facturas (
  id NUMBER NOT NULL PRIMARY KEY,
  fecha DATE,
  cantidad NUMBER,
  valor_total NUMBER,
  pedido_estado VARCHAR2(50),
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
  pedido_estado VARCHAR2(50)
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

CREATE OR REPLACE PROCEDURE OBTENER_TOTAL_STOCK IS
  v_total_stock NUMBER := 0;
  v_stock_actual NUMBER;
  v_nombre_producto VARCHAR2(50);
BEGIN
  FOR rec IN (SELECT nombre, stock FROM productos) LOOP
    DBMS_OUTPUT.PUT_LINE('el nombre del producto es: ' || rec.nombre);
    DBMS_OUTPUT.PUT_LINE('el stock actual del producto es: ' || rec.stock);
    v_total_stock := v_total_stock + rec.stock;
  END LOOP;

  DBMS_OUTPUT.PUT_LINE('el stock total es de: ' || v_total_stock);
END;



CALL TALLER11.obtener_total_stock();


CREATE OR REPLACE PROCEDURE GENERAR_AUDITORIA(
  p_fecha_inicio IN DATE,
  p_fecha_final IN DATE
) IS
  v_id_counter NUMBER := 0;
  v_factura_id NUMBER;
  v_factura_fecha DATE;
  v_factura_estado_pedido VARCHAR(50);
BEGIN
  FOR rec IN (SELECT id, fecha, pedido_estado FROM facturas) LOOP
    IF rec.fecha >= p_fecha_inicio AND rec.fecha <= p_fecha_final THEN
      INSERT INTO auditoria (id, fecha_inicio, fecha_final, factura_id, pedido_estado) 
      VALUES (v_id_counter, p_fecha_inicio, p_fecha_final, rec.id, rec.pedido_estado);
      v_id_counter := v_id_counter + 1;
    END IF;
  END LOOP;
END;


CALL TALLER11.GENERAR_AUDITORIA(TO_DATE('2020-10-28', 'YYYY-MM-DD'), TO_DATE('2022-02-20', 'YYYY-MM-DD'));


CREATE OR REPLACE PROCEDURE SIMULAR_VENTAS_MES IS
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


CALL TALLER11.simular_ventas_mes();

SELECT OBJECT_NAME, OBJECT_TYPE
FROM ALL_OBJECTS
WHERE OBJECT_NAME IN ('GENERAR_AUDITORIA', 'SIMULAR_VENTAS_MES')
AND OWNER = 'TALLER11';

SELECT ARGUMENT_NAME, DATA_TYPE
FROM ALL_ARGUMENTS
WHERE OBJECT_NAME = 'GENERAR_AUDITORIA'
AND OWNER = 'TALLER11';

SELECT OBJECT_NAME, OBJECT_TYPE
FROM ALL_OBJECTS
WHERE OBJECT_NAME = 'GENERAR_AUDITORIA'
AND OWNER = 'TALLER11';

SELECT TEXT
FROM ALL_SOURCE
WHERE NAME = 'GENERAR_AUDITORIA'
AND OWNER = 'TALLER11'
AND TYPE = 'PROCEDURE';

SELECT TEXT
FROM ALL_SOURCE
WHERE NAME = 'GENERAR_AUDITORIA'
AND OWNER = 'TALLER11'
AND TYPE = 'PROCEDURE'
ORDER BY LINE;

ALTER PROCEDURE TALLER11.GENERAR_AUDITORIA COMPILE;
