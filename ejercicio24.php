<?php
class persona{

    public $nombre;
    private $edad;
    protected $altura;

    public function asignarNombre($nuevoNombre){
        $this->nombre = $nuevoNombre;
    }


    public function imprimirNombre()  {
        echo "El nombre es: " . $this->nombre;
    }

    public function mostrarEdad()  {
        $this->edad = 20;
        return "La edad es: " . $this->edad;
    }   
}


$objAlumno = new persona();
$objAlumno->asignarNombre("Jesus");

$objAlumno2 = new persona();
$objAlumno2 -> asignarNombre("felix");
$objAlumno2 -> imprimirNombre();



echo $objAlumno2 -> nombre;
echo $objAlumno2 -> mostrarEdad();

echo $objAlumno -> nombre;

?>