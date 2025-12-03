--Funciones pequeñas: la sintaxis para definir una funcion es simplemente:
--nombreDeLaFuncion argumentos = expresion
--Por ejeemplo suma x x = x + x

--Listas: son colecciones de elementos del mismo tipo. Se definen usando corchetes y comas.
--Por ejemplo: miLista = [1, 2, 3, 4, 5]
--o el operador cons (::) para construir listas: miLista = 1 : 2 : 3 : []

--textos rangos: una forma conveniente de crear listas secuenciales: [1..10] genera la lista de numeros del 1 al 10.

--Listas intesiones [list comprehension]: una sintazis potente, inspirada en la notacion matematica de conjuntos, para generar listas
--a partir de otras listas, aplicando flitros (predicados) y transformaciones.
--Por ejemplo, para generar una lista de los cuadrados de los numeros pares entre 1 y 10:
--[expresion | generado,filtro]

--tuplas: son colecciones heterogeneas de elementos, es decir, pueden contener elementos de diferentes tipos.


--funcion 
doble x = x * 2

--operacion cons (ASIGNADA A UN NOMBRE)
listaCons = 4:[5,6,7]

--rango y
numeros = [1..10]

--lista intension
--explicacion nomnbre de ña funcion = [expresion | generador, filtro]
cuadradosPares = [x*2 | x <- [1..5], x `mod` 2 == 0] -- lista de los dobles de los numeros pares entre 1 y 5

--tupla
miTupla = (1, "Hola", True)

--unción Personalizada: Define una función llamada esBisiesto que tome un año y 
-- devuelva True si es el año 2024, False en cualquier otro caso (solo para practicar sintaxis, 
-- la lógica real de bisiesto es más compleja).

esBisiesto = [year | year <- [2024], year == 2024]

--lista intensional: use una compresion de listas para generar una lista con los cuadrados
--de los numeros del 1 al 15, pero solo si el cuadro es mayor que 50.

cuadrados = [x^2 | x <- [1..15], x^2 > 50]

-- 1. Función auxiliar para sacar los divisores de un número
divisores :: Int -> [Int]
divisores n = [x | x <- [1..n], n `mod` x == 0]

-- 2. Es primo si sus únicos divisores son 1 y él mismo (versión simple)
esPrimo :: Int -> Bool
esPrimo n = divisores n == [1, n]

-- 3. Suma las cifras (Recursiva simple)
sumaCifras :: Int -> Int
sumaCifras 0 = 0
sumaCifras n = (n `mod` 10) + sumaCifras (n `div` 10)

-- 4. Genera una lista con los primeros 'k' números primos
primerosPrimos :: Int -> [Int]
primerosPrimos k = take k [x | x <- [1..], esPrimo x]

-- 5. Cuenta cuántos números de una lista tienen suma de cifras par
contarCifrasPares :: [Int] -> Int
contarCifrasPares lista = length [x | x <- lista, even (sumaCifras x)]

-- 6. Función principal
-- Genera los valores x (0, 10, 20...) y para cada x calcula y
cuantos :: Int -> [(Int, Int)]
cuantos n = [(x, contarCifrasPares (primerosPrimos x)) | x <- [0, 10 .. 10*n]]

-- 7. Función auxiliar que compara parejas de números
-- Devuelve 1 si sube, -1 si baja, 0 si son iguales
obtenerCambios :: [Int] -> [Int]
obtenerCambios xs = [if a < b then 1 else if a > b then -1 else 0 | (a,b) <- zip xs (tail xs)]

-- 8. Función que analiza el comportamiento de la lista
quePasa :: [Int] -> String
quePasa xs
    | null cambiosReales        = "Todos iguales"
    | all (== 1) cambiosReales  = "creciente"
    | all (== -1) cambiosReales = "decreciente"
    | head cambiosReales == 1   = "sube y baja"
    | otherwise                 = "baja y sube"
    where
        -- Calculamos los cambios y eliminamos los ceros (los iguales no definen tendencia)
        cambios = obtenerCambios xs
        cambiosReales = filter (/= 0) cambios



