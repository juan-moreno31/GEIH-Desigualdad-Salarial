# ============================================================
# 3) Análisis Exploratorio de Datos (EDA)
# ============================================================

# Cargar librerías necesarias
if (!require("dplyr")) install.packages("dplyr")
if (!require("readr")) install.packages("readr")
if (!require("ggplot2")) install.packages("ggplot2")
if (!require("scales")) install.packages("scales")
if (!require("tidyr")) install.packages("tidyr", repos = "http://cran.us.r-project.org")
if (!require("corrplot")) install.packages("corrplot", repos = "http://cran.us.r-project.org")

library(dplyr)
library(readr)
library(ggplot2)
library(scales)
library(tidyr)
library(corrplot)

# Crear directorio para resultados
dir.create("Resultados", showWarnings = FALSE)

# 1) Cargar la base de datos limpia
df <- read_csv("Data/Procesed-based/cleaned_base.csv", show_col_types = FALSE) |>
  mutate(
    ingreso_hora = as.numeric(ingreso_hora),
    log_ingreso = log(ingreso_hora)
  )

# Diccionarios y transformaciones
df <- df |>
  mutate(
    sexo_label = factor(sexo, levels = c(0, 1), labels = c("Hombre", "Mujer")),
    informal_label = factor(informal, levels = c(0, 1), labels = c("Formal", "Informal")),
    # Agrupar educación
    nivel_educativo_label = case_when(
      nivel_educativo %in% c("1", "2") ~ "1. Sin educ./Preescolar",
      nivel_educativo %in% c("3", "4") ~ "2. Primaria",
      nivel_educativo %in% c("5", "6", "7", "8") ~ "3. Secundaria/Media",
      nivel_educativo %in% c("9", "10") ~ "4. Técnico/Tecnólogo",
      nivel_educativo %in% c("11", "12") ~ "5. Profesional",
      nivel_educativo %in% c("13") ~ "6. Posgrado",
      TRUE ~ NA_character_
    )
  )

# ============================================================
# 1. Descripción de la muestra (Tabla 1)
# ============================================================


tabla_descriptiva <- data.frame(
  Variable = c("Edad", "Ingreso hora", "Tiempo empresa", "Mujer (%)", "Informal (%)"),
  Media = c(
    mean(df$edad, na.rm=TRUE),
    mean(df$ingreso_hora, na.rm=TRUE),
    mean(df$Tiempo_empresa, na.rm=TRUE),
    mean(df$sexo, na.rm=TRUE) * 100,
    mean(df$informal, na.rm=TRUE) * 100
  ),
  `Desv. Est.` = c(
    sd(df$edad, na.rm=TRUE),
    sd(df$ingreso_hora, na.rm=TRUE),
    sd(df$Tiempo_empresa, na.rm=TRUE),
    NA,
    NA
  ),
  Mín = c(
    min(df$edad, na.rm=TRUE),
    min(df$ingreso_hora, na.rm=TRUE),
    min(df$Tiempo_empresa, na.rm=TRUE),
    NA,
    NA
  ),
  Máx = c(
    max(df$edad, na.rm=TRUE),
    max(df$ingreso_hora, na.rm=TRUE),
    max(df$Tiempo_empresa, na.rm=TRUE),
    NA,
    NA
  )
)

write_csv(tabla_descriptiva, "Resultados/1_Tabla_Descriptiva.csv")

# Info extra
cat("N =", nrow(df), "\n")
cat("Año = 2025\n")
cat("Fuente = GEIH / DANE\n")

# ============================================================
# 2. Distribución del ingreso (Histograma y Densidad)
# ============================================================


p_hist <- ggplot(df, aes(x = log_ingreso)) +
  geom_histogram(bins = 40, fill = "#3498db", color = "white", alpha = 0.8) +
  labs(title = "Histograma: Logaritmo del Ingreso por Hora",
       x = "Log(Ingreso por Hora)", y = "Frecuencia",
       caption = "Elaborado con datos de GEIH / DANE 2025") +
  theme_minimal()
ggsave("Resultados/2a_Hist_LogIngreso.png", plot = p_hist, width = 7, height = 5)

p_dens <- ggplot(df |> filter(ingreso_hora < quantile(ingreso_hora, 0.98)), aes(x = ingreso_hora)) +
  geom_density(fill = "#e74c3c", color = "#c0392b", alpha = 0.6) +
  scale_x_continuous(labels = dollar_format(prefix = "$", big.mark = ".", decimal.mark = ",")) +
  labs(title = "Densidad: Ingreso por Hora",
       subtitle = "Visualiza la asimetría (filtrando el 2% más alto para legibilidad)",
       x = "Ingreso por Hora (COP)", y = "Densidad",
       caption = "Elaborado con datos de GEIH / DANE 2025") +
  theme_minimal()
