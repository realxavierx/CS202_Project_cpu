# CS202 Final Project
Final project of CS202 Computer Organization - an Implementation of a single-cycle cpu.  
The result is 123/100 (Max Score with All Bonus is 130).

## Team Member
12012902 肖煜玮 & 12012719 李思锐 & 12010336 黄慧惠

## Introduction
Implementing an single-cycle cpu by FPGA and Verilog. The cpu is of Von-Neumann structure.  
We constructed several modules including Controller, Decoder, IFetch, Data Memory, ALU, I/O and etc.  
The I/O module includes LED, Switch, Keyboard and UART.  
The ISA(Instruction Set Architecture) is based on Minisys.  
And we used Assembly to construct several test scenes.

## Implementation
You can check the introduction and specific requirements in the CS202_Project.pdf.  
You can get our idea in the CS202_Project_Report.pdf.  
Also, you can check our source code under the `code` directory and the test scene code is under `code/asm_coe` directory.

## Bonus 
We implemented several bonus including:
* UART
* Multiple I/O devices 
* Better interation with user

## Deficiency
* We didn't extend the instructions excluding Minisys.
* We didn't do much optimization on the execution of instrcutions.
* We didn't implemented I/O with VGA port.
