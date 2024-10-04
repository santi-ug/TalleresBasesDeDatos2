CREATE TABLE empleado(
	id SERIAL NOT NULL PRIMARY KEY,
	nombre TEXT,
	edad INTEGER,
	salario NUMERIC
);

CREATE TABLE nomina (
	id SERIAL NOT NULL PRIMARY KEY,
	fecha DATE,
	total_ingresos NUMERIC,
	total_deducciones NUMERIC,
	total_neto NUMERIC,
	empleado_id INTEGER,
	FOREIGN KEY (empleado_id) REFERENCES empleado(id)
);

CREATE TABLE detalle_nomina (
	id SERIAL NOT NULL PRIMARY KEY,
	concepto TEXT,
	tipo TEXT,
	valor NUMERIC,
	nomina_id INTEGER,
	FOREIGN KEY (nomina_id) REFERENCES nomina (id)
);

CREATE TABLE auditoria_nomina (
  id SERIAL PRIMARY KEY,
  fecha DATE,
  nombre TEXT,
  identificacion INTEGER,
  total_neto NUMERIC
);

CREATE TABLE auditoria_empleado (
  id SERIAL PRIMARY KEY,
  fecha DATE,
  nombre TEXT,
  identificacion INTEGER,
  concepto TEXT,
  valor NUMERIC
);


-- Trigger 1
CREATE OR REPLACE FUNCTION validar_presupuesto_nomina()
RETURNS TRIGGER AS $$
DECLARE
  presupuesto_nomina NUMERIC := 12000000;
  total_nomina NUMERIC;
BEGIN
  SELECT SUM(total_neto) INTO total_nomina
  FROM nomina
  WHERE EXTRACT(MONTH FROM fecha) = EXTRACT(MONTH FROM CURRENT_DATE)
  AND empleado_id = NEW.empleado_id;

  IF (total_nomina + NEW.total_neto) > presupuesto_nomina THEN
      RAISE EXCEPTION 'El presupuesto de nómina ha sido superado.';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER validar_insert_nomina
BEFORE INSERT ON nomina
FOR EACH ROW
EXECUTE FUNCTION validar_presupuesto_nomina();



-- Trigger 2
CREATE OR REPLACE FUNCTION registrar_auditoria_nomina()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO auditoria_nomina (fecha, nombre, identificacion, total_neto)
  SELECT CURRENT_DATE, e.nombre, e.id, NEW.total_neto
  FROM empleado e
  WHERE e.id = NEW.empleado_id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_insert_nomina
AFTER INSERT ON nomina
FOR EACH ROW
EXECUTE FUNCTION registrar_auditoria_nomina();



-- Trigger 3
CREATE OR REPLACE FUNCTION validar_salario()
RETURNS TRIGGER AS $$
DECLARE 
  presupuesto_salario NUMERIC := 12000000;
BEGIN
	IF NEW.salario > presupuesto_salario THEN
		RAISE EXCEPTION 'Salario supera valor permitido';
	END IF;

	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_update_salario
BEFORE UPDATE ON empleado
FOR EACH ROW 
EXECUTE FUNCTION validar_salario();


-- Trigger 4
CREATE OR REPLACE FUNCTION registrar_auditoria_empleado()
RETURNS TRIGGER AS $$
DECLARE
  cambio TEXT;
  valor_cambio NUMERIC;
BEGIN
  IF NEW.salario > OLD.salario THEN
    cambio := 'AUMENTO';
    valor_cambio := NEW.salario - OLD.salario;
  ELSE
    cambio := 'DISMINUCION';
    valor_cambio := OLD.salario - NEW.salario;
  END IF;

	INSERT INTO auditoria_empleado (fecha, nombre, identificacion, concepto, valor)
	VALUES (CURRENT_DATE, NEW.nombre, NEW.id, cambio, valor_cambio);

	RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_update_salario
AFTER UPDATE ON empleado
FOR EACH ROW 
EXECUTE FUNCTION registrar_auditoria_empleado();

-- Usando los triggers a traves de inserts

INSERT INTO empleado (nombre, edad, salario) VALUES ('Juan Perez', 35, 11000000);
INSERT INTO empleado (nombre, edad, salario) VALUES ('Maria Gomez', 29, 9000000);

UPDATE empleado SET salario = 13000000 WHERE nombre = 'Maria Gomez';  -- Debe arrojar excepción

INSERT INTO nomina (fecha, total_ingresos, total_deducciones, total_neto, empleado_id) 
VALUES ('2024-10-01', 12000000, 2000000, 10000000, 1);

INSERT INTO nomina (fecha, total_ingresos, total_deducciones, total_neto, empleado_id) 
VALUES ('2024-10-15', 4000000, 500000, 3500000, 1);  -- Debe arrojar excepción

UPDATE empleado SET salario = 9500000 WHERE nombre = 'Maria Gomez';  -- Aumento de salario

UPDATE empleado SET salario = 8500000 WHERE nombre = 'Maria Gomez';  -- Disminución de salario

SELECT * FROM auditoria_empleado;  -- Debería contener los cambios de aumento y disminución de salario

INSERT INTO nomina (fecha, total_ingresos, total_deducciones, total_neto, empleado_id) 
VALUES ('2024-10-20', 3000000, 500000, 2500000, 1);  -- Debe arrojar excepción por presupuesto mensual

UPDATE empleado SET salario = 13000000 WHERE id = 1;  -- Debe arrojar excepción
