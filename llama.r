# Wrapper that calls Ollama   ----
run_llama_summary <- function(text, max_chars = 3000) {
  prompt <- sprintf(
    "Summarise this document in bullet points:\n%s",
    substr(text, 1, max_chars)
  )
  
  # System call; Ollama server must be running in the background
  # Windows users can start it with 'start /B ollama serve'
  result <- system2(
    command = "ollama",
    args    = c("run", "llama3", "--prompt", shQuote(prompt)),
    stdout  = TRUE, stderr = TRUE
  )
  paste(result, collapse = "\n")
}
