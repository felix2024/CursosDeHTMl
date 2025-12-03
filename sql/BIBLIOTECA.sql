/* ============================================================================
   SECCIÓN 1: CONFIGURACIÓN DE BASE DE DATOS Y FILEGROUPS
   ============================================================================ */

-- Eliminar base de datos si existe (CUIDADO: borra todos los datos)
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'BIBLIOTECA')
BEGIN
    ALTER DATABASE BIBLIOTECA SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE BIBLIOTECA;
END
GO

-- Crear base de datos con filegroups
CREATE DATABASE BIBLIOTECA
ON PRIMARY 
(
    NAME = N'Biblioteca_Primary',
    FILENAME = N'C:\leopoldo_proyecto\Biblioteca_Primary.mdf',
    SIZE = 8 MB,
    FILEGROWTH = 64 MB
),
FILEGROUP TABLAS_DATA
(
    NAME = N'Tablas_Data',
    FILENAME = N'C:\leopoldo_proyecto\Tablas_Data.ndf',
    SIZE = 8 MB,
    FILEGROWTH = 64 MB
),
FILEGROUP FG_Historico_2025_T1
(
    NAME = N'Historico_2025_T1',
    FILENAME = N'C:\leopoldo_proyecto\Historico_2025_T1.ndf',
    SIZE = 8 MB,
    FILEGROWTH = 64 MB
),
FILEGROUP FG_Historico_2025_T2
(
    NAME = N'Historico_2025_T2',
    FILENAME = N'C:\leopoldo_proyecto\Historico_2025_T2.ndf',
    SIZE = 8 MB,
    FILEGROWTH = 64 MB
),
FILEGROUP FG_Historico_2025_T3
(
    NAME = N'Historico_2025_T3',
    FILENAME = N'C:\leopoldo_proyecto\Historico_2025_T3.ndf',
    SIZE = 8 MB,
    FILEGROWTH = 64 MB
),
FILEGROUP FG_Historico_2025_T4
(
    NAME = N'Historico_2025_T4',
    FILENAME = N'C:\leopoldo_proyecto\Historico_2025_T4.ndf',
    SIZE = 8 MB,
    FILEGROWTH = 64 MB
)
LOG ON
(
    NAME = N'Biblioteca_log',
    FILENAME = N'C:\leopoldo_proyecto\Biblioteca_log.ldf',
    SIZE = 8 MB,
    FILEGROWTH = 64 MB
);
GO

USE BIBLIOTECA;
GO

/* ============================================================================
   SECCIÓN 2: ESQUEMAS Y CONFIGURACIÓN DE PARTICIONAMIENTO
   ============================================================================ */

-- Creación de esquemas para organizar las tablas
CREATE SCHEMA libros;
GO
CREATE SCHEMA usuarios;
GO
CREATE SCHEMA prestamos;
GO

-- Función de partición por trimestres 2025
CREATE PARTITION FUNCTION PF_HistoricoPorTrimestre_2025 (DATE)
AS RANGE RIGHT FOR VALUES (
    '2025-04-01',  -- Límite T1 (Ene-Mar)
    '2025-07-01',  -- Límite T2 (Abr-Jun)
    '2025-10-01'   -- Límite T3 (Jul-Sep)
);
GO

-- Esquema de partición
CREATE PARTITION SCHEME PS_HistoricoPorTrimestre_2025
AS PARTITION PF_HistoricoPorTrimestre_2025
TO (
    FG_Historico_2025_T1,
    FG_Historico_2025_T2,
    FG_Historico_2025_T3,
    FG_Historico_2025_T4
);
GO

/* ============================================================================
   SECCIÓN 3: ESQUEMA USUARIOS - Gestión de usuarios
   ============================================================================ */

CREATE TABLE usuarios.Usuario (
    usuario_no INT PRIMARY KEY,
    apellido NVARCHAR(50) NOT NULL,
    nombre NVARCHAR(50) NOT NULL,
    inicial CHAR(1)
) ON TABLAS_DATA;
GO

CREATE TABLE usuarios.Adulto (
    usuario_adulto_no INT PRIMARY KEY,
    usuario_no INT NOT NULL,
    calle NVARCHAR(100),
    ciudad NVARCHAR(50),
    estado NVARCHAR(50),
    codigopostal CHAR(5),
    telefono CHAR(10),
    fecha_exp DATE NOT NULL,
    FOREIGN KEY (usuario_no) REFERENCES usuarios.Usuario(usuario_no)
) ON TABLAS_DATA;
GO

