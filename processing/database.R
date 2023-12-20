library(DBI)
library(dbplyr)
library(odbc)

con <- dbConnect(odbc::odbc(), .connection_string = 
                   "Driver={BMF SQLite3 ODBC Driver};Database=ExampleData.db", 
                 timeout = 10)

con <- dbConnect(RSQLite::SQLite(),
                 'ExampleData.sqlite')

dbDisconnect(con)

#Upload some made up data
made_up_data <- data.frame('index_num' = seq(1,100,1),
                           'state' = sample(c('CO','WY','CA','NY'),100,
                                            replace = TRUE),
                           'measurement' = c(rep('Height(m)',50),
                                             rep('JumpHeight(m)',50)),
                           'value' = abs(rnorm(100,3,1)))


con <- dbConnect(odbc::odbc(), .connection_string = 
                   "Driver={BMF SQLite3 ODBC Driver};Database=ExampleData.db", 
                 timeout = 10)


con <- dbConnect(RSQLite::SQLite(),
                 'ExampleData.sqlite')

dplyr::copy_to(con, made_up_data, overwrite = TRUE, temporary = FALSE, 
        name = 'SurveyData')

dbDisconnect(con)