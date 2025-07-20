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



{Insert top level diagram}
