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
      tableOutput("mrScoreResults")
    )
  )
)

server <- function(input, output) {
  source("mrscore.R")
  
  reactiveResults = reactiveValues(gsmTable = NULL)
  
  observeEvent(input$calculate, {
    withProgress(message = paste("Loading ", input$gsm), {
      reactiveResults$gsmTable = gsmTable <- Table(getGEO(input$gsm))
    })
  })
  
  output$mrScoreResults <- renderTable({
    x <- calculateMRscore(reactiveResults$gsmTable)
  })
}

# Run the application 
shinyApp(ui = ui, server = server)

