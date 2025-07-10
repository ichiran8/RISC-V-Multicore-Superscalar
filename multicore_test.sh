# Author  : Jerry Chen | ECE 437 TA
# Date    : 7/9/25
# Purpose : Automated testing for multicore assembly test cases
# Script file for testing Multicore Testcases
# To be used for all base test cases (assuming lab 12 palgorithm is done)
fname="Multicore_Test_$(date +"%Y_%m_%d_%I_%M_%p").txt"
echo "Multicore Assembly Test Case Report File $(date +"%Y_%m_%d_%I_%M_%p")" > "$fname"

for ram_lat in 0 2 6 10
do
   sed -r "s|LAT = [0-9]+|LAT = $ram_lat|1" source/ram.sv > temp_ram
   cat temp_ram > source/ram.sv

   rm temp_ram
   make clean

   echo -e "**************************************** \e[1mTEST FOR LAT = $ram_lat \e[0m ****************************************" 
   echo "**************************************** TEST FOR LAT = $ram_lat ****************************************" >> "$fname"

   echo " " >> "$fname" #| tee -a "$fname"

   for testcase in test.coherence1.asm test.coherence2.asm dual.llsc.asm dual.mergesort.asm example.asm palgorithm.asm
   do
      echo "Testing Lat = $ram_lat for testcase $testcase!" >> "$fname" #| tee -a "$fname"
      echo " " >> "$fname" #| tee -a "$fname"

      asm asmFiles/$testcase 
      make system.sim >> dump.txt
      rm dump.txt
      sim -m

      if diff memcpu.hex memsim.hex > simulate.hex; then
         echo -e "Test Case \e[32mPassed!\e[0m"
         echo "Test Case Passed!" | tee -a "$fname"
      else
         echo -e "Test Case \e[31mFailed!\e[0m" 
         echo "Test Case Failed!" | tee -a "$fname"
      fi

      echo " " | tee -a "$fname"
   done
done
