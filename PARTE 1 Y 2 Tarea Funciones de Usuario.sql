-- Crear la base de datos
CREATE DATABASE tienda_online;

-- Seleccionar la base de datos tienda_online
USE tienda_online;

-- Crear la tabla Clientes
CREATE TABLE Clientes (
    Cliente_ID INT PRIMARY KEY AUTO_INCREMENT ,
    Nombre_Cliente VARCHAR(50) NOT NULL,
    Apellido_Cliente VARCHAR(50) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    Telefono VARCHAR(30),
    Fecha_Registro DATE NOT NULL
);

-- Visualizar la tabla
SELECT * FROM Clientes;

-- Crear la tabla Productos
CREATE TABLE Productos (
    Producto_ID INT PRIMARY KEY AUTO_INCREMENT ,
    Nombre_Producto VARCHAR(50) NOT NULL UNIQUE,
    Precio_Producto DECIMAL(10,2) NOT NULL CHECK (Precio_Producto > 0),
    Stock INT NOT NULL CHECK (Stock >= 0),
    Descripcion TEXT
);

-- Visualizar la tabla
SELECT * FROM Productos;

-- Crear la tabla Pedidos
CREATE TABLE Pedidos (
    Pedido_ID INT PRIMARY KEY AUTO_INCREMENT ,
    Cliente_ID INT,
    Fecha_Pedido DATE NOT NULL,
    Total DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (Cliente_ID) REFERENCES Clientes(Cliente_ID)
);

-- Visualizar la tabla
SELECT * FROM Pedidos;

-- Crear la tabla Detalles_Pedido
CREATE TABLE Detalles_Pedido (
    Detalles_Pedido_ID INT AUTO_INCREMENT PRIMARY KEY,
    Pedido_ID INT,
    Producto_ID INT,
    Cantidad INT NOT NULL CHECK (Cantidad > 0),
    Precio_Unitario DECIMAL(10,2) NOT NULL CHECK (Precio_Unitario > 0),
    FOREIGN KEY (Pedido_ID) REFERENCES Pedidos(Pedido_ID),
    FOREIGN KEY (Producto_ID) REFERENCES Productos(Producto_ID)
);

-- Visualizar la tabla
SELECT * FROM Detalles_Pedido;

-- Insertar registros en la tabla Clientes
INSERT INTO Clientes (Nombre_Cliente, Apellido_Cliente, Email, Telefono, Fecha_Registro)
VALUES 
('Josue', 'Estrada', 'josue.estrada@gmail.com', '6543246', '2022-02-14'),
('Susana', 'Cajamarca', 'susana.cajamarca@gmail.com', '5555555', '2023-03-17'),
('David', 'Mora', 'david.mora@gmail.com', '2222222', '2021-08-27');

-- Visualizar la tabla
SELECT * FROM Clientes;


-- Insertar registros en la tabla Productos
INSERT INTO Productos (Nombre_Producto, Precio_Producto, Stock, Descripcion)
VALUES 
('Computador', 1000.00, 65, 'Computador con procesador i9, 64GB RAM y 2048GB HDD'),
('Tablet', 500.00, 115, 'Tablet con pantalla SOLID y cámara HD de 80MP'),
('Parlantes', 170.00, 222, 'Parlantes inalámbricos Bluetooth');

-- Visualizar la tabla
SELECT * FROM Productos;


-- Insertar registros en la tabla Pedidos
INSERT INTO Pedidos (Cliente_ID, Fecha_Pedido, Total)
VALUES 
(1, '2023-12-10', 1170.00), 
(2, '2023-12-05', 500.00),
(3, '2023-12-01', 1000.00);

-- Visualizar la tabla
SELECT * FROM Pedidos;

-- Insertar registros en la tabla Detalles_Pedido
INSERT INTO Detalles_Pedido (Pedido_ID, Producto_ID, Cantidad, Precio_Unitario)
VALUES 
(1, 1, 1, 1000.00),  
(1, 3, 1, 170.00),   
(2, 2, 1, 500.00),   
(3, 1, 1, 1000.00);  

-- Visualizar la tabla
SELECT * FROM Detalles_Pedido;

-- Función para obtener el nombre completo de un cliente:
-- Esta función debe aceptar un cliente_id como 
-- parámetro y devolver el nombre completo (nombre + apellido) del cliente.

DELIMITER //
CREATE FUNCTION Obtener_Nombre_Apellido(p_Cliente_ID INT)
RETURNS VARCHAR(200)
DETERMINISTIC

