# load&clean.R


# libraires
library(geojsonio)
library(sp)
library(raster)
library(leaflet)
library(tidyverse)
library(xtable)

# cargando manzandas del 2010 y del 2016
mza_16 <- geojson_read("data/manzanas.json", what = "sp")
mza_10 <- geojson_read("data/manzanas-10.json", what = "sp")

# cargando censo poblacional del 2010
censo <- read_csv("data/censo.csv")
censo %>%
  filter(mza != "000") %>%
  filter(mun == "006") %>%
  mutate(
    id_p = paste(ageb, mza, sep="/")
  ) %>% 
  dplyr::select(
    ageb, mza, id_p, pobtot
  ) %>% 
  filter(pobtot >0) -> censo_culiacan


# cargando proyecciones
proy <- read.csv("data/proyecciones.csv")
proy %>%
  gather(
    anio, proyeccion, 5:25
  ) -> proyecciones


# sacando area de cada manzana
mza_16$area <- area(mza_16)
mza_10$area <- area(mza_10)

# creando un id unico para los agebs del 2016 
mza_16$id_p <- paste(mza_16$cve_ageb, mza_16$cve_mza, sep = "/")

# agregamos la poblacion del 2010 a los agebs del 2016
# esto se hace de esta manera porque las manzanas del 2010 no cuentan con los datos 
# suficientes para hacer un merge con la base de población
# posteriormente con el overlap los podemos tratar como agebs del 2010
overlap <- sp::over(mza_10, mza_16)
manzanas_overlap <- overlap$id_p  # obtenemos los ids unicos de las manznas que tuvieron overlap

# manzamos final 2010
overlap %>%
  left_join(censo_culiacan) -> manzanas_2010_df
manzanas_2010_df %>% unique() -> manzanas_2010_df


# quitamos las manzanas que existen en ambos layers de las manzanas del 2016
# de tal manera que nos quedan las zonas nuevas
nuevas_mza <- subset(mza_16, !(id_p%in% manzanas_overlap))



# modelo lineal
manzanas_2010_df %>%
  filter(
    pobtot > 15 & pobtot < 250  # algunas mnzanas las consideramos outliers
) -> model_data 
model <- lm(log(pobtot) ~ log(area), data=model_data)
summary(model)


# predicciones
df_preds <- as.data.frame(nuevas_mza)
preds <- as.data.frame(predict(model, newdata = as.data.frame(nuevas_mza)))
names(preds) <- c("preds_log")
df_preds %>%
  mutate(
    poblacion_prediccion = round(exp(preds$preds_log))  # sacamos exp porque esta en lgoaritmo
  ) -> df_preds
  
# escribiendo a csv
write_csv(df_preds, "data/pob_manzanas.csv")
