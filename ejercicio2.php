<?php


//recibir informacion del formulario html metodo post
//para que funciona el metodo post
//para enviar informacion de manera segura
if($_POST){
    $nombre = $_POST['txtnombre'];
    echo "Hola Mundo " . $nombre;
}

?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
</head>
<body>
    <form action="ejercicio2.php" method="post">
        <input type="text" name="txtnombre" id="nombre">
        <br>
        <input type="submit" value="Enviar">
    </form>
</body>
</html>