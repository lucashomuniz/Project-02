library(readxl)
library(openxlsx)
library(dplyr)
library(stringr)
library(tools)
library(httr)
library(jsonlite)
library(writexl)

# Criar o nome do arquivo de saída 
output_file <- "master_defect_log.xlsx"

# Definir os caminhos dos arquivos e suas respectivas pastas de origem para cada código
files_phase1 <- list(
  "uat/Jonathan/consumption.xlsx",
  "uat/Sonny/consumption.xlsx",
  "uat/Charles/consumption.xlsx",
  "uat/Theodore/consumption.xlsx",
  "uat/Amber/consumption.xlsx",
  "uat/Richard/consumption.xlsx",
  "uat/Kelly/consumption.xlsx",
  "uat/Anthony/consumption.xlsx",
  "uat/Manoel/consumption.xlsx",
  "uat/Jose/consumption.xlsx",
  "uat/Matheus/consumption.xlsx",
  "uat/Fiona/consumption.xlsx",
  "uat/Scott/consumption.xlsx",
  "uat/Rachel/consumption.xlsx",
  "uat/David/consumption.xlsx"
)

files_phase2 <- list(
  "uat/Jonathan/shipment.xlsx",
  "uat/Sonny/shipment.xlsx",
  "uat/Charles/shipment.xlsx",
  "uat/Theodore/shipment.xlsx",
  "uat/Amber/shipment.xlsx",
  "uat/Richard/shipment.xlsx",
  "uat/Kelly/shipment.xlsx",
  "uat/Anthony/shipment.xlsx",
  "uat/Manoel/shipment.xlsx",
  "uat/Jose/shipment.xlsx",
  "uat/Matheus/shipment.xlsx",
  "uat/Fiona/shipment.xlsx",
  "uat/Scott/shipment.xlsx",
  "uat/Rachel/shipment.xlsx",
  "uat/David/shipment.xlsx"
)

files_phase3 <- list(
  "uat/Jonathan/totalview.xlsx",
  "uat/Sonny/totalview.xlsx",
  "uat/Charles/totalview.xlsx",
  "uat/Theodore/totalview.xlsx",
  "uat/Amber/totalview.xlsx",
  "uat/Richard/totalview.xlsx",
  "uat/Kelly/totalview.xlsx",
  "uat/Anthony/totalview.xlsx",
  "uat/Manoel/totalview.xlsx",
  "uat/Jose/totalview.xlsx",
  "uat/Matheus/totalview.xlsx",
  "uat/Fiona/totalview.xlsx",
  "uat/Scott/totalview.xlsx",
  "uat/Rachel/totalview.xlsx",
  "uat/David/totalview.xlsx"
)

# Lista de usuários "Champion"
normal_users <- c("Theodore", "Amber", "Jose", "Matheus", "Scott", "Fiona", "Rachel", "Jonathan", "Richard")

# Lista de usuários "Super User"
super_users <- c("Charles", "Kelly", "Sonny", "David", "Anthony", "Manoel")

