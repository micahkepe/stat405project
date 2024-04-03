# Shiny app to demonstrate the findings from reports.

## APP DESCRIPTION
# In our killer plot, we will have concentric circles where each circle 
# represents a contributing factor to car crashes. The size of the circle 
# represents how common the contributing factor is (based on the number of car 
# crashes caused). For instance, if distracted driving is the most common 
# contributing factor, the circle representing distracted driving will be the 
# largest. Each circle will resemble a 12 hour clock. Along the circumference of 
# each circle, we will have two lines that depict the number of car crashes caused 
# by the contributing factor throughout the day. One line will represent AM and 
# the other line will represent PM. To make the peak crash times more pronounced 
# and visible, we plan to apply a “softmax” function (borrowing from its common 
# application in machine learning output layers) to apply greater weighting to 
# times with higher probabilities. This will make evident the “pulses/peaks” in 
# crash times and filter out the additional noise. This plot will allow us to 
# very clearly see how the number of car crashes is related to both the hour of 
# the day and contributing factors. 

if (!requireNamespace("shiny", quietly = TRUE)) {
  install.packages("shiny")
}

library(shiny)
library(bslib)
library(DBI)
library(RSQLite)
library(sqldf)
library(dplyr)
library(ggplot2)

# # load the data from ("../data/app_data.db")
app_con <- dbConnect(RSQLite::SQLite(), "../data/app_data.db")

# Define UI for the app based on the description above
ui <- fluidPage(
  titlePanel("Car Crash Analysis"),
  sidebarLayout(
    sidebarPanel(
      selectInput("factor", "Select a contributing factor:",
                  choices = dbGetQuery(app_con, "SELECT DISTINCT Contributing_Factor_Category FROM app_data")$Contributing_Factor_Category,
                  selected = "Driver Behavior"),
      selectInput("borough", "Select a borough:",
                  choices = dbGetQuery(app_con, "SELECT DISTINCT BOROUGH FROM app_data")$BOROUGH,
                  selected = "BROOKLYN"),
      selectInput("year", "Select a year:",
                  choices = dbGetQuery(app_con, "SELECT DISTINCT strftime('%Y', [CRASH.DATE]) AS year 
                                                FROM app_data
                                                ORDER BY year")$year,
                  selected = "2021")
    ),
    mainPanel(
      plotOutput("killerPlot")
    )
  )
)


# Define server logic
server <- function(input, output) {
  
  # Disconnect from the database when server stops
  onStop(function() {
    dbDisconnect(app_con())
  })
  
  output$killerPlot <- renderPlot({
    # Filter data based on user inputs
    data_filtered <- dbGetQuery(app_con, sprintf("
      SELECT Contributing_Factor_Category, [CRASH.DATE], [CRASH.TIME], BOROUGH
      FROM app_data
      WHERE Contributing_Factor_Category = '%s'
        AND BOROUGH = '%s'
        AND strftime('%%Y', [CRASH.DATE]) = '%s'
    ", input$factor, input$borough, input$year))
    
    # Prepare data for the plot
    data_summary <- data_filtered %>%
      mutate(
        CRASH.HOUR = as.integer(substr(CRASH.TIME, 1, 2)),
        CRASH.AMPM = ifelse(CRASH.HOUR < 12, "AM", "PM")
      ) %>%
      group_by(Contributing_Factor_Category, CRASH.HOUR, CRASH.AMPM) %>%
      summarize(count = n()) %>%
      ungroup()
    
    # Apply softmax function to the count for each contributing factor
    data_summary <- data_summary %>%
      group_by(Contributing_Factor_Category) %>%
      mutate(softmax_count = exp(count) / sum(exp(count))) %>%
      ungroup()
    
    # Create the plot
    ggplot(data_summary, aes(x = CRASH.HOUR, y = softmax_count, color = CRASH.AMPM)) +
      geom_line(size = 1) +
      facet_wrap(~ Contributing_Factor_Category, ncol = 1) +
      scale_x_continuous(breaks = 0:23, labels = paste0(0:23, ":00")) +
      labs(x = "Hour of the Day", y = "Softmax Count", color = "AM/PM") +
      theme_minimal() +
      theme(
        plot.title = element_text(hjust = 0.5),
        strip.text = element_text(size = 12, face = "bold"),
        panel.spacing = unit(1, "lines")
      ) +
      ggtitle("Car Crashes by Contributing Factor and Time of Day")
  })
}
  

# Run the application
shinyApp(ui = ui, server = server)
   
                    