Vendor Concentration
================

-   [Processing Previous Vendor Tiering file](#processing-previous-vendor-tiering-file)

``` r
library(dplyr)
```

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

``` r
library(tidyr)
library(readr)
library(rChoiceDialogs)
```

    ## Loading required package: rJava

    ## This is rChoiceDialogs 1.0.6 2014-09-05

``` r
library(xlsx)
```

    ## Loading required package: xlsxjars

``` r
library(RODBC)
library(DBI)
```

``` r
choose_file_directory <- function()
{
  v <- jchoose.dir()
  return(v)
}

my_dir <- choose_file_directory()
```

Processing Previous Vendor Tiering file
---------------------------------------

This process begins with the previous season's file. After GIS included the tier changes (previous season) we need to move this work over to enrich the new data we pull from EDW. Let's start by reprocessing the previous season's file similar to below. All the following headings need to be exactly as shown here: `MasterVendorID`, `PAR_VENDOR_ID`, `PAR_VENDOR_LEGAL_DESC`, `VENDOR_ID`, `VENDOR_LGCY_ID`, `VENDOR_LEGAL_DESC`, `Wovens`, `Sweaters`, `Knits`, `IP`, `Denim & Woven Bottoms`, `Category Other`, `Accessories`, `3P & Lic`. Any variation in headings will throw an error. Other columns can be included but are ignored.

``` r
Parent_Vendor_Table <- read_csv(paste(choose_file_directory(), 'Vendor_Workbook_from_GIS.csv' , sep = '/'))
Parent_Vendor_Table <- Parent_Vendor_Table[, -which(names(Parent_Vendor_Table) %in% c("X1"))]
```

Select only the columns we need.

``` r
Parent_Vendor_Table <- Parent_Vendor_Table %>%
  select(MasterVendorID, PAR_VENDOR_ID, PAR_VENDOR_LEGAL_DESC, VENDOR_ID, VENDOR_LGCY_ID,
         VENDOR_LEGAL_DESC, Wovens, Sweaters, Knits, IP, 
         `Denim & Woven Bottoms`, `Category Other`, Accessories, `3P & Lic`)
```

Gather the Category columns so that we only have one row per Vender.

``` r
Parent_vendor_Master <- Parent_Vendor_Table %>%
  gather("Category", "Tier", 
        Wovens, Sweaters, Knits, IP, `Denim & Woven Bottoms`, 
        `Category Other`, Accessories, `3P & Lic`) 
```

``` r
write_csv(Parent_vendor_Master, path = paste(dirname(path),  'VendorMaster.csv', sep = '/' ))
```

``` r
my_uid <- read_lines("C:\\Users\\Ke2l8b1\\Documents\\my_uid.txt")
my_pwd <- read_lines("C:\\Users\\Ke2l8b1\\Documents\\my_pwd.txt")

my_connect <- odbcConnect(dsn= "IP EDWP", uid= my_uid, pwd= my_pwd)
# sqlTables(my_connect, catalog = "EDWP", tableName  = "tables")
sqlQuery(my_connect, query = "SELECT  * from dbc.dbcinfo;")
```

The `Parent_vendor_Master` table we will use to enrich the raw data that we will pull from EDW.

``` r
Vendor_ELC_table <- sqlQuery(my_connect, query = "Select        
CASE
            WHEN a11.PAR_VENDOR_ID = (-1) THEN a11.VENDOR_ID
            ELSE a11.PAR_VENDOR_ID END AS MasterVendorID,
    a11.PAR_VENDOR_ID,
    a21.VENDOR_LEGAL_DESC as PAR_VENDOR_LEGAL_DESC,
    a21.VENDOR_LGCY_ID,
    a11.VENDOR_ID,
    b21.VENDOR_LEGAL_DESC as VENDOR_LEGAL_DESC,
    case
        when SUBSTR(a112.AGT_DEPT_ABBR_DESC, 1, 2) = '3P' then '3P & Lic'
        when SUBSTR(a112.AGT_DEPT_ABBR_DESC, 1, 2) = 'A_' then 'Accessories'
        when SUBSTR(a112.AGT_DEPT_ABBR_DESC, 1, 2) = 'AL' then 'IP'
        when SUBSTR(a112.AGT_DEPT_ABBR_DESC, 1, 2) = 'D_' then 'Denim and Woven Bottoms'
        when SUBSTR(a112.AGT_DEPT_ABBR_DESC, 1, 2) = 'DW' then 'Denim and Woven Bottoms'
        when SUBSTR(a112.AGT_DEPT_ABBR_DESC, 1, 2) = 'I_' then 'IP'
        when SUBSTR(a112.AGT_DEPT_ABBR_DESC, 1, 2) = 'K_' then 'Knits'
        when SUBSTR(a112.AGT_DEPT_ABBR_DESC, 1, 2) = 'KF' then 'Knits'
        when SUBSTR(a112.AGT_DEPT_ABBR_DESC, 1, 2) = 'LC' then '3P & Lic'
        when SUBSTR(a112.AGT_DEPT_ABBR_DESC, 1, 2) = 'S_' then 'Sweaters'   
        when SUBSTR(a112.AGT_DEPT_ABBR_DESC, 1, 2) = 'W_' then 'Wovens'
        else 'Category Other'
        end as Category,
    sum(ELC_AMT_USD * FCST_QTY) as Total_FCST_ELC
    
    FROM VIEWORDER.VIUFF_INBND_UNT_FCST_FCT a11
    
    left outer join  VIEWORDER.VVLNL_VND_LEGAL_NM_LOOKUP a21
     on (MasterVendorID = a21.VENDOR_ID)
    left outer join  VIEWORDER.VVLNL_VND_LEGAL_NM_LOOKUP b21
     on (a11.VENDOR_ID = b21.VENDOR_ID)
     left outer join (Select  AGT_DEPT_ID, AGT_DEPT_ABBR_DESC  as AGT_DEPT_ABBR_DESC, SRC_LST_UPDT_DT from ViewDST.TAGDL_AGT_DEPT_LOOKUP 
        Qualify
        row_number() Over (partition by AGT_DEPT_ID order by SRC_LST_UPDT_DT desc)= 1 ) a112
            on a11.AGT_DEPT_ID = a112.AGT_DEPT_ID
     
     where ((a11.SHIP_CANCEL_DATE between DATE '2016-01-31' and CURRENT_DATE ) or (a11.PLANNED_STOCKED_DATE between DATE '2016-01-31' and CURRENT_DATE))
     
     group by
        MasterVendorID,
        a11.PAR_VENDOR_ID,
        a11.VENDOR_ID,
        a21.VENDOR_LGCY_ID,
        a21.VENDOR_LEGAL_DESC,
        b21.VENDOR_LEGAL_DESC,
        Category;")
```

Next we need to consolidate the categories into columns with one row per vendor to make it easier for GIS to process.

``` r
# Tidying data
spread_Vendor_ELC_table <- Vendor_ELC_table %>%
                            mutate(Total_FCST_ELC = as.character(Vendor_ELC_table$Total_FCST_ELC))%>%
                            spread(Category,  value= Total_FCST_ELC)
```

Next we need to join together the data pull (keeping all rows) and the previous season's data to enrich with the Tiering history.

``` r
Join_table <- left_join(Vendor_ELC_table, 
                        Parent_vendor_Master, 
                        by = c('MasterVendorID', 
                               'Category', 
                               "PAR_VENDOR_ID", 
                               "VENDOR_ID")
                        )
```

And output only the rows we want.

``` r
Output_table <- Join_table %>% select(c(1:8)) %>% 
  spread(`Category`, `Total_FCST_ELC`)
 Output_table2 <- Join_table %>% select(1:7, 12) %>% spread(Category, "Tier")
```

Also, we can compare the Current and previous tables to see what new vendor/categories are showing up. These are rows that we should supply so that GIS knows to pay special attention to them.

``` r
# Anti-Join table
anti_join_table <- anti_join(Vendor_ELC_table, 
                             Parent_vendor_Master, 
                             by = c('MasterVendorID', 
                                    'Category', 
                                    "PAR_VENDOR_ID", 
                                    "VENDOR_ID")
                             )
```

Now we can create an Excel notebook for GIS consumption. The first tab labled "Tiering" is where GIS should make any changes or additions.

``` r
write.xlsx(Output_table2, 
           paste(my_dir, "Vendor_Workbook.xlsx", sep = "/"), 
           sheetName = "Tiering",  showNA = FALSE)
write.xlsx(Output_table, 
           paste(my_dir, "Vendor_Workbook.xlsx", sep = "/"), 
           sheetName = "ELC", append= TRUE, showNA = FALSE)
write.xlsx(anti_join_table, 
           paste(my_dir, "Vendor_Workbook.xlsx", sep = "/"), 
           sheetName = "New Vendors", append= TRUE, showNA = FALSE)
```
