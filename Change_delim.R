library(dplyr)
library(tidyr)
library(readr)
library(rChoiceDialogs)

choose_file_directory <- function()
{
  v <- jchoose.dir()
  return(v)
}


Delim_Table <- read_csv(paste(choose_file_directory(), 'my_clean_table 20160815.csv' , sep = '/'))

Delim_Table <- mutate(Delim_Table, "Date_modified" = as.Date('2016-08-15'))

write_delim(Delim_Table, paste(choose_file_directory(), 'Vendor_Tier_table 20160815.txt', sep='/'), delim ='^')

Vendor_ELC_table <- read_delim(paste(choose_file_directory(), 'Master_Vendor_with_ELC.txt', sep = '/'), delim = '^')

# Tidying data
spread_Vendor_ELC_table <- Vendor_ELC_table %>%
                            mutate(Total_FCST_ELC = as.character(Vendor_ELC_table$Total_FCST_ELC))%>%
                              spread(Category,  value= Total_FCST_ELC)

nm_vec <- names(spread_Vendor_ELC_table)[1:5]
spread_Vendor_ELC_table <- spread_Vendor_ELC_table[c(nm_vec,'Wovens', 'Sweaters', 'Knits', 'IP', 'Denim and Woven Bottoms', 'Category Other', 'Accessories', '3P & Lic')]

# Table with ELC
View(spread_Vendor_ELC_table)

# Table with Tier
Vendor_Tier_Table <- Vendor_ELC_table %>% mutate("Tier" = NA)
Vendor_Tier_Table <- Vendor_Tier_Table[c(1:6, 8, 7)]
View(Vendor_Tier_Table)

Join_table <- left_join(Delim_Table, Vendor_Tier_Table, by = c('MasterVendorID', 'Category', "PAR_VENDOR_ID", "VENDOR_ID"))
