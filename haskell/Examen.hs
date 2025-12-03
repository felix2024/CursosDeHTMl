--Examen de haskell papadio

--Eliminar numnero de una poscion dada
eliminarNumeros :: [Int] -> Int -> [Int]
eliminarNumeros xs n = [x | (i,x)<- zip [0..]xs, i /= n]

--eliminar todas las apariciones de un numero dado
eliminarApariciones  :: [Int] -> Int -> [Int]
eliminarApariciones xs n = [x | x<- xs  , x /= n]

--Pedir la lista de numeros entero de 0 al 4 por teclado y  eliminar las apariciones del numero dado
main = do
    putStrLn "Ingresar numeros de 0 a 4 separados por espacios:"
    input <- getLine
    let numeros = map read (words input) :: [Int]
    putStrLn "Ingresar el numero que quieras Eliminar:"
    numEliminar <- getLine
    let eliminarNumeros = read numEliminar :: Int
    let resultado = eliminarApariciones numeros eliminarNumeros
    print resultado



--Segundo ejercicio: Función que recibe dos listas de enteros, que estarán ordenados crecientemente. Generando  una tercera que contenga todos sus elementos, de forma que sigan ordenados.
listasJuntas :: [Int] -> [Int] -> [Int]
listasJuntas [] ys = ys
listasJuntas [] xs = xs
listasJuntas (x:xs) (y:ys)
    | x <- y  = x : listasJuntas xs (y:ys)
    | otherwise = y : listasJuntas (x:xs) ys

ordenarlistasjuntas :: [Int] -> [Int] -> [Int]
ordenarlistasjuntas xs ys = listasJuntas (quickSort xs) (quickSort ys)
quickSort :: [Int] -> [Int]
quickSort [] = []

recibirListas = do
    putStrLn "Ingresar la primera lista de numeros enteros separados por espacios:"
    input1 <- getLine
    let lista1 = map read (words input1) :: [Int]
    putStrLn "Ingresar la segunda lista de numeros enteros separados por espacios:"
    input2 <- getLine
    let lista2 = map read (words input2) :: [Int]
    return (lista1, lista2)    
    putStrLn "La lista ordenada combinada es:"
    let (lista1, lista2) = recibirListas
    resultado <- ordenarlistasjuntas lista1 lista2
    print resultado