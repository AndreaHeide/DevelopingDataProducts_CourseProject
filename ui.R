#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.

library(shiny)
library(shinyTime)
library(lubridate)
library(leaflet)
library(plyr)
library(caret)
library(rpart)
library(plotly)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  
 ## headerPanel("Hunter's Help"),
  
        
  ## tabs
  navbarPage("Hunter's Help",
             tabPanel("Input game observations",
             
  
  # input location and weather conditions
  sidebarPanel(
          selectInput('Location', 'Select your location:', 
                      choices = c("Favourite field", "Neighbouring field", "Favourite woods","Neighbouring woods")),
          
          selectInput('Weather', 'Select weather type:', 
                      choices = c("Clear", "Light clouds", "Cloudy", "Light rain", "Heavy rain", "Snow")),
          
          sliderInput("Temperature",
                      "Indicate temperature:",
                      min = -25,
                      max = 40,
                      value = 20),
          hr(),
          
          dateInput("Date", "Date:", value = Sys.Date(), format = "dd-mm-yyyy"),
          
          selectInput('Time', 'Select time of day:', 
                      choices = c("Morning", "Afternoon", "Evening", "Night")),
          hr(),
          
        
          ## Game type
          selectInput('Type', 'Select game observed:', 
                      choices = c("Boar", "Deer", "Fox")),
          
          
          ## Count field
          numericInput('Count', 'Number:', 0, min = 0, max = 50, step = 1),
          helpText("Insert number of individuals observed.")
         
          
        ), # close brakket sidebar panel
  
    # Show choices for location and weather
    mainPanel(
     h5('These conditions are being recorded together with your sightings.'),
     h5('You entered location:'), verbatimTextOutput("oid1"),
     h5("You entered weather type:"),
     verbatimTextOutput("oid2"),
     h5("You entered temperature:"),
     verbatimTextOutput("oid3"),
     h5("Date:"),
     verbatimTextOutput("oid4"),
     h5("Time of day:"),
     verbatimTextOutput("oid4b"),
     hr(),
     
    # Show count values inserted
    h5('These counts are being recorded.'),
    h5('Type of game:'),
    verbatimTextOutput("oid5"),
    h5("Number of indiciduals observed:"),
    verbatimTextOutput("oid6"),
    hr(),
     
    ## Save button
    actionButton("Save", "Save"),
    singleton(
            tags$head(tags$script(src = "message-handler.js"))
    ),     
    
    h6("On this tab, the hunter can insert observations. These are saved to a .csv file."),
    h6("Not working properly yet: a confirmation message when the save button is clicked 
       and the record was saved successfully")
          ) # close main panel
 
        ), # close tab1
  
  tabPanel("Overview", 
         mainPanel(
           leafletOutput('game_map'),
           p(),
           h5("The observations of the last 4 weeks are shown as a proof of principle and using dummy data and locations."),
           h6("Planned functionality: users can select which type of game they want to display with check boxes,
              different icons / colours are used to display."),
           h6("Furthermore, specific hunting areas will be indicated with lines")
           
           ) # close main panel
  ), # close tab panel
  
  
  tabPanel("Prediction",
           sidebarPanel(
                 ## input prediction parameters 
                   selectInput('Loc', 'Select location:', 
                                choices = c("Favourite field", "Neighbouring field", "Favourite woods","Neighbouring woods")),
                   
                   selectInput('Timeblock', 'Select time of day:', 
                               choices = c("Morning", "Afternoon", "Evening", "Night")),
                   
                   selectInput('Conditions', 'Select weather conditions:', 
                               choices = c("Clear", "Light clouds", "Cloudy", "Light rain", "Heavy rain", "Snow")),
                   hr(),
                   
                   ## Predict button
                   actionButton("Predict", "Predict")
                   
           ), ## close sidebar panel
           mainPanel(
  h6("Modelling will take some time, please be patient..."),
  h6("At the moment, only boar sightings are predicted using a random forest model with number of boars as the outcome and location, time of day and weather as variables."),
  h6("The model has to be improved and variables as temperature, moon phase and others can be added. In the future, a time series model may also possible."), 
  hr(),
  
  h4("Expected number of game for selected conditions:"),
  verbatimTextOutput("oid7"),
  hr(),
  
  plotlyOutput("plot")
          
                 ) ## close main panel
                 ) ## close tab
         ) # close navbar
   ) # close fluid page
  ) # close shiny ui

