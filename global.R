library(leaflet)
library(dplyr)

weather_data <- readRDS("weather_test.rds")

#TODO: create a graph of the weather data based on some inputs

base_leaflet_map <- function() {

  data_map <- leaflet(width = 1250, height = 900) %>%
    setView(lat = 39.191, lng = -106.81, zoom = 7) %>% 
    addProviderTiles(providers$OpenStreetMap)

}


# #TODO: Make for actual data
# leaflet_map <- function(data, cal_counties_geo, var = "Rate.Percentage") {
    
#     #join the measures with the geographic table
#     cal_counties_w_variable = cal_counties_geo %>% 
#         left_join(data, by = c("NAME" = "County")) %>%
#         rename(map_var = .data[[var]])
    
#     colors_for_palette = c("#EBF6FF","#6BAED6", "#08306B")
#     pal = colorNumeric(colors_for_palette, domain = cal_counties_w_variable$map_var, na.color = "#f1f1e0")
    
#     #make hover
#     if(var == "Rate.Percentage"){
#         var_label = "Unadjusted Rate"
#     }else{
#         var_label = "Age-adjusted Rate"
#     }
    
#     hover_text = paste0(
#         "<b>",cal_counties_w_variable$NAME,"</b><br>",
#         var_label,": ", cal_counties_w_variable$map_var)
    
#     cal_counties_w_variable$hover_text = lapply(hover_text, function(x) shiny::HTML(x))
    
#     map_continous_scale = leaflet(width = 1250, height = 800,   
#                                   options = leafletOptions(zoomControl = FALSE,
#                                                            minZoom = 5.7,
#                                                            maxZoom = 5.7,
#                                                            dragging = FALSE)) %>%
#         addProviderTiles(providers$Esri.WorldGrayCanvas) %>% #this is a more plain tile layer
#         addPolygons(data = cal_counties_w_variable,
#                     color = "black", #controls the color of the shape boundaries
#                     weight = 2, #conrtrols the thickness of the shape boundaries
#                     fillOpacity = 1, #controls the opacity of the fill color
#                     fillColor = ~pal(map_var),
#                     label = ~hover_text)     #NAME is a variable in our shapefile
    
    
#     map_continous_scale %>%
#         addLegend("bottomright",
#                   pal = pal,
#                   values = cal_counties_w_variable$map_var,
#                   na.label = paste("N/A"),
#                   opacity = 1)
# }