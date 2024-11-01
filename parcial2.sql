CREATE TABLE IF NOT EXISTS usuarios (
	id SERIAL PRIMARY KEY,
	nombre TEXT,
	direccion TEXT,
	email TEXT,
	fecha_registro DATE,
	estado TEXT -- activo/inactivo
);

CREATE TABLE IF NOT EXISTS tarjetas (
	id SERIAL PRIMARY KEY,
	numero_tarjeta INTEGER,
	fecha_expiracion DATE,
	cvv INTEGER,
	tipo_tarjeta TEXT -- visa/mastercard
);

CREATE TABLE IF NOT EXISTS productos (
	id SERIAL PRIMARY KEY,
	codigo_producto INTEGER,
	nombre TEXT,
	categoria TEXT, -- celular/pc/televisor
	porcentaje_impuesto NUMERIC,
	precio NUMERIC
);

CREATE TABLE IF NOT EXISTS pagos (
	id SERIAL PRIMARY KEY,
	codigo_pago INTEGER,
	fecha DATE,
	estado TEXT, -- exitoso/fallido
	monto NUMERIC,
	producto_id INTEGER,
	tarjeta_id INTEGER,
	usuario_id INTEGER,
	FOREIGN KEY (producto_id) REFERENCES productos (id),
	FOREIGN KEY (tarjeta_id) REFERENCES tarjetas (id),
	FOREIGN KEY (usuario_id) REFERENCES usuarios (id)
);

CREATE TABLE IF NOT EXISTS comprobantes_pago_json (
	id SERIAL PRIMARY KEY,
	detalle_json JSONB
);

CREATE TABLE IF NOT EXISTS comprobantes_pago_xml (
	id SERIAL PRIMARY KEY,
	detalle_xml XML
);

-- Punto 1a
CREATE OR REPLACE FUNCTION obtener_pagos_usuario (p_usuario_id INTEGER, p_fecha DATE)
RETURNS TABLE (
	codigo_pago INTEGER,
	nombre_producto TEXT,
	monto NUMERIC,
	estado TEXT
) AS $$
BEGIN
	RETURN QUERY
	SELECT p.codigo_pago, pr.nombre, p.monto, p.estado
	FROM pagos p
	JOIN productos pr ON p.producto_id = pr.id
	WHERE p.usario_id = $1 AND p.fecha = p_fecha;

END $$ LANGUAGE plpgsql;

-- Punto 1b
CREATE OR REPLACE FUNCTION obtener_tarjetas_usuario_monto_mayor (p_usuario_id INTEGER)
RETURNS TABLE (
	nombre_usuario TEXT,
	email TEXT,
	numero_tarjeta INTEGER,
	cvv INTEGER,
	tipo_tarjeta TEXT
) AS $$
DECLARE 
	monto_minimo NUMERIC := 10000;
BEGIN
	RETURN QUERY
	SELECT u.nombre, u.email
	FROM pagos p
	JOIN usuarios u ON u.id = p.usuario_id
	WHERE p.usuario_id = $1;	
	
END;
$$ LANGUAGE plpgsql;

-- Punto 2a
CREATE OR REPLACE FUNCTION obtener_tarjetas_detalle_usuario (p_usuario_id INTEGER)
RETURNS VARCHAR AS $$
DECLARE 
	rec RECORD;
	cur CURSOR FOR SELECT * FROM pagos WHERE usuario_id = p_usuario_id;
	detalle_usuario VARCHAR := '';
BEGIN
	OPEN CUR;
	LOOP
		FETCH cur INTO rec;
		EXIT WHEN NOT FOUND;
		detalle_usuario := detalle_usuario || 'Pago ID: ' || rec.id || ', Monto: ' || rec.monto || ', Estado: ' || rec.estado || '; ';
	END LOOP;
	CLOSE CUR;
	RETURN detalle_usuario;
END;
$$ LANGUAGE plpgsql;

-- Punto 2b


-- Punto 2c
CREATE OR REPLACE PROCEDURE guardar_xml(p_xml XML)
LANGUAGE plpgsql
AS $$
DECLARE
BEGIN
	INSERT INTO comprobantes_pago_xml(detalle_xml) VALUES (p_xml);
END;
$$;


-- Punto 3d
CREATE OR REPLACE PROCEDURE guardar_json(p_json JSON))
LANGUAGE plpgsql
AS $$
DECLARE
BEGIN
	INSERT INTO comprobantes_pago_json(detalle_json) VALUES (p_json);
END;
$$;


-- Punto 3a
CREATE OR REPLACE FUNCTION validar_producto()
RETURNS TRIGGER AS $$
BEGIN
	IF NEW.precio < 1 THEN
		RAISE EXCEPTION 'Precio debe ser mayor a 0'; 
	ELSIF NEW.precio > 19999 THEN
		RAISE EXCEPTION 'Precio debe ser menor a 20,000';
	ELSIF NEW.porcentaje_impuesto < 2 THEN
		RAISE EXCEPTION 'Porcentaje de impuesto debe ser mayor a 1';
	ELSIF NEW.porcentaje_impuesto > 20 THEN
		RAISE EXCEPTION 'Porcentaje de impuest debe ser menor o igual a 20';
	END IF;
	RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER validaciones_producto
BEFORE INSERT ON productos
FOR EACH ROW
EXECUTE FUNCTION validar_producto();

-- Punto 3b
CREATE OR REPLACE FUNCTION almacenar_xml_json()
RETURNS TRIGGER AS $$
BEGIN 
	INSERT INTO comprobantes_pago_xml(detalle_xml) VALUES (NEW.detalle_xml);
	INSERT INTO comprobantes_pago_json(detalle_json) VALUES (NEW.detalle_json);
	RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_xml
AFTER INSERT ON pagos
FOR EACH ROW 
EXECUTE FUNCTION almacenar_xml_json();

-- Punto 4a
CREATE SEQUENCE seq_codigo_prod
    START 5
    INCREMENT BY 5;
   
INSERT INTO productos (codigo_producto) VALUES (nextval('seq_codigo_prod'));
INSERT INTO productos (codigo_producto) VALUES (nextval('seq_codigo_prod'));


-- Punto 4b
CREATE SEQUENCE seq_codigo_pagos
		START 1
		INCREMENT BY 100;

INSERT INTO pagos (codigo_pago) VALUES (nextval('seq_codigo_pagos'));
INSERT INTO pagos (codigo_pago) VALUES (nextval('seq_codigo_pagos'));

-- Punto 4c

-- Punto 4d


