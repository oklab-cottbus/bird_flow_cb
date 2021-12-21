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
  tryCatch({
  
  json <- read_json(file,simplifyVector = T)
  df <- data.frame(json$birds)
  df$latitude <- df$location$latitude
  df$longitude <- df$location$longitude
  df$location <- NULL
  df$has_helmet <- NULL
  df$bounty_id <- NULL
  df$timestamp <- as.POSIXct(as.numeric(sub("\\.json","",sub("\\D*","",file))),origin = "1970-01-01 00:00:00")
  df
  },
  error = function(cond){
    print(cond)
    NULL
  })
})
df_list <- df_list[lengths(df_list) != 0]
df <- do.call(rbind,df_list)

#Filter scooters for simplicity
#df <- df  %>% filter(grepl("F",code))
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
  #geom_text(df,mapping = aes(x= longitude,y=latitude,label = sub("..$","",code)))+
  labs(title = "{current_frame }")+
  transition_manual(timestamp)+
  theme(legend.position = "none")
  animate(plot,renderer = gifski_renderer(file = "density.gif"),width = 800, height = 800, fps = 12,nframes = length(levels(factor(df$timestamp))))

  
## Amount of scooters tracked
ggplot(df %>% group_by(timestamp) %>% mutate(code_count = length(levels(factor(code)))), aes(x = timestamp,y = code_count))+
  geom_line()

## Active Scooters
ggplot(df,aes(x = timestamp))+
  geom_point(aes(y=code,group = code,size = !is.na(bounty_id)))
  theme(legend.position = "none")
## Batterylevel

ggplot(df %>% group_by(timestamp) %>% mutate(mean_battery_level = mean(battery_level)),aes(x = timestamp))+
  geom_line(aes(y = battery_level,group = code))+
  geom_smooth(aes(y = mean_battery_level,color ="MEAN"))

## Travel distances
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
  
## Whats nest id
## I assume its when using scooters as a group
  
  
### calculating the mean position of a nest/group bay averaging all its members positions
### Then calculating the distance of a single scooter to its nest average position
### averaging all distances of scooters per nest to its nest average position
### calculating variance of distances of scooters per nest to its nest average position
## the average distance should be low for the assumption to be true
df <- df %>% group_by(timestamp,nest_id) %>%
  mutate(nest_id_mean_latitude = mean(latitude),
         nest_id_mean_longitude = mean(longitude)) %>%
  group_by(code) %>%
  mutate(distance_from_nest = getDistance(latitude,longitude,nest_id_mean_latitude,nest_id_mean_longitude))

df <- df %>% group_by(nest_id) %>%
  mutate(distance_from_nest_mean = mean(distance_from_nest))

ggplot(df %>% filter(!is.na(nest_id))) + 
  geom_col(aes(x = 1,fill= nest_id, y = distance_from_nest_mean),position = "dodge",)

ggplot(df %>% filter(!is.na(nest_id))) +
  geom_point(aes(y = distance_from_nest,x = code))


## Whats the id

ggplot(df) +
  geom_point(aes(x = timestamp,y = code,color = id))+
  theme(legend.position = "none")

