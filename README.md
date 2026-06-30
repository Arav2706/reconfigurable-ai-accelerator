# Reconfigurable CNN/Transformer Inference Accelerator

A SystemVerilog RTL implementation of a systolic multiply-accumulate (MAC) array for neural network inference, designed to reconfigure its dataflow between convolutional (CNN) and attention-based (Transformer) workloads. Developed and verified with the AMD Vivado toolchain, targeting Artix-7 (`xc7a35t`).

This project applies the same architectural principles used in production inference hardware, dense MAC arrays, dataflow-aware scheduling, operand reuse, and precision-optimized datapaths, at a scale suitable for full RTL design and simulation-based verification.

---

## Engineering summary

| Area | Demonstrated work |
|---|---|
| **RTL design** | Parameterized systolic array, processing-element microarchitecture, registered datapath, synchronous control |
| **Microarchitecture** | Weight-stationary vs. output-stationary dataflow, operand reuse, accumulation-width sizing, systolic operand propagation |
| **Verification** | Self-checking SystemVerilog testbenches, reference-model comparison, edge-case and timing-race coverage |
| **Tooling** | AMD Vivado, XSim behavioral simulation, target-device RTL flow |
| **Methodology** | Module-level verification before integration, parameterized/scalable design via `generate`, version-controlled development |

---

## Why this architecture

Production AI accelerators (NVIDIA Tensor Cores, Google TPU, Apple Neural Engine, and emerging RISC-V/dataflow startups) are built on large MAC arrays fed by carefully scheduled on-chip memory. The dominant compute primitive across both vision and language models is dense matrix multiplication, but the two workload classes stress the memory system differently:

- **Convolution** reuses a fixed weight kernel across a sliding spatial window — a *weight-stationary* dataflow.
- **Attention** performs large tiled matrix products (Q·Kᵀ, ·V) with streaming operands — an *output-stationary* dataflow.

A fixed-function accelerator commits silicon to one pattern. This design instead keeps a single MAC array and reconfigures the surrounding control and address-generation logic per workload, the same flexibility/efficiency tradeoff that drives architectural decisions in shipping inference silicon.

---

## Architecture

### Systolic MAC array (compute core)

A 2D array of processing elements (PEs). Each PE executes one signed MAC per cycle and forwards operands to its right and bottom neighbors, producing the rhythmic propagation that defines systolic execution. Operands enter at the array edges and are reused across multiple PEs as they advance, reducing operand-fetch bandwidth, the same reuse principle that makes large systolic arrays bandwidth-efficient in production.

- **Datapath precision:** signed INT8 operands, INT32 accumulation. Widened accumulators prevent overflow across long MAC chains, a standard quantized-inference datapath decision (cf. INT8 inference on Tensor Cores / NPUs).
- **PE microarchitecture:** registered MAC with registered operand pass-through, implementing the single-cycle systolic hop.
- **Control:** synchronous reset and accumulation enable.

### Parameterized, scalable RTL

The array is built with SystemVerilog `generate` constructs over a 2D interconnect grid, with PE connectivity expressed positionally so edge/interior wiring is derived automatically from array coordinates. Array dimension is a single parameter, the 2×2 and 4×4 variants share one connection rule, and the same RTL scales to larger arrays without structural rewrites. This is the design discipline required for synthesizable, maintainable hardware IP.

---

## Verification

Functional correctness is established per-module before integration, the standard bottom-up verification methodology used in RTL/ASIC flows:

- **PE:** verified across positive/negative operands and accumulate-hold behavior.
- **2×2 array:** verified against a full analytically computed 2×2 matrix product using the required staggered operand schedule.
- **4×4 array:** verified via identity-matrix multiplication (A × I = A), confirming correct dataflow and timing across all 16 PEs.

Testbenches drive stimulus on the inactive clock edge to eliminate sampling races and reproduce the staggered diagonal operand schedule mandated by systolic dataflow. Results are checked against reference values, not inspected by hand.

---

## Status

| Component | State |
|---|---|
| MAC processing element (INT8 × INT8 → INT32) | Complete, verified |
| 2×2 systolic array | Complete, verified |
| 4×4 systolic array (`generate`-based) | Complete, verified |
| On-chip operand buffers (SRAM) + automated feed | In progress |
| CNN convolution dataflow (weight-stationary) | Planned |
| Transformer attention dataflow (Q·Kᵀ, output-stationary) | Planned |
| Reconfigurable control / mode switching | Planned |
| Synthesis, timing closure, Fmax/utilization reporting | Planned |

---

## Repository layout

| File | Description |
|---|---|
| `mac_pe.sv` | Systolic processing element: registered MAC with operand pass-through |
| `systolic_2x2.sv` | 2×2 array, explicit interconnect |
| `systolic_4x4.sv` | 4×4 array, parameterized via `generate` |
| `systolic_2x2_tb.sv` | 2×2 functional testbench, staggered operand feed |
| `systolic_4x4_tb.sv` | 4×4 functional testbench, identity-matrix validation |

---

## Roadmap

Subsequent work advances the design from a hand-driven datapath to an integrated accelerator with a memory subsystem and reconfigurable scheduling:

1. **Memory subsystem** — banked on-chip buffers for activations and weights; hardware address generators replace testbench-driven operand staggering.
2. **CNN mode** — weight-stationary scheduling with sliding-window address generation.
3. **Transformer mode** — output-stationary tiled matrix multiplication for the Q·Kᵀ attention primitive, with tiling for operands exceeding the physical array dimension.
4. **Reconfiguration** — a control unit that retargets dataflow and buffer scheduling on a mode-select signal, running both workloads on the same physical array.
5. **Implementation** — Vivado synthesis and timing closure with reported Fmax, resource utilization, and achieved MAC throughput.

---

## Toolchain

SystemVerilog · AMD Vivado 2025.2 · XSim · target Artix-7 `xc7a35t`