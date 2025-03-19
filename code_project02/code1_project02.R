library(readxl)
library(openxlsx)
library(dplyr)
library(stringr)
library(tools)
library(httr)
library(jsonlite)
library(writexl)

# Função para processar os dados de cada diretório
process_data <- function(XPATH, uat_phase) {
  REGEX <- "UAT Project"
  
  tabs <- c("Tests-Functionality", "Tests-Drivers", "Tests-Reporting")
  cols <- c("t_func", "t_drivers", "t_export")
  cols_n <- paste0(cols, "_n")
  tabs_cols <- setNames(cols, tabs)
  
  user_type_mapping <- list(
    "Charles" = "Super",
    "Kelly" = "Super",
    "Sonny" = "Super",
    "Theodore" = "Normal",
    "Amber" = "Normal",
    "Jose" = "Normal",
    "David" = "Super",
    "Matheus" = "Normal",
    "Scott" = "Normal",
    "Fiona" = "Normal",
    "Rachel" = "Normal",
    "Jonathan" = "Normal",
    "Anthony" = "Super",
    "Manoel" = "Super",
    "Richard" = "Normal"
  )
  
  folders <- list.files(XPATH, full.names = FALSE)
  folders <- folders[!grepl(".xlsx$", folders) & !grepl("^\\.", folders)]
  
  res <- data.frame(user = folders, stringsAsFactors = FALSE)
  res$user_type <- sapply(res$user, function(x) ifelse(x %in% names(user_type_mapping), user_type_mapping[[x]], "Super"))
  res[cols] <- 0
  res[cols_n] <- 0
  res$completed <- 0
  res$total <- 0
  res$uat_phase <- uat_phase
  
  for (folder in folders) {
    files <- list.files(file.path(XPATH, folder))
    fs_list <- files[str_detect(files, REGEX)]
    
    if (length(fs_list) == 0) {
      next
    }
    
    fs <- fs_list[1]
    file_path <- file.path(XPATH, folder, fs)
    
    counter <- 0
    for (tab in names(tabs_cols)) {
      xl <- read_excel(file_path, sheet = tab)
      
      f_pass <- !is.na(xl$`Pass / Fail`)
      f_id <- !is.na(xl$`Test Case ID`)
      
      res[res$user == folder, tabs_cols[[tab]]] <- sum(f_id & f_pass, na.rm = TRUE)
      res[res$user == folder, paste0(tabs_cols[[tab]], "_n")] <- sum(f_id, na.rm = TRUE)
      counter <- counter + sum(f_id, na.rm = TRUE)
    }
    
    res[res$user == folder, "completed"] <- rowSums(res[res$user == folder, cols])
    res[res$user == folder, "total"] <- counter
  }
  
  # Reordenando as colunas para que "UAT Phase" seja a primeira
  res <- res %>% select(uat_phase, everything())
  
  return(res)
}

# Processando os dados das três fases e combinando em uma única tabela
data1 <- process_data("uat/consumption", "1")
data2 <- process_data("uat/shipment", "2")
data3 <- process_data("uat/totalview", "3")

final_data <- bind_rows(data1, data2, data3)

# Salvando o resultado no Excel com uma única aba "Tests Information"
output_path <- "uat_test.xlsx"
wb <- createWorkbook()
addWorksheet(wb, "Tests Information")

# Escrevendo os dados no arquivo
writeData(wb, "Tests Information", final_data)

# Formatando a aba
header_fill <- createStyle(fgFill = "#800080", fontColour = "#FFFFFF", textDecoration = "bold")
addStyle(wb, sheet = "Tests Information", style = header_fill, rows = 1, cols = 1:ncol(final_data), gridExpand = TRUE)

setColWidths(wb, sheet = "Tests Information", cols = 1:ncol(final_data), widths = "auto")

border_style <- createStyle(borderColour = "black", borderStyle = "thin")
addStyle(wb, sheet = "Tests Information", style = border_style, rows = 1:nrow(final_data) + 1, cols = 1:ncol(final_data), gridExpand = TRUE)

# Salvando o arquivo
saveWorkbook(wb, output_path, overwrite = TRUE)
