library(shiny)
library(tidyverse)
library(readxl)
library(shinythemes) # This is necessary for the theming function

# Load data
pdata <- read.csv("Kenya_Poverty_Trends.csv")

# Define UI
ui <- fluidPage(
    theme = shinytheme("cyborg"),
    titlePanel("Kenya Poverty Insights Dashboard"),
    sidebarLayout(
        sidebarPanel(
            selectInput("region", "Select Region", choices = unique(pdata$region))
        ),
        mainPanel(
            tabsetPanel(
                tabPanel("Multidimensional Poverty Index",
                         tableOutput("table"),
                         textOutput("text")),
                tabPanel("Contribution of Dimension to Poverty (%)",
                         plotOutput("secondplot"))
            )
        )
    )
)

# Define Server
server <- function(input, output) {
    
    output$secondplot <- renderPlot({
        filtered_data <- pdata %>%
            filter(region == input$region)
        ggplot(filtered_data, aes(x = dimension, y = Value)) +
            geom_col(fill = "steelblue") +
            labs(title = "Contribution of Dimensions to Poverty", 
                 x = "Dimension", 
                 y = "Contribution (%)") +
            theme_minimal()
    })
    
    output$table <- renderTable({
        pdata %>%
            filter(region == input$region) %>%
            select(MPI) %>%
            head(1) %>%
            rename(`Multidimensional Poverty Index (MPI)` = MPI)
    })
    
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
