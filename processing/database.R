library(dbplyr)

#SEE: https://wcc.sc.egov.usda.gov/awdbRestApi/swagger-ui.html#/

SNOTEL_API = 'https://wcc.sc.egov.usda.gov/awdbRestApi'

PARAMETERS = list(
    beginDate='',
    duration='',
    elements='',
    endDate='',
    stationTriplets=''
)