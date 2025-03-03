## Capstone 4 part A 
## November 18, 2024 
install.packages("maps")
library(maps)
setwd('/Users/erikalesperance/Desktop/Grad_school/Computational_bio/Capstone4/')

LatLong=read.table("Lat_Long_combined.txt", header = FALSE)
map("world")

#help("map")

#plotted points for all FIVE species, distinguished by color, type and/or size of point character 
plot.new()
png("species_map.png", width=2244, height = 2244, res=300)

cast=subset(LatLong, V3 == "castaneus")
dom=subset(LatLong, V3 == "domesticus")
mol=subset(LatLong, V3 == "molossinus")
mus=subset(LatLong, V3 == "musculus")
spr=subset(LatLong, V3 == "spretus")


#background color to map, map axes, title 
par(bg="white")
map("world", xlim = c(-180,180), ylim= c(-90,90))
title("Species Ranges Around The World", xlab = "Longitude", ylab = "Latitude")
help(title)

#set ranges for each axis, increments of 30 
axis(1, at = seq(-180,180, by=30), labels = TRUE, cex=0.7)
axis(2, at = seq(-90,90, by=30), labels = TRUE, cex=0.7)

par(mar=c(2,2,2,2))

#legend to identify each subspecies datapoints (matching colors)
species=c( expression(italic("Mus musculus musculus")), expression(italic("Mus spretus")), expression(italic("Mus musculus domesticus")), 
    expression(italic("Mus musculus castaneus")), expression(italic("Mus musculus molossinus")))

colors=c("violet", "pink", "hotpink", "purple", "red")

legend("bottomleft", legend=species, col=colors, pch=20, cex=0.6, box.lwd=1)


#lakes filled with blue color 
map('lakes', add=TRUE, fill=TRUE, col="lightblue", boundary = "blue")

# add points for each species 
points(mus$V2, mus$V1, col="violet", cex=0.3, pch=20)
points(spr$V2, spr$V1, col="pink", cex=0.3, pch=20)
points(dom$V2, dom$V1, col="hotpink", cex=0.3, pch=20)
points(cast$V2, cast$V1, col="purple",cex=0.3, pch=20)
points(mol$V2, mol$V1, col="red", cex=0.4, pch=20)


#turn off/restart plot 
dev.off()
