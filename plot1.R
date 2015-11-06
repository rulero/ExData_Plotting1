# This script will plot power consumption data into a PNG file
# INPUTS:
#   Power consumption file, it is automatically downloaded if necessary
#
# OUTPUTS:
#   A 480x480 px PNG file named plot1.png

library(data.table)
library(lubridate)

## Read data file into a variable named power.data
GetPowerData <- function() {
    # Download and unzip the zip file, if needed
    kDataFile <- "household_power_consumption.txt"
    if (!file.exists(kDataFile)) {
        kUrlSource <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip"
        kZipDestination <- "exdata_data_household_power_consumption.zip"

        download.file(kUrlSource, kZipDestination)
        unzip(kZipDestination)
    }

    dat <- fread(kDataFile, na.strings="?"
                 , colClasses = c(rep("character", 2), rep("numeric", 7)))

    # Filter the dates first, it's faster this way
    dat <- dat[Date %in% c("1/2/2007", "2/2/2007"), with = TRUE]

    # Create Date_time column from Date and Time as a date type
    dat[, Date_time := dmy_hms(paste(Date, Time))]
}

# Don't load data again, if variable already exists
if (!exists("power.data")) {
    power.data <- GetPowerData()
}

################################################################################

# Open png device, create file with default 480 x 480 px size
# Use a transparent background as the provided figures
png("plot1.png", bg = "transparent")

# Plot the data
with(power.data,
    hist(Global_active_power
         , col = "#FF2500"    # The Orange in figures
         , main = "Global Active Power"
         , xlab = "Global Active Power (kilowatts)"))

# Close the png file device
dev.off()
