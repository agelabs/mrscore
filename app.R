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
  
  titlePanel("Calculate all-cause mortality from 450k"),
  
  sidebarLayout(
    sidebarPanel(
      textInput(inputId = "gsm",
                label = "Input a GEO accession sample number containing 450k data",
                placeholder = "GSMxxx"),
      helpText("Use GSM1886935 for example"),
      actionButton(inputId = "calculate", "Calculate all-cause mortality"),
      hr(),
      p("Calculates a persons all-cause mortality from their 450k DNA methylation based on the MRscore and cont.MRscore algorithms published in",
        a(href="https://doi.org/10.1038/ncomms14617", "\"DNA methylation signatures in peripheral blood strongly predict all-cause mortality\""),
        "by",
        a(href="https://www.researchgate.net/profile/Yan_Zhang121", "Yan Zhang"),
        " et al. Code available at ",
        a(href="https://github.com/agelabs/mrscore", "Github."),
        "Send comments or questions to",
        a(href="https://twitter.com/snowpong", "@snowpong")
      )
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
    trimmedGSM <- trimws(input$gsm)
    withProgress(message = paste("Loading and calculating ", trimmedGSM), {
      reactiveResults$gsmTable <- tryCatch({
        Table(getGEO(trimmedGSM))
      }, error = function(e) {
        NULL
      })
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

