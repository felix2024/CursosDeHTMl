<?php

if($_POST){
    $valorA = $_POST['valorA'];
    $valorB = $_POST['valorB'];

    $suma = $valorA + $valorb;
    $resta = $valorA - $valorb;
    $multripicacion = $valorA * $valorb;
    $division = $valorA / $valorb;



    echo "<br/>".$suma;
    echo "<br/>".$resta;
    echo "<br/>".$multripicacion;
    echo "<br/>".$division;




}



?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Operadores aritmeticos</title>
</head>
<body>
    <form action="ejercicio8.php" method="post">
        Valor A:
        <input type="text"name="valorA">
        Valor B:
        <input type="text"name="valorB">
        <br>
        <input type="submit" value="Calcular">
    </form>
</body>
</html>