set terminal png
set ylabel "LO Freq [MHz]"
set xlabel "Temp [deg C]"
set xrange [-20:40]
set autoscale y
set format y "%.5f"
set key off
set grid xtics mxtics ytics mytics back ls 12 ls 13
show grid

f(x)= a*x + q

fit f(x) "data.txt" using 1:2 via a,q

set output "temp_calib.png" 
plot "data.txt" using 1:2 with points, f(x)
