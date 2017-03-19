 
## server.r code of Hunter's Help

library(shiny)
library(shinyTime)
library(lubridate)
library(leaflet)
library(plyr)
library(caret)
library(rpart)
library(plotly)

# Define server logic to show choices and counts
shinyServer(function(input, output, session) {
        
        ## prepare data, load data
        GameData<- read.table(file = "./GameData.csv", sep = ",", header = TRUE) 
        GameData$Date <-as.Date(GameData$Date)

         
        ## show choices on ui 
        output$oid1 <- renderPrint({input$Location})
        output$oid2 <- renderPrint({input$Weather})
        output$oid3 <- renderPrint({input$Temperature})
        
        
        output$oid4 <- renderPrint({ paste(format(as.Date(input$Date, format = "yyyy-mm-dd"), format="%d-%m-%Y"))
        output$oid4b <- renderPrint({input$Time})        
                })
        
     
                   
        ## show type
        output$oid5 <- renderPrint({input$Type})
        
        ## show counts
        output$oid6 <- renderPrint({input$Count})
        
        
        ## button
        observeEvent(input$Save, { 
                
                var_date <- format(as.Date(input$Date, format = "yyyy-mm-dd"), format="%Y-%m-%d")
          
                record <- cbind("Game" = input$Type, "Number" = input$Count, "Location" = input$Location, 
                                "Date" = var_date , "Weather" = input$Weather, 
                                "Temperature" = input$Temperature, "TimeBlock" = input$Time)
                
                GameData <- rbind(GameData, record)
                        
                ## save data frame as csv
                write.csv(GameData, file = "./GameData.csv", row.names=FALSE, na="")
             
                session$sendCustomMessage(type = 'testmessage',
                                          message = 'Your observation has been saved.')
                
                updateNumericInput(session, "Count","Number:", 0)
                
                  })
        
        
        ## make map
        ## defining coordinates of the locations, add in dataset later
        set.seed(123123)
        location_data <- data.frame(lat= runif(4, min=50.82, max=50.83), lng= runif(4, min=5.75, max=5.78))
        
        ## Selecting last 4 weeks and - for now - only game type "boar" (add dynamic selection later)
        GameData_boar <- GameData[(GameData$Game == "Boar"), ]
        GameData_month <- GameData_boar[(GameData_boar$Date > (GameData_boar$Date - weeks(4))),]   
        wildlife_info <-  aggregate(GameData_month$Number, by=list(Category= GameData_month$Location, GameData_month$Game), FUN=sum)
        
        colnames(wildlife_info) <- c("Location","Game", "Count")
        wildlife_popup <- cbind(wildlife_info$Location, wildlife_info$Count, wildlife_info$Game)
        
        
        ## define icon (boar)
        wildlife <- makeIcon(   iconUrl = "./boar.png",
                                iconWidth = 31*215/230, iconHeight = 31,
                                iconAnchorX = 31*215/230/2, iconAnchorY = 16)
        
        
        mymap <-  location_data %>%
                leaflet %>%
                addTiles %>%
                addMarkers(icon = wildlife, popup = wildlife_info, clusterOptions = markerClusterOptions())
        
        output$game_map <- renderLeaflet({mymap})
        
        
        ## model for prediction: using a random forest model to predict number of game from input parameters
        
        ## button for prediction
        observeEvent(input$Predict, { 
                
                GameData_model <- GameData[(GameData$Game == "Boar"), ]
              
                modFit <- train(Number ~ Location + Weather + TimeBlock, method="rf", data=GameData_model)

                pred_data <- cbind("Location" = input$Loc, "Weather" = input$Conditions, "TimeBlock" <- input$Timeblock)
                
                prediction <- as.integer(predict(modFit, newdata = pred_data))
              
                ## show prediction
                output$oid7 <- renderPrint({prediction})
        })
        
        ## add plot for overview 
        GameOverview <- aggregate(GameData$Number, by=list(GameData$Location, GameData$Game), FUN=sum)
        colnames(GameOverview) <- c("Location","Game", "Count")
         
        output$plot <- renderPlotly({
                plot_ly(GameOverview) %>% 
                       add_trace(data = GameOverview, type = "bar", x = ~Location, y = ~Count, color = ~Game) %>%  
                        layout(barmode = "grouped",
                                title = "Overview numbers of game sighted",
                              xaxis = list(title = "Number of game"),
                              yaxis = list(title = "Location")) 
                
                
        })       
        
     
        
        
        
})

  

