# load.R


# library
library(plyr)
library(tidyverse)
library(scales)
library(xtable)
library(stargazer)


# leyendo datos de ventas
bm <- read_csv("data/bops_bm.csv")
online <- read_csv("data/bops_online.csv")

# haciendo clean y transform
# en este caso nos vamos a quedar con una base de datos general
# en esta base juntaremos las ventas de b&m, y las de online, agregnaod un indicador del tipo
# de canal donde proviene la venta, 0 para b&m y 1 para online
# esto permetira tener todo en un conjunto sin perder la desagregacion de los datos

# cleaning bm
bm %>%
  mutate(
    type = factor("bm"),
    country = factor(if_else(usa == 0, "canada", "usa")),
    program = factor(if_else(after == 0, "before", "after"))) %>%
  rename(
    id = `id (store)`
  ) %>%
  select(
    id, year, month, week, type, program, sales, country) -> bm


# cleaning online
online %>%
  rename(
    id = `id (DMA)`
  ) %>%
  mutate(
    type = factor("online"),# pondremos un pais solo para tener la columna, sabemos que es tipo online
    program = factor(if_else(after == 0, "before", "after")),
    distance = factor(if_else(close == 0, "<50m" , ">50m"))
  ) %>%
  select(
    id, year, month, week, type, program, sales, distance) -> online

# base final
base_final <- rbind.fill(online, bm)
  
  
  
