# load.R
# Archivo para cargar y limpiar las bases a usar en los casos


#libraries
library(plyr)
library(tidyverse)
library(sp)
library(spatialEco)
library(geojsonio)
library(leaflet)


# agebs estado de mexico
agebs_edo <- geojson_read("data/estado_agebs.json", what="sp")

# en base a la metadata que da el INEGI, el municipio de Toluca tiene la
# clave 106, filtraremos los agebs del estado para dejar solamente los 
# de Toluca
agebs_toluca <- subset(agebs_edo, cve_mun==106)
nrow(agebs_toluca)

# censo poblacional 2010
toluca_censo <- read_csv("data/censo_toluca.csv")

# limpiando columnas
cols <- colnames(toluca_censo) %>% tolower()
colnames(toluca_censo) <- cols


# proyecciones poblacion toluca
proyecciones <- read_csv("data/proyecciones_toluca_conapo.csv")

