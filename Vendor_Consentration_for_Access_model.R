library(dplyr)
library(tidyr)
library(readr)
library(rChoiceDialogs)

# Sys.setenv(JAVA_HOME='C:\\Program Files\\Java\\jre6')
# library(rJava)

choose_file_directory <- function()
{
  v <- jchoose.dir()
  return(v)
}

path <- choose_file_directory()

Parent_Vendor_Table <- read_csv(paste(choose_file_directory(), 'Parent Child Vendors with Tier 20161027.csv' , sep = '/'))
# View(Parent_Vendor_Table)

# path <- file.path('~', 'Executive Dashboard', 'Q2 2016', 'Vendor', '2016_08_08', 'my_file.csv')

# Parent_Vendor_Table <- read_csv(paste(dirname(path), 'Parent Child Vendors with Tier 20160805.csv' , sep = '/'))
# View(Parent_Vendor_Table)

Parent_Vendor_Table <- Parent_Vendor_Table %>%
  select(MasterVendorID, PAR_VENDOR_ID, PAR_VENDOR_LEGAL_DESC, VENDOR_ID, 
         VENDOR_LEGAL_DESC, Wovens, Sweaters, Knits, IP, 
         `Denim & Woven Bottoms`, `Category Other`, Accessories, `3P & Lic`)

View(Parent_Vendor_Table)

Parent_vendor_Master <- Parent_Vendor_Table %>%
  gather("Category", "Tier", 
         Wovens, Sweaters, Knits, IP, `Denim & Woven Bottoms`, 
         `Category Other`, Accessories, `3P & Lic`) 

View(Parent_vendor_Master)


Parent_vendor_Master2 <- Parent_Vendor_Table %>%
  gather("Category", "Tier", 
         Wovens, Sweaters, Knits, IP, `Denim & Woven Bottoms`,
         `Category Other`, Accessories, `3P & Lic`, na.rm=TRUE)

View(Parent_vendor_Master2)

write_csv(Parent_vendor_Master, path = paste(dirname(path),  'VendorMaster.csv', sep = '/' ))
write_csv(Parent_vendor_Master2, path = paste(dirname(path),  'VendorMaster2.csv', sep = '/' ))


Claimed_Vendors <- Parent_vendor_Master2 %>% 
  select(Category, VENDOR_ID, VENDOR_LEGAL_DESC, Tier) %>%
  mutate(Total_Category =  paste('Total', Category, sep=' ' ), Claimed = -1) %>% 
  select(Total_Category, VENDOR_ID, VENDOR_LEGAL_DESC, Tier, Claimed)

names(Claimed_Vendors) <- c("Category", "Vendor ID", "Vendor Name", "Vendor Status", "Claimed")
View(distinct(Claimed_Vendors))

write_csv(distinct(Claimed_Vendors), path = paste(path,  'Claimed Vendors.csv', sep = '/' ))


GIS_Master_Vendor <- Parent_vendor_Master2 %>% 
  select(Category, MasterVendorID, VENDOR_LEGAL_DESC, Tier, VENDOR_LGCY_ID) %>%
  mutate(Category=replace(Category, Category=="Denim & Woven Bottoms", 'Denim and Woven Bottoms')) %>%
  mutate(Total_Category =  paste('Total', Category, sep=' ' )) %>% 
  select(MasterVendorID, Category, Total_Category,  VENDOR_LEGAL_DESC, Tier, VENDOR_LGCY_ID)

 View(GIS_Master_Vendor)
 write_csv(GIS_Master_Vendor, path = paste(path,  'GIS_Master_Vendor_Status.csv', sep = '/' ))
 