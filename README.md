**DISCLAIMER** For any ECE Purdue student, do not even think about attempting this design for a computer architecture class or referencing it. It will be very obvious when your design choices are tailored as the following. This design is pretty out of scope for the course (feasible but this is not covered in the course material) and you will not have the time to implement this given the course structure (WIP!)

The following design is a RISC-V Central Processing Unit (CPU) with Dual-Core design for multithreading performance.

1) Cache coherence is maintained with the MSI Cache Coherence Protocol
   --> Will be updated to MOESIF protocol for the next design
2) Each core is designed with a classic RISC pipeline with 2-way superscaling and full forwarding and hazarding
3) Tournament predictor is designed with a gShare predictor and local predictor as the selector
  --> If the first instruction is a branch or jump followed by another branch or jump, the second instruction is automatically disgraded the direction of the branch
4) Instructions will be speculatively launched if next line predictor is taken
5) Designed with a sequential consistency memory model
  --> Only one load or store is issued to the L-1 Dcache per core
  --> Each cache is non blocking




<img width="1194" height="583" alt="Screenshot 2025-07-19 at 11 09 14 PM" src="https://github.com/user-attachments/assets/633d645b-5f9d-4f06-b4d6-0e944084adc1" />


Future Design:

<img width="1032" height="480" alt="Screenshot 2025-07-19 at 11 08 23 PM" src="https://github.com/user-attachments/assets/ea1f29a3-deda-4df1-a8c6-7346118710be" />
