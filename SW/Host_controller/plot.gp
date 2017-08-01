set terminal png  size 800,640

set output "Frequency_time.png" 
set xdata time
set timefmt "%s"
set format x "%H:%M:%S"
set key under
set xlabel "Time"
set ylabel "Freq deviation [Hz]"
f0=140000000
plot "temperature.log" using 1:($3-f0) with linespoints title "CLKGEN01B 140 MHz"

