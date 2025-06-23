library(DBI)

db_path <- "docai_data.sqlite"

init_db <- function() {
  con <- dbConnect(RSQLite::SQLite(), db_path)
  dbExecute(con, "
    CREATE TABLE IF NOT EXISTS extracted_data (
      id           INTEGER PRIMARY KEY AUTOINCREMENT,
      filename     TEXT,
      invoice_no   TEXT,
      total_amount TEXT,
      doc_date     TEXT,
      summary      TEXT,
      ts           DATETIME DEFAULT CURRENT_TIMESTAMP
    );
  ")
  dbDisconnect(con)
}

save_record <- function(filename, fields, summary) {
  con <- dbConnect(RSQLite::SQLite(), db_path)
  dbWriteTable(
    con, "extracted_data",
    data.frame(
      filename     = filename,
      invoice_no   = fields$invoice,
      total_amount = fields$total,
      doc_date     = fields$date,
      summary      = summary,
      stringsAsFactors = FALSE
    ),
    append = TRUE
  )
  dbDisconnect(con)
}

