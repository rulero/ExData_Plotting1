# This script will plot power consumption data into a PNG file
# INPUTS:
#   Power consumption file, it is automatically downloaded if necessary
#
# OUTPUTS:
#   A 480x480 px PNG file named plot3.png

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

## Change the language to make the day labels match figures
## preserve the existing locale (as suggested in forums)
my_locale <- Sys.getlocale("LC_ALL")

## change locale to English
Sys.setlocale("LC_ALL", "English")

# Open png device, create file with default 480 x 480 px size
# Use a transparent background as the provided figures
png("plot3.png", bg = "transparent")

# Plot the data
kLineColors <- c("#101010", "#FF2500", "#0433FF")
with(power.data, {
    # To be safe, call plot type-n with max values, so all lines will fit
    plot(Date_time, pmax(Sub_metering_1, Sub_metering_2, Sub_metering_3)
         , type="n", xlab = NA, ylab = "Energy sub metering")
    lines(Sub_metering_1, x = Date_time, col = kLineColors[1])
    lines(Sub_metering_2, x = Date_time, col = kLineColors[2])
    lines(Sub_metering_3, x = Date_time, col = kLineColors[3])
    legend("topright", col = kLineColors, lty = 1
           , legend = c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"))
})

# Close the png file device
dev.off()

## restore locale
Sys.setlocale("LC_ALL", my_locale)
