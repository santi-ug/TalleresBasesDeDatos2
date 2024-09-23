CREATE TABLE empleados (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(100),
  identificacion VARCHAR(50),
  tipo_contrato_id INT
);

CREATE TABLE tipo_contrato (
  id SERIAL PRIMARY KEY,
  descripcion VARCHAR(100),
  cargo VARCHAR(100),
  salario_total DECIMAL
);

CREATE TABLE conceptos (
  id SERIAL PRIMARY KEY,
  codigo VARCHAR(50),
  nombre VARCHAR(100),
  porcentaje DECIMAL
);

CREATE TABLE nomina (
  id SERIAL PRIMARY KEY,
  mes INT,
  ano INT,
  fecha_pago DATE,
  total_devengado DECIMAL,
  total_deducciones DECIMAL,
  total DECIMAL,
  cliente_id INT
);

CREATE TABLE detalles_nomina (
  id SERIAL PRIMARY KEY,
  concepto_id INT,
  valor DECIMAL,
  nomina_id INT
);

DO $$
BEGIN
  FOR i IN 1..10 LOOP
    INSERT INTO empleados (nombre, identificacion, tipo_contrato_id)
    VALUES ('Empleado ' || i, 'ID' || i, (i % 10) + 1);
  END LOOP;

  FOR i IN 1..10 LOOP
    INSERT INTO tipo_contrato (descripcion, cargo, salario_total)
    VALUES ('Descripcion ' || i, 'Cargo ' || i, 1000 + (i * 100));
  END LOOP;

  FOR i IN 1..15 LOOP
    INSERT INTO conceptos (codigo, nombre, porcentaje)
    VALUES ('Codigo ' || i, 'Concepto ' || i, (i * 0.1));
  END LOOP;

  FOR i IN 1..5 LOOP
    INSERT INTO nomina (mes, ano, fecha_pago, total_devengado, total_deducciones, total, cliente_id)
    VALUES (i, 2023, CURRENT_DATE + i, 1000 + (i * 100), 100 + (i * 10), 900 + (i * 90), i);
  END LOOP;

  FOR i IN 1..15 LOOP
    INSERT INTO detalles_nomina (concepto_id, valor, nomina_id)
    VALUES ((i % 15) + 1, 100 + (i * 10), (i % 5) + 1);
  END LOOP;
END $$;


CREATE OR REPLACE FUNCTION obtener_nomina_empleado(identificacion VARCHAR, mes INT, ano INT)
RETURNS TABLE (
  nombre VARCHAR,
  total_devengado DECIMAL,
  total_deducciones DECIMAL,
  total DECIMAL
) AS $$
BEGIN
  RETURN QUERY
  SELECT e.nombre, n.total_devengado, n.total_deducciones, n.total
  FROM empleados e
  JOIN nomina n ON e.id = n.cliente_id
  WHERE e.identificacion = $1 AND n.mes = $2 AND n.ano = $3;
END $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION total_por_contrato(tipo_contrato_id INT)
RETURNS TABLE (
  nombre VARCHAR,
  fecha_pago DATE,
  ano INT,
  mes INT,
  total_devengado DECIMAL,
  total_deducciones DECIMAL,
  total DECIMAL
) AS $$
BEGIN
  RETURN QUERY
  SELECT e.nombre, n.fecha_pago, n.ano, n.mes, n.total_devengado, n.total_deducciones, n.total
  FROM empleados e
  JOIN nomina n ON e.id = n.cliente_id
  WHERE e.tipo_contrato_id = $1;
END $$ LANGUAGE plpgsql;

SELECT * FROM obtener_nomina_empleado('ID1', 1, 2023);

SELECT * FROM total_por_contrato(1);
