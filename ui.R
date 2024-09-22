# ui ----

ui <- fluidPage(
  titlePanel("Student Time Analysis"),
  sidebarLayout(
    sidebarPanel(
      selectInput("term_filter",
                  "Semester Term:",
                  choices = c("Term 1" = "1", "Term 2" = "2"),
                  selected = "Term 1"),
      selectInput("day_filter",
                  "Day of Week:",
                  choices = c(
                    "All", "Mon", "Tues", "Wed", 
                    "Thurs", "Fri", "Sat", "Sun"
                  ),
                  selected = "All"),
      uiOutput("student_id_ui"),
      uiOutput("class_ui"),
      uiOutput("major_ui"),
      uiOutput("conc_ui"),
      uiOutput("dept_ui"),
      selectInput("max_gap_filter",
                  "Max Gap Between Classes (min):",
                  choices = c(10, 30, 60, 120, 180, 300, 600),
                  selected = 600),
      selectInput("increment_filter",
                  "Time Increment (min):",
                  choices = c(10, 20, 30, 60),
                  selected = 20),
      width = 3
    ),
    mainPanel(
      plotlyOutput("heatmap_plot", width = "100%", height = "800px"),
      width = 9
    )
  )
)