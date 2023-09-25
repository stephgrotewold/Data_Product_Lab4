# Server
library(dplyr)
library(shiny)
library(scales)
titanic <- read.csv("train.csv")

server <- function(input, output) {
  
  # Función reactiva para calcular la suma de sobrevivientes según el filtro de sexo
  suma_sobrevivientes <- reactive({
    filtered_data <- titanic
    if (nrow(filtered_data) == 0) {
      return(0)
    }
    
    # Aplicar el filtro de sexo si es "male" o "female"
    if (input$sexo_filtrado %in% c("male", "female")) {
      filtered_data <- filtered_data[filtered_data$Sex == input$sexo_filtrado, ]
    }
    
    sobrevivientes <- nrow(filtered_data[filtered_data$Survived == 1, ])
    return(sobrevivientes)
  })
  
  output$total_sobrevivientes <- renderText({
    suma_sobrevivientes()
  })
  
  output$tabla_campos <- renderTable({
    if (length(input$campos) == 0) {
      return(data.frame())
    } else {
      filtered_data <- titanic[, input$campos, drop = FALSE]
      filtered_data
    }
  })
  
  output$tabla_filt <- DT::renderDataTable({
    filtered_data <- titanic
    if (input$sexo_filtrado %in% c("male", "female")) {
      filtered_data <- filtered_data[filtered_data$Sex == input$sexo_filtrado, ]
    }
    datatable(filtered_data, filter = "top")
  })
  
  output$grafica <- renderPlot({
    muertos <- nrow(titanic[titanic$Survived == 0, ])
    sobrevivientes <- nrow(titanic[titanic$Survived == 1, ])
    pie(c(muertos, sobrevivientes),
        labels = c("Muertos", "Sobrevivientes"),
        main = "Supervivientes del Titanic")
  })
}