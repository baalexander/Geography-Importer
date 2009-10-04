import os

# Maps state names to state abbreviations
nameToAbbreviation = {
    'Alabama'              : 'AL',
    'Alaska'               : 'AK',
    'Arizona'              : 'AZ',
    'Arkansas'             : 'AR',
    'California'           : 'CA',
    'Colorado'             : 'CO',
    'Connecticut'          : 'CT',
    'Delaware'             : 'DE',
    'District of Columbia' : 'DC',
    'Florida'              : 'FL',
    'Georgia'              : 'GA',
    'Hawaii'               : 'HI',
    'Idaho'                : 'ID',
    'Illinois'             : 'IL',
    'Indiana'              : 'IN',
    'Iowa'                 : 'IA',
    'Kansas'               : 'KS',
    'Kentucky'             : 'KY',
    'Louisiana'            : 'LA',
    'Maine'                : 'ME',
    'Maryland'             : 'MD',
    'Massachusetts'        : 'MA',
    'Michigan'             : 'MI',
    'Minnesota'            : 'MN',
    'Mississippi'          : 'MS',
    'Missouri'             : 'MO',
    'Montana'              : 'MT',
    'Nebraska'             : 'NE',
    'Nevada'               : 'NV',
    'New Hampshire'        : 'NH',
    'New Jersey'           : 'NJ',
    'New Mexico'           : 'NM',
    'New York'             : 'NY',
    'North Carolina'       : 'NC',
    'North Dakota'         : 'ND',
    'Ohio'                 : 'OH',
    'Oklahoma'             : 'OK',
    'Oregon'               : 'OR',
    'Pennsylvania'         : 'PA',
    'Rhode Island'         : 'RI',
    'South Carolina'       : 'SC',
    'South Dakota'         : 'SD',
    'Tennessee'            : 'TN',
    'Texas'                : 'TX',
    'Utah'                 : 'UT',
    'Vermont'              : 'VT',
    'Virginia'             : 'VA',
    'Washington'           : 'WA',
    'West Virginia'        : 'WV',
    'Wisconsin'            : 'WI',
    'Wyoming'              : 'WY'
}

# Column layout:
# SUMLEV,state,county,PLACE,cousub,NAME,STATENAME,POPCENSUS_2000,POPBASE_2000,POP_2000,POP_2001,POP_2002,POP_2003,POP_2004,POP_2005,POP_2006,POP_2007,POP_2008

# File to parse
READ_FILE = 'census.csv'
# Temporary file for processing
TEMP_FILE = 'states.csv.tmp'
# Final list of states
WRITE_FILE = 'states.csv'

#######################################################################
# Parses file
#######################################################################

readFile = open(READ_FILE, 'rb')
tempFile = open(TEMP_FILE, 'w')

firstTime = True
for line in readFile:
    # Skip header line
    if firstTime:
        firstTime = False
        continue

    columns = line.split(',')

    name = columns[5]
    stateName = columns[6]

    if name != stateName:
        continue

    stateId = columns[1]

    # Map state name to state abbreviation
    stateAbbreviation = nameToAbbreviation[name]

    # Format is stateId,state,abbreviation. Abbreviation will be added manually
    tempFile.write(stateId + ',' + name + ',' + stateAbbreviation + '\n')

readFile.close()

tempFile.close()

#######################################################################
# Removes duplicate lines
#######################################################################
tempFile = open(TEMP_FILE, 'rb')
writeFile = open(WRITE_FILE, 'w')

# Creates a unique sorted list then writes to file
uniqueLines = sorted(set(tempFile.read().split('\n')))
# Removes the empty line
uniqueLines.remove('')
writeFile.write(''.join([line + "\n" for line in uniqueLines]))

writeFile.close()
tempFile.close()

# Deletes temporary file
os.remove(TEMP_FILE)

