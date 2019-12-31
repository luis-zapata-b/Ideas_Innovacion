conectar = function(in_web){
  "El siguiente apartado estable el proxy a utilizar."
  proxyname = "bcrproxy.bcrp.gob"
  proxyport = 8080
  userdomain = Sys.getenv("USERDOMAIN")
  "Adicionalmente, establecemos el tiempo de espera para realizar conexion"
  timeoutsecs = 60
  
  if(userdomain == "BCRP"){ 
    conn <- GET(as.character(in_web),
                config(ssl_verifypeer = FALSE),
                use_proxy(proxyname, proxyport,"","","any"))
  } else {
    conn <- GET(as.character(in_web))
  }
  return(conn)
}