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

spread_Vendor_ELC_table <- Vendor_ELC_table %>%
                              spread(Category,  value= Total_FCST_ELC)