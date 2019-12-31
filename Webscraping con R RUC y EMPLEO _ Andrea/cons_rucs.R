#CONSOLIDADO DE RUCS

#Limpiar el espacio de trabajo
rm(list=ls())

#Establecer las librerias necesarias
library(RSelenium)
library(readxl)
library(rvest) 
library(tidyr)

#Establecer la ruta
fname = paste("/Users/Andrea/Documents/WEB SCRAPING")
setwd(fname)

#Establecer fecha del sistema
fecha1 = Sys.Date()

#Importar el excel con los nombres de empresas
ruc = read_excel("./Scraper/Input/RUC2_23.xlsx")

#Establecer el servidor remoto
remDr <- remoteDriver(remoteServerAddr="localhost",port=4445L,browser="chrome")
remDr$open()
remDr$deleteAllCookies

#Acceder a google y la 1ra pagina web
remDr$navigate("http://www.google.com")
remDr$navigate("http://www.universidadperu.com/empresas/")

#Hacer click en el buscador de universidades del peru
webElem <- remDr$findElement(using = 'class', "txtinput")
webElem$highlightElement()
webElem$clickElement()

#Establecer vectores de ayuda
rucs = vector(length = 0)
cant =dim(ruc)[1]

for (ii in 1:dim(ruc)[1]){
  
  #  info <- sprintf("%d%% realizado", round((ii/cant)*100))
  # setWinProgressBar(pb, ii/(cant)*100, label=info)
  
  rs = ruc[ii,2]
  rs = as.character(rs)
  webElem$sendKeysToActiveElement(list(rs))
  webElem$sendKeysToActiveElement(list(key = "enter"))
  
  pg <- remDr$getPageSource() %>% .[[1]] %>% read_html()
  ru <- pg %>% html_node(".exp:nth-child(1)") %>% html_text()
  ru = gsub("RUC: ","",ru)
  
  a = sum(is.na(ru))
  a = as.numeric(a)
  
  if (a == 1){
    ru <- c("No")
    b = cbind(ruc[ii,2],ru)
    rucs = rbind(rucs,b)
    
  } else {
    b = cbind(ruc[ii,2],ru)
    rucs = rbind(rucs, b)
  }
  
  webElem <- remDr$findElement(using = 'class', "txtinput")
  webElem$highlightElement()
  webElem$clickElement()
  
}

remDr$navigate("http://www.google.com")
remDr$navigate("http://www.datosperu.org")

webElem <- remDr$findElement(using = 'class', "form-control")
webElem$highlightElement()
webElem$clickElement()

rucs_2 = vector(length=0)

for (jj in 1:dim(rucs)[1]){
  
  if (rucs[jj,2] == "No"){
    
    webElem <- remDr$findElement(using = 'class', "form-control")
    webElem$highlightElement()
    webElem$clickElement()
    
    rs = ruc[jj,2]
    rs = as.character(rs)
    remDr$setImplicitWaitTimeout(1000)
    webElem$sendKeysToElement(list(rs))
    webElem$sendKeysToElement(list(rs))
    webElem$sendKeysToActiveElement(list(key = "enter"))
    
    pg <- remDr$getPageSource() %>% .[[1]] %>% read_html()
    ru = vector(length=0)
    ru <- pg %>% html_node(".col-sm-12") %>% html_text()
    ru = gsub("\n","",ru)
    ru = gsub("\t","",ru)

    a = sum(is.na(ru))
    a = as.numeric(a)
    
    if (a == 1){
      
      rucs_2 = rbind(rucs_2,"No")
      
    } else {
    
      d = substr(ruc[jj,2],1,8)
      e = gsub(" ","",ru)
      e = substr(e,1,8)
      e = gsub(" ","",e)
      
        if(d == e){
          ru = gsub("\\D","",ru)
          rucs_2 = rbind(rucs_2, ru)
        } else {
          rucs_2 = rbind(rucs_2,"No")
          
        }
    
    webElem <- remDr$findElement(using = 'class', "form-control")
    webElem$highlightElement()
    webElem$clickElement()
    webElem$sendKeysToActiveElement(list(key = "control","a"))
    webElem$sendKeysToActiveElement(list(key="delete"))
    remDr$setImplicitWaitTimeout(1000)
    
    }
    
  } else {
    rucs_2 = rbind(rucs_2,"Ok")
  }
  
}

rucs = cbind(rucs,rucs_2)
names(rucs)[2] <- paste("univ_peru")
names(rucs)[3] <- paste("datos_peru")

merge = vector(length=0)

for (aa in 1:dim(rucs)[1]){
  
  if (rucs$univ_peru[aa] != paste("No")){
    
    a = as.character(rucs$univ_peru[aa])
    merge = rbind(merge,a)
    
  } else {
    
    if((rucs$datos_peru[aa] != paste("No")) & (rucs$datos_peru[aa] != paste("Ok"))){
    
    a = as.character(rucs$datos_peru[aa])
    merge = rbind(merge,a)}
    
    else {
    
      a = c("")
      merge = rbind(merge,a)}}
}

rucs = cbind(rucs,merge) 
  

install.packages(xlsx)
library(xlsx)

ruta=paste("./Scraper/Consolidado/rucs_",fecha1,".csv",sep="")
write.csv(rucs,ruta)
  
  


