#####################################
# Limpieza de datos
#####################################

# En este script se realiza la limpieza de los datos importados en
# el script 1_import.r. Se unifican los datos de los tres módulos 
# (ocupados, características generales y vivienda) en un solo
# dataframe llamado union_base.csv.

#####################################
# Cargar librerías necesarias

if (!require("dplyr")) install.packages("dplyr")
# En esta ocasion dplyr es necesario para remplazar nombres de 
# columnas, manejar NA, seleccionar columnas, remplazar valores, etc.
if (!require("readr")) install.packages("readr")
# solo necesitamos readr para leer la base de datos que ya realizamos y escribir la nueva

library(dplyr)
library(readr)

######################################
# 1) Cargamos la base de detos

df <- read_csv("C:\\Users\\diego\\Documents\\GEIH-Desigualdad-Salarial\\Data\\Procesed-based\\union_base.csv")

# revisamos la estructura de la base de datos

head(df)

# 2) Seleccionamos las columnas que nos interesan para el análisis

df <- df |> select(
  P3271, P6040, P3042, P6500, P6800,
  RAMA2D_R4, P6426, P6090, P6920, P6780,
  DPTO, P3069, P3065, P6775, P6430
)

df <- df |> filter(
  !is.na(P3271) & !is.na(P6040) & !is.na(P3042) &
  !is.na(P6800) & 
  !is.na(RAMA2D_R4) & !is.na(P6426) & !is.na(P6090) &
  !is.na(P6920) & !is.na(DPTO) & !is.na(P3069) & !is.na(P6430)
)

# 4) Trasformamos los nombres de las columnas para que sean más descriptivos
df <- df |> rename(
  sexo = P3271,
  edad = P6040,
  nivel_educativo = P3042,
  Salario_mensual = P6500,
  horas_trabajo = P6800,
  rama_actividad = RAMA2D_R4,
  Tiempo_empresa = P6426,
  Afi_salud = P6090,
  afi_pension = P6920,
  departamento = DPTO,
  Tipo_de_trabajo = P6780,
  Num_trabajdores_empresa = P3069,
  camara_comercio = P3065,
  contabilidad = P6775,
  posicion_ocupacional = P6430
)

# 5) Creamos las variables de interés para el análisis

# 5.1) Creamos la variable de ingreso por hora y convertimos tiempo en empresa a años
df <- df |>
  mutate(
    ingreso_hora = as.numeric(Salario_mensual) / (as.numeric(horas_trabajo) * 4.33),
    Tiempo_empresa = as.numeric(Tiempo_empresa) / 12
  ) |>
  filter(!is.na(ingreso_hora)) |>
  select(-Salario_mensual, -horas_trabajo)

# 5.2) Creamos la variable de informalidad
df <- df |>
  mutate(
    informal = case_when(
      # Asalariados (incluyendo gobierno)
      posicion_ocupacional %in% c("1","2","3","8") & (Afi_salud == "2" | afi_pension == "2") ~ 1,
      posicion_ocupacional %in% c("1","2","3","8") & (Afi_salud == "1" & afi_pension == "1") ~ 0,
      
      # Independientes: Formales si tienen Cámara de Comercio, Contabilidad O empresa de 6 o más trabajadores (códigos 4 al 10 en P3069)
      posicion_ocupacional %in% c("4","5") & (
        camara_comercio == "1" | 
        contabilidad == "1" | 
        Num_trabajdores_empresa %in% c("4", "5", "6", "7", "8", "9", "10")
      ) ~ 0,
      posicion_ocupacional %in% c("4","5") ~ 1,
      
      # Familiares y otros sin remuneración
      posicion_ocupacional %in% c("6","7","9") ~ 1,
      
      TRUE ~ NA_real_
    )
  )

# 5.3) Seleccionamos solo las variables finales para el modelo (eliminamos las auxiliares)
df <- df |>
  select(-c(Afi_salud, afi_pension, camara_comercio, contabilidad, 
            Num_trabajdores_empresa, posicion_ocupacional, Tipo_de_trabajo))

# 6) Guardamos la base de datos limpia
write_csv(df, "C:\\Users\\diego\\Documents\\GEIH-Desigualdad-Salarial\\Data\\Procesed-based\\cleaned_base.csv")












