# UI
library(shiny)
titanic <- read.csv("train.csv")
ui <- fluidPage(
  titlePanel("Tabla de Titanic"),
  tabsetPanel(
    tabPanel("Campos",
             fluidRow(
               checkboxGroupInput("campos", "Campos a mostrar:",
                                  choices = names(titanic),
                                  selected = c("Name", "Survived")
               ),
               tableOutput("tabla_campos")
             ),
             title = "Selección de Campos"
    ),
    tabPanel("Tabla Filtrada",
             fluidRow(
               h3("Suma de Sobrevivientes:"),
               textOutput("total_sobrevivientes"),
               selectInput("sexo_filtrado", "Filtrar por Sexo:",
                           choices = c("male", "female", "all"),
                           selected = "all"),  # Opciones: "male", "female", "all"
               DT::dataTableOutput("tabla_filt")
             ),
             title = "Tabla Filtrada"
    ),
    tabPanel("Gráfica",
             fluidRow(
               plotOutput("grafica")
             ),
             title = "Gráfica de pie"
    )
  )
)