#######################################################################
#####                       Eliminar duplicados                    ####
########################################################################
#"Objetivo: Eliminar los links duplicados para no scrapear lo mismo dos veces.


rm(list=ls())

fecha1= Sys.Date()
"*********************************************************************"
"Aptitus"

fname = paste("./datos_R/aptitus",fecha1,".RData",sep="")
load(fname)
bd_a= DAT
remove(DAT)

bd1_a = bd_a %>% distinct(link,.keep_all = TRUE)

  "Save"
  fname = paste("./Links_Anuncios/aptitus_",fecha1,".RData",sep="")
  save(bd1_a,file=fname)

"*******************************************************************"
"Bumeran"

fname = paste("./datos_R/bumeran",fecha1,".RData",sep="")
load(fname)
bd_b = dat.subarea
remove(dat.subarea)

bd1_b = bd_b %>% distinct(link,.keep_all = TRUE)

  "Save"
  fname = paste("./Links_Anuncios/bumeran_",fecha1,".RData",sep="")
  save(bd1_b,file=fname) 


 "********************************************************************"
"Computrabajo"
  
fname = paste("./datos_R/computrabajo",fecha1,".RData",sep="")
load(fname)
bd_c = DAT
remove(DAT)
  
bd1_c = bd_c %>% distinct(link,.keep_all = TRUE)
  
  "Save"
  fname = paste("./Links_Anuncios/computrabajo_",fecha1,".RData",sep="")
  save(bd1_c,file=fname) 









