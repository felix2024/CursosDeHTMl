<?php

$servidor = "localhost"; //127.0.0.1
$usuario = "root";
$password = "";

try {
    $conexion = new PDO("mysql:host=$servidor;dbname=album", $usuario, $password);
    $conexion->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo "Conexión establecida correctamente";
    
    $sql = "SELECT * FROM fotos";

    $sentencia= $conexion->prepare($sql);
    $sentencia->execute();

    $resultado = $sentencia ->fetchAll();

    $conexion->exec($sql);
    


    foreach($resultado as $foto){
            print_r ($foto);


    }

}catch (PDOException $e){
    echo "Error de conexión: " . $e->getMessage();
}



?>