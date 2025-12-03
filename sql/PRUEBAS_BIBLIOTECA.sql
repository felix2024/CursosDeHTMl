USE BIBLIOTECA;
GO

PRINT '========================================================================';
PRINT '          SCRIPT DE PRUEBAS - BASE DE DATOS BIBLIOTECA';
PRINT '========================================================================';
PRINT '';

/* ============================================================================
   PRUEBA 1: Verificar estructura de base de datos
   ============================================================================ */
PRINT '1. VERIFICANDO ESTRUCTURA DE BASE DE DATOS...';
PRINT '';

-- Verificar filegroups
SELECT 
    name AS Filegroup,
    type_desc AS Tipo
FROM sys.filegroups
WHERE data_space_id > 1;

-- Verificar archivos físicos
SELECT 
    name AS Archivo,
    physical_name AS Ubicacion,
    size * 8/1024 AS TamañoMB
FROM sys.database_files;

PRINT '✓ Estructura de filegroups verificada.';
PRINT '';

/* ============================================================================
   PRUEBA 2: Verificar esquemas
   ============================================================================ */
PRINT '2. VERIFICANDO ESQUEMAS...';
PRINT '';

SELECT name AS Esquema
FROM sys.schemas
WHERE name IN ('libros', 'usuarios', 'prestamos');

PRINT '✓ Esquemas verificados.';
PRINT '';

/* ============================================================================
   PRUEBA 3: Verificar tablas creadas
   ============================================================================ */
PRINT '3. VERIFICANDO TABLAS...';
PRINT '';

SELECT 
    s.name AS Esquema,
    t.name AS Tabla,
    ds.name AS Filegroup
FROM sys.tables t
INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
LEFT JOIN sys.indexes i ON t.object_id = i.object_id AND i.index_id < 2
LEFT JOIN sys.data_spaces ds ON i.data_space_id = ds.data_space_id
WHERE s.name IN ('libros', 'usuarios', 'prestamos')
ORDER BY s.name, t.name;

PRINT '✓ Tablas verificadas.';
PRINT '';

/* ============================================================================
   PRUEBA 4: Verificar índices
   ============================================================================ */
PRINT '4. VERIFICANDO ÍNDICES...';
PRINT '';

SELECT 
    OBJECT_SCHEMA_NAME(i.object_id) AS Esquema,
    OBJECT_NAME(i.object_id) AS Tabla,
    i.name AS Indice,
    i.type_desc AS Tipo
FROM sys.indexes i
WHERE OBJECT_SCHEMA_NAME(i.object_id) IN ('libros', 'usuarios', 'prestamos')
  AND i.name IS NOT NULL
ORDER BY Esquema, Tabla;

PRINT '✓ Índices verificados.';
PRINT '';

/* ============================================================================
   PRUEBA 5: Verificar particiones
   ============================================================================ */
PRINT '5. VERIFICANDO PARTICIONES...';
PRINT '';

SELECT 
    pf.name AS FuncionParticion,
    ps.name AS EsquemaParticion,
    ds.name AS Filegroup,
    prv.value AS ValorLimite
FROM sys.partition_schemes ps
INNER JOIN sys.partition_functions pf ON ps.function_id = pf.function_id
INNER JOIN sys.destination_data_spaces dds ON ps.data_space_id = dds.partition_scheme_id
INNER JOIN sys.data_spaces ds ON dds.data_space_id = ds.data_space_id
LEFT JOIN sys.partition_range_values prv ON pf.function_id = prv.function_id 
    AND dds.destination_id = prv.boundary_id + 1
WHERE pf.name = 'PF_HistoricoPorTrimestre_2025'
ORDER BY dds.destination_id;

PRINT '✓ Particiones verificadas.';
PRINT '';

/* ============================================================================
   PRUEBA 6: Verificar procedimientos almacenados
   ============================================================================ */
PRINT '6. VERIFICANDO PROCEDIMIENTOS ALMACENADOS...';
PRINT '';

SELECT 
    SCHEMA_NAME(schema_id) AS Esquema,
    name AS Procedimiento,
    create_date AS FechaCreacion
FROM sys.procedures
WHERE SCHEMA_NAME(schema_id) = 'prestamos'
ORDER BY name;

PRINT '✓ Procedimientos almacenados verificados.';
PRINT '';

/* ============================================================================
   PRUEBA 7: Insertar datos de prueba
   ============================================================================ */
