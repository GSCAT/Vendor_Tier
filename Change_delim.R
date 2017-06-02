library(dplyr)
library(tidyr)
library(readr)
library(rChoiceDialogs)
library(xlsx)

choose_file_directory <- function()
{
  v <- jchoose.dir()
  return(v)
}

my_dir <- choose_file_directory()

# Delim_Table <- read_csv(paste(choose_file_directory(), 'VendorMaster.csv' , sep = '/'))
Delim_Table <- read_delim(paste(choose_file_directory(), 'Vendor_Tier_LR.txt' , sep = '/'), delim = "^")

Delim_Table <- mutate(Delim_Table, "Date_modified" = as.Date('2016-11-11'))
Delim_Table <- Delim_Table %>% mutate(Category=replace(Category, Category=="Denim & Woven Bottoms", 'Denim and Woven Bottoms'))
write_delim(Delim_Table, paste(my_dir, 'Vendor_Tier_table 20170424.txt', sep='/'), delim ='^')

######## Need to persist Legacy Vendor ID

Vendor_ELC_table <- read_delim(paste(choose_file_directory(), 'SQLAExport.txt', sep = '/'), delim = '^')

# Tidying data
spread_Vendor_ELC_table <- Vendor_ELC_table %>%
                            mutate(Total_FCST_ELC = as.character(Vendor_ELC_table$Total_FCST_ELC))%>%
                              spread(Category,  value= Total_FCST_ELC)

nm_vec <- names(spread_Vendor_ELC_table)[1:6]
spread_Vendor_ELC_table <- spread_Vendor_ELC_table[c(nm_vec,'Wovens', 'Sweaters', 'Knits', 'IP', 'Denim and Woven Bottoms', 'Category Other', 'Accessories', '3P & Lic')]

# Table with ELC
View(spread_Vendor_ELC_table)

# Table with Tier
Vendor_Tier_Table <- Vendor_ELC_table 
# Vendor_Tier_Table <- Vendor_Tier_Table[c(1:6, 8, 7)]
# View(Vendor_Tier_Table)

Join_table <- left_join(Delim_Table, Vendor_Tier_Table, by = c('MasterVendorID', 'Category', "PAR_VENDOR_ID", "VENDOR_ID"))

Output_table <- Join_table %>% select(c(1:9,13)) %>% 
  spread(`Category`, `Total_FCST_ELC`)
Output_table2 <- Join_table %>% select(1:9) %>% spread(Category, "Tier")

write.xlsx(Output_table2, paste(my_dir, "Vendor_Workbook.xlsx", sep = "/"), sheetName = "Tiering",  showNA = FALSE)
write.xlsx(Output_table, paste(my_dir, "Vendor_Workbook.xlsx", sep = "/"), sheetName = "ELC", append= TRUE, showNA = FALSE)


colSums(Output_table[, -c(1:6)], na.rm = TRUE)

# Anti-Join table
anti_join_table <- anti_join(Vendor_Tier_Table, Delim_Table,  by = c('MasterVendorID', 'Category', "PAR_VENDOR_ID", "VENDOR_ID"))
write.xlsx(anti_join_table, paste(my_dir, "Vendor_Workbook.xlsx", sep = "/"), sheetName = "New Vendors", append= TRUE, showNA = FALSE)
