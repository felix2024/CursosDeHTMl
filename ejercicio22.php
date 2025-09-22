<?php


$frutas = array ("m"=>"manzana", "b"=> "banana", "naranja", "fresa", "kiwi");


print_r($frutas);


echo $frutas ["m"]."<br>";



foreach ($frutas as $indice=>$valor){

    echo $valor."<br/>";

    echo $frutas[$indice]."<br/>";
}

?>