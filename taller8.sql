CREATE TABLE usuarios (
	id SERIAL NOT NULL PRIMARY KEY,
	nombre VARCHAR,
	identificacion NUMERIC NOT NULL UNIQUE,
	edad INTEGER,
	correo VARCHAR
);
CREATE TABLE facturas (
	id SERIAL NOT NULL PRIMARY KEY,
	fecha DATE,
	producto VARCHAR NOT NULL,
	cantidad INTEGER,
	valor_unitario NUMERIC,
	valor_total NUMERIC,
	usuario_id INTEGER,
	foreign key (usuario_id) references usuarios(id)
);

CREATE OR REPLACE PROCEDURE poblar_bdd()
LANGUAGE plpgsql
AS $$
DECLARE 
	counter_clientes INTEGER := 1;
	id_cliente_actual INTEGER;
BEGIN
	WHILE counter_clientes <= 50 LOOP
		INSERT INTO usuarios (nombre, identificacion) VALUES ('juli'||counter_clientes, counter_clientes);
		IF counter_clientes % 2 = 0 THEN
			SELECT id into id_cliente_actual FROM usuarios WHERE identificacion = counter_clientes;
			INSERT INTO facturas (producto, usuario_id) VALUES ('aguacate'||counter_clientes, id_cliente_actual);
		END IF;
		counter_clientes = counter_clientes + 1;
	END LOOP;
END;
$$;

CALL poblar_bdd();

CREATE OR REPLACE PROCEDURE prueba_identificacion_unica()
LANGUAGE plpgsql
AS $$
DECLARE 
BEGIN
	INSERT INTO usuarios (nombre, identificacion) VALUES('juliana', 23);
EXCEPTION
	WHEN unique_violation THEN
		ROLLBACK;
		RAISE NOTICE 'Usuario con esa identificacion ya existe';
END;
$$;

CALL prueba_identificacion_unica();

CREATE OR REPLACE PROCEDURE prueba_cliente_debe_existir()
LANGUAGE plpgsql
AS $$
DECLARE 
BEGIN
	INSERT INTO facturas (producto, usuario_id) VALUES('carne', 23);
	INSERT INTO facturas (producto, usuario_id) VALUES('pechuga', 87);
EXCEPTION
	WHEN foreign_key_violation THEN
		ROLLBACK;
		RAISE NOTICE 'Usuario con esa identificacion no existe';
END;
$$;

CALL prueba_cliente_debe_existir();

CREATE OR REPLACE PROCEDURE prueba_producto_vacio()
LANGUAGE plpgsql
AS $$
DECLARE 
BEGIN
	INSERT INTO facturas (producto, usuario_id) VALUES(null, 23);
EXCEPTION
	WHEN others THEN
		ROLLBACK;
		RAISE NOTICE 'producto no puede ser null';
END;
$$;

CALL prueba_producto_vacio();