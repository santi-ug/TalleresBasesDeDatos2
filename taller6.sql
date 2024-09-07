CREATE TABLE clientes(
	id Serial NOT NULL PRIMARY KEY,
	nombre VARCHAR,
	identificacion INTEGER,
	email VARCHAR,
	direccion VARCHAR,
	telefono INTEGER
);

CREATE TABLE servicios(
	id Serial NOT NULL PRIMARY KEY,
	codigo INTEGER,
	mes INTEGER,
	tipo VARCHAR,
	monto NUMERIC,
	cuota NUMERIC,
	intereses NUMERIC,
	estado VARCHAR,
	valor_total NUMERIC,
	cliente_id INTEGER,
	FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

CREATE TABLE pagos(
	id Serial NOT NULL PRIMARY KEY,
	codigo_transaccion INTEGER,
	fecha_pago DATE,
	total NUMERIC,
	servicio_id INTEGER,
	FOREIGN KEY (servicio_id) REFERENCES servicios(id)
);

CREATE OR REPLACE PROCEDURE poblar_bdd()
LANGUAGE plpgsql
AS $$
DECLARE 
	counter_clientes INTEGER := 1;
	counter_servicios INTEGER := 1;
	id_cliente_actual INTEGER;
	id_servicio_actual INTEGER;
BEGIN
	WHILE counter_clientes <= 50 LOOP
		INSERT INTO clientes (nombre, identificacion) VALUES ('juli'||counter_clientes, counter_clientes);
		while counter_servicios <= 3 LOOP
			SELECT id into id_cliente_actual FROM clientes WHERE identificacion = counter_clientes;
			IF counter_servicios = 1 THEN
 
				INSERT INTO servicios (codigo, mes, tipo, estado, valor_total, cliente_id) VALUES (counter_clientes*counter_servicios, floor(random() * 12 + 1), 'gas', 'pendiente', 2000, id_cliente_actual);
				SELECT id into id_servicio_actual FROM servicios WHERE codigo = counter_clientes*counter_servicios;
				INSERT INTO pagos (codigo_transaccion, fecha_pago, total, servicio_id) VALUES (counter_clientes, CURRENT_DATE, 2000, id_servicio_actual);
			ELSE 
				INSERT INTO servicios (codigo, mes, tipo, estado, valor_total, cliente_id) VALUES (counter_clientes*counter_servicios, floor(random() * 12 + 1), 'electricidad', 'pago', 1000, id_cliente_actual);
			END IF;
			counter_servicios = counter_servicios + 1;
		END LOOP;
		counter_servicios = 1;
		counter_clientes = counter_clientes + 1;
	END LOOP;
END;
$$;

CALL poblar_bdd();


CREATE OR REPLACE FUNCTION transacciones_total_mes(p_id_cliente INTEGER, p_mes INTEGER)
RETURNS NUMERIC AS
$$
	-- total de pago de los servicios que pago el cliente en ese mes
DECLARE 
	v_total NUMERIC;
	v_mes INTEGER;
	v_valor INTEGER;
BEGIN

	FOR v_mes, v_valor IN SELECT total FROM pagos WHERE pagos.servicio_id = servicio.id AND servicio.cliente_id = p_id_cliente LOOP
		IF v_mes = p_mes THEN
			v_total = v_total + v_valor;
		END IF;
	END LOOP;

	RETURN total;
END
$$
LANGUAGE plpgsql;

SELECT transacciones_total_mes(13, 6);


