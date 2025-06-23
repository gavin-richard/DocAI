Document AI Prototype (R + Shiny)
Offline prototype inspired by Google Document AI. Processes PDF invoices with high-resolution OCR (Tesseract), extracts key fields (invoice number, amount, date) via regex, stores results in SQLite, and offers a dark-mode Shiny UI with tabbed navigation.
📂 Project Structure

DocAIApp/
├── app.R               # Main Shiny app (UI + server)
├── R/
│   ├── ocr.R           # High-DPI OCR helper
│   ├── db.R            # SQLite helpers
│   └── llama.R         # (optional) LLaMA 3 prompt helper
├── www/                # Static assets (logo, CSS)
└── docai_data.sqlite   # Auto-created database

⚙️ Prerequisites

Tool / Package   | Notes
---------------- | -----
R 4.3+           | https://cran.r-project.org
Rtools (Win)     | Needed for package compilation
RStudio (opt)    | IDE
Tesseract 5      | UB Mannheim build (Windows) and add to PATH
Poppler          | PDF→PNG conversion; add poppler-bin to PATH
Packages         | shiny, shinyjs, pdftools, magick, tesseract, stringr, DBI, RSQLite

Install R packages:

install.packages(c(
  "shiny", "shinyjs", "pdftools", "magick",
  "tesseract", "stringr", "DBI", "RSQLite"
))

(Optional) For LLaMA 3 prompts: install Ollama and run `ollama serve`.
🚀 Running the App

git clone https://github.com/<your-user>/DocAIApp.git
cd DocAIApp
Rscript -e "shiny::runApp()"


1. Open the browser window that Shiny launches.
2. Upload a PDF invoice.
3. Click Extract.
   - Tab 1 shows raw OCR text & extracted fields.
   - Tab 2 lists all saved records from docai_data.sqlite.
4. Download fields as CSV if needed.

💡 Customising

Feature                 | How to tweak
----------------------- | ------------------------------
OCR DPI                 | Slider in sidebar (150–600 dpi)
Field patterns          | Edit regex strings in app.R (observeEvent)
Dark mode colours       | Modify inline CSS in app.R tags$style()
LLaMA prompts (optional)| Call run_llama_prompt() from R/llama.R

🛣️ Roadmap

- Batch upload & queue processing
- Visual PDF preview with bounding boxes
- Docker image for one-command deployment
- Integrate LLaMA 3 summaries/Q&A in UI

