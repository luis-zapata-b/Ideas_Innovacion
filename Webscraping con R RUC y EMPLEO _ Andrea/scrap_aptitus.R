######################################################################################
#                                     scrap_aptitus.R                               #
######################################################################################
"OBJETIVO: Cargar datos de los anuncios laborales de la pagina web: 
          #www.aptitus.com# diariamente.

 SALIDA: Los datos, clasificados en areas, son almacenados en una base de datos #data# 
         en formato .RData con nombre #aptitus_areas# seguido de la fecha de descarga.     
         Esta contiene informacion de cuando se publico el anuncio, la empresa, el 
         lugar, el puesto y una descripcion del mismo."
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

#Se procede a leer el archivo excel aptitus.xlsx por sus respectivas hojas
#(Estas contienen la informacion de los nombres de las areas y las diferentes
#url de las que se descargaran los datos)
areas = read_excel("aptitus.xlsx",sheet="areas")

"PASO 3: ESTABLECIMIENTO DE PARAMETROS PREVIOS"

#Se crea la constante "npags" que considera a la longitud (numero de filas) 
#de areas (pagina de xlsx) como la cantidad total de areas de la WP.
npags = nrow(areas)

"****Cargar datos del overview"
#Conocer la cantidad de anuncios por area -segun indicado en la pagina web-
#Cargar el doc del overview 
fname = paste("./raw_overview/aptitus_view",fecha1,".RData",sep="")
load(fname)
#Reestablecer el DF para conservar la informacion
conteopag = contpag
#Eliminar el DF anterior
rm(list=c("contpag","fname"))
"***********************************************************"

# Se crea una lista (data) de ayuda que despues sera utilizada para almacenar la informacion
# conforme se ejecute el bucle. Ademas se crea dos vectores numericos de longitud cero;
# con nombres "resumen", "area", que seran llenados tambien con la ejecucion del bucle.
data= list()
resumen = vector(mode="numeric",length=0)
area = vector(mode="numeric",length=0)

# Barra de Progreso - Paso1: 
#El comando winProgressBar mostrara una barra de progreso 
#centrada en la pantalla, con las caracteristicas de titulo, etiqueta que se especifiquen.
#la barra representara el progreso de un minimo a un maximo, con un punto inicial.     
pb = winProgressBar(title="En proceso", label="0% realizado", min=0, max=100, initial=0)

"PASO 4: INICIO DE BUCLE"

