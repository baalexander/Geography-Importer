import os

# Column layout:
# SUMLEV,state,county,PLACE,cousub,NAME,STATENAME,POPCENSUS_2000,POPBASE_2000,POP_2000,POP_2001,POP_2002,POP_2003,POP_2004,POP_2005,POP_2006,POP_2007,POP_2008

MIN_POPULATION = 25000

# File to parse
READ_FILE = 'census.csv'
# Temporary file holds results. Not final file, because duplicates need to be removed.
TEMP_FILE = 'cities.csv.tmp'
# Final list of cities
WRITE_FILE = 'cities.csv'

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
    nameParts = name.split(' ')
    
    # Makes sure is a city or similar
    lastName = nameParts[-1].lower()
    if lastName != 'city' \
        and lastName != 'village' \
        and lastName != 'municipality' \
        and lastName != 'township' \
        and lastName != 'borough':
            continue

    # Ignore balances, like Balance of Clay township
    firstName = nameParts[0].lower()
    if firstName == 'balance':
        continue

    # Make sure population is over minimum (based off 2008 population)
    population = columns[17]
    if int(population) < MIN_POPULATION:
        continue;

    # Remove last name, like city or village
    city = ' '.join(nameParts[0:-1])

    # Remove 'charter' as in 'charter township', common in Michigan
    if len(nameParts) > 2 and nameParts[-2].lower() == 'charter':
        city = ' '.join(nameParts[0:-2])

    # Special case city formatting
    #Juneau City and Borough
    if name.lower().find('juneau city') >= 0:
        city = 'Juneau'

        
    state = columns[6]

    # Format is city,state
    tempFile.write(city + ',' + state + '\n')

readFile.close()

#######################################################################
# Post processing 
#######################################################################

# Adds the 5 boroughs of New York City
tempFile.write('The Bronx,New York\n')
tempFile.write('Manhattan,New York\n')
tempFile.write('Brooklyn,New York\n')
tempFile.write('Queens,New York\n')
tempFile.write('Staten Island,New York\n')

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
