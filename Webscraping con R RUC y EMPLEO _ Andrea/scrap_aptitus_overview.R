#######################################################################################
#                                 "scrap_aptitus_overview.R"                          #
#######################################################################################
"OBJETIVO: Cargar datos de los filtros de la página web: #www.aptitus.com# diariamente.

 SALIDA: Los datos son almacenados en una lista `agregados` en formato .RData con nombre
          de script #aptitus_view# seguido de la fecha de descarga.     
          Contiene informacion de los filtros: Areas, fechas de publicacion, modalidad
          de contrato, nivel profesional, salario y ubicacion"
#######################################################################################

"PASO 1: Preámbulo"

#Se procede a remover todas las variables del workspace.
rm(list=ls())
#Identificación automática de la fecha:
fecha1 = Sys.Date()
#Llama al script conectar de carpeta laboral
source("conectar.R")

"PASO 2: Website y Coneccion"

#Link de aptitus que presenta los filtros de areas a scrapear
website = "https://aptitus.com/buscar-trabajo-en-peru"
#Usa la funcion conectar para entrar al website
conn = conectar(website)

"PASO 3: Captura"

#En la variable producto, se extrae el contenido de la página web
#El tipo de output es parsed, tipo texto/html, valor UTF8
producto = content(conn,"parsed","text/html","UTF8")

#html_nodes extrae piezas de documentos html
#html_text extrae atributos, textos y tag-names de html
#str_trim elimina espacios en blanco de un string

####Area
#Posicion en WP_ Parte de izquierda, areas
area = html_nodes(producto, "div.filter_bar ul:nth-child(1) li:nth-child(2) li.filter_options span.filter_name")
area = html_text(area)
area = str_trim(area)
#Posicion en WP_ Parte de izquierda, areas, el conteo
area_count = html_nodes(producto, "div.filter_bar ul:nth-child(1) li:nth-child(2) li.filter_options span.count")
area_count = html_text(area_count)
area_count = str_trim(area_count)

"****Extraer el conteo de anuncios del WP"
#contpag: Reemplazar valores que no sean digitos por vacío, en area_count
contpag = gsub("\\D","",area_count)
#convertir valor a numeric
contpag = as.numeric(contpag)
#establecer DF de nombre del area y su conteo tipo numerico
contpag=data.frame(area,contpag)
"*****************"

#consolidar area y area_count como caracteres
area_t = paste0(area,area_count)

####Nivel
#Posicion en WP_ Parte de izquierda, debajo de areas
nivel = html_nodes(producto, "div.filter_bar ul:nth-child(2) li:nth-child(2) li.filter_options span.filter_name")
nivel = html_text(nivel)
nivel = str_trim(nivel)
#Posicion en WP_ Parte de izquierda, al lado de nivel, el conteo
nivel_count = html_nodes(producto, "div.filter_bar ul:nth-child(2) li:nth-child(2) li.filter_options span.count")
nivel_count = html_text(nivel_count)
nivel_count = str_trim(nivel_count)
#Concatenar niveles con el conteo de niveles
nivel_t = paste0(nivel,nivel_count)

####Salario
#Posicion en WP_ Parte de izquierda, debajo de nivel
salario = html_nodes(producto, "div.filter_bar ul:nth-child(3) li:nth-child(2) li.filter_options span.filter_name")
salario = html_text(salario)
salario = str_trim(salario)

#Posicion en WP_ Parte de izquierda, al lado de salario, el conteo
salario_count = html_nodes(producto, "div.filter_bar ul:nth-child(3) li:nth-child(2) li.filter_options span.count")
salario_count = html_text(salario_count)
salario_count = str_trim(salario_count)

#Concatenar el salario y el conteo
salario_t = paste0(salario, salario_count)

####Ubicacion
#Posicion en WP_ Parte de izquierda, debajo de salario
ubicacion = html_nodes(producto, "div.filter_bar ul:nth-child(4) li:nth-child(2) li.filter_options span.filter_name")
ubicacion = html_text(ubicacion)
ubicacion = str_trim(ubicacion)
#Posicion en WP_ Parte de izquierda, al lado de ubicacion, el conteo
ubicacion_count = html_nodes(producto, "div.filter_bar ul:nth-child(4) li:nth-child(2) li.filter_options span.count")
ubicacion_count = html_text(ubicacion_count)
ubicacion_count = str_trim(ubicacion_count)
#Concatenar ubicacion y conteo
ubicacion_t = paste0(ubicacion,ubicacion_count)

####Fecha
#Posicion en WP_ Parte de izquierda, debajo de ubicacion
fecha = html_nodes(producto, "div.filter_bar ul:nth-child(5) li:nth-child(2) li.filter_options span.filter_name")
fecha = html_text(fecha)
fecha = str_trim(fecha)
#Posicion en WP_ Parte de izquierda, al lado de fecha, el conteo
fecha_count = html_nodes(producto, "div.filter_bar ul:nth-child(5) li:nth-child(2) li.filter_options span.count")
fecha_count = html_text(fecha_count)
fecha_count = str_trim(fecha_count)
#Concatenar fecha y conteo
fecha_t = paste0(fecha, fecha_count)

####Modalidad
#Posicion en WP_ Parte de izquierda, debajo de fecha
modalidad = html_nodes(producto, "div.filter_bar ul:nth-child(6) li:nth-child(2) li.filter_options span.filter_name")
modalidad = html_text(modalidad)
modalidad = str_trim(modalidad) 
#Posicion en WP_ Parte de izquierda, al lado de modalidad, el conteo
modalidad_count = html_nodes(producto, "div.filter_bar ul:nth-child(6) li:nth-child(2) li.filter_options span.count")
modalidad_count = html_text(modalidad_count)
modalidad_count = str_trim(modalidad_count) 
#Concatenar modalidad y conteo
modalidad_t = paste0(modalidad, modalidad_count)

#Crear una lista que intgre todos los valores obtenidos.
agregados = list(area_t,fecha_t,modalidad_t,nivel_t, salario_t,ubicacion_t)

"PASO 4: Grabar"
#Guardar agregados: lista con todos los filtros de pagina, los 6
#Guardar contpag: DF con los nombres de areas y sus respectivos conteos
#Fname:ruta, se guarda en raw_overview/aptitus_view,fechaHoy,formatoR
fname = paste("./raw_overview/aptitus_view",fecha1,".RData",sep="")
save(agregados,contpag,file=fname)


