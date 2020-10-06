# ming M20 Microprocessors

**USER MANUAL**

M80-UserManual-0291

**Author:** Wei, Zhang; Fang, Wang

Copyright (c) 1978 ming, Inc. All right reserved.

---

## Memory Map

0x000 - 0x0FF -> 256 Byte RAM
0x200 - 0xFFF -> 512 Byte ROM

---

## Registers

| Register | OpCode | Type                   |
| -------- | ------ | ---------------------- |
| acc      | 0      | Accumulator            |
| r0       | 1      | General purpose        |
| r1       | 2      | General purpose        |
| r2       | 3      | General purpose        |
| r3       | 4      | General purpose        |
| r4       | 5      | General purpose        |
| r5       | 6      | General purpose        |
| r6       | 7      | General purpose        |
| ctrl     | -      | M80 Status and Control |

---

## Ports

The M80 provides two types of ports.

| Port | OpCode | Type             |
| ---- | ------ | ---------------- |
| p0   | 8      | analog           |
| p1   | 9      | analog           |
| p2   | A      | analog           |
| p3   | B      | analog           |
| p4   | C      | analog / digital |
| p5   | D      | analog / digital |
| p6   | E      | analog / digital |
| p7   | F      | analog / digital |

---

## Instructions & OpCodes

**General**

| Code | Assembly          | Meaning                                         |
| ---- | ----------------- | ----------------------------------------------- |
| 0000 | NOP               | NOP                                             |
| 0xxx | JMP label         | Sets the program counter to xxx Start(0x200)    |
| 00FF | RET               | Return from Subroutine                          |
| 10xy | MOV x(R/P) y(R/P) | Copies a value of a register to target register |
| 2xxy | MOV x(V) y(R/P)   | Copies a integer to target register             |
| FFFF | RES               | Resets CPU                                      |

**Arithmetic Operations**

| Code | Assembly   | Meaning                                        |
| ---- | ---------- | ---------------------------------------------- |
| 300x | ADD x(R/P) | Adds value of register to acc register         |
| 31xx | ADD x(V)   | Adds integer to acc register                   |
| 320x | SUB x(R/P) | Substracts value of register from acc register |
| 33xx | SUB x(V)   | Substracts integer from acc register           |
| 3400 | INC        | Increments acc by 1                            |
| 3500 | DEC        | Decrements acc by 1                            |
| 360x | MUL x(R/P) | Multiplies value of register with acc register |
| 37xx | MUL x(V)   | Multiplies integer with acc register           |
| 380x | DIV x(R/P) | Divides value of register with acc register    |
| 39xx | DIV x(V)   | Divides integer with acc register              |
| 3A0x | AND x(R/P) | Bitwise AND value of register to acc register  |
| 3Bxx | AND x(V)   | Bitwise AND integer to acc register            |
| 3C0x | OR x(R/P)  | Bitwise OR value of register to acc register   |
| 3Dxx | OR x(V)    | Bitwise OR integer to acc register             |
| 3E0x | XOR x(R/P) | Bitwise XOR value of register to acc register  |
| 3Fxx | XOR x(V)   | Bitwise XOR integer to acc register            |

**Bit Manipulation**

| Code | Assembly | Meaning                    |
| ---- | -------- | -------------------------- |
| 400x | STB x(V) | Set Bit position x on acc  |
| 410x | GTB x(V) | Get Bit position x on acc  |
| 420x | SHL x(V) | Shift left acc by x bits   |
| 430x | SHR x(V) | Shift right acc by x bits  |
| 440x | RTL x(V) | Rotate left acc by x bits  |
| 450x | RTR x(V) | Rotate right acc by x bits |
| 4600 | GCN      | Load ctrl to acc           |
| 4700 | SCN      | Save acc to ctrl           |

**Compare Operations**

| Code | Assembly   | Meaning                                        |
| ---- | ---------- | ---------------------------------------------- |
| 500x | CMP x(R/P) | if (x == acc) next line ? else: skip next line |
| 51xx | CMP x(V)   | if (x == acc) next line ? else: skip next line |
| 520x | CNE x(R/P) | if (x != acc) next line ? else: skip next line |
| 53xx | CNE x(V)   | if (x != acc) next line ? else: skip next line |
| 540x | CGT x(R/P) | if (x < acc) next line ? else: skip next line  |
| 55xx | CGT x(V)   | if (x < acc) next line ? else: skip next line  |
| 560x | CLT x(R/P) | if (x > acc) next line ? else: skip next line  |
| 57xx | CLT x(V)   | if (x > acc) next line ? else: skip next line  |
| 580x | CGE x(R/P) | if (x <= acc) next line ? else: skip next line |
| 59xx | CGE x(V)   | if (x <= acc) next line ? else: skip next line |
| 5A0x | CLE x(R/P) | if (x >= acc) next line ? else: skip next line |
| 5Bxx | CLE x(V)   | if (x >= acc) next line ? else: skip next line |

**Error Codes**

If a command is not found, the tokenizer will return the following pseudo op codes:

| Pseudo OpCode | Meaning                   |
| ------------- | ------------------------- |
| 0x8000        | Illegal instruction found |
| 0x8001        | Illegal address found     |
| 0x8002        | Memory access violation   |
