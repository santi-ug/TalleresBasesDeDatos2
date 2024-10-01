CREATE TABLE IF NOT EXISTS envios (
    id SERIAL PRIMARY KEY,
    fecha_envio DATE,
    destino TEXT,
    observacion TEXT,
    estado TEXT
);

INSERT INTO envios (fecha_envio, destino, observacion, estado)
SELECT 
    generate_series('2023-01-01'::date, '2023-01-31'::date, '1 day'),
    'Ciudad ' || generate_series(1, 50),
    'Observación inicial',
    'pendiente'
FROM generate_series(1, 50);

CREATE OR REPLACE PROCEDURE primera_fase_envio()
LANGUAGE plpgsql
AS $$
DECLARE
    rec RECORD;
    cur CURSOR FOR SELECT * FROM envios WHERE estado = 'pendiente';
BEGIN
    OPEN cur;
    LOOP
        FETCH cur INTO rec;
        EXIT WHEN NOT FOUND;

        UPDATE envios
        SET observacion = observacion || ', Primera etapa del envío',
            estado = 'en ruta'
        WHERE CURRENT OF cur;
    END LOOP;
    CLOSE cur;
END;
$$;

CREATE OR REPLACE PROCEDURE ultima_fase_envio()
LANGUAGE plpgsql
AS $$
DECLARE
    rec RECORD;
    cur CURSOR FOR SELECT * FROM envios WHERE estado = 'en ruta' AND fecha_envio < CURRENT_DATE - INTERVAL '5 day';
BEGIN
    OPEN cur;
    LOOP
        FETCH cur INTO rec;
        EXIT WHEN NOT FOUND;

        UPDATE envios
        SET observacion = 'Envio realizado satisfactoriamente',
            estado = 'entregado'
        WHERE CURRENT OF cur;
    END LOOP;
    CLOSE cur;
END;
$$;

CALL primera_fase_envio();
CALL ultima_fase_envio();