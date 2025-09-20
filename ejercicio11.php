<?php

if($_POST){
    $valorA = $_POST['valorA'];
    $valorB = $_POST['valorB'];

    $suma = $valorA + $valorB;
    $resta = $valorA - $valorB;
    $multripicacion = $valorA * $valorB;
    $division = $valorA / $valorB;



    echo "<br/>".$suma;
    echo "<br/>".$resta;
    echo "<br/>".$multripicacion;
    echo "<br/>".$division;


    if($valorA == $valorB){
        echo "El valor de A es mayor que el valor de B ";
        
        if($valorA ==4){
            echo "El valor de A es igual a 4";


        }

        if($valorA==5){


            echo "el valor es 5";
        }
        
    
    


    }


    if($valorA === $valorB) {
        echo "El valor de A es igual a B y es el numero 4";
    }



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
    <form action="ejercicio11.php" method="post">
        Valor A:
        <input type="text"name="valorA">
        Valor B:
        <input type="text"name="valorB">
        <br>
        <input type="submit" value="Calcular">
    </form>
</body>
</html>