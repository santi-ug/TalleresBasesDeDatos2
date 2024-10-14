CREATE TABLE libros (
    isbn VARCHAR(13) PRIMARY KEY,
    descripcion XML
);


CREATE OR REPLACE FUNCTION taller15.guardar_libro(isbn_input VARCHAR, xml_input XML) 
RETURNS VOID AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM taller15.libros WHERE isbn = isbn_input) THEN
        RAISE EXCEPTION 'Book with this ISBN already exists';
    ELSE
        INSERT INTO taller15.libros (isbn, descripcion) VALUES (isbn_input, xml_input);
    END IF;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION taller15.actualizar_libro(isbn_input VARCHAR, xml_input XML)
RETURNS VOID AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM taller15.libros WHERE isbn = isbn_input) THEN
        RAISE EXCEPTION 'Book with this ISBN does not exist';
    ELSE
        UPDATE taller15.libros SET descripcion = xml_input WHERE isbn = isbn_input;
    END IF;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION taller15.obtener_autor_libro_por_titulo(titulo_input TEXT)
RETURNS TEXT AS $$
DECLARE
    autor TEXT;
BEGIN
    SELECT xpath('/libro/autor/text()', descripcion)::TEXT
    INTO autor
    FROM taller15.libros
    WHERE xpath('/libro/titulo/text()', descripcion)::TEXT = titulo_input;

    IF autor IS NULL THEN
        RAISE EXCEPTION 'No author found for the given title';
    END IF;

    RETURN autor;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION taller15.obtener_libro(isbn_input VARCHAR, titulo_input TEXT)
RETURNS XML AS $$
DECLARE
    libro_xml XML;
BEGIN
    IF isbn_input IS NOT NULL THEN
        SELECT descripcion INTO libro_xml FROM libros WHERE isbn = isbn_input;
    ELSIF titulo_input IS NOT NULL THEN
        SELECT descripcion INTO libro_xml 
        FROM taller15.libros 
        WHERE xpath('/libro/titulo/text()', descripcion)::TEXT = titulo_input;
    END IF;  

    IF libro_xml IS NULL THEN
        RAISE EXCEPTION 'No book found for the given ISBN or title';
    END IF;

    RETURN libro_xml;
END;
$$ LANGUAGE plpgsql;