BEGIN
    DECLARE Nombres_Apellido VARCHAR(250);

    SELECT CONCAT(Nombre_Cliente, ' ', Apellido_Cliente) 
    INTO Nombres_Apellido
    FROM Clientes
    WHERE Cliente_ID = p_Cliente_ID;

    RETURN Nombres_Apellido;
END //
DELIMITER ;


-- Función para calcular el descuento de un producto:
-- Esta función debe aceptar el precio y el descuento 
-- como parámetros y devolver el precio con descuento.

DELIMITER //
CREATE FUNCTION Calcular_Descuento(Precio DECIMAL(10,2), Descuento DECIMAL(5,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC

BEGIN
    DECLARE Precio_Con_Descuento DECIMAL(10,2);
    SET Precio_Con_Descuento = Precio - (Precio * Descuento / 100);
    RETURN Precio_Con_Descuento;
END //
DELIMITER ;


-- Función para calcular el total de un pedido:
-- Esta función debe aceptar un pedido_id y calcular 
-- el total del pedido sumando los precios de los 
-- productos multiplicados por sus respectivas cantidades.

DELIMITER $$
CREATE FUNCTION Calcular_Total_Pedido(pedido_id INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC

BEGIN
    DECLARE total DECIMAL(10,2) DEFAULT 0.00;
                -- Sumar el precio de cada producto * cantidad
    SELECT SUM(dp.Cantidad * dp.Precio_Unitario) 
    INTO total
    FROM Detalles_Pedido dp
    WHERE dp.Pedido_ID = pedido_id;
    
    RETURN total;
END $$
DELIMITER ;


-- Función para verificar la disponibilidad de stock de un producto:
-- Esta función debe aceptar un producto_id y una cantidad 
-- como parámetros y devolver TRUE si el stock disponible 
-- es suficiente, de lo contrario, debe devolver FALSE.

DELIMITER //
CREATE FUNCTION Verificar_Stock_Disponible(Producto_ID INT, Cantidad INT)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE Stock_Disponible INT;
    
    SELECT Stock INTO Stock_Disponible
    FROM Productos
    WHERE Producto_ID = Producto_ID
    LIMIT 1;
    
    IF Stock_Disponible >= Cantidad THEN
        RETURN TRUE;  -- 1 = Stock disponible
    ELSE
        RETURN FALSE ; -- 0 = Stock no disponible
    END IF;
END //
DELIMITER ;


-- Función para calcular la antigüedad de un cliente:
-- Esta función debe aceptar un cliente_id y calcular 
-- la antigüedad del cliente en años a partir de la fecha de registro.

DELIMITER //
CREATE FUNCTION Calcular_Antiguedad_Cliente(a_cliente_id INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE año_registro INT;
    DECLARE año_actual INT;
    DECLARE antiguedad INT;

    -- Obtener el año de registro del cliente 
    SELECT YEAR(Fecha_Registro)
    INTO año_registro
    FROM Clientes
    WHERE Cliente_ID = a_cliente_id
    LIMIT 1;

    -- Obtener año actual
    SET año_actual = YEAR(CURDATE());

    -- Calcular antigüedad del cliente en años
    SET antiguedad = año_actual - año_registro;

    -- Retornar antigüedad en años
    RETURN antiguedad;
END //
DELIMITER ;

-- Seleccionar la función Calcular_Antiguedad_Cliente
SELECT Calcular_Antiguedad_Cliente(1) AS Años_Antigüedad;



-- Seleccionar la función Obtener_Nombre_Apellido
SELECT Obtener_Nombre_Apellido(1); 

-- Seleccionar la función Calcular_Descuento
SELECT Calcular_Descuento(170.00, 10);

-- Seleccionar la función Calcular_Total_Pedido
SELECT Calcular_Total_Pedido(2);


-- Seleccionar la función Verificar_Stock_Disponible con ID del Producto y la cantidad
-- True=1, False=0
SELECT Verificar_Stock_Disponible(1, 23);

-- Seleccionar la función Verificar_Stock_Disponible con ID del Producto y la cantidad
-- True=1, False=0
SELECT Verificar_Stock_Disponible(1, 105);

-- ___________________________________________

-- PARTE 2
-- Aprendizaje de Funciones SQL: Creación, Análisis y
-- Ejecución
-- Objetivo:
-- El objetivo de esta actividad es aprender a crear y utilizar funciones definidas por el usuario en SQL, analizar su estructura y lógica, y practicar la creación de tablas y consultas con funciones personalizadas. También se incluirán ejemplos prácticos para mostrar cómo utilizar estas funciones en un contexto real.
-- Instrucciones:
-- 1.	Transcripción y análisis del código SQL.
-- 2.	Creación de las tablas necesarias para almacenar los datos.
-- 3.	Ejecución de las funciones SQL creadas y captura de los resultados.
-- 4.	Explicación detallada de cada línea del código.

-- Se crea y se selecciona la base de datos.
CREATE DATABASE Parte2;
USE Parte2;

-- EJERCICIO 1
-- Se crea la función
DELIMITER $$
CREATE FUNCTION CalcularTotalOrden(id_orden INT) -- LA función CalcularTotalOrden tiene un parámetro id_orden de tipo entero.
RETURNS DECIMAL(10,2)  -- La función devolverá un valor tipo DECIMAL de 10 dígitos y 2 decimales.
DETERMINISTIC    
BEGIN
-- Se declaran dos variables: el total y el iva, de tipo DECIMAL.
	DECLARE total DECIMAL(10, 2);  
    DECLARE iva DECIMAL(10, 2);
    
    SET iva = 0.15;  -- Se asigna el valor de 15% a la variable iva.
    
    SELECT SUM(P.precio * O.cantidad) INTO total -- Se calcular el precio total multiplicando el precio de cada producto por la cantidad.
    FROM Ordenes O 
    JOIN Productos P ON O.ProductoID = p.ProductoID
    WHERE O.OrdenID = id_orden;
    
    SET total = total + (total * iva);  -- Se suma el total con el iva.
    
    RETURN total;   -- Devuelve el valor total, calculado con el IVA.
END $$
DELIMITER ;


-- Crear la tabla Productos
CREATE TABLE Productos (
    ProductoID INT AUTO_INCREMENT PRIMARY KEY,  
    Nombre VARCHAR(100) NOT NULL,               
    Precio DECIMAL(10, 2) NOT NULL,             
    Stock INT NOT NULL                  
);

-- Crear la tabla Ordenes
CREATE TABLE Ordenes (
    OrdenID INT AUTO_INCREMENT PRIMARY KEY,    
    ClienteID INT NOT NULL,                    
    Fecha DATE NOT NULL,                       
    ProductoID INT,                            
    Cantidad INT NOT NULL,                     
    FOREIGN KEY (ProductoID) REFERENCES Productos(ProductoID) 
);


-- Insertar registros en la tabla Productos
INSERT INTO Productos (Nombre, Precio, Stock) VALUES 
('Sardina', 12.00, 50),
('Atún', 24.00, 30),
('Fideos', 13.00, 10),  
('Arroz', 26.00, 20);


-- Insertar registros en la tabla Ordenes
INSERT INTO Ordenes (ClienteID, Fecha, ProductoID, Cantidad) VALUES
(1, '2024-06-01', 1, 2),  
(1, '2024-06-02', 2, 1),  
(2, '2024-06-03', 3, 5), 
(3, '2024-06-04', 4, 3); 

-- Seleccionar la función CalcularTotalOrden
Select CalcularTotalOrden(2) AS TotalOrdenConIVA; 



-- EJERCICIO 2
-- Se crea la función
DELIMITER $$
CREATE FUNCTION CalcularEdad(fecha_nacimiento DATE) -- Función que toma un parámetro fecha tipo DATE.
RETURNS INT   -- La función devuelve un valor de tipo INT.
DETERMINISTIC
BEGIN
	DECLARE edad INT;
    SET edad = TIMESTAMPDIFF(YEAR, fecha_nacimiento, CURDATE());  -- Se usa la función TIMESTAMPDIFF para la diferencia en años entre la fecha_nacimiento y fecha actual (CURDATE()).
    RETURN edad;   -- Devuelve la edad calculada.
END $$
DELIMITER ;


-- Crear la tabla Clientes
CREATE TABLE Clientes (
    ClienteID INT AUTO_INCREMENT PRIMARY KEY,  
    Nombre VARCHAR(100) NOT NULL,             
    FechaNacimiento DATE NOT NULL             
);


-- Insertar registro en la tabla Clientes
INSERT INTO Clientes (Nombre, FechaNacimiento) VALUES
('Mauricio Montalvo', '1993-03-15'),
('Mishelle Constante', '1982-07-21'),
('Javier Maldonado', '2003-11-05');


-- Seleccionar la función CalcularEdad
SELECT CalcularEdad(FechaNacimiento) AS EdadCliente
FROM Clientes
WHERE ClienteID = 3;


-- EJERCICIO 3
-- Se crea la función
DELIMITER $$
CREATE FUNCTION VerificarStock(producto_id INT) -- Función que toma un parámetro producto_id de tipo INT.

RETURNS BOOLEAN  -- La función devuelve un valor BOOLEAN indicando si hay o no hay stock del producto.
DETERMINISTIC
BEGIN
	DECLARE stock_A INT;
    SELECT stock INTO stock_A -- Realizar una consulta a la tabla Productos para obtener la cantidad de stock del producto.
    FROM Productos
    WHERE ProductoID = producto_id;
    
    IF stock_A > 0 THEN  -- Si el stock es mayor que 0, la función devuelve TRUE = 1, stock disponible.
		RETURN TRUE;
	ELSE
		RETURN FALSE; -- Si no hay stock devuelve FALSE = 0.
	END IF;  -- Se cierra la estructura condicional.
END $$
DELIMITER ;


-- Crear la tabla Productos
CREATE TABLE Productos (
    ProductoID INT AUTO_INCREMENT PRIMARY KEY,  
    Nombre VARCHAR(100) NOT NULL,               
    Precio DECIMAL(10, 2) NOT NULL,             
    Stock INT NOT NULL                  
);

-- Insertar registros en la tabla Productos
INSERT INTO Productos (Nombre, Precio, Stock) VALUES 
('Sardina', 12.00, 50),
('Atún', 24.00, 30),
('Fideos', 13.00, 10),  
('Arroz', 26.00, 20);


-- Seleccionar la función VerificarStock
SELECT VerificarStock(3) AS StockDisponible;
-- True=1,  False=0



-- EJERCICIO 4
-- Se crea la función
DELIMITER $$
CREATE FUNCTION CalcularSaldo(id_cuenta int) -- La función toma un parámetro id_cuenta de tipo INT.
RETURNS DECIMAL(10, 2) -- La función devuelve un valor de tipo DECIMAL con 10 dígitos y 2 decimales.
DETERMINISTIC
BEGIN
	DECLARE saldo DECIMAL(10,2);
	-- Se utiliza una consulta SELECT para calcular el saldo. 
    -- Si la transacción es un "depósito" se agrega el monto al saldo y si es un "retiro" se resta.
    
    SELECT SUM(CASE   
		WHEN TipoTransaccion = 'deposito' THEN monto
        WHEN TipoTransaccion = 'retiro' THEN -monto
		ELSE 0
	END) INTO saldo
    FROM Transacciones  -- Se filtra las transacciones donde la cuenta_id coincide con el parámetro id_cuenta.
    WHERE CuentaID  = id_cuenta;
    
    RETURN saldo;  -- Devuelve el saldo de la transacción.
END $$
DELIMITER ;


-- Crear la tabla Cuentas
CREATE TABLE Cuentas (
    CuentaID INT AUTO_INCREMENT PRIMARY KEY,    
    ClienteID INT NOT NULL,                     
    Saldo DECIMAL(10, 2) NOT NULL               
);

-- Crear la tabla Transacciones 
CREATE TABLE Transacciones (
    TransaccionID INT AUTO_INCREMENT PRIMARY KEY,  
    CuentaID INT NOT NULL,                         
    TipoTransaccion ENUM('deposito', 'retiro') NOT NULL,  
    Monto DECIMAL(10, 2) NOT NULL,                 
    Fecha DATE NOT NULL,                           
    FOREIGN KEY (CuentaID) REFERENCES Cuentas(CuentaID)  
);


-- Insertar registros en la tabla Cuentas
INSERT INTO Cuentas (ClienteID, Saldo) VALUES
(1, 7000.00),  
(2, 5000.00),  
(3, 2000.00);  



-- Insertar registros en la tabla Transacciones
INSERT INTO Transacciones (CuentaID, TipoTransaccion, Monto, Fecha) VALUES
(1, 'deposito', 250.00, '2024-07-01'),  
(1, 'retiro', 100.00, '2024-07-02'),    
(2, 'deposito', 550.00, '2024-07-03'),  
(3, 'retiro', 115.00, '2024-07-04');    

-- Seleccionar la función CalcularSaldo
SELECT CalcularSaldo(2) AS MontoTransacción;


























