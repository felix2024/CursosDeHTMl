module Actividad where

-- 1. Terreno Mayor
terrenoMayor :: Float -> Float -> Float -> Float -> Float
terrenoMayor a1 h1 a2 h2 = max (a1 * h1) (a2 * h2)

-- 2. Siembra Sinaloa (11=Nov, 12=Dic, 1=Ene)
esSiembraExitosa :: Int -> Bool
esSiembraExitosa mes = mes == 11 || mes == 12 || mes == 1

-- 3. Etapas de vida (Tipo definido por usuario)
data Etapa = Nino | Joven | Adulto | AdultoMayor deriving (Show, Eq)

clasificarEtapa :: Int -> Etapa
clasificarEtapa edad
    | edad <= 11 = Nino
    | edad <= 18 = Joven
    | edad < 50  = Adulto
    | otherwise  = AdultoMayor

-- 4. Tenencia
pagaTenencia :: Int -> Int -> String
pagaTenencia anioActual modelo
    | (anioActual - modelo) >= 10 = "Si paga tenencia"
    | otherwise                   = "No paga tenencia"

-- 5. Competencias
nivelCompetencia :: Int -> String
nivelCompetencia calificacion
    | calificacion >= 95 = "Sobresaliente"
    | calificacion >= 90 = "Altamente Competente"
    | calificacion >= 80 = "Competente"
    | calificacion >= 70 = "Suficiente"
    | otherwise          = "No Competente"