#!/bin/bash


##############################################
# Test installation
#
# (container)
# ($>) su postgres
# ($>) create testdb
# ($>) createdb testdb
#
# (host)
# ($>)  python -m venv .venv
# ($>) . .venv/bin/activate
# ($>) pip install --upgrade pip sqlalchemy psycopg2-binary

# (container)
# ($>) dropdb testdb
##############################################


IP_ADDR="10.0.3.29"

if python test_build.py $IP_ADDR; then
    echo "Pass"
else
    echo "Fail"
fi


    
	