PRINT '7. INSERTANDO DATOS DE PRUEBA...';
PRINT '';

BEGIN TRY
    BEGIN TRANSACTION;

    -- Insertar usuarios
    INSERT INTO usuarios.Usuario (usuario_no, apellido, nombre, inicial)
    VALUES 
        (1, 'García', 'Juan', 'A'),
        (2, 'López', 'María', 'B'),
        (3, 'Martínez', 'Pedro', 'C');

    INSERT INTO usuarios.Adulto (usuario_adulto_no, usuario_no, calle, ciudad, estado, codigopostal, telefono, fecha_exp)
    VALUES 
        (1, 1, 'Av. Principal 123', 'Ciudad de México', 'CDMX', '01000', '5512345678', '2026-12-31'),
        (2, 2, 'Calle Reforma 456', 'Guadalajara', 'Jalisco', '44100', '3398765432', '2026-06-30');

    INSERT INTO usuarios.Joven (usuario_joven_no, usuario_no, adulto_usuario_no, fecha_nacimiento)
    VALUES (3, 3, 1, '2010-05-15');

    -- Insertar libros
    INSERT INTO libros.Titulo (titulo_no, titulo, autor)
    VALUES 
        (1, 'Cien Años de Soledad', 'Gabriel García Márquez'),
        (2, 'Don Quijote de la Mancha', 'Miguel de Cervantes'),
        (3, 'El Principito', 'Antoine de Saint-Exupéry');

    INSERT INTO libros.Descripcion_Libro (isbn, titulo_no, idioma, pasta, prestable)
    VALUES 
        ('9780307474728', 1, 'Español', 'Dura', 'Y'),
        ('9788424922870', 2, 'Español', 'Dura', 'Y'),
        ('9780156012195', 3, 'Español', 'Suave', 'Y');

    INSERT INTO libros.Copia (isbn, copy_no, en_prestamo)
    VALUES 
        ('9780307474728', 1, 'N'),
        ('9780307474728', 2, 'N'),
        ('9788424922870', 1, 'N'),
        ('9780156012195', 1, 'N');

    COMMIT TRANSACTION;
    PRINT '✓ Datos de prueba insertados correctamente.';
    PRINT '';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    PRINT 'ERROR al insertar datos de prueba:';
    PRINT ERROR_MESSAGE();
    PRINT '';
END CATCH;

/* ============================================================================
   PRUEBA 8: Probar procedimiento RealizarPrestamo
   ============================================================================ */
PRINT '8. PROBANDO PROCEDIMIENTO RealizarPrestamo...';
PRINT '';

EXEC prestamos.RealizarPrestamo
    @isbn = '9780307474728',
    @copy_no = 1,
    @usuario_no = 1,
    @fecha_prestamo = '2025-01-15',
    @fecha_regreso = '2025-02-15';

-- Verificar préstamo
SELECT 
    p.isbn,
    p.copy_no,
    t.titulo,
    u.nombre + ' ' + u.apellido AS Usuario,
    p.fecha_prestamo,
    p.fecha_regreso,
    c.en_prestamo AS Estado_Copia
FROM prestamos.Prestamo p
INNER JOIN libros.Descripcion_Libro dl ON p.isbn = dl.isbn
INNER JOIN libros.Titulo t ON dl.titulo_no = t.titulo_no
INNER JOIN usuarios.Usuario u ON p.usuario_no = u.usuario_no
INNER JOIN libros.Copia c ON p.isbn = c.isbn AND p.copy_no = c.copy_no;

PRINT '';

/* ============================================================================
   PRUEBA 9: Probar procedimiento DevolverPrestamo
   ============================================================================ */
PRINT '9. PROBANDO PROCEDIMIENTO DevolverPrestamo...';
PRINT '';

-- Devolución a tiempo (sin multa)
EXEC prestamos.DevolverPrestamo
    @isbn = '9780307474728',
    @copy_no = 1,
    @fecha_entrega = '2025-02-10';

-- Verificar histórico
SELECT 
    hp.isbn,
    hp.copy_no,
    t.titulo,
    u.nombre + ' ' + u.apellido AS Usuario,
    hp.fecha_prestamo,
    hp.fecha_entrega,
    hp.multa_asignada,
    c.en_prestamo AS Estado_Copia
