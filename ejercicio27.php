<?php

class UnaClase {

    public static function unMetodo(){
        echo "Hola Mundo";
    }
}


$obj = new UnaClase();
$obj->unMetodo();

UnaClase::unMetodo();
?>