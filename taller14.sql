-- Crear la tabla factura
CREATE TABLE factura (
    codigo SERIAL PRIMARY KEY,
    cliente VARCHAR(100),
    producto VARCHAR(100),
    descuento DECIMAL(5, 2),
    valor_total DECIMAL(10, 2),
    numero_fe INT
);

-- Crear la secuencia para el número de facturación electrónica
CREATE SEQUENCE seq_numero_fe
    START 100
    INCREMENT BY 100;

-- Insertar los registros en la tabla factura
INSERT INTO factura (cliente, producto, descuento, valor_total, numero_fe)
VALUES
('Cliente 1', 'Producto A', 5.00, 1500.00, nextval('seq_numero_fe')),
('Cliente 2', 'Producto B', 10.00, 3000.00, nextval('seq_numero_fe')),
('Cliente 3', 'Producto C', 0.00, 1200.00, nextval('seq_numero_fe')),
('Cliente 4', 'Producto D', 15.00, 5000.00, nextval('seq_numero_fe')),
('Cliente 5', 'Producto E', 7.00, 1800.00, nextval('seq_numero_fe')),
('Cliente 6', 'Producto F', 0.00, 4500.00, nextval('seq_numero_fe')),
('Cliente 7', 'Producto G', 20.00, 2500.00, nextval('seq_numero_fe')),
('Cliente 8', 'Producto H', 3.00, 3300.00, nextval('seq_numero_fe')),
('Cliente 9', 'Producto I', 5.00, 4100.00, nextval('seq_numero_fe')),
('Cliente 10', 'Producto J', 12.00, 5200.00, nextval('seq_numero_fe'));

-- Consultar los registros insertados
SELECT * FROM factura;
