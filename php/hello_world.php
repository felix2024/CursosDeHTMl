<?php
//hola mundo
echo "Hola, PHP \n ";

/* 
hola
mundo
en
varias
lineas
*/

//variables tipo de datos primitivos
$my_String = "Esto es una cadena de texto"; //string
$my_String = "Esto es otra cadena de texto"; //reasignacion
echo $my_String . "\n"; //imprime variable string
echo gettype($my_String); //imprime tipo de variable


$my_String = 6;
echo $my_String . "\n"; //imprime variable 
echo gettype($my_String); //imprime tipo de variable

$my_String = "Esto es una cadena de texto"; //string

$my_int = 7; //integer
$my_int = $my_int + 3; //reasignacion
echo $my_int . "\n"; //imprime variable integer
echo $my_int - 2;
echo $my_int. "\n"; //imprime variable integer

$my_double = 6.5; //double
echo $my_double . "\n"; //imprime variable double
echo $my_int + $my_double . "\n"; //imprime suma integer + double

$my_boo = true; //boolean
echo $my_boo . "\n"; //imprime variable boolean
$my_boo = false; //reasignacion
echo $my_boo . "\n"; //imprime variable boolean
echo gettype($my_boo); //imprime tipo de variable


echo "Evl valor de mi integer es $my_int y el de mi boolen es $my_boo.\n"; //imprime texto

//constantes

const MY_CONTANT = "Esto es una constante"; // SIEMPRE EN MAYUSCULAS
echo MY_CONTANT . "\n";


//LISTAS

$my_array = [$my_String, $my_int, $my_double, $my_boo]; //declaracion de lista
echo gettype($my_array) . "\n"; //imprime tipo de variable
echo $my_array[0] . "\n"; //imprime primer elemento de la lista
echo $my_array[3] . "\n"; //imprime segundo elemento de la lista
array_push($my_array, "Nuevo elemento"); //agrega un elemento al final de la lista
print_r ($my_array); //imprime toda la lista



// Diccionario Estructura que estan ordenadas por clave-valor
//sintaxis: array("clave1" => valor1, "clave2" => valor2)
$my_dict = array("String" =>$my_String, "int" => $my_int,"bool" => $my_boo); //declaracion de diccionario
echo gettype($my_dict) . "\n"; //imprime tipo de variable
print_r($my_dict); //imprime todo el diccionario
echo $my_dict ["int"]. "\n"; //imprime el valor de la clave "int"


//set
array_push($my_array, "Brais");
array_push($my_array, "Brais");
print_r($my_array); //imprime toda la lista
print_r(array_unique($my_array)); //imprime toda la lista sin elementos repetidos


//flujo de control
for($index=0; $index<=10; $index++){
    echo $index . "\n";

}

foreach($my_array as $my_item){
    echo $my_item . "\n";
}

$index =0;
while($index <= sizeof($my_array)-1){
    echo $my_array[$index]. "\n";
    $index++;
}

if($mt_int = 11){
    echo "El valor es 11 \n";
} elseif($my_int = 10){
    echo "El valor es 10 \n";
} else {
    echo "El valor no es ni 10 ni 11 \n";
}

//funciones
function print_number($my_number){
    echo $my_number . "\n";
}

print_number(55);
print_number(10.5);
print_number("Hola Mundo");


//clases y objetos
class MyClass{

    public $name;
    public $age;

    function __construct($name, $age){
        $this->name = $name;
        $this->age = $age;
    }
}

$my_object = new MyClass("Brais", 30);
print_r($my_object);
echo $my_object->name . "\n";
echo $my_object->age . "\n";
    

?>

