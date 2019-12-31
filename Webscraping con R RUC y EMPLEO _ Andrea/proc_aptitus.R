###############################################################################
#                                proc_aptitus.R                               #
###############################################################################
"OBJETIVO: Procesar datos del archivo en formato #.Rdata# previamente guardados 
para tenerlos en un BD limpia #DAT#.

SALIDA: Archivos en formato .Rdata y .csv"
#******************************************************************************
"Preambulo"

#Remover los objetos del workspace
rm(list=ls())
#Identificacion automatica de fecha
fecha1 = Sys.Date()

"******************************Cargar datos************************************"
#Carga archivo y data obtenida del raw data obtenido en scrap_aptitus
fname = paste("./raw_data/aptitus_areas",fecha1,".RData",sep="")
load(fname)
#Renombrar para reutilizar info
areas = agregado
data.areas = data
#Eliminar lo innecesario
rm(list=c("agregado","data","fname"))

"****************************Construir detalle*********************************"
#Establecer el num de areas por la longitud de data.areas
Nareas =  length(data.areas)

#Procesar la base de datos por area
for(ii in 1:Nareas){
  
  #Se guardaran solo los elementos unicos de la base de datos por areas en "dd"
  dd = distinct(data.areas[[ii]])
  
  #Solo si se tiene al menos 1 dato, se prosigue.
  if(nrow(dd)>0){
    
    ####Distrito
    distrito = dd[,1]
    
    ####Duracion 
    # duracion: de la segunda columna de dd (cuando)
    #(eliminar la palabra hace) extrae a partir del quinto caracter hasta el ultimo
    duracion = str_sub(dd[,2],start=5,end=-1)
    # Se quiere identificar si se trata de dias, meses, horas, minutos
    # DF estableciendo True or False en caso sean dias.meses.horas o min
    # str_detect: Detecta la presencia o ausencia de un patron en una cadena
    # su valor es un vector logico. Cuando encuentre lo especificadoen "XXX"; 
    # colocar: TRUE, de lo contrario, FALSE.  
    dias = as.data.frame(str_detect(duracion,"d"))
    mes = as.data.frame(str_detect(duracion,"mes"))
    hrs = as.data.frame(str_detect(duracion,"hora"))
    mins = as.data.frame(str_detect(duracion,"min"))
    #Reemplazar todo lo que no sea digito por nada
    #Convertir el valor a numero
    num = as.numeric(gsub("[^0-9]", "", duracion))
    
    ####Empresa
    empresa = as.data.frame(dd[,3])
    
    ####Oficio
    oficio = as.data.frame(dd[,4])
    
    ####Link
    link = as.data.frame(dd[,6])
    #Consolidar datos
    dat = cbind(distrito,dias,mes,hrs,mins,num,empresa, oficio,link)
    # Los nombres del objeto "dat" se especifican en un vector.     
    names(dat) = c("distrito","dia","mes","hrs","mins","num","empresa","oficio","link")
    # se añade una columna por el area respectiva
    dat$area = areas[ii,1]
    
    #se ira almacenando cada una de las bases de datos por areas (dat) en DAT (base final)   
    if(ii==1){
      #Si el num de areas = 1, solo asignar una vez; sino, consolidar
      DAT = dat
    }
    else {
      DAT = rbind(DAT,dat)  
    }
  }#Termina el si num filas de dd mayor a 0
} #Termina el loop que va a traves de las areas


# Se añade una columna con la fecha del dia a la base final
DAT$fecha = fecha1
# Se ordena la base de datos final de acuerdo a los nombre de las columnas especificados
DAT = DAT[c("distrito","fecha","dia","mes","hrs","mins","num",
            "empresa","oficio","area","link")]
#Numero de registros = dimension de DAT
N = dim(DAT)[1]
#Se coloca nombre a las filas de la base de datos (DAT): del 1 a la ultima observacion
rownames(DAT) = seq(1,N)

# Se guarda la base de datos total (DAT) en la ruta especificada por "fname_R":
#en formato .RData y por "fname_csv": en formato .csv . Usa una (",") para el 
#punto decimal y un (";") como separador.
fname_R = paste("./datos_R/aptitus",fecha1,".RData",sep="")
fname_csv = paste("./datos_csv/aptitus",fecha1,".csv",sep="")

#write.csv2: Exporta o escribe datos desde R a .csv (valores separados por comas).
write.csv2(DAT,file=fname_csv)
save(DAT,file=fname_R)

