# 📊 Desigualdad Salarial e Informalidad Laboral en Colombia

<div align="center">
  <img src="https://img.shields.io/badge/R-276DC3?style=for-the-badge&logo=r&logoColor=white">
  <img src="https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white">
  <img src="https://img.shields.io/badge/Machine%20Learning-FF6F00?style=for-the-badge&logo=scikit-learn&logoColor=white">
  <img src="https://img.shields.io/badge/Quarto-4B9CE3?style=for-the-badge&logo=quarto&logoColor=white">
</div>

---

## 📌 Sobre el Proyecto

Este repositorio contiene una investigación cuantitativa exhaustiva sobre dos de las dinámicas estructurales más críticas del mercado laboral colombiano: la **desigualdad salarial** y la **informalidad laboral**. 

Utilizando microdatos de la **Gran Encuesta Integrada de Hogares (GEIH) del DANE (2025)**, este proyecto cruza el puente entre la econometría laboral clásica y la ciencia de datos moderna mediante un enfoque metodológico mixto:

1. **Regresión Cuantílica (Ecuación de Mincer):** Permite evaluar cómo variables socioeconómicas (género, educación, informalidad) afectan el ingreso a lo largo de *toda* la distribución salarial, permitiéndonos ver qué pasa con los más pobres frente a los más ricos.
2. **Machine Learning (Random Forest):** Entrenamos un algoritmo de clasificación no paramétrico para perfilar y predecir con alta exactitud la probabilidad de que un trabajador caiga en la informalidad basándonos únicamente en sus características sociodemográficas.

## 🚀 Principales Hallazgos

*   🧗‍♀️ **Techo de Cristal Innegable:** La penalización salarial por ser mujer se agrava severamente a medida que avanzamos hacia los deciles más ricos, demostrando barreras estructurales en los altos cargos y posiciones directivas.
*   📉 **Trampa de la Informalidad:** Ser informal representa un castigo salarial devastador en la base de la pirámide (hasta un 69% menos de ingresos frente a sus pares formales), pero este castigo se diluye en las clases altas, donde obedece a dinámicas de profesionales independientes.
*   🎓 **Retornos a la Educación:** La educación superior sigue siendo un motor de crecimiento salarial, pero sus beneficios marginales son marcadamente mayores para quienes ya se encuentran en los deciles más favorecidos.
*   🤖 **Predicción de Informalidad:** El modelo *Random Forest* entrenado logró un **AUC de 0.88** y un *Recall* del 80%, demostrando que la informalidad no es un evento aleatorio de la economía, sino un fenómeno altamente predecible a partir del perfil del individuo.

## 📂 Estructura del Repositorio

El proyecto está organizado de la siguiente manera para garantizar su total reproducibilidad:

```text
📦 GEIH-Desigualdad-Salarial
 ┣ 📂 Data
 ┃ ┗ 📂 Procesed-based          # Base de datos limpia (excluida del repo por peso/privacidad)
 ┣ 📂 Reporte
 ┃ ┣ 📜 Reporte.pdf             # Artículo de investigación final (Resultados)
 ┃ ┣ 📜 Reporte.qmd             # Código fuente de Quarto para el reporte
 ┃ ┗ 📜 references.bib          # Bibliografía
 ┣ 📂 Resultados                # Gráficas, curvas ROC y visualizaciones exportadas
 ┣ 📂 scripts
 ┃ ┣ 📜 1_import.r              # Carga inicial de datos brutos
 ┃ ┣ 📜 2_cleaning.r            # Feature Engineering y filtrado de nulos/outliers
 ┃ ┣ 📜 3_EDA.r                 # Análisis Exploratorio de Datos (Estadísticas)
 ┃ ┣ 📜 4_modeloEconometrico.r  # Regresiones Cuantílicas de Mincer (R)
 ┃ ┗ 📜 5_modeloIA.ipynb        # Modelo predictivo Random Forest (Python)
 ┗ 📜 README.md                 # Este archivo
```

## 🛠️ Cómo Reproducir el Proyecto

1. **Pre-requisitos:** Asegúrate de tener instalados **R** y **Python 3**, junto con sus librerías de análisis de datos (`quantreg`, `tidyverse` en R; `pandas`, `scikit-learn`, `seaborn` en Python) y el sistema de publicación científica [Quarto](https://quarto.org/).
2. **Ejecución de Scripts:** Corre los scripts de la carpeta `scripts/` en orden numérico (del 1 al 5). R se encargará de la limpieza, análisis estadístico y econométrico. Python se encargará de entrenar el modelo de Machine Learning y guardar las gráficas de desempeño.
3. **Generación del Reporte:** Abre el archivo `Reporte/Reporte.qmd` y utiliza el comando *Render* de Quarto para compilar el artículo final. Todos los gráficos generados en el paso anterior se integrarán automáticamente en el PDF resultante.

---
*Elaborado por Juan Diego Moreno Sánchez, Universidad Externado de Colombia.*
