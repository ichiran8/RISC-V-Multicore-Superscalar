#!/bin/bash

# Developed by Adam Busch - ECE437 Fall 2021
# Modified and adpated by Robert Murphy - ECE437 Fall 2022
# Modified and adapted by Zach Lagpacan - ECE437 Fall 2024

# commandline:
# 	bash exec_data_sweep.sh
#		OR
#	bash exec_data_sweep.sh -d
#  		-d: enable dual-core simulation for Labs 10, 11, and 12

# mergesort.asm / dual.mergesort.asm are used by default. If this program doesn't work on your design, manually change asm_file

# lat0.txt, lat2.txt, lat6.txt, lat10.txt, sim_results.txt, and syn_results.txt are reserved file names used by this script

# start report file
report_file="sweep_report_$(date +"%Y_%m_%d_%I_%M_%p").txt"
echo "Execution Data Sweep Report File $(date +"%Y_%m_%d_%I_%M_%p")" > $report_file

# select asm file
if [ "$1" == "-d" ]; then
	asm_file="asmFiles/dual.mergesort.asm"
else
	asm_file="asmFiles/mergesort.asm"
fi

# loop through RAM LAT's for simulation
	# put intermediate results in lat#.txt file, which will be used in the next loop
for ram_lat in 0 2 6 10
do
	# change LAT in ram module
	sed -r "s|LAT = [0-9]+|LAT = $ram_lat|1" source/ram.sv | cat > temp_ram
	cat temp_ram > source/ram.sv
	rm temp_ram

	# simulate design to get # cycles
	make clean
	asm $asm_file
	make system.sim > sim_results.txt
	grep "Halted at" sim_results.txt > lat$ram_lat.txt
	rm sim_results.txt
done

# loop through RAM LAT's for synthesis, and build table entries
	# do it this way so can keep LAT=2 synthesis results around after script finishes
for ram_lat in 0 2 6 10
do
	# start next table entry
	echo -e "\n________________________________________________________________________________________________________________________" >> $report_file
	echo "LAT = $ram_lat" >> $report_file

	# get previously collected simulation cycles
	echo -e "\nRAM CLK Cycles:" >> $report_file
	cat lat$ram_lat.txt >> $report_file
	rm lat$ram_lat.txt

	# synthesize design to get frequency (only for LAT=0 and LAT=2)
	echo -e "\nSlow 1200mV 85C Model Fmax Summary:" >> $report_file
	if [ $ram_lat -le 2 ]; then
		
		# change LAT in ram module
		sed -r "s|LAT = [0-9]+|LAT = $ram_lat|1" source/ram.sv | cat > temp_ram
		cat temp_ram > source/ram.sv
		rm temp_ram
		
		# synthesize and collect Fmax Summary
			# need to asm first
		make clean
		asm $asm_file
		synthesize -t -f 200 system
		grep -A 7 "Slow 1200mV 85C Model Fmax Summary" ._system/system.sta.rpt | tail -n7 > syn_results.txt
		cat syn_results.txt >> $report_file
	else 
		cat syn_results.txt >> $report_file
		echo "(copied from LAT=2)" >> $report_file
	fi
done

rm syn_results.txt