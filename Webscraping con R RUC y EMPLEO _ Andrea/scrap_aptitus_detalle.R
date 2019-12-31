######################################################################################
#                              scrap_aptitus_detalle.R                               #
######################################################################################
"OBJETIVO: Obtener una base de datos donde la descripcion de los anuncios sea detallada.

SALIDA: BD con data de resumen + descripción del anuncio "
######################################################################################

"PASO 1: PREAMBULO"

#Se procede a remover todas las variables del workspace
rm(list=ls())
#Vector de tiempo de procesamiento
inicio = proc.time()
#Identificacion automatica de la fecha: esta se realiza con el comando Sys.Date()
fecha1 = Sys.Date()
#Llama al script conectar y lo carga
source("conectar.R")

"PASO 2: LECTURA DE ARCHIVO EXCEL"

#Se procede a leer el archivo aptitus.Rdata. Desde el cual se obtienen los links a scrapear
#nombre = paste("./datos_R/aptitus",fecha1,".Rdata",sep="")
nombre = paste("./Links_Anuncios/aptitus_",fecha1,".Rdata",sep="")
load(nombre)
#Crear elemento para no sobreescribir informacion
BD_links = bd1_a
#Eliminar elemento base
remove(list=c("bd1_a"))

#Conseguir la cantidad de links
cant_links= dim(BD_links)

#Crear la barra de progreso
pb = winProgressBar(title="En proceso", label="0% realizado", min=0, max=100, initial=0)

#Crear vector de ayuda donde posteriormente se almacenara informacion
DB = vector(length=0)

#Empieza el loop a través de los links de anuncios
for (ii in 1:cant_links[1]){
  
  #Actualizar barra de progreso
  info <- sprintf("%d%% realizado", round((ii/cant_links)*100))
  setWinProgressBar(pb, ii/(cant_links)*100, label=info)
  
  #Especificar el website
  website = BD_links[ii,11]
  #Conectar el website
  conn = conectar(website)
  #Imprimir el website para visualizar el avance a traves de las paginas en la consola
  print(website)
  
  #Obtener data plana de la pagina web
  producto = content(conn,"parsed","text/html","UTF8")
  #Obtener el nodo detalle de la etiqueta respectiva (GadgetSelector)
  detalle = html_node(producto,".b-job-info")
  #Establecer los datos en texto
  detalle = html_text(detalle,"href")
  detalle = gsub("\\n"," ",detalle)
  detalle = gsub("\\r"," ",detalle)
  detalle = trim(detalle)
  
  
  #Almacenar la informacion en el vector vacio previamente creado
  DB = rbind(DB, detalle)
  
}#Termina el loop a traves de la cant de links

#Cerrar la barra de progreso
close(pb)

#Establecer el vector como un data frame para facilitar la visualizacion
Base = as.data.frame(DB)
#Acoplar datos recopilados en el script anterior
Base=cbind(BD_links,Base)
#Renombrar las columnas
names(Base) = c("Distrito","Fecha","Dia","Mes","hrs","mins","num","Empresa","Oficio","Area","Link","Descripcion")

#Guardar la Base en la ruta fname
fname = paste("./Detalle/Detalle_Aptitus_",fecha1,".RData",sep="")
save(Base,file=fname)

#Se exporta la data Base a Excel
library(xlsx)
ruta=paste("H:/DpIndGAER/Practicante/Laboral/DetalleExcel/Detalle_aptitus.xlsx",fecha1,".xlsx",sep="")
write.xlsx(Base,ruta)




