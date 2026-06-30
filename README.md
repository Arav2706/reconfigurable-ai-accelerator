# Reconfigurable AI Accelerator

A reconfigurable hardware accelerator in SystemVerilog supporting CNN and 
Transformer workloads on a shared systolic MAC array. Designed and verified 
in AMD Vivado, targeting Artix-7.

## Status
- [x] MAC processing element with signed INT8 inputs, INT32 accumulation
- [x] 2x2 systolic array, verified with matrix multiplication
- [x] 4x4 systolic array using generate loops, verified
- [ ] Memory buffers (SRAM) and automated data feeding
- [ ] CNN convolution mode
- [ ] Transformer attention mode
- [ ] Reconfigurable control unit
- [ ] Synthesis and performance results

## Architecture
The core is a systolic array of multiply-accumulate (MAC) processing elements. 
Data flows through the array rhythmically: matrix A from the left, matrix B from 
the top, with each PE passing inputs to its neighbors. The same array will be 
reconfigured to support both CNN convolution and Transformer attention dataflows.

## Files
- `mac_pe.sv` - MAC processing element (the systolic cell)
- `systolic_2x2.sv` - 2x2 array (hand-wired)
- `systolic_4x4.sv` - 4x4 array (generate loops)
- `*_tb.sv` - testbenches

## Tools
SystemVerilog, AMD Vivado 2025.2, XSim simulator, target Artix-7 (xc7a35t)