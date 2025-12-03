module Actividad2 where

-- Definición de Tipos de Datos (Necesarios para que funcionen las firmas de abajo)
data Direccion = Norte | Sur | Este | Oeste deriving (Show, Eq)
data Color = Verde | Amarillo | Rojo deriving (Show, Eq)
data Mes = Ene | Feb | Mar | Abr | May | Jun | Jul | Ago | Sep | Oct | Nov | Dic deriving (Show, Eq)
data Estacion = Primavera | Verano | Otono | Invierno deriving (Show, Eq)

-- 1. Estaciones del año (Uso de Patrones)
estacion :: Mes -> Estacion
estacion m
    | m `elem` [Mar, Abr, May] = Primavera
    | m `elem` [Jun, Jul, Ago] = Verano
    | m `elem` [Sep, Oct, Nov] = Otono
    | otherwise                = Invierno

-- 2. Máximo Común Divisor (Algoritmo de Euclides)
mcd :: Integer -> Integer -> Integer
mcd a 0 = a
mcd a b = mcd b (mod a b)

-- 3. Factorial (a: Guardas, b: Patrones)
-- Versión con Patrones
factPatrones :: Integer -> Integer
factPatrones 0 = 1
factPatrones n = n * factPatrones (n - 1)

-- Versión con Guardas (La que pide la firma 'fact')
fact :: Integer -> Integer
fact n
    | n == 0    = 1
    | otherwise = n * fact (n - 1)

-- 4. Girar 90 grados (Sentido horario)
girar90 :: Direccion -> Direccion
girar90 Norte = Este
girar90 Este  = Sur
girar90 Sur   = Oeste
girar90 Oeste = Norte

-- 5. Semáforo
semaforo :: Color -> Color
semaforo Verde    = Amarillo
semaforo Amarillo = Rojo
semaforo Rojo     = Verde

-- 6. Múltiplo (Dice si b es múltiplo de a)
múltiploDe :: Integer -> Integer -> Bool 
múltiploDe a b = (mod b a) == 0

-- 7. Raíces de ecuación cuadrática (Fórmula general)
-- Nota: Si el discriminante es negativo, dará NaN (Not a Number) en Float
raíces :: Float -> Float -> Float -> (Float, Float)
raíces a b c = (x1, x2)
    where
        discriminante = sqrt (b^2 - 4*a*c)
        x1 = (-b + discriminante) / (2*a)
        x2 = (-b - discriminante) / (2*a)

-- 8. Función constante cero
cero :: Integer -> Integer
cero _ = 0

-- 9. Votación
votar :: Int -> Bool
votar edad = edad >= 18

-- 10. Exención de examen
excenta :: (Eq a, Num a) => a -> [Char]
excenta calificacion
    | calificacion == 100 = "Exento"
    | otherwise           = "Presenta Examen"



-- 11. Rango 0-9
enRango :: Int -> String
enRango n
    | n >= 0 && n <= 9 = "Esta en rango"
    | otherwise        = "Fuera de rango"

-- 12. Previo y Siguiente (Tupla)
previoSiguiente :: Int -> (Int, Int)
previoSiguiente n = (n-1, n+1)

-- 13. Simulación AND Lógico
andLogico :: Bool -> Bool -> Bool
andLogico True True = True
andLogico _    _    = False

-- 14. Valor Absoluto
valorAbsoluto :: Int -> Int
valorAbsoluto n
    | n < 0     = -n
    | otherwise = n

-- 15. Signo del número
signo :: Int -> String
signo n
    | n > 0     = "Positivo"
    | n < 0     = "Negativo"
    | otherwise = "Cero"