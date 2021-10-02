library(ggplot2)
library(dplyr)
library(jsonlite)
library(gganimate)
library(ggmap)
library(transformr)
library(av)


getDistance <- function(lat1,lon1,lat2,lon2)
{
  
  
  dist <- (6378.388 * acos(sin(lat2*0.01745) * sin(lat1*0.01745) + cos(lat2*0.01745) * cos(lat1*0.01745) * cos(lon1*0.01745 - lon2*0.01745))*1000)
  return(ifelse(is.na(dist),0,dist))

}

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
                                             zoom = 13, 
                                             maptype = "toner")

## Desitymap
plot <- ggmap(scooter_map)+
  geom_density_2d_filled(df,mapping = aes(x = longitude,y=latitude),alpha = 0.5)+
  geom_point(df, mapping = aes(x = longitude,y=latitude))+
  #geom_text(df,mapping = aes(x= longitude,y=latitude,label = sub("..$","",code)))+
  labs(title = "{current_frame }")+
  transition_manual(timestamp)
  animate(plot,renderer = av_renderer(file = "density.webm"),width = 500, height = 500, fps = 12,nframes = length(levels(factor(df$timestamp))))

  
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

df <- df %>% 
  #filter(grepl("^FZ5",code)) %>% 
  group_by(timestamp) %>% 
  group_by(code) %>%
  mutate(distance = getDistance(latitude,longitude,lag(latitude),lag(longitude)))

df <- df%>%
  group_by(format(timestamp,"%F%H")) %>%
  mutate(total_distance_per_hour = sum(distance))

ggplot(df,aes(x=timestamp,y=total_distance_per_hour))+
  geom_line()
  theme(legend.position = "none")
