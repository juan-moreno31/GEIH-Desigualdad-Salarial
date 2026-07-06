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

nrow(df)