CREATE TABLE usuarios.Joven (
    usuario_joven_no INT PRIMARY KEY,
    usuario_no INT NOT NULL,
    adulto_usuario_no INT NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    FOREIGN KEY (usuario_no) REFERENCES usuarios.Usuario(usuario_no),
    FOREIGN KEY (adulto_usuario_no) REFERENCES usuarios.Adulto(usuario_adulto_no)
) ON TABLAS_DATA;
GO

/* ============================================================================
   SECCIÓN 4: ESQUEMA LIBROS - Gestión del catálogo
   ============================================================================ */

CREATE TABLE libros.Titulo (
    titulo_no INT PRIMARY KEY,
    titulo NVARCHAR(100) NOT NULL,
    autor NVARCHAR(100) NOT NULL
) ON TABLAS_DATA;
GO

CREATE TABLE libros.Descripcion_Libro (
    isbn VARCHAR(13) NOT NULL PRIMARY KEY,
    titulo_no INT NOT NULL,
    idioma NVARCHAR(30),
    pasta NVARCHAR(5),
    prestable CHAR(1) CHECK (prestable IN ('Y','N')),
    FOREIGN KEY (titulo_no) REFERENCES libros.Titulo(titulo_no)
) ON TABLAS_DATA;
GO

CREATE TABLE libros.Copia (
    isbn VARCHAR(13) NOT NULL,
    copy_no SMALLINT NOT NULL,
    en_prestamo CHAR(1) DEFAULT 'N' CHECK (en_prestamo IN ('Y','N')),
    PRIMARY KEY (isbn, copy_no),
    FOREIGN KEY (isbn) REFERENCES libros.Descripcion_Libro(isbn)
) ON TABLAS_DATA;
GO

/* ============================================================================
   SECCIÓN 5: ESQUEMA PRESTAMOS - Gestión de préstamos
   ============================================================================ */

CREATE TABLE prestamos.Prestamo (
    isbn VARCHAR(13) NOT NULL,
    copy_no SMALLINT NOT NULL,
    titulo_no INT NOT NULL,
    usuario_no INT NOT NULL,
    fecha_prestamo DATE NOT NULL,
    fecha_regreso DATE NOT NULL,
    PRIMARY KEY (isbn, copy_no, fecha_prestamo),
    FOREIGN KEY (isbn, copy_no) REFERENCES libros.Copia(isbn, copy_no),
    FOREIGN KEY (usuario_no) REFERENCES usuarios.Usuario(usuario_no)
) ON TABLAS_DATA;
GO

CREATE TABLE prestamos.Historico_Prestamo (
    isbn VARCHAR(13) NOT NULL,
    copy_no SMALLINT NOT NULL,
    titulo_no INT NOT NULL,
    usuario_no INT NOT NULL,
    fecha_prestamo DATE NOT NULL,
    fecha_registro DATE NOT NULL,
    fecha_entrega DATE NULL,
    multa_asignada DECIMAL(6,2) NULL,
    multa_pagada DECIMAL(6,2) NULL,
    PRIMARY KEY NONCLUSTERED (isbn, copy_no, fecha_prestamo),
    FOREIGN KEY (isbn, copy_no) REFERENCES libros.Copia(isbn, copy_no),
    FOREIGN KEY (usuario_no) REFERENCES usuarios.Usuario(usuario_no)
) ON PS_HistoricoPorTrimestre_2025(fecha_prestamo);
GO

CREATE TABLE prestamos.Reservacion (
    isbn VARCHAR(13) NOT NULL,
    usuario_no INT NOT NULL,
    fecha_reserva DATE NULL,
    PRIMARY KEY (isbn, usuario_no),
    FOREIGN KEY (isbn) REFERENCES libros.Descripcion_Libro(isbn),
    FOREIGN KEY (usuario_no) REFERENCES usuarios.Usuario(usuario_no)
) ON TABLAS_DATA;
GO

/* ============================================================================
   SECCIÓN 6: PROCEDIMIENTOS ALMACENADOS
   ============================================================================ */