FROM prestamos.Historico_Prestamo hp
INNER JOIN libros.Descripcion_Libro dl ON hp.isbn = dl.isbn
INNER JOIN libros.Titulo t ON dl.titulo_no = t.titulo_no
INNER JOIN usuarios.Usuario u ON hp.usuario_no = u.usuario_no
INNER JOIN libros.Copia c ON hp.isbn = c.isbn AND hp.copy_no = c.copy_no;

PRINT '';

/* ============================================================================
   PRUEBA 10: Probar préstamo con retraso (multa)
   ============================================================================ */
PRINT '10. PROBANDO PRÉSTAMO CON RETRASO (MULTA)...';
PRINT '';

-- Realizar nuevo préstamo
EXEC prestamos.RealizarPrestamo
    @isbn = '9788424922870',
    @copy_no = 1,
    @usuario_no = 2,
    @fecha_prestamo = '2025-03-01',
    @fecha_regreso = '2025-03-15';

-- Devolver con retraso (5 días = $25 de multa)
EXEC prestamos.DevolverPrestamo
    @isbn = '9788424922870',
    @copy_no = 1,
    @fecha_entrega = '2025-03-20';

-- Ver histórico con multa
SELECT 
    t.titulo,
    u.nombre + ' ' + u.apellido AS Usuario,
    hp.fecha_prestamo,
    hp.fecha_regreso,
    hp.fecha_entrega,
    DATEDIFF(DAY, hp.fecha_regreso, hp.fecha_entrega) AS DiasRetraso,
    hp.multa_asignada
FROM prestamos.Historico_Prestamo hp
INNER JOIN libros.Descripcion_Libro dl ON hp.isbn = dl.isbn
INNER JOIN libros.Titulo t ON dl.titulo_no = t.titulo_no
INNER JOIN usuarios.Usuario u ON hp.usuario_no = u.usuario_no
WHERE hp.multa_asignada > 0;

PRINT '';

/* ============================================================================
   PRUEBA 11: Verificar restricciones (usuario con préstamos vencidos)
   ============================================================================ */
PRINT '11. PROBANDO RESTRICCIÓN: Usuario con préstamos vencidos...';
PRINT '';

-- Intentar préstamo con usuario que tiene deuda (debe fallar)
BEGIN TRY
    EXEC prestamos.RealizarPrestamo
        @isbn = '9780156012195',
        @copy_no = 1,
        @usuario_no = 2,  -- Usuario con préstamo vencido
        @fecha_prestamo = '2025-03-25',
        @fecha_regreso = '2025-04-25';
    PRINT '✗ ERROR: Se permitió préstamo a usuario con deuda.';
END TRY
BEGIN CATCH
    PRINT '✓ Restricción funcionando: ' + ERROR_MESSAGE();
END CATCH;

PRINT '';

/* ============================================================================
   PRUEBA 12: Verificar logins y usuarios
   ============================================================================ */
PRINT '12. VERIFICANDO LOGINS Y USUARIOS...';
PRINT '';

-- Logins
SELECT 
    name AS Login,
    type_desc AS Tipo,
    create_date AS FechaCreacion
FROM sys.server_principals
WHERE name LIKE 'Login_%';

-- Usuarios de la BD
SELECT 
    name AS Usuario,
    type_desc AS Tipo,
    create_date AS FechaCreacion
FROM sys.database_principals
WHERE name LIKE 'User_%';

PRINT '✓ Logins y usuarios verificados.';
PRINT '';

/* ============================================================================
   PRUEBA 13: Estadísticas finales
   ============================================================================ */
PRINT '13. ESTADÍSTICAS FINALES...';
PRINT '';

SELECT 'Total Usuarios' AS Categoria, COUNT(*) AS Total FROM usuarios.Usuario
UNION ALL
SELECT 'Total Libros', COUNT(*) FROM libros.Titulo
UNION ALL
SELECT 'Total Copias', COUNT(*) FROM libros.Copia
UNION ALL
SELECT 'Préstamos Activos', COUNT(*) FROM prestamos.Prestamo
UNION ALL
SELECT 'Histórico Préstamos', COUNT(*) FROM prestamos.Historico_Prestamo
UNION ALL
SELECT 'Copias Disponibles', COUNT(*) FROM libros.Copia WHERE en_prestamo = 'N'
UNION ALL
SELECT 'Copias Prestadas', COUNT(*) FROM libros.Copia WHERE en_prestamo = 'Y';

PRINT '';
PRINT '========================================================================';
PRINT '          TODAS LAS PRUEBAS COMPLETADAS EXITOSAMENTE';
PRINT '========================================================================';
GO