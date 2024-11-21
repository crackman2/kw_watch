import os

var tmp = 0
while tmp < 10:
    echo("testcmd: " & $(tmp))
    tmp = tmp + 1
    sleep(1000)
echo "testcmd: goodbye!"