# Função para ler os dados e adicionar as colunas "UAT PHASE", "UAT User", "USER TYPE" e "STATUS" vazia
read_and_label <- function(file_path, sheet_name, phase) {
  data <- read_excel(file_path, sheet = sheet_name)

# Verifica se as colunas 'Tester Name' e 'Date Tested' existem antes de removê-las
colunas_para_remover <- c("Tester Name", "Date Tested")
colunas_existentes <- colunas_para_remover[colunas_para_remover %in% colnames(data)]

if (length(colunas_existentes) > 0) {
  data <- data %>% select(-all_of(colunas_existentes))
}

uat_user <- basename(dirname(file_path)) 
user_type <- ifelse(uat_user %in% champion_users, "Normal",
                    ifelse(uat_user %in% super_users, "Super", ""))

# Ler e combinar os dados de cada aba com as colunas adicionadas para cada fase
merged_data_func1 <- do.call(rbind, lapply(files_phase1, function(f) 
  read_and_label(f, "Tests-Functionality", "1")))

merged_data_func2 <- do.call(rbind, lapply(files_phase2, function(f) 
  read_and_label(f, "Tests-Functionality", "2")))

merged_data_func3 <- do.call(rbind, lapply(files_phase3, function(f) 
  read_and_label(f, "Tests-Functionality", "3")))

merged_data_mbd1 <- do.call(rbind, lapply(files_phase1, function(f) 
  read_and_label(f, "Tests-Drivers", "1")))

merged_data_mbd2 <- do.call(rbind, lapply(files_phase2, function(f) 
  read_and_label(f, "Tests-Drivers", "2")))

merged_data_mbd3 <- do.call(rbind, lapply(files_phase3, function(f) 
  read_and_label(f, "Tests-Drivers", "3")))

merged_data_export1 <- do.call(rbind, lapply(files_phase1, function(f) 
  read_and_label(f, "Tests-Reporting", "1")))

merged_data_export2 <- do.call(rbind, lapply(files_phase2, function(f) 
  read_and_label(f, "Tests-Reporting", "2")))

merged_data_export3 <- do.call(rbind, lapply(files_phase3, function(f) 
  read_and_label(f, "Tests-Reporting", "3")))

merged_data_defect1 <- do.call(rbind, lapply(files_phase1, function(f) 
  read_and_label(f, "Defect-Log", "1")))

merged_data_defect2 <- do.call(rbind, lapply(files_phase2, function(f) 
  read_and_label(f, "Defect-Log", "2")))

merged_data_defect3 <- do.call(rbind, lapply(files_phase3, function(f) 
  read_and_label(f, "Defect-Log", "3")))

# Concatenar os dados de todas as fases para cada aba
merged_data_func <- bind_rows(merged_data_func1, merged_data_func2, merged_data_func3)
merged_data_mbd <- bind_rows(merged_data_mbd1, merged_data_mbd2, merged_data_mbd3)
merged_data_export <- bind_rows(merged_data_export1, merged_data_export2, merged_data_export3)
merged_data_defect <- bind_rows(merged_data_defect1, merged_data_defect2, merged_data_defect3)

# Reorganizar as colunas para que "UAT PHASE" seja a primeira
merged_data_func <- reorder_columns(merged_data_func)
merged_data_mbd <- reorder_columns(merged_data_mbd)
merged_data_export <- reorder_columns(merged_data_export)
merged_data_defect <- reorder_columns(merged_data_defect)

# Converter os nomes das colunas para MAIÚSCULO

format_column_names <- function(df) {
  colnames(df) <- toupper(colnames(df))
  return(df)
}

merged_data_func <- format_column_names(merged_data_func)
merged_data_mbd <- format_column_names(merged_data_mbd)
merged_data_export <- format_column_names(merged_data_export)
merged_data_defect <- format_column_names(merged_data_defect)

# Criar uma lista com os dataframes para salvar como abas separadas
data_list <- list(
  "Tests-Functionality" = merged_data_func,
  "Tests-Drivers" = merged_data_mbd,
  "Tests-Reporting" = merged_data_export,
  "Defect-Log" = merged_data_defect
)

# Criar o arquivo Excel com formatação
wb <- createWorkbook()

# Salvar o arquivo Excel com o nome dinâmico
saveWorkbook(wb, output_file, overwrite = TRUE)

# Exibir mensagem de sucesso
message("DONE", output_file)

# 🔑 Insert your OpenAI API Key
api_key <- "?"
ocr_api_key <- "?"

# Define o arquivo Excel e as abas
excel_file <- "master_defect_log.xlsx"
sheets <- c("Defect-Log", "Tests-Functionality", "Tests-Drivers", "Tests-Reporting")

# Lê os dados de todas as abas
data <- read_excel(excel_file, sheet = sheets[1])
functionality_data <- read_excel(excel_file, sheet = sheets[2])
mbd_data <- read_excel(excel_file, sheet = sheets[3])
reporting_data <- read_excel(excel_file, sheet = sheets[4])

# 🔹 FILTRAGEM: Remover linhas onde "TEST CASE ID" e "TEST CASE DESCRIPTION" estão vazias ou onde "TEST CASE DESCRIPTION" é "Example"
data_filtered <- data %>%
  filter(!(is.na(`TEST CASE ID`) | `TEST CASE ID` == "") & 
           !(is.na(`TEST CASE DESCRIPTION`) | `TEST CASE DESCRIPTION` == "" | `TEST CASE DESCRIPTION` == "Example")) %>%
  distinct(`UAT USER`, `USER TYPE`, `TEST CASE ID`, .keep_all = TRUE)

# Seleciona e combina colunas relevantes para a base de texto de classificação
texts <- data_filtered %>% 
  mutate(text_combined = paste(`TEST CASE DESCRIPTION`, `DESCRIPTION`, `COMMENTS`, sep = " | ")) %>%
  pull(text_combined)

# Define os arquivos PDF para contexto adicional
pdf_files <- c(
  "support_files/User_Acceptance_Testing.pdf",
  "support_files/App.pdf",
  "support_files/Instructions.pdf"
)

# Função para extrair texto de PDFs via API OCR
extract_pdf_text_api <- function(pdf_path) {
  tryCatch({
    response <- POST(
      url = "https://api.ocr.space/parse/image",
      body = list(
        apikey = ocr_api_key,
        file = upload_file(pdf_path),
        language = "eng"
      ),
      encode = "multipart"
    )
    content_data <- content(response, as = "parsed")
    if (!is.null(content_data$ParsedResults)) {
      text <- paste(sapply(content_data$ParsedResults, function(x) x$ParsedText), collapse = " ")
    } else {
      text <- ""
    }
    return(text)
  }, error = function(e) {
    message("Error reading ", pdf_path, ": ", e$message)
    return("")
  })
}

# Extrai texto dos PDFs via OCR API
pdf_content <- sapply(pdf_files, extract_pdf_text_api, USE.NAMES = FALSE)
combined_pdf_text <- paste(pdf_content, collapse = " ")

# Função para classificar textos com GPT-4o
classify_text_gpt4o <- function(text, test_case_desc) {
  if (is.na(test_case_desc) || test_case_desc == "") {
    return(c(NA, NA))
  }
  
  response <- POST(
    url = "https://api.openai.com/v1/chat/completions",
    add_headers(
      `Authorization` = paste("Bearer", api_key),
      `Content-Type` = "application/json"
    ),
    body = toJSON(list(
      model = "gpt-4o",
      messages = list(
        list(role = "system", content = paste("You are an AI-powered classifier designed to evaluate user feedback 
      collected during User Acceptance Testing (UAT) for an application. Your primary objective is to analyze the
      provided text and classify it into one of six predefined categories: Visualization Issue, Calculation Error, 
      Format Modification, Mapping Alignment and Others. It is essential to ensure that the category 
      Visualization Issue is assigned exclusively to feedback related to visual elements, such as charts and 
      graphs, and not to other types of issues. Beyond determining the primary category, you must also generate a 
      secondary category that further specifies the nature of the issue. This secondary classification should be 
      a concise phrase containing no more than five words, effectively summarizing the reported problem. Your 
      classification must be based on a thorough analysis of the provided information, ensuring that all relevant 
      details are considered before making a final determination. The accuracy of this classification process is 
      critical for the correct identification and resolution of issues encountered during UAT.

      Use the following reference documentation as background knowledge for classification:
      ", combined_pdf_text, "
      
      Output format:
      Primary Category: [Category Name]
      Secondary Category: [Category Name with 5 words]")),
        list(role = "user", content = paste("Text:", text))
      )
    ), auto_unbox = TRUE)
  )
  
  response_text <- content(response, as = "parsed")
  
  if (!is.null(response_text$error)) {
    print("🚨 API Error:")
    print(response_text$error$message)
    return(c("API Error", response_text$error$message))
  } else if (length(response_text$choices) == 0) {
    print("⚠️ No response generated by the API")
    return(c("No response", "No response"))
  } else {
    output_text <- response_text$choices[[1]]$message$content
    primary_category <- sub("Primary Category: ", "", strsplit(output_text, "\n")[[1]][1])
    secondary_category <- sub("Secondary Category: ", "", strsplit(output_text, "\n")[[1]][2])
    return(c(primary_category, secondary_category))
  }
}

# Obtém a data e hora atuais menos 2 horas no formato MM/DD/YYYY HH:MM
current_timestamp <- format(Sys.time() - 7200, "%m/%d/%Y %H:%M")

# Aplica a função de classificação aos textos filtrados
classification_results <- mapply(classify_text_gpt4o, texts, data_filtered$`TEST CASE DESCRIPTION`)

# Prepara os dados das abas para junção, garantindo unicidade por TEST CASE ID
functionality_subset <- functionality_data %>% 
  select(`TEST CASE ID`, FUNCTIONALITY) %>%
  distinct(`TEST CASE ID`, .keep_all = TRUE)
mbd_subset <- mbd_data %>% 
  select(`TEST CASE ID`, DRIVER) %>%
  distinct(`TEST CASE ID`, .keep_all = TRUE)
reporting_subset <- reporting_data %>% 
  select(`TEST CASE ID`, REPORTING) %>%
  distinct(`TEST CASE ID`, .keep_all = TRUE)

# Cria DataFrame com os resultados e faz junções à esquerda
results_df <- data_filtered %>%
  select(`UAT PHASE`, `UAT USER`, `USER TYPE`, `STATUS`, `TEST CASE ID`, `TEST CASE DESCRIPTION`, `DESCRIPTION`, `COMMENTS`, `ATTACHMENTS`, `READY FOR RETEST`, `RETEST PASS/FAIL`) %>%
  mutate(
    `TIMESTAMP` = current_timestamp,
    `CRITICALITY` = "",
    `PRIMARY CATEGORIZATION` = classification_results[1, ],
    `SECONDARY CATEGORIZATION` = classification_results[2, ],
    `RESOLUTIONS` = "",
    # Modifica a criação do KEY para incluir colchetes
    `KEY` = paste(`UAT PHASE`, `TIMESTAMP`, `UAT USER`, `USER TYPE`, `CRITICALITY`, `TEST CASE ID`, sep = "")
  ) %>%
  left_join(functionality_subset, by = "TEST CASE ID") %>%
  left_join(mbd_subset, by = "TEST CASE ID") %>%
  left_join(reporting_subset, by = "TEST CASE ID") %>%
  mutate(
    FUNCTIONALITY = coalesce(FUNCTIONALITY, ""),
    DRIVER = coalesce(DRIVER, ""),
    REPORTING = coalesce(REPORTING, ""),
    `RETEST COMMENTS` = "",
    `UNIQUE DEFECT` = "",
    `RELATED DEFECTS` = "",
    `UNIQUE_DEFECT STATUS` = ""
  ) %>%
  select(`KEY`, `UAT PHASE`, `TIMESTAMP`, `UAT USER`, `USER TYPE`, `STATUS`, `CRITICALITY`, `TEST CASE ID`, `DRIVER`, `FUNCTIONALITY`, `REPORTING`, `PRIMARY CATEGORIZATION`, `SECONDARY CATEGORIZATION`, `TEST CASE DESCRIPTION`, `DESCRIPTION`, `COMMENTS`, `ATTACHMENTS`, `RESOLUTIONS`, `READY FOR RETEST`, `RETEST PASS/FAIL`, `RETEST COMMENTS`, `UNIQUE DEFECT`, `RELATED DEFECTS`, `UNIQUE_DEFECT STATUS`)

# Ordenação dos dados (integrado do Código 2)
results_df <- results_df %>%
  # Salvar o formato original de TIMESTAMP como string para uso posterior
  mutate(TIMESTAMP_original = `TIMESTAMP`) %>%
  # Converter TIMESTAMP para POSIXct apenas para ordenação
  mutate(TIMESTAMP = as.POSIXct(`TIMESTAMP`, format = "%m/%d/%Y %H:%M")) %>%
  # Ordenar por UAT PHASE, UAT USER, TIMESTAMP e TEST CASE ID
  arrange(`UAT PHASE`, `UAT USER`, `TIMESTAMP`, `TEST CASE ID`) %>%
  # Reverter TIMESTAMP para o formato original sem fuso horário
  mutate(TIMESTAMP = format(`TIMESTAMP`, "%m/%d/%Y %H:%M")) %>%
  # Remover a coluna auxiliar TIMESTAMP_original
  select(-TIMESTAMP_original)

# Cria o arquivo Excel
wb <- createWorkbook()
addWorksheet(wb, "Defect Log Categorized")

# Salva o arquivo Excel
output_file <- "master_defect_log_cat_now.xlsx"
saveWorkbook(wb, output_file, overwrite = TRUE)

cat("Output Saved", output_file, "\n")
cat("DONE\n")
