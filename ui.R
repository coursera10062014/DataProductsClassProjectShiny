library(shiny)
shinyUI(pageWithSidebar(
  headerPanel("Global Temperature Trends"),
  sidebarPanel(
    h3('Year Range'),
    sliderInput('range', 'Years:', min=1880, max=2014, step=1,
                value=c(1880,2014))
  ),
  mainPanel(
    plotOutput("oPlot"),
    div(paste(
      "The plot above plots Northern Hemisphere mean annual temperature ",
      "over both land and sea, compared to the period 1951-1980.  The ",
      "units are expressed in hundredths of a degree Fahrenheit as the ",
      "offset from the baseline.")),
    div(paste("Based on the period you selected, a linear fit suggests ",
              "that the temperature is rising approximately this many ",
              "hundredths of a degree celcius every year:")),
    verbatimTextOutput("oSlope"),

    h3("Data Source"),
    div("This data comes from the a NASA"),
    a(href="http://data.giss.nasa.gov/gistemp/tabledata_v3/NH.Ts+dSST.txt",
      "data source")
  )
))