-- Procedimiento: Registrar préstamo
CREATE OR ALTER PROCEDURE prestamos.RealizarPrestamo
    @isbn VARCHAR(13),
    @copy_no SMALLINT,
    @usuario_no INT,
    @fecha_prestamo DATE,
    @fecha_regreso DATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM prestamos.Prestamo
        WHERE usuario_no = @usuario_no
          AND fecha_regreso < GETDATE()
    )
    BEGIN
        RAISERROR('El usuario tiene préstamos vencidos.', 16, 1);
        RETURN;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE libros.Copia
        SET en_prestamo = 'Y'
        WHERE isbn = @isbn
          AND copy_no = @copy_no
          AND en_prestamo = 'N';

        IF @@ROWCOUNT = 0
            THROW 50000, 'El libro ya está prestado o no existe.', 1;

        INSERT INTO prestamos.Prestamo (isbn, copy_no, titulo_no, usuario_no, fecha_prestamo, fecha_regreso)
        SELECT d.isbn, @copy_no, d.titulo_no, @usuario_no, @fecha_prestamo, @fecha_regreso
        FROM libros.Descripcion_Libro d
        WHERE d.isbn = @isbn;

        COMMIT TRANSACTION;
        PRINT 'ÉXITO: Préstamo registrado correctamente.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        PRINT 'ERROR: No se completó la transacción.';
        THROW;
    END CATCH;
END;
GO

-- Procedimiento: Procesar devolución
CREATE OR ALTER PROCEDURE prestamos.DevolverPrestamo
    @isbn VARCHAR(13),
    @copy_no SMALLINT,
    @fecha_entrega DATE
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE
            @fecha_regreso DATE,
            @usuario_no INT,
            @titulo_no INT,
            @fecha_prestamo DATE,
            @multa DECIMAL(6,2) = 0;

        SELECT TOP 1
            @fecha_regreso = fecha_regreso,
            @usuario_no = usuario_no,
            @titulo_no = titulo_no,
            @fecha_prestamo = fecha_prestamo
        FROM prestamos.Prestamo
        WHERE isbn = @isbn AND copy_no = @copy_no;

        IF @usuario_no IS NULL
        BEGIN
            RAISERROR('No se encontró préstamo activo para este libro.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        IF @fecha_entrega > @fecha_regreso
            SET @multa = DATEDIFF(DAY, @fecha_regreso, @fecha_entrega) * 5;

        INSERT INTO prestamos.Historico_Prestamo (
            isbn, copy_no, titulo_no, usuario_no, fecha_prestamo,
            fecha_registro, fecha_entrega, multa_asignada
        )
        VALUES (
            @isbn, @copy_no, @titulo_no, @usuario_no,
            @fecha_prestamo, GETDATE(), @fecha_entrega, @multa
        );

        DELETE FROM prestamos.Prestamo
        WHERE isbn = @isbn AND copy_no = @copy_no;

        UPDATE libros.Copia
        SET en_prestamo = 'N'
        WHERE isbn = @isbn AND copy_no = @copy_no;

        COMMIT TRANSACTION;

        PRINT 'ÉXITO: Devolución procesada correctamente.';
        IF @multa > 0
            PRINT 'MULTA: $' + CAST(@multa AS VARCHAR(10)) + ' por ' + 
                  CAST(DATEDIFF(DAY, @fecha_regreso, @fecha_entrega) AS VARCHAR(5)) + ' días de retraso.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        PRINT 'ERROR: No se pudo procesar la devolución.';
        THROW;
    END CATCH;
END;
GO

/* ============================================================================
   SECCIÓN 7: ÍNDICES Y OPTIMIZACIÓN
   ============================================================================ */

-- Índice 1: Histórico por fecha (CLUSTERED)
CREATE CLUSTERED INDEX IX_Historico_FechaPrestamo
ON prestamos.Historico_Prestamo (fecha_prestamo)
INCLUDE (isbn, copy_no, usuario_no, fecha_entrega, multa_asignada);
GO

-- Índice 2: Histórico por usuario
CREATE NONCLUSTERED INDEX IX_Historico_Usuario
ON prestamos.Historico_Prestamo (usuario_no)
INCLUDE (isbn, copy_no, multa_asignada, multa_pagada, fecha_prestamo);
GO

-- Índice 3: Estado de copias
CREATE NONCLUSTERED INDEX IX_Copia_EnPrestamo
ON libros.Copia (en_prestamo)
INCLUDE (isbn, copy_no);
GO

-- Índice 4: Préstamos activos por usuario
CREATE NONCLUSTERED INDEX IX_Prestamo_Usuario_Covering
ON prestamos.Prestamo (usuario_no)
INCLUDE (isbn, copy_no, fecha_prestamo, fecha_regreso);
GO

-- Índice 5: Libros por idioma y prestabilidad
CREATE NONCLUSTERED INDEX IX_Descripcion_Libro_Idioma_Prestable
ON libros.Descripcion_Libro(idioma, prestable)
INCLUDE (isbn, titulo_no);
GO

-- Índice 6: Préstamos por fecha
CREATE NONCLUSTERED INDEX IX_Prestamo_Fecha
ON prestamos.Prestamo(fecha_prestamo)
INCLUDE (usuario_no, isbn, copy_no);
GO

-- Índice 7: Usuarios por ciudad
CREATE NONCLUSTERED INDEX IX_Adulto_Ciudad
ON usuarios.Adulto(ciudad)
INCLUDE (usuario_adulto_no, calle, telefono, fecha_exp);
GO

-- Índice 8: Libros prestables
CREATE NONCLUSTERED INDEX IX_Descripcion_Prestable
ON libros.Descripcion_Libro(prestable)
INCLUDE (isbn, titulo_no);
GO

-- Índice 9: Préstamos por usuario y fecha
CREATE NONCLUSTERED INDEX IX_Prestamo_Usuario_Fecha
ON prestamos.Prestamo(usuario_no, fecha_prestamo)
INCLUDE (isbn, copy_no, fecha_regreso);
GO

/* ============================================================================
   SECCIÓN 8: SEGURIDAD - Logins y Usuarios
   ============================================================================ */

USE master;
GO

-- Crear logins (nivel servidor)
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = N'Login_Biblio_Jefe')
    CREATE LOGIN [Login_Biblio_Jefe] WITH PASSWORD=N'Admin123!', CHECK_POLICY=OFF;

IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = N'Login_Lector_01')
    CREATE LOGIN [Login_Lector_01] WITH PASSWORD=N'UserPass1!', CHECK_POLICY=OFF;

IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = N'Login_Auditor_X')
    CREATE LOGIN [Login_Auditor_X] WITH PASSWORD=N'Audit2025!', CHECK_POLICY=OFF;
GO

USE BIBLIOTECA;
GO

-- Crear usuarios (nivel base de datos)
CREATE USER [User_Bibliotecario] FOR LOGIN [Login_Biblio_Jefe];
CREATE USER [User_Lector] FOR LOGIN [Login_Lector_01];
CREATE USER [User_Auditor] FOR LOGIN [Login_Auditor_X];
GO

PRINT 'Base de datos BIBLIOTECA creada y configurada correctamente.';
GO

/* ============================================================================
   SECCIÓN 9: ASIGNACIÓN DE ROLES Y PERMISOS (El paso final)
   ============================================================================ */

-- 1. Crear los Roles
CREATE ROLE [Rol_Bibliotecario];
CREATE ROLE [Rol_Lector];
CREATE ROLE [Rol_Auditor];
GO

-- 2. Asignar Permisos a los Roles
-- Bibliotecario: Dueño de la operación
GRANT SELECT, INSERT, UPDATE ON SCHEMA::[usuarios] TO [Rol_Bibliotecario];
GRANT SELECT, INSERT, UPDATE ON SCHEMA::[libros] TO [Rol_Bibliotecario];
GRANT EXECUTE, SELECT ON SCHEMA::[prestamos] TO [Rol_Bibliotecario];

-- Lector: Solo ver catálogo
GRANT SELECT ON libros.Titulo TO [Rol_Lector];
GRANT SELECT ON libros.Descripcion_Libro TO [Rol_Lector];
GRANT SELECT ON libros.Copia TO [Rol_Lector];

-- Auditor: Ver histórico
GRANT SELECT ON prestamos.Historico_Prestamo TO [Rol_Auditor];
GO

-- 3. Meter a los Usuarios en los Roles
ALTER ROLE [Rol_Bibliotecario] ADD MEMBER [User_Bibliotecario];
ALTER ROLE [Rol_Lector] ADD MEMBER [User_Lector];
ALTER ROLE [Rol_Auditor] ADD MEMBER [User_Auditor];
GO

PRINT 'Script finalizado exitosamente. Base de datos lista para producción.';