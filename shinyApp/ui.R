#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Word Prediction"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
        textInput(inputId = "text",
                  label = "Type your text:",
                  value = ""),
        submitButton("Predict next words")
        
        
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
        h3("The next word could be one of these:"),
        verbatimTextOutput("words", placeholder = TRUE),
        
        h5("This Shiny App tries to predict the next word for a given input string"),
        h5("Once the text 'Enter text and press the button' appears in the field above, the data is loaded and you can start"),
        h5("To use this app simply enter a text into the input field and push the button, the result will appear as a list of the 3 most probable words")
    )
  )
))
