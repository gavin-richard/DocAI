library(tesseract)
library(pdftools)

pdf_to_text <- function(pdf_path) {
  eng <- tesseract("eng")  # R will use system PATH if Tesseract is installed properly
  images <- pdf_convert(pdf_path, dpi = 300)
  texts <- vapply(images, function(img) ocr(img, engine = eng), character(1))
  paste(texts, collapse = "\n")
}
