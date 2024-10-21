import sys
from sqlalchemy import create_engine, text
from sqlalchemy.exc import ProgrammingError

ip_address = str(sys.argv[1])

def main(ip_address):    
    engine = create_engine("postgresql://postgres:postgres@" + ip_address + "/testdb")
    
    with engine.connect() as conn:
        try:
            conn.execute(text("DROP TABLE test_table"))
            conn.commit()
        except ProgrammingError:
            pass

    with engine.connect() as conn:
        conn.execute(text("CREATE TABLE test_table (x int)"))
        conn.execute(
            text("INSERT INTO test_table (x) VALUES (:x)"),
            [{"x": 22}]
        )
        conn.commit()

    with engine.connect() as conn:
        res = conn.execute(text("SELECT * FROM test_table"))

    line = res.fetchone()

        
    if line[0] == 22:
        return 0
    else:
        return 1
    

if __name__ == '__main__':
    exit(main(ip_address))
    
