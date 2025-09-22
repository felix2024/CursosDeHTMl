<?php

$servidor = "localhost"; //127.0.0.1
$usuario = "root";
$password = "";

try {
    $conexion = new PDO("mysql:host=$servidor;dbname=album", $usuario, $password);
    $conexion->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo "Conexión establecida correctamente";
    
    $sql = "INSERT INTO `fotos` (`numero`, `nombre`, `ruta del archivo`) VALUES (NULL, 'Jugando con la programacion', 'foto.jpqj')";
    $conexion->exec($sql);
    

}catch (PDOException $e){
    echo "Error de conexión: " . $e->getMessage();
}



?>