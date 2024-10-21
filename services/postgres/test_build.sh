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




if python test_build.py $1; then
    echo "Pass"
else
    echo "Fail"
fi


    
	
