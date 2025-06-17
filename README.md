# MIPS32 Pipelined Processor

A high-performance, 32-bit MIPS processor implementation featuring a five-stage pipeline architecture with comprehensive instruction support for arithmetic, logical, and memory operations.

## Executive Summary

This project presents a complete MIPS32 processor design implemented in Verilog HDL, featuring a classical five-stage pipeline (IF-ID-EX-MEM-WB) with master-slave register control. The processor supports 11 carefully selected MIPS instructions, demonstrating fundamental concepts of modern processor architecture including pipelining, hazard management, and memory hierarchy.

## Key Features

- **Five-Stage Pipeline Architecture** with optimized data flow
- **Dual-Port Register File** supporting simultaneous read operations
- **Synchronous Memory Subsystem** with separate instruction and data memories
- **Advanced ALU Design** supporting arithmetic, logical, and comparison operations
- **Master-Slave Pipeline Control** ensuring proper timing and data integrity
- **Comprehensive Instruction Support** covering essential MIPS operations

## Processor Architecture

### Pipeline Overview

The processor implements a classical RISC pipeline with the following stages:

| Stage | Function | Components |
|-------|----------|------------|
| **IF** | Instruction Fetch | Program Counter, Instruction Memory, IF/ID Register |
| **ID** | Instruction Decode | Register File, Control Logic, Sign Extension, ID/EX Register |
| **EX** | Execute | Arithmetic Logic Unit, EX/MEM Register |
| **MEM** | Memory Access | Data Memory Interface, Load/Store Logic, MEM/WB Register |
| **WB** | Write Back | Register File Write Control, Destination Selection |

### Core Components

**Program Counter (PC)**
- 10-bit counter supporting 1024 instruction addresses
- Automatic increment with each clock cycle
- Reset capability for program initialization

**Register File**
- 32 general-purpose registers (32-bit width)
- Dual read ports for simultaneous operand access
- Single write port with enable control
- Register $0 hardwired to zero (MIPS standard)

**Arithmetic Logic Unit (ALU)**
- 32-bit operand processing
- Opcode-based operation selection
- Support for arithmetic, logical, and comparison operations
- Synchronous operation with clock edge alignment

**Memory Subsystem**
- **Instruction Memory**: 1K × 32-bit preloaded program storage
- **Data Memory**: 1K × 32-bit synchronous read/write memory
- Word-aligned addressing with automatic address translation

## Instruction Set Architecture

### Supported Instructions

The processor implements a carefully curated subset of the MIPS32 instruction set:

#### Arithmetic Operations
```assembly
ADD  rd, rs, rt     # rd = rs + rt
SUB  rd, rs, rt     # rd = rs - rt  
MUL  rd, rs, rt     # rd = rs × rt
ADDI rt, rs, imm    # rt = rs + sign_extend(imm)
```

#### Logical Operations
```assembly
AND  rd, rs, rt     # rd = rs & rt
OR   rd, rs, rt     # rd = rs | rt
SLT  rd, rs, rt     # rd = (rs < rt) ? 1 : 0
```

#### Shift Operations
```assembly
SLLI rd, rt, shamt  # rd = rt << shamt
```

#### Memory Operations
```assembly
LW   rt, offset(rs) # rt = Memory[rs + sign_extend(offset)]
SW   rt, offset(rs) # Memory[rs + sign_extend(offset)] = rt
```

### Instruction Encoding

The processor supports standard MIPS instruction formats:

**R-Type Format (Arithmetic/Logical)**
```
[31-26] [25-21] [20-16] [15-11] [10-6] [5-0]
opcode    rs      rt      rd    shamt  funct
```

**I-Type Format (Immediate/Memory)**
```
[31-26] [25-21] [20-16] [15-0]
opcode    rs      rt    immediate
```

## Pipeline Implementation

### Data Path Design

The processor utilizes variable-width pipeline buses optimized for each stage:

**IF/ID Pipeline Register (42 bits)**
- Instruction word (32 bits)
- Program counter value (10 bits)

**ID/EX Pipeline Register (108 bits)**
- Instruction opcode (6 bits)
- Source operands A and B (64 bits)
- Destination register address (5 bits)
- Control signals and padding (33 bits)

**EX/MEM Pipeline Register (76 bits)**
- Store data for memory operations (32 bits)
- Instruction opcode (6 bits)
- ALU result/memory address (32 bits)
- Destination register and control (6 bits)

**MEM/WB Pipeline Register (44 bits)**
- Instruction opcode (6 bits)
- Write-back data (32 bits)
- Destination register address (5 bits)
- Load operation flag (1 bit)

### Pipeline Control Mechanism

The processor employs master-slave flip-flops for pipeline register implementation:

- **Rising Edge**: Data latches into master stage
- **Falling Edge**: Data propagates to slave stage and pipeline outputs
- **Synchronous Operation**: All pipeline stages advance simultaneously
- **Reset Capability**: Global reset clears all pipeline stages

## Technical Specifications

| Parameter | Specification |
|-----------|---------------|
| **Architecture** | MIPS32 with 5-stage pipeline |
| **Data Width** | 32-bit throughout |
| **Instruction Width** | 32-bit fixed format |
| **Register File** | 32 × 32-bit registers |
| **Program Counter** | 10-bit (1024 instruction capacity) |
| **Instruction Memory** | 1K × 32-bit, preloaded |
| **Data Memory** | 1K × 32-bit, synchronous |
| **ALU Operations** | 9 primary operations |
| **Pipeline Registers** | Master-slave with dual-edge clocking |

## Performance Characteristics

### Pipeline Efficiency
- **Throughput**: One instruction per clock cycle (steady state)
- **Latency**: 5 clock cycles per instruction (pipeline depth)
- **Hazard Handling**: Currently implements structural hazard avoidance

### Resource Utilization
- **Logic Elements**: Optimized for FPGA implementation
- **Memory Usage**: Efficient dual-memory architecture
- **Critical Path**: ALU operations determine maximum frequency

## Design Constraints and Limitations

### Current Limitations
- **Control Flow**: No branch or jump instruction support
- **Hazard Detection**: Limited data hazard resolution
- **Memory Model**: Word-aligned access only
- **Exception Handling**: No interrupt or exception support

### Architectural Decisions
- **Simplified ISA**: Focus on core MIPS operations for educational clarity
- **Synchronous Design**: All operations tied to single clock domain
- **Harvard Architecture**: Separate instruction and data memories

## Future Development Roadmap

### Phase 1: Control Flow Enhancement
- Implement branch instructions (BEQ, BNE, BLT)
- Add jump instructions (J, JAL, JR)
- Integrate branch prediction logic

### Phase 2: Hazard Management
- Data forwarding network implementation
- Pipeline stall and flush mechanisms
- Load-use hazard detection

### Phase 3: Performance Optimization
- Instruction cache integration
- Data cache implementation
- Pipeline depth optimization analysis

### Phase 4: Advanced Features
- Floating-point unit integration
- Coprocessor interface development
- Exception and interrupt handling

## Development Environment

### Prerequisites
- **HDL Simulator**: ModelSim, Vivado, or Icarus Verilog
- **Synthesis Tools**: Xilinx Vivado or Intel Quartus (for FPGA implementation)
- **Assembly Tools**: MIPS cross-assembler for program development

### Build Instructions
1. Clone repository and navigate to project directory
2. Compile all Verilog source files in dependency order
3. Load testbench and execute simulation
4. Analyze waveforms and verify correct operation

---
