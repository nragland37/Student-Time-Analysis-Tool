# server ----

server <- function(input, output, session) {
  # filter ui ----
  
  # # student ID filter ----
  #  output$student_id_ui <- renderUI({
  #    selectizeInput("student_id",
  #                   "Student ID:",
  #                   choices = NULL,
  #                   multiple = TRUE,
  #                   options = list(maxOptions = 1000))
  #  })
  # 
  # ## server side processing for student ID filter ----
  #  observe({
  #    updateSelectizeInput(session, "student_id",
  #                         choices = unique(student_data$id),
  #                         server = TRUE)
  #  })
  
  ## class level filter ----
  output$class_ui <- renderUI({
    selectizeInput("class_filter",
                   "Class Level:",
                   choices = unique(student_data$cl),
                   multiple = TRUE,
                   options = list(maxOptions = 1000))
  })
  
  ## major filter ----
  output$major_ui <- renderUI({
    selectizeInput("major_filter",
                   "Major:",
                   choices = unique(student_data$major1_majortext),
                   multiple = TRUE,
                   options = list(maxOptions = 1000))
  })
  
  ## major concentration filter ----
  output$conc_ui <- renderUI({
    selectizeInput("conc_filter",
                   "Concentration:",
                   choices = unique(student_data$major1_conctext),
                   multiple = TRUE,
                   options = list(maxOptions = 1000))
  })
  
  ## department filter ----
  output$dept_ui <- renderUI({
    selectizeInput("dept_filter",
                   "Department:",
                   choices = unique(student_data$crs_dept),
                   multiple = TRUE,
                   options = list(maxOptions = 1000))
  })
  
  #*****************************************************************************
  # reactive expressions (caches data for efficiency) ----
  
  ## filter logic ----
  filtered_data <- reactive({
    inc <- as.numeric(input$increment_filter)
    max_gap <- as.numeric(input$max_gap_filter)
    
    student_results <- gap_interval_matching(inc)
    student_results <- filter_max_gap(student_results, max_gap)
    
    student_results %>%
      filter((term == input$term_filter) | (term == "full")) %>%
      filter(if (input$day_filter != "All") days == input$day_filter 
             else TRUE) %>%
      filter(length(input$student_id) == 0 | 
               id %in% input$student_id) %>%
      filter(length(input$class_filter) == 0 | 
               cl %in% input$class_filter) %>%
      filter(length(input$major_filter) == 0 | 
               major1_majortext %in% input$major_filter) %>%
      filter(length(input$conc_filter) == 0 | 
               major1_conctext %in% input$conc_filter) %>%
      filter(length(input$dept_filter) == 0 | 
               crs_dept %in% input$dept_filter)
  })
  
  ## counts ----
  term_counts <- reactive({
    get_term_counts(filtered_data(), input$term_filter)
  })
  
  ## heatmap ----
  output$heatmap_plot <- renderPlotly({
    p <- get_heatmap(term_counts(), input$term_filter)
    ggplotly(p)
  })
  
}

#*******************************************************************************