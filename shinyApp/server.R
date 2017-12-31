#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(data.table)
uniGramsTable <- read.table("data/uniGramsTable.Rdata")
biGramsTable <- read.table("data/biGramsTable.Rdata")
triGramsTable <- read.table("data/triGramsTable.Rdata")
fourGramsTable <- read.table("data/fourGramsTable.Rdata")

uniGramsTable <- setDT(uniGramsTable[,2:3], keep.rownames = TRUE)
biGramsTable <- setDT(biGramsTable[,2:4], keep.rownames = TRUE)
triGramsTable <- setDT(triGramsTable[,2:5], keep.rownames = TRUE)
fourGramsTable <- setDT(fourGramsTable[,2:6], keep.rownames = TRUE)

setkey(uniGramsTable, word1)
setkey(biGramsTable, word1, word2)
setkey(triGramsTable, word1, word2, word3)
setkey(fourGramsTable, word1, word2, word3, word4)

# Define server logic to predict next words
shinyServer(function(input, output) {
   
    
    
    getNGramPrediction <- function(inputSplit, wordNumber, gramsTable, threshold) {
        #number of words to be returned
        numberReturnWords <- 3
        # get from n-gram all that start with those lastWords
        if(wordNumber >= 3) {
            gramsTableFiltered <- na.omit(gramsTable[.(tail(inputSplit,3)[1], tail(inputSplit,3)[2], tail(inputSplit,3)[3])][,5:6])
        } else if(wordNumber == 2) {
            gramsTableFiltered <- na.omit(gramsTable[.(tail(inputSplit,2)[1], tail(inputSplit,2)[2])][,4:5])
        } else if(wordNumber == 1) {
            gramsTableFiltered <- na.omit(gramsTable[.(tail(inputSplit,1)[1])][,3:4])
        } else {
            gramsTableFiltered <- na.omit(gramsTable[order(-gramsTable$freq),][,2:3])
        }
        names(gramsTableFiltered) <- c("words", "freq")
        # if no results left, return empty list
        if(nrow(gramsTableFiltered) == 0) {
            return(data.table(words = character(0), freq = integer(0)))
        }
        # return numberReturnWords words ordered by descending frequency
        gramsTableFiltered <- gramsTableFiltered[order(-gramsTableFiltered$freq),][1:min(nrow(gramsTableFiltered), numberReturnWords),]
        return(gramsTableFiltered)
    }
    
    getNextWords <- function(inputString) {
        #convert inputString to lower
        inputString <- tolower(inputString)
        #split inputString by space
        inputSplit <- strsplit(inputString, " ")[[1]]
        #get word count of input string
        wordCount <- as.integer(length(inputSplit))
        #prepare predictions
        predictions <- data.table(words = character(0), freq = integer(0))
        setkey(predictions, words)
        #add predictions from all n-grams
        if(wordCount >= 3) {
            predictions <- rbind(predictions, getNGramPrediction(inputSplit, 3, fourGramsTable, 0.1))
        }
        if(nrow(predictions) == 0 && wordCount >= 2) {
            predictions <- rbind(predictions, getNGramPrediction(inputSplit, 2, triGramsTable, 0.1))
        }
        if(nrow(predictions) == 0 && wordCount >= 1) {
            predictions <- rbind(predictions, getNGramPrediction(inputSplit, 1, biGramsTable, 0.1))
        }
        if(nrow(predictions) == 0 && wordCount >= 0) {
            predictions <- rbind(predictions, getNGramPrediction(inputSplit, 0, uniGramsTable, 0.1))
        }
        # return the 3 with the highest probability
        return(setDT(predictions)$words)
    }
    
    
    output$words <- renderText({
        
        validate(need(input$text != "", "Enter text and press the button"))
        paste( getNextWords(input$text), collapse = "\n")})     
    
  
})
