
#' list locations via breeding API.
#'
#' Sweetpotatobase API uses internally paging; this call uses a pageSize of 10000 for now to retrieve all locations.
#'
#' @return a data.frame of locations
#' @author Reinhard Simon
#' @references \url{http://docs.brapi.apiary.io/reference/locations/list/list-locations}
#' @import httr
#' @export
locations_list <- function(){
  locs = brapi_GET("locations?pageSize=10000&page=1&")
  req = httr::content(locs)$result$data
  if (is.null(req)) stop("No data retrieved.\n Probably time out.\n Try reconnect.")
  #print(req)
  n = length(req)
  rdf = data.frame(
    locationDbId = integer(n),
    altitude = integer(n),
    countryCode = character(n),
    countryName = character(n),
    name = character(n),
    longitude = numeric(n),
    latitude = numeric(n),
    geodetic.datum = character(n),
    Uniquename = character(n),
    Agricultural.Ecological.Zone = character(n),
    Continent = character(n),
    adm1 = character(n),
    adm2 = character(n),
    adm3 = character(n)
    , stringsAsFactors = F)

  for(i in 1:n){
    # flatten attributes
    dat = req[[i]]
    # temporary bug: countryCode and countryNaem reversed in response data
    x = dat$countryCode
    dat$countryCode = dat$countryName
    dat$countryName = x

    atr = dat$attributes
    lna = length(atr)
    dat$attributes = NULL
    if(lna > 0) dat = c(dat, list(`geodetic datum` = atr[[1]]$`geodetic datum`))
    if(lna > 1) dat = c(dat, list(Uniquename =atr[[2]]$Uniquename))
    if(lna > 2) dat = c(dat, list(`Agricultural Ecological Zone` = atr[[3]]$`Agricultural Ecological Zone`))
    if(lna > 3) dat = c(dat, list(Continent = atr[[4]]$Continent))
    if(lna > 4) dat = c(dat, list(adm1 = atr[[5]]$adm1))
    if(lna > 5) dat = c(dat, list(adm2 = atr[[6]]$adm2))
    if(lna > 6) dat = c(dat, list(adm3 = atr[[7]]$adm3))

    m = length(dat)
    cn = names(dat)
    cnr= stringr::str_replace_all(cn, " ", ".")
    for(j in 1:m){
      ct = typeof(rdf[, cnr[j]])
      val = assign_item(cn[j], dat, ct)
      rdf[i, cnr[j]] <- val
    }
  }
  rdf
}
