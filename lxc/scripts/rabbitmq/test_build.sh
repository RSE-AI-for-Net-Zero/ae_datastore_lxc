######################################################################
# Test installation
#
# (host)
# ($>) python -m venv .venv 
# ($>) . .venv/bin/activate
# ($>) pip install --upgrade pip pika
#
#
######################################################################
IP_ADDR="10.0.3.206"

if python test_build.py ${IP_ADDR} | grep "Hello World!"; then
    echo "PASS"
else
    echo "FAIL"
fi



