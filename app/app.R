# Shiny app to demonstrate the findings from reports.

## APP DESCRIPTION
# In our killer plot, we visualize the relative frequency of car crashes by
# contributing factor and time of day in a unique 24-hour clock format. The
# dotted line represents the average frequency of crashes for each contributing
# factor. The user can select the contributing factors, borough, year, and set
# the "softmax temperature" to control the aggressiveness of the softmax function,
# which determines the distribution of the relative frequencies. The user can
# select multiple contributing factors and a specific borough to analyze the
# data.

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

# Define UI for the app based on the description above
ui <- fluidPage(
  titlePanel("NYC Car Crash Analysis"),
  sidebarLayout(
    sidebarPanel(
      checkboxGroupInput("factors", "Select contributing factors to include:",
                         choices = NULL),
      selectInput("borough", "Select a borough:",
                  choices = NULL,
                  selected = "All Boroughs"),
      sliderInput("year", "Select a year:",
                  min = 2012, max = 2024, value = 2012, timeFormat = "%Y", sep = "", step = 1),
      sliderInput("temperature", "Softmax temperature:",
                  min = 0.1, max = 10, value = 1, step = 0.1),
      helpText("The softmax temperature controls the aggressiveness of the softmax function. A higher temperature will make the peaks more pronounced, while a lower temperature will make the distribution more uniform. The default value is 1."),
      helpText("The dotted line represents the average frequency of crashes for each contributing factor.")
    ),
    mainPanel(
      plotOutput("killerPlot", height = "1000px")
    )
  )
)

# Define server logic
server <- function(input, output, session) {
  # Connect to the database when the app starts
  app_con <- dbConnect(RSQLite::SQLite(), file.path("data", "app_data.db"))
  
  # Update the choices for contributing factors and boroughs based on the data
  updateCheckboxGroupInput(session, "factors",
                           choices = dbGetQuery(app_con, "SELECT DISTINCT Contributing_Factor_Category FROM app_data")$Contributing_Factor_Category,
                           selected = unique(dbGetQuery(app_con, "SELECT DISTINCT Contributing_Factor_Category FROM app_data")$Contributing_Factor_Category))
  
  updateSelectInput(session, "borough",
                    choices = c("All Boroughs", dbGetQuery(app_con, "SELECT DISTINCT BOROUGH FROM app_data")$BOROUGH),
                    selected = "All Boroughs")
  
  # Disconnect from the database when the app stops
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
      mutate(CRASH.HOUR = CRASH.HOUR %% 24) %>%
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
      scale_x_continuous(
        breaks = 0:23,  # Make sure this includes 0 and 23
        labels = function(x) ifelse(x == 0, "00:00", paste0(sprintf("%02d", x %% 24), ":00")),  # Add label for 24:00
        limits = c(0, 24)  # Explicitly set the limits to include 0 to 24
      ) +
      scale_y_continuous(labels = scales::percent_format()) +
      labs(x = "Hour of the Day", color = "AM/PM") +
      labs(y = "Relative Frequency") +
      theme_minimal() +
      theme(
        plot.title = element_text(hjust = 0.5),
        strip.text = element_text(size = 12, face = "bold"),
        panel.spacing = unit(1, "lines"),
        aspect.ratio = 1,
        legend.position = "right"
      ) +
      guides(color = guide_legend(title.position = "top", title.hjust = 0.5)) +
      ggtitle("Car Crashes by Contributing Factor and Time of Day") +
      labs(linetype = "Average Frequency")
  }, height = 800) 
}

# Run the application
shinyApp(ui = ui, server = server)




