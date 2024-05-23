# Kenya Poverty Insights Dashboard

This Shiny application provides insights into the Multidimensional Poverty Index (MPI) by region in Kenya. It allows users to select a region and view the MPI and the contribution of different dimensions to poverty.

## Features

- **Multidimensional Poverty Index by Region**: Displays the MPI for the selected region.
- **Contribution of Dimension to Poverty**: Visualizes the contribution of various dimensions to the poverty index.

## Data Source

The data used in this application is from the "Kenya_Poverty_Trends.csv" file, published and updated by the Oxford Poverty and Human Development Initiative in 2021. The Global MPI is measured in over 100 countries and tracks indicators across 10 dimensions, including health, education, and living standards.

## Prerequisites

Make sure you have the following R packages installed:

- `shiny`
- `tidyverse`
- `readxl`
- `shinythemes`

You can install these packages using the following commands:

```r
install.packages("shiny")
install.packages("tidyverse")
install.packages("readxl")
install.packages("shinythemes")
```

## How to Run the Application

1. **Clone the Repository or Download the Source Code**:
   - Clone the repository using Git:

     ```sh
     git clone <repository-url>
     ```

   - Or download the source code as a ZIP file and extract it.

2. **Prepare the Data File**:
   - Ensure the "Kenya_Poverty_Trends.csv" file is in the same directory as the R script.

3. **Run the Application**:
   - Open the R script file in your R IDE (such as RStudio) or R console.
   - Run the script to launch the application:

     ```r
     # Load the necessary libraries
     library(shiny)
     library(tidyverse)
     library(readxl)
     library(shinythemes)

     # Load data
     pdata <- read.csv("Kenya_Poverty_Trends.csv")

     # Define UI and Server components
     # (Ensure these are in your script)

     # Run the application
     shinyApp(ui = ui, server = server)
     ```

4. **Interact with the Application**:
   - After running the script, a web browser window should open displaying the Kenya Poverty Insights Dashboard.
   - Use the dropdown menu to select a region and view the MPI and dimension contributions for that region.

## License

This project is licensed under the MIT License. See the LICENSE file for details.

## Acknowledgments

The data used in this application is provided by the Oxford Poverty and Human Development Initiative.
