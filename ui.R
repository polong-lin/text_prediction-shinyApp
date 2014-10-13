library(shiny)
shinyUI(fluidPage(
    titlePanel("Text Prediction App"),
    fluidRow("Note: When the page loads, please give 10-15 seconds for the app to load in the background."),
    hr(),
    fluidRow("In the space below:"),
    fluidRow("1. Type a sentence"),
    fluidRow("2. Press Submit"), 
    fluidRow("Wait a few seconds... and then you will see a few words that are likely to come next!"),
    hr(),
    textInput('sentenceInputVar', 'Type here:'),
    actionButton('submitButton', 'Submit'),
    fluidRow('(Example: "I want to go" or "She used to")'),
    verbatimTextOutput("oWordPredictions"),
    
    hr(),
    
    fluidRow("This app uses a very simplified version of the Kneser-Ney smoothing algorithm."),
    fluidRow("For more information, contact the creator of this app."),
    hr(),
    fluidRow("This app was created by Polong Lin. polong [dot] lin [at] gmail [dot] com.")
)
)