CREATE TABLE factura (
    codigo SERIAL PRIMARY KEY,
    punto_venta VARCHAR(50),
    descripcion JSONB
);

INSERT INTO factura (codigo, punto_venta, descripcion)
VALUES (
    1,
    'PV001',
    '{
        "cliente": "Santi",
        "identificacion": "123456789",
        "direccion": "Calle 123, Bogotá",
        "codigo": "PV001",
        "total_descuento": 2000,
        "total_factura": 30000,
        "productos": [
            {
                "cantidad": 2,
                "valor": 10000,
                "producto": {
                    "nombre": "Pimienta Negra",
                    "descripcion": "Pimienta en grano",
                    "precio": 5000,
                    "categorias": ["especias", "condimentos"]
                }
            },
            {
                "cantidad": 1,
                "valor": 15000,
                "producto": {
                    "nombre": "Canela Molida",
                    "descripcion": "Canela en polvo",
                    "precio": 15000,
                    "categorias": ["especias"]
                }
            }
        ]
    }'
);

-- PUNTO 1
CREATE OR REPLACE FUNCTION guardar_factura(
    p_punto_venta VARCHAR(50),
    p_descripcion JSONB
) RETURNS VOID AS $$
BEGIN
    IF (p_descripcion->>'total_factura')::NUMERIC > 10000 THEN
        RAISE EXCEPTION 'El valor total de la factura no puede superar 10,000 dólares';
    ELSIF (p_descripcion->>'total_descuento')::NUMERIC > 50 THEN
        RAISE EXCEPTION 'El descuento máximo para una factura debe ser de 50 dólares';
    END IF;
    
    INSERT INTO factura (punto_venta, descripcion)
    VALUES (p_punto_venta, p_descripcion);
END;
$$ LANGUAGE plpgsql;


-- PUNTO 2
CREATE OR REPLACE FUNCTION actualizar_factura(
    p_codigo INTEGER,
    p_descripcion JSONB
) RETURNS VOID AS $$
BEGIN
    UPDATE factura
    SET descripcion = p_descripcion
    WHERE codigo = p_codigo;
END;
$$ LANGUAGE plpgsql;


-- PUNTO 3
CREATE OR REPLACE FUNCTION obtener_nombre_cliente(
    p_identificacion VARCHAR
) RETURNS VARCHAR AS $$
DECLARE
    nombre_cliente VARCHAR;
BEGIN
    SELECT descripcion->>'cliente'
    INTO nombre_cliente
    FROM factura
    WHERE descripcion->>'identificacion' = p_identificacion;
    
    RETURN nombre_cliente;
END;
$$ LANGUAGE plpgsql;


-- PUNTO 4
CREATE OR REPLACE FUNCTION obtener_facturas_informacion() RETURNS TABLE(
    cliente TEXT,
    identificacion TEXT,
    codigo_factura INTEGER,
    total_descuento NUMERIC,
    total_factura NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        descripcion->>'cliente' AS cliente,
        descripcion->>'identificacion' AS identificacion,
        codigo AS codigo_factura,
        (descripcion->>'total_descuento')::NUMERIC AS total_descuento,
        (descripcion->>'total_factura')::NUMERIC AS total_factura
    FROM factura;
END;
$$ LANGUAGE plpgsql;


-- PUNTO 5
CREATE OR REPLACE FUNCTION obtener_productos_por_factura(
    p_codigo INTEGER
) RETURNS SETOF JSONB AS $$
BEGIN
    RETURN QUERY
    SELECT jsonb_array_elements(descripcion->'productos')
    FROM factura
    WHERE codigo = p_codigo;
END;
$$ LANGUAGE plpgsql;


-- PROBANDO
SELECT guardar_factura('PV002', '{
    "cliente": "Juan Manuel Molo",
    "identificacion": "987654321",
    "direccion": "Av Santander Manizales",
    "codigo": "PV002",
    "total_descuento": 40,
    "total_factura": 8000,
    "productos": [
        {
            "cantidad": 3,
            "valor": 15000,
            "producto": {
                "nombre": "Clavo de Olor",
                "descripcion": "Clavo entero",
                "precio": 5000,
                "categorias": ["especias"]
            }
        }
    ]
}');

SELECT actualizar_factura(1, '{
    "cliente": "Santi modificado",
    "identificacion": "123456789",
    "direccion": "Calle 123, Manizales",
    "codigo": "PV001",
    "total_descuento": 30,
    "total_factura": 5000,
    "productos": [
        {
            "cantidad": 1,
            "valor": 5000,
            "producto": {
                "nombre": "Pimienta Blanca",
                "descripcion": "Pimienta en polvo",
                "precio": 5000,
                "categorias": ["especias"]
            }
        }
    ]
}');

SELECT obtener_nombre_cliente('123456789');

SELECT * FROM obtener_facturas_informacion();

SELECT * FROM obtener_productos_por_factura(1);

SELECT * FROM factura;
