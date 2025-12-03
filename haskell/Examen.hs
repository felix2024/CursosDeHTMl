--Examen de haskell papadio

--Eliminar numnero de una poscion dada
EliminarNumeros :: [Int] -> Int -> [Int]
EliminarNumeros xs n = [x | (i,x)<- zip [0..]xs, i /= n]

--eliminar todas las apariciones de un numero dado
EliminarApariciones  :: [Int] -> Int -> [Int]
EliminarApariciones xs n = [x | x<- xs  , x /= n]

--Pedir la lista de numeros entero de 0 al 4 por teclado y  eliminar las apariciones del numero dado
main :: IO ()
main = do
    putStrLn "Ingresar numeros de 0 a 4 separados por espacios:"
    input <- getLine
    let numeros = map read (words input) :: [Int]