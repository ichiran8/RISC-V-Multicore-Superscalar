# # Jerry Chen : Bash file testing for Multicore assembly testcases




# fname="Multicore_Test_$(date +"%Y_%m_%d_%I_%M_%p").txt"
# echo "Multicore Assembly Test Case Report File $(date +"%Y_%m_%d_%I_%M_%p")" > $fname

# for  ram_lat in 0 2 6 10
# do
#    sed -r "s|LAT = [0-9]+|LAT = $ram_lat|1" source/ram.sv | cat > temp_ram
#    cat temp_ram > source/ram.sv
#    rm temp_ram
#    make clean

#    echo "********TEST FOR LAT = $ram_lat********" | tee -a "$fname"
   
#    echo " " | tee -a "$fname" 
   

#    echo "Testing Lat = $ram_lat for testcase test.coherence1.asm!" | tee -a "$fname" 
#    echo " " | tee -a "$fname" 
#    asm asmFiles/test.coherence1.asm
#    make system.sim
#    sim -m
#    if diff memcpu.hex memsim.hex > simulate.hex > /dev/null; then
#       echo "Test Case Passed!" | tee -a "$fname"
#    else
#       echo "Test Case Failed!" | tee -a "$fname"
#    fi
#    echo "Testing Lat = $ram_lat for testcase test.coherence2.asm!" | tee -a "$fname"
#    echo " " | tee -a "$fname" 
#    asm asmFiles/test.coherence2.asm 
#    make system.sim
#    sim -m
#    if diff memcpu.hex memsim.hex > simulate.hex > /dev/null; then
#       echo "Test Case Passed!" | tee -a "$fname"
#    else
#       echo "Test Case Failed!" | tee -a "$fname"
#    fi
#    echo "Testing Lat = $ram_lat for testcase dual.llsc.asm!" | tee -a "$fname"
#    echo " " | tee -a "$fname" 
#    asm asmFiles/dual.llsc.asm
#    make system.sim
#    sim -m
#    if diff memcpu.hex memsim.hex > simulate.hex > /dev/null; then
#       echo "Test Case Passed!" | tee -a "$fname"
#    else
#       echo "Test Case Failed!" | tee -a "$fname"
#    fi
#    echo "Testing Lat = $ram_lat for testcase dual.mergesort.asm!" | tee -a "$fname"
#    echo " " | tee -a "$fname" 
#    asm asmFiles/dual.mergesort.asm
#    make system.sim
#    sim -m
#    if diff memcpu.hex memsim.hex > simulate.hex > /dev/null; then
#       echo "Test Case Passed!" | tee -a "$fname"
#    else
#       echo "Test Case Failed!" | tee -a "$fname"
#    fi
#    echo "Testing Lat = $ram_lat for testcase example.asm!" | tee -a "$fname" 
#    echo " " | tee -a "$fname" 
#    asm asmFiles/example.asm
#    make system.sim
#    sim -m
#    if diff memcpu.hex memsim.hex > simulate.hex > /dev/null; then
#       echo "Test Case Passed!" | tee -a "$fname"
#    else
#       echo "Test Case Failed!" | tee -a "$fname"
#    fi
#    echo "Testing Lat = $ram_lat for testcase palgorithm.asm!" | tee -a "$fname"
#    echo " " | tee -a "$fname" 
#    asm asmFiles/palgorithm.asm
#    make system.sim
#    sim -m
#    if diff memcpu.hex memsim.hex > simulate.hex > /dev/null; then
#       echo "Test Case Passed!" | tee -a "$fname"
#    else
#       echo "Test Case Failed!" | tee -a "$fname"
#    fi
# done
# Jerry Chen : Bash file testing for Multicore assembly testcases

fname="Multicore_Test_$(date +"%Y_%m_%d_%I_%M_%p").txt"
echo "Multicore Assembly Test Case Report File $(date +"%Y_%m_%d_%I_%M_%p")" > "$fname"

for ram_lat in 0 2 6 10
do
   # Set RAM latency in source/ram.sv
   sed -r "s|LAT = [0-9]+|LAT = $ram_lat|1" source/ram.sv > temp_ram
   cat temp_ram > source/ram.sv

   rm temp_ram
   make clean

   echo "******** TEST FOR LAT = $ram_lat ********" | tee -a "$fname"
   echo | tee -a "$fname"

   for testcase in test.coherence1.asm test.coherence2.asm dual.llsc.asm dual.mergesort.asm example.asm palgorithm.asm
   do
      echo "Testing Lat = $ram_lat for testcase $testcase!" | tee -a "$fname"
      echo | tee -a "$fname"

      asm asmFiles/$testcase
      make system.sim
      sim -m

      if diff memcpu.hex memsim.hex > simulate.hex; then
         echo "Test Case Passed!" | tee -a "$fname"
      else
         echo "Test Case Failed!" | tee -a "$fname"
      fi

      echo | tee -a "$fname"
   done
done
