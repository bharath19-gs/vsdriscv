# vsdriscv

This repository contains all the information needed to build your RISC-V pipelined core, which has support of base interger RV32I instruction format using TL-Verilog on makerchip platform.

# Table of Contents
- [Introduction to RISC-V ISA](#introduction-to-risc-v-isa)
- [Overview of GNU compiler toolchain](#overview-of-gnu-compiler-toolchain)
- 
- [Introduction to ABI](#introduction-to-abi)
- [Acknowledgements](#acknowledgements)

# Introduction to RISC-V ISA 

A RISC-V(pronounced “risk-five”) ISA is defined as a base integer ISA, which must be present in any implementation, plus optional extensions to the base ISA.
Each base integer instruction set is characterized by the width of the integer registers and the corresponding size of the address space and by the number
of integer registers. There are two primary base integer variants, RV32I and RV64I.<br>
(XLEN)-  We use the term XLEN to refer to the width of an integer register in bits (either 32 or 64).<br>
The other ISA's are RV32E(subset variant of the RV32I base instruction set) and RV128I(XLEN = 128).


More details on RISC-V ISA can be obtained [here](https://github.com/riscv/riscv-isa-manual/releases/download/draft-20200727-8088ba4/riscv-spec.pdf).

# Overview of GNU compiler toolchain

The GNU Toolchain is a set of programming tools in Linux systems that programmers can use to make and compile their code to produce a program or library. So, how the machine code which is understandable by processer is explained below.

  * Preprocessor - Process source code before compilation. Macro definition, file inclusion or any other directive if present then are preprocessed. 
  * Compiler - Takes the input provided by preprocessor and converts to assembly code.
  * Assembler - Takes the input provided by compiler and converts to relocatable machine code.
  * Linker - Takes the input provided by Assembler and converts to Absolute machine code.

Under the risc-v toolchain, 
  * To use the risc-v gcc compiler use the below command:
  
     `riscv64-unknown-elf-gcc -O1 -mabi=lp64 -march=rv64i -o <object filename.o> <C filename>`
  
  * To use the risc-v gcc compiler use the below command(works in a compiled form compared to previous one):

    `riscv64-unknown-elf-gcc -Ofast -mabi=lp64 -march=rv64i -o <object filename.o> <C filename>`

    More generic command with different options:

    `riscv64-unknown-elf-gcc <compiler option -O1 ; Ofast> <ABI specifier -lp64; -lp32; -ilp32> <architecture specifier -rv64 ; rv32> -o <object filename.o> <C      filename>`
  
    The -march argument is essentially defined by the RISC-V user-level ISA manual. -march controls instruction set from which the compiler is allowed to generate instructions. This argument determines the set of implementations that a program will run on: any RISC-V compliant system that subsumes the -march value used to compile a program should be able to run that program.
    
    The -mabi argument to GCC specifies both the integer and floating-point ABIs to which the generated code complies. Much like how the -march argument specifies which hardware generated code can run on, the -mabi argument specifies which software generated code can link against. We use the standard naming scheme for integer ABIs (ilp32 or lp64), with an argumental single letter appended to select the floating-point registers used by the ABI (ilp32 vs ilp32f vs ilp32d).
    
    
    More details on compiler options can be obtained [here](https://www.sifive.com/blog/all-aboard-part-1-compiler-args)
    
  * To view assembly code use the below command,
    
    `riscv64-unknown-elf-objdump -d <object filename>`
    
  * To use SPIKE simualtor to run risc-v obj file use the below command,
  
    `spike pk <object filename>`
    
    To use SPIKE as debugger
    
    `spike -d pk <object Filename>` with degub command as `until pc 0 <pc of your choice>`

    To install complete risc-v toolchain locally on linux machine,
      1. [RISC-V GNU Toolchain](http://hdlexpress.com/RisKy1/How2/toolchain/toolchain.html)
      2. [RISC-V ISA SImulator - Spike](https://github.com/kunalg123/riscv_workshop_collaterals)
    
    Once done with installation add the PATH to .bashrc file for future use.

Test Case for the above commands [(Summation of 1 to 9)]()

  * Below image shows the disassembled file `sum1ton.o` with `main` function highlighted, while the command riscv-unknown-elf-gcc is run with -O1.
    
    ![disassemble]
  
  * Below image shows the disassembled file `sum1ton.o` with `main` function highlighted, while the command riscv-unknown-elf-gcc is run with -Ofast.

    ![disassemble]


  * To view the registers we can use command as `reg <core> <register name>`. 

    Below image shows how to debug the disassembled file using Spike simulator where a1,a2 register are checked before and after the instructions got executed.

    ![spike_debug]


# Signed and Unsigned Labs 


# Introduction to ABI

An Application Binary Interface is a set of rules enforced by the Operating System on a specific architecture. So, Linker converts relocatable machine code to absolute machine code via ABI interface specific to the architecture of machine.

So, it is system call interface used by the application program to access the registers specific to architecture. Overhere the architecture is RISC-V, so to access 32 registers of RISC-V below is the table which shows the calling convention (ABI name) given to registers for the application programmer to use.
[(Image source)](https://riscv.org/wp-content/uploads/2015/01/riscv-calling.pdf)

![calling_convention]

Test Case for ABI Call: [Summation of 1 to 9] through [assembly code]

  * Below image shows the `main` function.

    ![main_ABI]

  * Below image shows 2 sections from [load.S] (one is load and other is loop).

    ![load_ABI

  * Below image shows the output of Summation from 1 to 9.

    ![compile_ABI]

# Acknowledgements
- [Kunal Ghosh](https://github.com/kunalg123), Co-founder, VSD Corp. Pvt. Ltd.
- [Steve Hoover](https://github.com/stevehoover), Founder, Redwood EDA
