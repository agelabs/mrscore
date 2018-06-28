#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(GEOquery)

ui <- fluidPage(
  
  titlePanel("Calculate MRscore and cont.MRscore using Zhang et al."),
  
  sidebarLayout(
    sidebarPanel(
      textInput(inputId = "gsm",
                label = "Input a GEO accession number",
                placeholder = "GSMxxx"),
      helpText("Note: Use GSM1886935 for example",
               "on the full dataset."),
      actionButton(inputId = "calculate", "Calculate MRscore")
    ),
    
    mainPanel(
      tableOutput("mrScoreResults"),
      tableOutput("mrCpGResults")
    )
  )
)

server <- function(input, output) {
  source("mrscore.R")
  
  reactiveResults = reactiveValues(gsmTable = NULL, calculation = NULL)
  
  observeEvent(input$calculate, {
    withProgress(message = paste("Loading and calculating ", input$gsm), {
      reactiveResults$gsmTable = gsmTable <- Table(getGEO(input$gsm))
      
    })
  })
  
  observeEvent(reactiveResults$gsmTable, {
    reactiveResults$calculation <- calculateMRscore(reactiveResults$gsmTable)
  })
  
  output$mrScoreResults <- renderTable({
    x <- reactiveResults$calculation$Results
  })
  output$mrCpGResults <- renderTable({
    x <- reactiveResults$calculation$CpGTable
  })
}

# Run the application 
shinyApp(ui = ui, server = server)

