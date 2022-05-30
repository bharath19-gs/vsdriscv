# vsdriscv

This repository contains all the information needed to build your RISC-V pipelined core, which has support of base interger RV32I instruction format using TL-Verilog on makerchip platform.

# Table of Contents
- [Introduction to RISC-V ISA](#introduction-to-risc-v-isa)
- [Overview of GNU compiler toolchain](#overview-of-gnu-compiler-toolchain)
- [Introduction to ABI](#introduction-to-abi)
- [Digital Logic with TL-Verilog and Makerchip](#digital-logic-with-tl-verilog-and-makerchip)
  - [Combinational logic](#combinational-logic)
  - [Sequential logic](#sequential-logic)
  - [Pipelined logic](#pipelined-logic)
  - [Validity](#validity)
- [Basic RISC-V CPU micro-architecture](#basic-risc-v-cpu-micro-architecture)
  - [Fetch](#fetch)
  - [Decode](#decode)
  - [Register File Read and Write](#register-file-read-and-write)
  - [Execute](#execute)
  - [Control Logic](#control-logic)
- [Pipelined RISC-V CPU](#pipelined-risc-v-cpu)
  - [Pipelining the CPU](#pipelining-the-cpu)
  - [Load and store instructions and memory](#load-and-store-instructions-and-memory)
  - [Completing the RISC-V CPU](#completing-the-risc-v-cpu)

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

Test Case for the above commands [(Summation of 1 to 9)](https://github.com/bharath19-gs/vsdriscv/blob/main/Introduction/sum1ton_code_snippet.png)

  * Below image shows the disassembled file `sum1ton.o` with `main` function highlighted, while the command riscv-unknown-elf-gcc is run with -O1.
    
    ![disassemble](https://github.com/bharath19-gs/vsdriscv/blob/main/Introduction/sum1ton_objectfile_code_with_O1command.png)
  
  * Below image shows the disassembled file `sum1ton.o` with `main` function highlighted, while the command riscv-unknown-elf-gcc is run with -Ofast.

    ![disassemble](https://github.com/bharath19-gs/vsdriscv/blob/main/Introduction/sum1ton_objectfile_code_with_Ofastcommand.png)


  * To view the registers we can use command as `reg <core> <register name>`. 

    Below image shows how to debug the disassembled file using Spike simulator where a1,a2 register are checked before and after the instructions got executed.

    ![spike_debug](https://github.com/bharath19-gs/vsdriscv/blob/main/Introduction/spike_debugging.png)


# Signed and Unsigned interger Labs 
    
 * in the below images we can see the signed and unsigned numbers being run using the c code.

    ![image1](https://github.com/bharath19-gs/vsdriscv/blob/main/Introduction/signed_and_unsigned_image.png)
    ![image2](https://github.com/bharath19-gs/vsdriscv/blob/main/Introduction/signed_and_unsigned.png)

# Introduction to ABI

An Application Binary Interface is a set of rules enforced by the Operating System on a specific architecture. So, Linker converts relocatable machine code to absolute machine code via ABI interface specific to the architecture of machine.

So, it is system call interface used by the application program to access the registers specific to architecture. Overhere the architecture is RISC-V, so to access 32 registers of RISC-V below is the table which shows the calling convention (ABI name) given to registers for the application programmer to use.
[(Image source)](https://riscv.org/wp-content/uploads/2015/01/riscv-calling.pdf)

![calling_convention]

Test Case for ABI Call: Summation of 1 to 7 through assembly code

  * Below image shows the `main` function and the `load` assembly code. 

    ![main_ABI](https://github.com/bharath19-gs/vsdriscv/blob/main/Introduction/day2_c_assembly_code.png)
  * Below image shows the output of Summation from 1 to 7.

    ![compile_ABI](https://github.com/bharath19-gs/vsdriscv/blob/main/Introduction/spike_simulation.png)

# Introduction to RISC-V ISA 

## Lab 2 : To run and verify on a RISC-V Core
  An RTL implementation of a RISC-V core has been provided to us and we run the above program using the scripts provided to using iverilog simulator, just to observe  the behaviour of the program in hardware. A similar core would be implemented by us in the forthcoming days.
  
  

## How do we run the same program on RISC-V CPU

This section contains sample program already written just to show the flow of how to run a program on a RISC-V CPU core.
- We have a RISC-V CPU core written in Verilog and an already written testbench code for the same.
- The entire C program will be converted into a hex format and and will be loaded into memory.
- The CPU will then read the contents of the memory, process it and finally display the output result of sum of numbers from 1 to n.

**Block Diagram to run C program on RISC-V CPU**


### List of Commands:
1. We clone the RISC-V workshop collaterals repository into our local machine:
`$git clone https://github.com/kunalg123/riscv_workshop_collaterals.git`

2. After downloading is complete, move inside the directory.
`$cd riscv_workshop_collaterals`

3. Move to the labs folder.
`$cd labs`

4. To list the contents of the directory, type : 
`$ls -ltr`


5. To view the RISC-V CPU code (for picorv32) written in Verilog :
`$vim picorv32.v` .  This contains the entire verilog netlist.

6. To view the testbench file:
`$vim testbench.v` .  This is where we read the hexfile. Scroll down to see the line : **$readmemh("firmware.hex",memory)**

7. To view the standard script of how do we create the hex file :
`$vim rv32im.sh` .  This file contains basically all the necessary set of scripts required to convert the C and Assembly code into hex file and load it into the memory, and then run it. 

8. In order to run this shell script file, we have to change the read/write/execute permissions.
`$chmod 777 rv32im.sh`

9. To run the  script file, type :
`./rv32im.sh`

10. To view the internals of the firmware hex files:
For 64-bit : `$vim firmware.hex`
For 32-bit : `$vim firmware32.hex`  

These files shows how the application software is converted into bitstreams and this firmware file is loaded into the memory through the testbench. This file is then processed by the RISC-V core and finally it displays the output results.



# Digital Logic with TL-Verilog and Makerchip

[Makerchip](https://makerchip.com/) is a free online environment for developing high-quality integrated circuits. You can code, compile, simulate, and debug Verilog designs, all from your browser. Your code, block diagrams, and waveforms are tightly integrated.

All the examples shown below are done on Makerchip IDE using TL-verilog. Also there are other tutorials present on IDE which can be found [here](https://makerchip.com/sandbox/) under Tutorials section.

![makerchip](https://github.com/bharath19-gs/vsdriscv/blob/main/Introduction/maker_chip.png)

## Combinational logic

Starting with basic example in combinational logic is an inverter. To write the logic of inverter using TL-verilog is `$out = ! $in;`. There is no need to declare `$out` and `$in` unlike Verilog. There is also no need to assign `$in`. Random stimulus is provided, and a warning is produced. 
  ### 1. not_gate
  
![image](https://github.com/bharath19-gs/vsdriscv/blob/main/Introduction/not_gate.png)


 ### 2. Combinational Calculator
 
Below is snapshot of Combinational Calculator that has to be implemented.

![image](https://github.com/bharath19-gs/vsdriscv/blob/main/Introduction/calculator_to_be_implemented.png)

The implementation of the calculator.

![image](https://github.com/bharath19-gs/vsdriscv/blob/main/Introduction/calculator.png)

Below image shows the implemetation of mux using makerchip

![mux](https://github.com/bharath19-gs/vsdriscv/blob/main/Introduction/mux_maker_chip.png)

## Sequential logic

Starting with basic example in sequential logic is Fibonacci Series with reset. To write the logic of Series using TL-Verilog is `$num[31:0] = $reset ? 1 : (>>1$num + >>2$num)`. This operator `>>?` is ahead of operator which will provide the value of that signal 1 cycle before and 2 cycle before respectively.

## 1. Fibonaci series 

![image](https://github.com/bharath19-gs/vsdriscv/blob/main/Introduction/fibonacci.png)



## 2. Sequential Counter
Below is snapshot of Sequential Counter which remembers the last result, and uses it.
![image](https://github.com/bharath19-gs/vsdriscv/blob/main/Introduction/counter.png)

## Pipelined logic

Timing abstract powerful feature of TL-Verilog which converts a code into pipeline stages easily. Whole code under `|pipe` scope with stages defined as `@?`

Below is snapshot of 2-cycle calculator which clears the output alternatively and output of given inputs are observed at the next cycle.

![image](https://github.com/bharath19-gs/vsdriscv/blob/main/Introduction/calculator_pipelining.png)


## Validity

Validity is TL-verilog means signal indicates validity of transaction and described as "when" scope else it will work as don't care. Denoted as `?$valid`. Validity provides easier debug, cleaner design, better error checking, automated clock gating.

Below is snapshot of 2-cycle calculator with validity. 

![image](https://github.com/bharath19-gs/vsdriscv/blob/main/Introduction/calculator_pipelining_lab2.png)

# Basic RISC-V CPU micro-architecture

Designing the basic processor of 3 stages fetch, decode and execute based on RISC-V ISA.

## Next PC Logic
![image](https://github.com/bharath19-gs/vsdriscv/blob/main/Introduction/pc.png)

## Fetch

* Program Counter (PC): Holds the address of next Instruction
* Instruction Memory (IM): Holds the set of instructions to be executed

During Fetch Stage, processor fetches the instruction from the IM pointed by address given by PC.

Below is snapshot from Makerchip IDE after performing the Fetch Stage.
![image](https://github.com/bharath19-gs/vsdriscv/blob/main/Introduction/fetch.png)



## Decode

6 types of Instructions:
  * R-type - Register 
  * I-type - Immediate
  * S-type - Store
  * B-type - Branch (Conditional Jump)
  * U-type - Upper Immediate
  * J-type - Jump (Unconditional Jump)

Instruction Format includes Opcode, immediate value, source address, destination address. During Decode Stage, processor decodes the instruction based on instruction format and type of instruction.

Below is snapshot from Makerchip IDE after performing the Decode Stage.
![image](https://github.com/bharath19-gs/vsdriscv/blob/main/Introduction/decode_instructions.png)



## Register File Read and Write

Here the Register file is 2 read, 1 write means 2 read and 1 write operation can happen simultanously.

Inputs:
  * Read_Enable   - Enable signal to perform read operation
  * Read_Address1 - Address1 from where data has to be read 
  * Read_Address2 - Address2 from where data has to be read 
  * Write_Enable  - Enable signal to perform write operation
  * Write_Address - Address where data has to be written
  * Write_Data    - Data to be written at Write_Address

Outputs:
  * Read_Data1    - Data from Read_Address1
  * Read_Data2    - Data from Read_Address2

Below is snapshot from Makerchip IDE after performing the Register File Read followed by Register File Write.

![image](https://github.com/bharath19-gs/vsdriscv/blob/main/Introduction/read.png)

![image](https://github.com/bharath19-gs/vsdriscv/blob/main/Introduction/write.png)

## Execute

During the Execute Stage, both the operands perform the operation based on Opcode.

Below is snapshot from Makerchip IDE after performing the Execute Stage.

![image](https://github.com/bharath19-gs/vsdriscv/blob/main/Introduction/post_execute.png)

## Control Logic

During Decode Stage, branch target address is calculated and fed into PC mux. Before Execute Stage, once the operands are ready branch condition is checked.

Below is snapshot from Makerchip IDE after including the control logic for branch instructions.

![image](https://github.com/bharath19-gs/vsdriscv/blob/main/Introduction/control_branch.png)

# Pipelined RISC-V CPU

Converting non-piepleined CPU to pipelined CPU using timing abstract feature of TL-Verilog. This allows easy retiming wihtout any risk of funcational bugs. More details reagrding Timing Abstract in TL-Verilog can be found in IEEE Paper ["Timing-Abstract Circuit Design in Transaction-Level Verilog" by Steven Hoover.](https://ieeexplore.ieee.org/document/8119264)

## Pipelining the CPU

Pipelining the CPU with branches still having 3 cycle delay rest all instructions are pipelined. Pipelining the CPU in TL-Verilog can be done in following manner:
```
|<pipe-name>
    @<pipe stage>
       Instructions present in this stage
       
    @<pipe_stage>
       Instructions present in this stage
       
```

Below is snapshot of pipelined CPU with a test case of assembly program which does summation from 1 to 9 then stores to r10 of register file. In snapshot `r10 = 45`. Test case:
```
*passed = |cpu/xreg[10]>>5$value == (1+2+3+4+5+6+7+8+9);
```
![image](https://github.com/bharath19-gs/vsdriscv/blob/main/Introduction/pipe_lined_riscv_testbench.png)




## Load and store instructions and memory

Similar to branch, load will also have 3 cycle delay. So, added a Data Memory 1 write/read memory.

Inputs:
  * Read_Enable - Enable signal to perform read operation
  * Write_Enable - Enable signal to perform write operation
  * Address - Address specified whether to read/write from
  * Write_Data - Data to be written on Address (Store Instruction)

Output: 
  * Read_Data - Data to be read from Address (Load Instruction)

Added test case to check fucntionality of load/store. Stored the summation of 1 to 9 on address 4 of Data Memory and loaded that value from Data Memory to r17.
```
*passed = |cpu/xreg[17]>>5$value == (1+2+3+4+5+6+7+8+9);
```
Below is snapshot from Makerchip IDE after including load/store instructions.

![image](https://github.com/bharath19-gs/vsdriscv/blob/main/Introduction/load_store.png)

## Completing the RISC-V CPU

Added Jumps and completed Instruction Decode and ALU for all instruction present in RV32I base integer instruction set.

Below is final Snapshot of Complete Pipelined RISC-V CPU.
![image](https://github.com/bharath19-gs/vsdriscv/blob/main/Introduction/final_riscv.png)


# Acknowledgements
- [Kunal Ghosh](https://github.com/kunalg123), Co-founder, VSD Corp. Pvt. Ltd.
- [Steve Hoover](https://github.com/stevehoover), Founder, Redwood EDA
- Shivani Shah, TA
- Shivam Potdar, TA
- Vineet Jain, TA

# Author 
- [Bharath G S](https://github.com/bharath19-gs), BE(Electronics and Communication)
