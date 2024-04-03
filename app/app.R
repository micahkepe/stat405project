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


# Load the data from ("../data/app_data.db")
app_con <- dbConnect(RSQLite::SQLite(), "../data/app_data.db")

# Define UI for the app based on the description above
ui <- fluidPage(
  titlePanel("NYC Car Crash Analysis"),
  sidebarLayout(
    sidebarPanel(
      checkboxGroupInput("factors", "Select contributing factors to include:",
                         choices = dbGetQuery(app_con, "SELECT DISTINCT Contributing_Factor_Category FROM app_data")$Contributing_Factor_Category,
                         selected = unique(dbGetQuery(app_con, "SELECT DISTINCT Contributing_Factor_Category FROM app_data")$Contributing_Factor_Category)),
      selectInput("borough", "Select a borough:",
                  choices = c("All Boroughs", dbGetQuery(app_con, "SELECT DISTINCT BOROUGH FROM app_data")$BOROUGH),
                  selected = "All Boroughs"),
      sliderInput("year", "Select a year:",
                  min = 2012, max = 2024, value = 2012, timeFormat = "%Y", sep = "", step = 1),
      sliderInput("temperature", "Softmax temperature:",
                  min = 0.1, max = 10, value = 1, step = 0.1),
      helpText("The softmax temperature controls the aggressiveness of the softmax function. A higher temperature will make the peaks more pronounced, while a lower temperature will make the distribution more uniform. The default value is 1.")
    ),
    mainPanel(
      plotOutput("killerPlot", height = "1000px")
    )
  )
)

# Define server logic
server <- function(input, output) {
  # Disconnect from the database when server stops
  onStop(function() {
    dbDisconnect(app_con)
  })
  
  output$killerPlot <- renderPlot({
    # Filter data based on user inputs
    if (input$borough == "All Boroughs") {
      data_filtered <- dbGetQuery(app_con, sprintf("
        SELECT Contributing_Factor_Category, [CRASH.DATE], [CRASH.TIME], BOROUGH
        FROM app_data
        WHERE Contributing_Factor_Category IN ('%s')
          AND strftime('%%Y', [CRASH.DATE]) = '%s'
      ", paste(input$factors, collapse = "', '"), input$year))
    } else {
      data_filtered <- dbGetQuery(app_con, sprintf("
        SELECT Contributing_Factor_Category, [CRASH.DATE], [CRASH.TIME], BOROUGH
        FROM app_data
        WHERE Contributing_Factor_Category IN ('%s')
          AND BOROUGH = '%s'
          AND strftime('%%Y', [CRASH.DATE]) = '%s'
      ", paste(input$factors, collapse = "', '"), input$borough, input$year))
    }
    
    # Prepare data for the plot
    data_summary <- data_filtered %>%
      mutate(
        CRASH.HOUR = as.integer(substr(CRASH.TIME, 1, 2)),
        CRASH.AMPM = ifelse(CRASH.HOUR < 12, "AM", "PM")
      ) %>%
      group_by(Contributing_Factor_Category, CRASH.HOUR, CRASH.AMPM) %>%
      summarize(count = n(), .groups = "drop") %>%
      ungroup()
    
    # Calculate relative frequency for each contributing factor
    data_summary <- data_summary %>%
      group_by(Contributing_Factor_Category) %>%
      mutate(relative_freq = count / sum(count)) %>%
      ungroup()
    
    # Apply softmax function with temperature to the relative frequency
    data_summary <- data_summary %>%
      group_by(Contributing_Factor_Category) %>%
      mutate(softmax_freq = exp(relative_freq * input$temperature) / sum(exp(relative_freq * input$temperature))) %>%
      ungroup()
    
    # Calculate average frequency for each contributing factor
    avg_freq <- data_summary %>%
      group_by(Contributing_Factor_Category) %>%
      summarize(avg_freq = mean(softmax_freq))
    
    # Merge average frequency with data summary
    data_summary <- data_summary %>%
      left_join(avg_freq, by = "Contributing_Factor_Category")
    
    # Create the plot with separate graphs for each contributing factor
    ggplot(data_summary, aes(x = CRASH.HOUR, y = softmax_freq, color = CRASH.AMPM, group = CRASH.AMPM)) +
      geom_line(linewidth = 1) +
      geom_line(aes(y = avg_freq), linetype = "dashed", color = "black", size = 0.5) +
      facet_wrap(~ Contributing_Factor_Category, ncol = 2) +
      coord_polar() +
      scale_x_continuous(breaks = seq(0, 23), labels = paste0(sprintf("%02d", seq(0, 23)), ":00")) +
      labs(x = "Hour of the Day", color = "AM/PM") +
      labs(y = "Relative Frequency") +
      theme_minimal() +
      theme(
        plot.title = element_text(hjust = 0.5),
        strip.text = element_text(size = 12, face = "bold"),
        panel.spacing = unit(1, "lines"),
        aspect.ratio = 1,
        legend.position = "right",
      ) +
      guides(color = guide_legend(title.position = "top", title.hjust = 0.5)) +
      ggtitle("Car Crashes by Contributing Factor and Time of Day") +
      labs(linetype = "Average Frequency")
  }, height = 800)
}

# Run the application
shinyApp(ui = ui, server = server)
   
                    