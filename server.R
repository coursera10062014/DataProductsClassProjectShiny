library(shiny)
library(ggplot2)
library(lattice)

loadData <- function() {
  sourceURL <- "http://data.giss.nasa.gov/gistemp/tabledata_v3/NH.Ts+dSST.txt"
  localFile = "data.text"
  if (!file.exists(localFile)) {
    download.file(sourceURL, destfile=localFile, quiet=TRUE)
  }
  raw <- read.fwf(localFile,
                  widths=c(4, 6, 5, 5, 5, 5, 5, 5, 5, 5, 5,
                           5, 5, 7, 4, 7, 5, 5, 5, 6),
                  skip=7,
                  col.names = c("Year", "Jan", "Feb", "Mar", "Apr",
                                "May", "Jun", "Jul", "Aug", "Sep",
                                "Oct", "Nov", "Dec", "AnnualMeanJanToDec",
                                "AnnualMeanDecToNov", "DJF", "MAM",
                                "JJA", "SON", "Year2"))
  # headers are repeated throughout with separator lines.
  # prune things down a bit
  year <- as.character(raw$Year)
  want <- grep("^\\d{4}$", year)
  goodYear <- raw[want,]
  # Still a few trailing junk values at the tail
  want <- grep("^\\s*-?\\d+$", as.character(goodYear$Jan))
  goodJan <- goodYear[want,]
  num <- lapply(goodJan, function(x) {
    suppressWarnings(as.numeric(as.character(x)))
  })
  num$Year <- as.integer(num$Year)
  num$Year2 <- as.integer(num$Year2)
  df <- as.data.frame(num)
  # Data is expressed in units of one one-hundredth of a degree
  # Celcius.  As an American imperialist, those units are
  # unsatisfying.
  
  # Units: 0.01 degrees celcius.
}

filterYears <- function(d, range) {
  subset(d, Year >= range[1] & Year <= range[2],
        select=Year:Year2)
}

shinyServer(
  function(input, output) {
    d <- loadData()
    cachedFY <- reactive({filterYears(d, input$range)})
    output$oSlope <- renderText({lm(cachedFY()$AnnualMeanJanToDec ~ cachedFY()$Year)$coefficients[2]})
    output$oPlot <- renderPlot({
      f <- filterYears(d, input$range)
      fit <- lm(f$AnnualMeanJanToDec ~ f$Year);
      xyplot(f$AnnualMeanJanToDec ~ f$Year, panel = function(x, y, ...) {
        panel.xyplot(x, y, ...)
        panel.abline(fit)
      },
      xlab="Year",
      ylab="Temperature Index",
      main=paste("Northerm Hemisphere Mean Temperature Index from ",
                 input$range[1], " to ", input$range[2])
      )
      })
  })