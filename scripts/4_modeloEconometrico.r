#################################
# Modelo de regresión cuantilica
#################################

if (!require("quantreg")) install.packages("quantreg")
if (!require("dplyr")) install.packages("dplyr")
if (!require("readr")) install.packages("readr")
if (!require("ggplot2")) install.packages("ggplot2")
if (!require("tidyr")) install.packages("tidyr")
if (!require("scales")) install.packages("scales")

# cargamos las librerias

library(quantreg)
library(dplyr)
library(readr)
library(ggplot2)
library(tidyr)
library(scales)


# 1) cargamos la base de datos limpia

df <- read_csv("Data/Procesed-based/cleaned_base.csv", show_col_types = FALSE)

df <-  df |> select( - nivel_educativo_nombre)

colnames(df)


# 2) Ajustamos el modelo de regresión cuantilica para los cuantiles 0.1 al 0.9 (deciles) y guardamos los resultados en una lista

modelos <- list()
modelos[[1]] <- rq(log(ingreso_hora) ~ sexo + edad + I(edad^2) + nivel_educativo + 
  rama_actividad + Tiempo_empresa + informal, data = df, tau = 0.1)
modelos[[2]] <- rq(log(ingreso_hora) ~ sexo + edad + I(edad^2) + nivel_educativo + 
  rama_actividad + Tiempo_empresa + informal, data = df, tau = 0.2)
modelos[[3]] <- rq(log(ingreso_hora) ~ sexo + edad + I(edad^2) + nivel_educativo + 
  rama_actividad + Tiempo_empresa + informal, data = df, tau = 0.3)
modelos[[4]] <- rq(log(ingreso_hora) ~ sexo + edad + I(edad^2) + nivel_educativo + 
  rama_actividad + Tiempo_empresa + informal, data = df, tau = 0.4)
modelos[[5]] <- rq(log(ingreso_hora) ~ sexo + edad + I(edad^2) + nivel_educativo + 
  rama_actividad + Tiempo_empresa + informal, data = df, tau = 0.5)
modelos[[6]] <- rq(log(ingreso_hora) ~ sexo + edad + I(edad^2) + nivel_educativo + 
  rama_actividad + Tiempo_empresa + informal, data = df, tau = 0.6)
modelos[[7]] <- rq(log(ingreso_hora) ~ sexo + edad + I(edad^2) + nivel_educativo + 
  rama_actividad + Tiempo_empresa + informal, data = df, tau = 0.7)
modelos[[8]] <- rq(log(ingreso_hora) ~ sexo + edad + I(edad^2) + nivel_educativo + 
  rama_actividad + Tiempo_empresa + informal, data = df, tau = 0.8)
modelos[[9]] <- rq(log(ingreso_hora) ~ sexo + edad + I(edad^2) + nivel_educativo + 
  rama_actividad + Tiempo_empresa + informal, data = df, tau = 0.9)

# 3) Vemos los resultados de los modelos

summary(modelos[[1]])
summary(modelos[[2]])
summary(modelos[[3]])
summary(modelos[[4]])
summary(modelos[[5]], se = "boot", R = 20)
summary(modelos[[6]], se = "boot", R = 20) # en estas dos porque el modelo es más complejo
summary(modelos[[7]], se = "boot", R = 20)
summary(modelos[[8]], se = "boot", R = 20)
summary(modelos[[9]], se = "boot", R = 20)



# ============================================================
# 4) Graficar los coeficientes a lo largo de los cuantiles
# ============================================================

# Extraer coeficientes en un loop para múltiples cuantiles (deciles)
taus <- seq(0.1, 0.9, by = 0.1)
resultados_coefs <- data.frame()

for (t in taus) {
  # Calculamos el modelo sin guardar el summary completo por memoria
  mod <- rq(log(ingreso_hora) ~ sexo + edad + I(edad^2) + nivel_educativo + 
              rama_actividad + Tiempo_empresa + informal, data = df, tau = t)
  
  cfs <- coef(mod)
  resultados_coefs <- rbind(resultados_coefs, data.frame(
    tau = t,
    sexo = cfs["sexo"],
    informal = cfs["informal"],
    nivel_educativo = cfs["nivel_educativo"]
  ))
}

# Transformar a formato largo para graficar
resultados_long <- resultados_coefs |>
  pivot_longer(cols = c(sexo, informal, nivel_educativo), 
               names_to = "Variable", values_to = "Coeficiente") |>
  mutate(Variable = case_when(
    Variable == "sexo" ~ "Brecha de Género (Mujer)",
    Variable == "informal" ~ "Castigo por Informalidad",
    Variable == "nivel_educativo" ~ "Retorno a la Educación"
  ))

# Graficar
dir.create("Resultados", showWarnings = FALSE)

p_coefs <- ggplot(resultados_long, aes(x = tau, y = Coeficiente, color = Variable)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 3) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "black") +
  facet_wrap(~Variable, scales = "free_y", ncol = 1) +
  scale_x_continuous(breaks = taus, labels = percent_format(accuracy = 1)) +
  labs(title = "Evolución de los Efectos a lo largo de la Distribución de Ingresos",
       subtitle = "Coeficientes de la Regresión por Cuantiles (Deciles)",
       x = "Cuantil de Ingreso", y = "Efecto porcentual sobre el Ingreso",
       caption = "Elaborado con datos de GEIH / DANE 2025") +
  theme_minimal() +
  theme(legend.position = "none",
        strip.text = element_text(size = 12, face = "bold"),
        panel.spacing = unit(1, "lines"))

ggsave("Resultados/7_Coeficientes_Cuantiles.png", plot = p_coefs, width = 8, height = 9)
cat("\n¡Gráfico de coeficientes generado exitosamente en Resultados/7_Coeficientes_Cuantiles.png!\n")
