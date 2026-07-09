# ============================================================
# Paquetes necesarios
# ============================================================

if (!require("dplyr")) install.packages("dplyr")
if (!require("readr")) install.packages("readr")
if (!require("zip")) install.packages("zip")

library(dplyr)
library(readr)
library(zip)

# ============================================================
# Parametros generales
# ============================================================

anio <- 2025
meses <- c("Enero", "Febrero", "Marzo", "Abril",
           "Mayo", "Junio", "Julio", "Agosto", "Septiembre",
           "Octubre", "Noviembre", "Diciembre")

meses_anio <- paste(meses, anio)  # "Enero 2025", "Febrero 2025", ...

#########################################################################################
# Esta es la unica ruta que hay que cambiar si se quiere correr el script en otra computadora

ruta_zips <- "Data"
ruta_extraccion <- "Data/GEIH-Zip-opened"

#########################################################################################

# listas donde vamos a ir guardando cada mes de cada modulo
lista_ocupados        <- list()
lista_caracteristicas <- list()

# ============================================================
# Ciclo: descomprimir cada zip y leer los modulos que nos sirven
# Solo usamos los CSV ocupados y caracteristicas generales, que son los que nos interesan
# ============================================================

for (mes in meses_anio) {

  # ruta del zip de ese mes, ej: ".../Abril 2025.zip"
  zip_path <- file.path(ruta_zips, paste0(mes, ".zip"))

  # si no existe el zip de ese mes, avisamos y pasamos al siguiente
  if (!file.exists(zip_path)) {
    message("No existe zip para: ", mes)
    next
  }

  message("Procesando: ", mes)

  # carpeta temporal donde se descomprime ese mes
  carpeta_mes <- file.path(ruta_extraccion, mes)
  dir.create(carpeta_mes, recursive = TRUE, showWarnings = FALSE)

  # usamos zip::unzip (no utils::unzip) porque los nombres con tildes/ñ
  # rompen el unzip base de R
  zip::unzip(zip_path, exdir = carpeta_mes)

  # buscamos todos los csv dentro de la carpeta del mes, en cualquier subcarpeta
  archivos_csv <- list.files(carpeta_mes, pattern = "\\.csv$",
                              full.names = TRUE, recursive = TRUE,
                              ignore.case = TRUE)

  # nos quedamos solo con los csv que estan en la subcarpeta CSV
  # (cada zip trae 3 carpetas, solo esta nos interesa)
  archivos_csv <- archivos_csv[grepl("/CSV/", archivos_csv, ignore.case = TRUE)]

  # identificamos cual archivo es cada modulo
  archivo_ocupados <- archivos_csv[grepl("^Ocupados", basename(archivos_csv), ignore.case = TRUE)]
  archivo_caract   <- archivos_csv[grepl("Caracter", basename(archivos_csv), ignore.case = TRUE)]

  # ---- leemos cada uno con read_csv2 (separador ";", como vienen los csv del DANE) ----
  # col_types = cols(.default = "c") fuerza que TODO se lea como texto,
  # asi evitamos que una columna choque por venir numerica en un mes
  # y como texto en otro (esto rompia el bind_rows())

  if (length(archivo_ocupados) > 0) {
    df <- read_csv2(archivo_ocupados[1], show_col_types = FALSE,
                     locale = locale(encoding = "latin1"),
                     col_types = cols(.default = "c"))
    df$mes <- mes
    lista_ocupados[[mes]] <- df
  }

  if (length(archivo_caract) > 0) {
    df <- read_csv2(archivo_caract[1], show_col_types = FALSE,
                     locale = locale(encoding = "latin1"),
                     col_types = cols(.default = "c"))
    df$mes <- mes
    lista_caracteristicas[[mes]] <- df
  }
}

# ============================================================
# Unimos los 12 meses de cada modulo en un solo dataframe
# ============================================================

ocupados             <- bind_rows(lista_ocupados)
caracteristicas_gral <- bind_rows(lista_caracteristicas)

# revisamos que quedo bien
nrow(ocupados)
nrow(caracteristicas_gral)

names(ocupados)  # ahora deberian verse las columnas separadas, no un solo string

# ============================================================
# Unimos los 2 modulos en un solo dataframe
# ============================================================

# Ocupados + Caracteristicas generales (nivel persona)
base_final <- ocupados |>
  left_join(
    caracteristicas_gral,
    by = c("DIRECTORIO", "SECUENCIA_P", "ORDEN", "mes"),
    suffix = c("_ocup", "")
  )
# revisamos
# nrow(ocupados)
# nrow(base_final)
 
# ============================================================
# descargamos el resultado final en un csv 
# ============================================================
# la ruta donde se quiera guardar puede cambiarse.
write_csv(base_final,
          "Data/Procesed-based/union_base.csv")