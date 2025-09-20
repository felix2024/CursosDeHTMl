<?php


if($_POST){

    $boton=$_POST('boton');
    
    
    switch($boton){
        case 1:
            echo "Presiono el boton 1";
            break;
        case 2:
            echo "Presiono el boton 2";
            break;
        case 3:
            echo "Presiono el boton 3";
            break;
        


    }     

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
    <form action="ejercicio13.php" method="post">

    <br>
    <input type="button" value="1" name="boton">
    <input type="button" value="2" nmae="boton"> 
    <input type="button" value="3" name="boton"> 


    </form>
</body>

</html>