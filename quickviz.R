library(ggplot2)
library(dplyr)
library(jsonlite)
library(gganimate)
library(ggmap)
library(transformr)

filelist <- list.files("database",full.names = T,pattern = "*.json")
df_list <- lapply(filelist, function(file){
  json <- read_json(file,simplifyVector = T)
  df <- data.frame(json$birds)
  df$latitude <- df$location$latitude
  df$longitude <- df$location$longitude
  df$location <- NULL
  df$timestamp <- as.POSIXct(as.numeric(sub("\\.json","",sub("\\D*","",file))),origin = "1970-01-01 00:00:00")
  df
})

df <- do.call(rbind,df_list)

scooter_map <- get_stamenmap(bbox = c(left = min(df$longitude), 
                                             bottom = min(df$latitude), 
                                             right = max(df$longitude), 
                                             top = max(df$latitude)),
                                             zoom = 15, 
                                             maptype = "toner")
## Desitymap
plot <- ggmap(scooter_map)+
  geom_density_2d_filled(df,mapping = aes(x = longitude,y=latitude),alpha = 0.5)+
  geom_point(df, mapping = aes(x = longitude,y=latitude))+
  labs(title = "{current_frame }")+
  transition_manual(timestamp)
 # shadow_wake(wake_length = 0.1)
  animate(plot,renderer = gifski_renderer(),width = 1000, height = 1000, fps = 25,duration = length(levels(factor(df$timestamp))))

  
## Amount of scooters tracked
ggplot(df %>% group_by(timestamp) %>% mutate(code_count = length(levels(factor(code)))), aes(x = timestamp,y = code_count))+
  geom_line()

## Active Scooters
ggplot(df,aes(x = timestamp))+
  geom_point(aes(y=code,color = battery_level,group = code))
## Batterylevel

ggplot(df %>% group_by(timestamp) %>% mutate(mean_battery_level = mean(battery_level)),aes(x = timestamp))+
  geom_line(aes(y = battery_level,group = code))+
  geom_smooth(aes(y = mean_battery_level,color ="MEAN"))
