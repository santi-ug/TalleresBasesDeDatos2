create table clientes (
	nombre varchar(20),
	id int not NULL,
	edad int,
	correo varchar(50),
	primary key (id)
);
create table productos (
	codigo int not NULL,
	nombre varchar(20),
	stock int,
	valor_unitario int,
	primary key (codigo)
);
create table pedidos (
	id int not NULL,
	fecha date,
	cantidad int,
	valor_total int,
	producto_id int,
	cliente_id int,
	primary key (id),
	foreign key (producto_id) references productos(codigo),
	foreign key (cliente_id) references clientes(id)
);

BEGIN;


INSERT INTO clientes (nombre, id, edad, correo) VALUES ('Juan', 1, 20, 'juan@gmail.com');
INSERT INTO clientes (nombre, id, edad, correo) VALUES ('Santiago', 2, 22, 'santi@gmail.com');
INSERT INTO clientes (nombre, id, edad, correo) VALUES ('Elsa', 3, 45, 'elsa@gmail.com');

INSERT INTO productos (nombre, codigo, stock, valor_unitario) VALUES ('pollo', 1, 5, 20000);
INSERT INTO productos (nombre, codigo, stock, valor_unitario) VALUES ('carne', 2, 7, 18000);
INSERT INTO productos (nombre, codigo, stock, valor_unitario) VALUES ('arroz', 3, 22, 5000);

INSERT INTO pedidos (id, fecha, cantidad, valor_total, producto_id, cliente_id) VALUES (1, CAST('2020-10-29' AS date), 3, 60000, 1, 1);
INSERT INTO pedidos (id, fecha, cantidad, valor_total, producto_id, cliente_id) VALUES (2, CAST('2022-02-19' AS date), 3, 15000, 3, 3);
INSERT INTO pedidos (id, fecha, cantidad, valor_total, producto_id, cliente_id) VALUES (3, CAST('2024-07-12' AS date), 1, 18000, 2, 2);



UPDATE clientes SET nombre = 'Juan Manuel' WHERE nombre = 'Juan';
UPDATE clientes SET correo = 'elsav33@gmail.com' WHERE nombre = 'Elsa';

UPDATE productos SET valor_unitario = 22000 WHERE nombre = 'pollo';
UPDATE productos SET stock = 12 WHERE nombre = 'carne';

UPDATE pedidos SET valor_total = 66000 WHERE id = 1;
UPDATE pedidos SET cantidad = 5 WHERE id = 2;



DELETE FROM pedidos WHERE id = 2;

DELETE FROM clientes WHERE id = 3;

DELETE FROM productos WHERE codigo = 3;



ROLLBACK;
