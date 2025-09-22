<?php
class persona{

    public $nombre;
    private $edad;
    protected $altura;

    function __construct($nuevoNombre){
        $this->nombre = $nuevoNombre;
    }

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


$objAlumno = new persona("Jesus");
// $objAlumno->asignarNombre("Jesus");
$objAlumno->imprimirNombre();


?>