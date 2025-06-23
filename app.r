source(file.path("D:", "Projects and Research", "DocAI App", "R", "ocr.r"))

source("D:\\Projects and Research\\DocAI App\\R\\llama.r")

source("D:\\Projects and Research\\DocAI App\\R\\db.r")
init_db()

ui <- fluidPage(
  useShinyjs(),
  tags$head(
    tags$style(HTML("body { background-color: #111; color: #fff; }
                     .well, .panel { background-color: #222; color: #eee; border-color: #ff4444; }
                     .btn { background-color: #ff4444; color: white; border: none; }
                     .btn:hover { background-color: #cc0000; }
                     .form-control { background-color: #333; color: #eee; border-color: #ff4444; }
                     .dataTables_wrapper { color: black; }"))
  ),
  titlePanel("Document AI - OCR Extractor"),
  sidebarLayout(
    sidebarPanel(
      fileInput("pdf", "Upload a PDF", accept = ".pdf"),
      sliderInput("dpi", "DPI (OCR Quality)", min = 150, max = 600, value = 400, step = 50),
      actionButton("run", "Extract Text & Fields"),
      hr(),
      downloadButton("csv", "Download CSV"),
      checkboxInput("lightmode", "Toggle Light Mode", FALSE)
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("OCR & Extraction",
                 h4("Raw OCR Text"),
                 verbatimTextOutput("raw_text"),
                 h4("Extracted Fields"),
                 tableOutput("fields")
        ),
        tabPanel("Saved Records",
                 tableOutput("db_table")
        )
      )
    )
  )
)

# ---------- Server ----------
server <- function(input, output, session) {
  rv <- reactiveValues(text = NULL, fields = NULL, csv_path = NULL)
  
  # Light / dark background switch
  observe({
    if (isTRUE(input$lightmode)) {
      runjs("document.body.style.backgroundColor = '#fff';")
      runjs("document.body.style.color = '#000';")
    } else {
      runjs("document.body.style.backgroundColor = '#111';")
      runjs("document.body.style.color = '#fff';")
    }
  })
  
  # ---------- Extraction workflow ----------
  observeEvent(input$run, {
    req(input$pdf)
    pdf_path <- input$pdf$datapath
    
    # OCR (note: pdf_to_text currently uses internal dpi = 400; slider not wired)
    txt <- pdf_to_text(pdf_path)
    rv$text <- txt
    
    # Flexible regex patterns
    invoice_pattern <- "(?i)(Invoice\\s*No|Inv\\s*No|Bill\\s*No)[:\\-]?\\s*\\w+"
    total_pattern   <- "(?i)(Total\\s*Amount|Amount\\s*Due|Grand\\s*Total)[:\\-]?\\s*[\\$£€]?\\s*[0-9,\\.]+"
    date_pattern    <- "(?i)(Date|Invoice\\s*Date|Bill\\s*Date)[:\\-]?\\s*\\d{2}/\\d{2}/\\d{4}"
    
    rv$fields <- list(
      invoice = stringr::str_extract(txt, invoice_pattern),
      total   = stringr::str_extract(txt, total_pattern),
      date    = stringr::str_extract(txt, date_pattern)
    )
    
    # Save to DB and CSV
    save_record(input$pdf$name, rv$fields, "NA")
    df <- data.frame(File = input$pdf$name,
                     Invoice = rv$fields$invoice,
                     Total   = rv$fields$total,
                     Date    = rv$fields$date)
    rv$csv_path <- tempfile(fileext = ".csv")
    write.csv(df, rv$csv_path, row.names = FALSE)
  })
  
  # ---------- Outputs ----------
  output$raw_text <- renderText({ req(rv$text); rv$text })
  output$fields   <- renderTable({ req(rv$fields); rv$fields }, rownames = TRUE)
  
  output$csv <- downloadHandler(
    filename = function() "extracted_fields.csv",
    content  = function(file) file.copy(rv$csv_path, file)
  )
  
  output$db_table <- renderTable({
    con <- DBI::dbConnect(RSQLite::SQLite(), "docai_data.sqlite")
    data <- DBI::dbReadTable(con, "extracted_data")
    DBI::dbDisconnect(con)
    data
  })
}

# ---------- Run App ----------
shinyApp(ui, server)


