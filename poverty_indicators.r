library(shiny)
library(tidyverse)
library(readxl)
library(shinythemes)
library(plotly)
library(shinyWidgets)

# Load data
pdata <- read.csv("Kenya_Poverty_Trends.csv")

# Check if year column exists (for optional time filter)
has_year <- "year" %in% names(pdata)
years <- if (has_year) sort(unique(pdata$year)) else NULL

# Define UI
ui <- fluidPage(
  theme = shinytheme("cyborg"),
  titlePanel("Kenya Poverty Insights Dashboard"),
  
  sidebarLayout(
    sidebarPanel(
      pickerInput(
        inputId = "region",
        label = "Select Region(s)",
        choices = unique(pdata$region),
        selected = unique(pdata$region),
        options = list(`actions-box` = TRUE),
        multiple = TRUE
      ),
      # Add year slider if available
      if (has_year) {
        sliderInput("year", "Select Year", 
                    min = min(pdata$year), max = max(pdata$year), 
                    value = max(pdata$year), step = 1, sep = "")
      },
      
      hr(),
      # Add download buttons
      downloadButton("downloadTable", "Download MPI Table"),
      downloadButton("downloadPlot", "Download Contribution Plot")
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Multidimensional Poverty Index",
                 br(),
                 # Value box style summary
                 uiOutput("mpiSummary"),
                 br(),
                 tableOutput("table"),
                 br(),
                 textOutput("text")),
        tabPanel("Contribution of Dimension to Poverty (%)",
                 br(),
                 plotlyOutput("secondplot"))
      )
    )
  )
)

# Define Server
server <- function(input, output, session) {
  
  # Reactive filtered data based on inputs
  filtered_data <- reactive({
    data <- pdata %>%
      filter(region %in% input$region)
    
    if (has_year) {
      data <- data %>% filter(year == input$year)
    }
    data
  })
  
  # Summary value box for MPI average
  output$mpiSummary <- renderUI({
    data <- filtered_data()
    
    avg_mpi <- data %>%
      summarise(avg = mean(MPI, na.rm = TRUE)) %>%
      pull(avg) %>%
      round(3)
    
    regions_selected <- length(unique(data$region))
    
    # Show summary box (simple bootstrap panel)
    div(style = "background-color:#222222; padding: 15px; border-radius: 8px; color: #00FFAA;",
        h4("Summary"),
        p(sprintf("Selected Regions: %d", regions_selected)),
        p(sprintf("Average MPI: %0.3f", avg_mpi))
    )
  })
  
  # Render the MPI table
  output$table <- renderTable({
    data <- filtered_data()
    
    # Distinct region and MPI average per region
    data %>%
      group_by(region) %>%
      summarise(`Multidimensional Poverty Index (MPI)` = round(mean(MPI, na.rm = TRUE), 3)) %>%
      rename(`Region` = region) %>%
      arrange(`Region`)
  })
  
  # Download handler for MPI table
  output$downloadTable <- downloadHandler(
    filename = function() {
      paste0("MPI_Table_", Sys.Date(), ".csv")
    },
    content = function(file) {
      write.csv(filtered_data() %>%
                  group_by(region) %>%
                  summarise(MPI = mean(MPI, na.rm = TRUE)),
                file,
                row.names = FALSE)
    }
  )
  
  # Render the contribution plot with ggplot + plotly
  output$secondplot <- renderPlotly({
    data <- filtered_data()
    
    # Validate there's data to plot
    req(nrow(data) > 0)
    
    p <- ggplot(data, aes(x = dimension, y = Value, fill = region)) +
      geom_col(position = "dodge") +
      labs(title = paste("Contribution of Dimensions to Poverty",
                         if (has_year) paste("(Year:", input$year, ")") else ""),
           x = "Dimension",
           y = "Contribution (%)") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
    
    ggplotly(p) %>% layout(legend = list(title = list(text = "<b>Region</b>")))
  })
  
  # Download handler for plot as PNG
  output$downloadPlot <- downloadHandler(
    filename = function() {
      paste0("Poverty_Contribution_Plot_", Sys.Date(), ".png")
    },
    content = function(file) {
      # Save ggplot as PNG
      ggsave(file, plot = last_plot(), device = "png", width = 10, height = 6)
    }
  )
  
  # Descriptive text output
  output$text <- renderText({
    paste(
      "The Multidimensional Poverty Index (MPI) reflects the population that is multidimensionally poor or suffering from acute poverty. ",
      "The data was published and updated by the Oxford Poverty and Human Development Initiative in 2021. The Global MPI is measured in over 100 countries, ",
      "tracking indicators across 10 dimensions including health (child mortality, nutrition), education (years of schooling, enrollment), and living standards ",
      "(water, sanitation, electricity, cooking fuel, floor, assets). ",
      "The chart on the second tab shows the contribution of each dimension to the poverty index. ",
      "Dimensions with the highest contribution (%) highlight programmatic areas that could be prioritized to address poverty."
    )
  })
}

# Run the application
shinyApp(ui = ui, server = server)
