# My-Programs-From-pwn.college

This repository contains my solutions and projects from pwn.college, focused on low-level programming and systems concepts using assembly.

## Contents

* **Web Server (Assembly)**
  A simple web server implemented in assembly. This project explores low-level networking, system calls, and handling HTTP requests without relying on high-level libraries.

* **Most Common Byte**
  A program that analyzes input data and determines the most frequently occurring byte. Useful for understanding loops, memory access, and data processing in assembly.

* **Byte Counting**
  A program that counts occurrences of bytes in a given input. Reinforces concepts like iteration, memory management, and efficient data handling.

* **StringLower**
  A program that calls convert letters to lowercase

## Purpose

The goal of this repository is to strengthen my understanding of:

* Assembly language programming
* Linux system calls
* Memory and data manipulation
* Low-level problem solving

## Notes

These programs are part of my learning process, so the focus is on understanding concepts rather than writing perfect or optimized code.

## How to Run

Most programs can be assembled and run using tools like:

```bash
nasm -f elf64 program.s -o program.o
ld program.o -o program
./program
```

(Some programs may require specific input methods or environments depending on the challenge.)

## Disclaimer

These are educational exercises from pwn.college and are not intended for production use.
