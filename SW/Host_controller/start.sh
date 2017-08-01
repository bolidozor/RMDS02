ulimit -c unlimited
~/Bolidozor/frequency_log.py&
jackd -c system -p128 -m -dalsa -dhw:CODEC -r48000 -p4096 -n4 -m -C -i2&
sleep 3
~/Bolidozor/radio-observer -c ~/Bolidozor/uFlu/uFlu-R0.json&
sleep 3