ggsave("Resultados/2b_Densidad_Ingreso.png", plot = p_dens, width = 7, height = 5)


# ============================================================
# 3. Educación (Boxplot)
# ============================================================


p_edu <- ggplot(df |> filter(!is.na(nivel_educativo_label), ingreso_hora < quantile(ingreso_hora, 0.98)), 
                aes(x = nivel_educativo_label, y = ingreso_hora, fill = nivel_educativo_label)) +
  geom_boxplot(alpha = 0.8, outlier.alpha = 0.1) +
  scale_y_continuous(labels = dollar_format(prefix = "$", big.mark = ".", decimal.mark = ",")) +
  coord_flip() +
  labs(title = "Ingreso por Hora vs Nivel Educativo",
       subtitle = "Filtrando el 2% superior para legibilidad",
       x = "Nivel Educativo", y = "Ingreso por Hora (COP)",
       caption = "Elaborado con datos de GEIH / DANE 2025") +
  theme_minimal() + theme(legend.position = "none")
ggsave("Resultados/3_Educacion_Ingreso.png", plot = p_edu, width = 8, height = 5)

# ============================================================
# 4. Formalidad
# ============================================================


p_form_box <- ggplot(df |> filter(!is.na(informal_label), ingreso_hora < quantile(ingreso_hora, 0.98)), 
                     aes(x = informal_label, y = ingreso_hora, fill = informal_label)) +
  geom_boxplot(alpha = 0.7, outlier.alpha = 0.1) +
  scale_y_continuous(labels = dollar_format(prefix = "$", big.mark = ".", decimal.mark = ",")) +
  labs(title = "Ingreso por Hora: Formal vs Informal",
       subtitle = "Filtrando el 2% superior para legibilidad",
       x = "Condición", y = "Ingreso por Hora (COP)",
       caption = "Elaborado con datos de GEIH / DANE 2025") +
  theme_minimal() + theme(legend.position = "none")
ggsave("Resultados/4a_Formalidad_Boxplot.png", plot = p_form_box, width = 6, height = 5)

# Barra de proporción
form_prop <- df |> filter(!is.na(informal_label)) |> count(informal_label) |> mutate(pct = n/sum(n))
p_form_bar <- ggplot(form_prop, aes(x = "", y = pct, fill = informal_label)) +
  geom_bar(stat = "identity", width = 0.5) +
  geom_text(aes(label = percent(pct, accuracy=1)), position = position_stack(vjust = 0.5), size=6, color="white") +
  coord_flip() +
  labs(title = "Proporción de Formalidad en el Mercado Laboral", x="", y="", fill="Condición",
       caption = "Elaborado con datos de GEIH / DANE 2025") +
  theme_minimal() + theme(axis.text = element_blank(), axis.ticks = element_blank())
ggsave("Resultados/4b_Formalidad_Barra.png", plot = p_form_bar, width = 8, height = 2)


# ============================================================
# 5. Edad vs Ingreso Promedio
# ============================================================


edad_ingreso <- df |> filter(edad < 70) |> group_by(edad) |> summarise(ingreso_promedio = mean(ingreso_hora, na.rm=TRUE))
p_edad <- ggplot(edad_ingreso, aes(x = edad, y = ingreso_promedio)) +
  geom_line(color = "#2c3e50", size = 1) +
  geom_point(color = "#2980b9", size = 2) +
  scale_y_continuous(labels = dollar_format(prefix = "$", big.mark = ".", decimal.mark = ",")) +
  labs(title = "Ingreso Promedio por Edad (Menores de 70 años)",
       subtitle = "Curva típica de ciclo de vida laboral",
       x = "Edad", y = "Ingreso Promedio (COP)",
       caption = "Elaborado con datos de GEIH / DANE 2025") +
  theme_minimal()
ggsave("Resultados/5_Edad_Ingreso.png", plot = p_edad, width = 8, height = 5)



# ============================================================
# 6. Correlaciones 
# ============================================================


vars_corr <- df |> select(edad, ingreso_hora, log_ingreso, Tiempo_empresa, sexo, informal) |> drop_na()
M <- cor(vars_corr)

png("Resultados/6_Correlaciones_Heatmap.png", width = 800, height = 800, res=100)
corrplot(M, method = "color", type = "lower", addCoef.col = "black", 
         tl.col = "black", tl.srt = 45, title = "Matriz de Correlaciones", mar = c(0,0,2,0))
dev.off()

