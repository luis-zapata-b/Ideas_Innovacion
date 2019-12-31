############################################################################
#####                        master_scrap_labor.R                          #                             
############################################################################
"OBJETIVO: Cargar datos diariamente datos laborales de las paginas Aptitus, 
Bumeran, Computrabajo

SALIDA: Bases de datos en formato .R y .csv"

#***************************************************************************

"Inicio"
rm(list=ls())

#start.time=Sys.time()


#Paquetes instalados
#install.packages("httr")
#install.packages("readxl")
#install.packages("xml2")
#install.packages("stringr")
#install.packages("tidyverse")
#install.packages("gdata")
#install.packages("tictoc")
#install.packages("foreign")
#install.packages("dplyr")


inicio <- proc.time()
require(tictoc) #Timer, tic: empieza, toc:termina
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
" PREAMBULO: DIRECTORIOS"
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
options(warn=1) #Muestra advertencias apenas sucedan

rm(list=ls())
#Obtener la ruta del directorio en el que se esta trabajando
directorio = dirname(rstudioapi::getSourceEditorContext()$path)
#Establecer el directorio en el que se trabaja
setwd(directorio)
#Establece la ruta madre
dirmother = dirname(getwd())


"Paquetes y funciones"
#*****************************************************************************
library(rvest)   # Para conectarse a la web y hacer scrapping
library(httr)    # Para leer url y usar rvest
library(readxl)  # Para leer archivos excel
library(xml2)    # Para usar rvest
library(stringr) # para manipular caracteres
library(tidyverse) #Para data science, que los datos trabajen en armonia
library(gdata)   # Manipulacion de datos. Ex. human-readable
library(foreign) # Leer info de stata, Minitap, entre otros
library(tictoc)

options(warn=2)  #Convierte advertencias en errores

"Aptitus"

#Empieza el timer
tic()
"Scrapeo"
source("scrap_aptitus_overview.R")
source("scrap_aptitus.R")
library(foreign)
library(dplyr) #Manipulacion de datos
"Procesamiento"
source("proc_aptitus.R")
exectime <- toc()
exectime <- exectime$toc - exectime$tic
#seguimiento=data.frame(nombre_archivo=factor(),tiempo=numeric(), tamano=integer(), fecha=as.Date(character()))
#Ruta de resultado de proc_aptitus
nombre_archivo1=c(fname_R)
tiempo=c(exectime)
tiempo
tamano=c(humanReadable(as.integer(file.info(fname_R)$size), standard="IEC"))
tamano
nuevas.filas=data.frame(nombre_archivo1,tiempo,tamano,fecha=c(Sys.Date()))
load("H:/DpIndGAER/Practicante/Laboral/SEGUIMIENTO1.RData")
if(seguimiento[nrow(seguimiento),1]!=nombre_archivo1){
  seguimiento=rbind(seguimiento,nuevas.filas)
  save(seguimiento,file="H:/DpIndGAER/Practicante/Laboral/SEGUIMIENTO1.RData")}
seguimiento


  "Bumeran"
    
  rm(list=ls())
  tic()
  source("scrap_bum_overview.R")
  source("scrap_bum_areas.R")
  source("scrap_bum_subareas.R")
  library(foreign)
  library(dplyr)
  "Procesamiento"
  source("proc_bumeran.R")
  exectime1 <- toc()
  exectime1 <- exectime1$toc - exectime1$tic
  nombre_archivo1=c(fname_R)
  tiempo=c(exectime1)
  tiempo
  tamano=c(humanReadable(as.integer(file.info(fname_R)$size), standard="IEC"))
  tamano
  nuevas.filas1=data.frame(nombre_archivo1,tiempo,tamano,fecha=c(Sys.Date()))
  load("H:/DpIndGAER/Practicante/Laboral/SEGUIMIENTO1.RData")
  if(seguimiento[nrow(seguimiento),1]!=nombre_archivo1){
    seguimiento=rbind(seguimiento,nuevas.filas1)
  save(seguimiento,file="H:/DpIndGAER/Practicante/Laboral/SEGUIMIENTO1.RData")}
  seguimiento
  
  
  "Computabajo"
  
  rm(list=ls())
  tic()
  source("scrap_computrabajo_overview.R")
    source("scrap_computrabajofinal.R")
  library(foreign)
  library(dplyr)
  "Procesamiento"
  source("proc_computrabajo.R")
  exectime2<- toc()
  exectime2<- exectime2$toc - exectime2$tic
  nombre_archivo1=c(fname_R)
  tiempo=c(exectime2)
  tiempo
  tamano=c(humanReadable(as.integer(file.info(fname_R)$size), standard="IEC"))
  tamano
  nuevas.filas2=data.frame(nombre_archivo1,tamano,fecha=c(Sys.Date()))
  load("H:/DpIndGAER/Practicante/Laboral/SEGUIMIENTO1.RData")
  if(seguimiento[nrow(seguimiento),1]!=nombre_archivo1){
    seguimiento=rbind(seguimiento,nuevas.filas2)
    save(seguimiento,file="H:/DpIndGAER/Practicante/Laboral/SEGUIMIENTO1.RData")}
  seguimiento


detach(package:dplyr)
detach(package:tidyverse)

print("Procedimiento terminado. Tiempo de duración: ")
print(duracion)


