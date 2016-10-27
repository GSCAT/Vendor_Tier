library(shiny)
library(dplyr)
library(tidyr)
library(lubridate)
library(readr)
library(shinythemes)

# use the below options code if you wish to increase the file input limit, in this example file input limit is increased from 5MB to 9MB
# options(shiny.maxRequestSize = 9*1024^2)

path <- file.path('~', 'Executive Dashboard', 'Q2 2016', 'Vendor', '2016_08_08', 'my_file.csv')

shinyServer(function(input,output){
  
  # This reactive function will take the inputs from UI.R and use them for read.table() to read the data from the file. It returns the dataset in the form of a dataframe.
  # file$datapath -> gives the path of the file

  
  data <- reactive({
    file1 <- input$file
    if(is.null(file1)){return()} 
    
    read.table(file=file1$datapath, sep=input$sep, header = input$header, 
               stringsAsFactors = input$stringAsFactors, quote = "\"", 
               check.names = FALSE, na.strings = c("", "NA"))
    
  })
  
  clean <- reactive({
    data()%>%
      select(`MasterVendorID`, `PAR_VENDOR_ID`, `PAR_VENDOR_LEGAL_DESC`, 
             `VENDOR_ID`, `VENDOR_LEGAL_DESC`, `Wovens`, `Sweaters`, `Knits`, 
             `IP`, `Denim & Woven Bottoms`, `Category Other`, `Accessories`, `3P & Lic`) %>%
      gather_(key_col = "Category", value_col ="Tier", 
              gather_cols = c("Wovens", "Sweaters", "Knits", "IP", 
                              "Denim & Woven Bottoms", "Category Other", 
                              "Accessories", "3P & Lic"), na.rm = input$na.rm ) %>%
      distinct()
  })
  
  # this reactive output contains the summary of the dataset and display the summary in table format
  output$filedf <- renderTable({
    if(is.null(data())){return ()}
    input$file 
  }) 
  
  # this reactive output contains the summary of the dataset and display the summary in table format
  output$sum <- renderTable({
    if(is.null(data())){return ()}
    summary(data())
    
  })
  
  # This reactive output contains the dataset and display the dataset in table format
  output$table <- renderTable({
    if(is.null(data())){return ()}
    my_clean_table <- data()%>%
      select(`MasterVendorID`, `PAR_VENDOR_ID`, `PAR_VENDOR_LEGAL_DESC`, 
             `VENDOR_ID`, `VENDOR_LEGAL_DESC`, `Wovens`, `Sweaters`, `Knits`, 
             `IP`, `Denim & Woven Bottoms`, `Category Other`, `Accessories`, `3P & Lic`) %>%
      gather_(key_col = "Category", value_col ="Tier", 
              gather_cols = c("Wovens", "Sweaters", "Knits", "IP", 
                              "Denim & Woven Bottoms", "Category Other", 
                              "Accessories", "3P & Lic"), na.rm = input$na.rm ) %>%
      distinct()
    
    # this_day <- today()
    # my_file <- paste('my_clean_table ', year(this_day), month(this_day), day(this_day), '.csv', sep = "")
    # write_csv(my_clean_table, path = paste(dirname(path),  my_file, sep = '/' ))
    # my_clean_table
    
  })
  
  output$downloadData <- downloadHandler(
    filename = function() {
      paste('ShinyTable', Sys.Date(), '.csv', sep='')
    },
    content = function(file) {
      write_csv(clean() , file)
    },
    contentType = "text/csv")
  # the following renderUI is used to dynamically generate the tabsets when the file is loaded. Until the file is loaded, app will not show the tabset.
  output$tb <- renderUI({
    if(is.null(data()))
      h5("Powered by GSCAT: ", tags$img(src='insidepocket3.jpg', heigth=400, width=400))
    else
      tabsetPanel(tabPanel("Data", tableOutput("table")), 
                  tabPanel("About file", tableOutput("filedf")),
                  tabPanel("Summary", tableOutput("sum")),
                  tabPanel("Download", downloadButton('downloadData', 'Download')))
  })
})
# output$downloadData <- downloadHandler(
#   filename = function() {
#     paste('data-', Sys.Date(), '.csv', sep='')
#   },
#   content = function(file) {
#     write.csv(data, file)
#  }
# )