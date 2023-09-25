# Server
library(dplyr)
library(shiny)
library(ggplot2)
library(scales)
library(DT)
titanic <- read.csv("train.csv")

server <- function(input, output, session) {
  
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
  
  observe({
    query = parseQueryString(session$clientData$url_search)
    pclass = query[["pclass"]]
    age = query[["age"]]
    
    if (!is.null(pclass) && !is.null(age)) {
      pclass = gsub("%20", " ", pclass) # Reemplazar %20 con espacios
      age = gsub("%20", " ", age)
      
      updateTextInput(session, 'pclass', value = pclass)
      updateTextInput(session, 'age', value = age)
    }
  })
  observe({
    pclass = input$pclass
    age = input$age
    
    if (session$clientData$url_port == '') {
      x = NULL
    } else {
      x = paste0(':', session$clientData$url_port)
    }
    
    link = paste0("http://",
                  session$clientData$url_hostname,
                  x,
                  session$clientData$url_pathname,
                  "?","pclass=", pclass,
                  "&", "age=", paste(age, collapse = ",")
    )
    updateTextInput(session,
                    'url_param',
                    value = link)
  })
  
  filtered_data <- reactive({
    pclass = input$pclass
    age = input$age
    filtered_titanic <- titanic %>%
      filter(Pclass == pclass, Age >= age[1], Age <= age[2])
    return(filtered_titanic)
  })
  
  output$titanicPlot <- renderPlot({
    filtered_data() %>%
      ggplot(aes(x = Age, fill = Sex)) +
      geom_histogram(binwidth = 5) +
      labs(title = "Distribución de Edades por Género",
           x = "Edad",
           y = "Frecuencia") +
      theme_minimal()
  })
}