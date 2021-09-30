library(ggplot2)
library(dplyr)
library(jsonlite)
library(gganimate)

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

plot <- ggplot(df, aes(x = longitude,y=latitude,group = code)) +
  geom_line()+
  #geom_text(aes(label=code),hjust=0, vjust=0)+
  labs(title = "{frame_along}")+
  transition_reveal(timestamp)+
  ease_aes("cubic-in-out")
animate(plot, renderer = gifski_renderer())