#Correra a traves de la cantidad de areas
for(jj in 1:npags){
  
  #Barra de Progreso - Paso2:
  #Se asigna a la variable info la impresion de la etiqueta y se especifica
  #el porcentaje a ser mostrado en la barra de progreso.
  info <- sprintf("%d%% realizado", round((jj/npags)*100))
  
  #Barra de Progreso - Paso3:
  #el comando setWinProgessBar actualizara los valores, el titulo y la etiqueta
  #(la variable info predeterminada), conforme de desarrolle el proceso.
  setWinProgressBar(pb, jj/(npags)*100, label=info)
  
  "Parametros previos: Conexion al area"
  #website: URL de cada area, estos estan en la 3ra columna de areas (xlsx)
  website =  areas$pagina[jj]
  #website_stay: se utiliza luego para el paso de paginas
  website_stay = website
  #DD: vector numerico que ira almacenando los datos, para ser luego guardados.
  DD =  vector(mode="numeric",length=0)
  #Conectar al website
  conn = conectar(website[[1]])
  
  "Extraer información"
  #En la variable producto, se extrae el contenido de la pagina web
  producto = content(conn,"parsed","text/html","UTF8")
  
  ####Para obtener el ultimo numero de paginas por area####
  
  #Selecciona el paginador, cuadro de nums de pag para navegar en la WP
  paginador = html_nodes(producto, ".b-paginator_item-link")
  
  #Extraer atributos, texto o tag names de html de todo el paginador
  #Extraer links por num de pagina del paginador
  np = html_attr(paginador,"href")
  #Extrae el ultimo boton, pagina final 
  ww = html_node(producto,".b-paginator_item-last-child .b-paginator_item-link")
  #Sacar el ultimo link de cant de pags
  page_fin = tail(np,1)
  #Encontrar "page=", posicion inicial y final
  page_fin_index = str_locate(page_fin,"page=")
  
  if(is.na(page_fin_index[2])){
    #Si es NA, entonces solo hay una pagina y la pag final sera 1
    page_fin_num=1
  } else {
    #Si no, extraer el substring (el num de pag final) desde la posicion
    #despues de page=, hasta el final
    page_fin_num = str_sub(page_fin,start=page_fin_index[2]+1,end=-1)
    #Convertir a numero la cantidad de pagians de la misma area
    page_fin_num = as.integer(page_fin_num)    
  }

  ####Empieza a ir pagina por pagina####
  
  for(ii in 1:page_fin_num){
      
    #Tiempo desde la publicacion del anuncio
    cuando1 = html_nodes(producto, ".g-job-notice_time")
    cuando = html_text(cuando1,trim=T) #Trim spaces
    #cuando = str_trim(cuando) 
    
    #Ubicacion del anuncio
    donde1 = html_nodes(producto, ".g-job-notice_detail-location .g-job-notice_text")
    donde = html_text(donde1)
    donde = str_trim(donde)
    
    #Nombre de la empresa del anuncio
    empresah4 = html_nodes(producto, ".g-job-notice_company")
    empresa.h4 = html_text(empresah4)
    empresa = str_trim(empresa.h4)
    
    #Titulo del anuncio. Contiene el nombre del puesto
    oficio1 = html_nodes(producto, ".g-job-notice_title")
    oficio = html_text(oficio1)
    oficio = str_trim(oficio)
    
    #Descripcion del puesto
    descripcion = html_nodes(producto, ".g-job-notice_description-text")
    descripcion = html_text(descripcion)
    descripcion = str_trim(descripcion)
    
    #Link del anuncio
    link= html_nodes(producto,".g-job-notice--listing")
    link = html_attr(link,"href")
    
    #Consolidar la info en un DF
    D = cbind.data.frame(donde, cuando,empresa,oficio,descripcion,link)
    #Consolidar la info en el vector de ayuda antes establecido, DD
    DD = rbind(DD,D)
    
    #Sacar el nombre del area a la var p1
    p1 = areas$area[jj]
    #Establecer el avance del buble
    textop1 = paste("Haciendo ", p1, " pagina ", ii, " de ", page_fin_num)
    #Imprimir el avance
    print(textop1)    
    
    #Avanzar a través de las paginas de la misma area
    website = paste(website_stay,"?page=",ii+1,sep="")
    conn = conectar(website)
    producto <- content(conn,"parsed","text/html","UTF8")
    
  }#Fin del loop a traves del num de pag por area

  # Un data frame se utiliza un marco de datos para almacenar tablas de datos. 
  # Es una lista de vectores de igual longitud; lista de variables 
  # del mismo numero de filas con nombres de fila unicos.
  DD = as.data.frame(DD)
  #Asignar el area respectiva
  DD$area = as.character(areas[jj,2])
  
  "Conteo de anuncios de BD"
  # Se elabora una tabla resumen (agregado), en donde se especificara 
  # el numero de anuncios (casos) por area.
  casos = dim(DD)[1]
  area = rbind(area, as.character(areas[jj,2]))
  resumen = rbind(resumen,casos)
  
  # "data" ira almacenando cada una de las bases de datos (DD) por areas.  
  data[[jj]]= DD
  
}#Fin de bucle de todas las areas

#Se cierra la barra de progreso.
close(pb)

#Establecer la duracion de la corrida
duracion = proc.time() - inicio
print("Procedimiento terminado. Tiempo de duraciÃ³n: ")
print(duracion)

#Crear los nombres de area sacados del excel como DF
agregado = as.data.frame(area)

"***** Hacer match entre el área y la cantidad de anuncios - según página web -"
#Crear objetos de ayuda.
x=1
y=1
cant=vector(length = 0)

#Se compara los nombres de areas del excel y de la página web.
for(y in 1:dim(agregado)[1]){
  for (x in 1:dim(conteopag)[1]){
   if(conteopag[x,1] == agregado[y,1]){
#Se asigna la cantidad establecida en la pagina web.
      cant=rbind(cant,conteopag[x,2])
      
    }
  }
}

"******************************************************************"
#Numerar la cantidad de num de anuncios por area
rownames(resumen)=seq(1,length(resumen))
#Comparar la cant de anuncios WP y BD
diferencia = cant - resumen
#Consolidado para validad la cant de anuncios del WP y del bucle
agregado = cbind(agregado,cant,resumen,diferencia)
names(agregado) = c("Área","Conteo WP","Conteo BD","Diferencia")

# Se guarda la base de datos total (data) en la ruta especificada por "fname".
fname = paste("./raw_data/aptitus_areas",fecha1,".RData",sep="")
#Se guarda la validacion de cant de anuncios: agregado
#Se guarda el consolidado de info por area: data
save(agregado,data,file=fname)

#Se exporta la data de validacion - presente en agregado - a Excel

library(xlsx)
ruta=paste("H:/DpIndGAER/Practicante/Laboral/Excel/Val_aptitus.xlsx",fecha1,".xlsx",sep="")
write.xlsx(agregado,ruta)
  




