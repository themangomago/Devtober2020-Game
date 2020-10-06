# Compiler Workflow

## Tokenizer

The tokenizer takes a line of code and split it in its elements:

`MOV 8 acc ;Test Code`

will result in:

`{command: xxx, args:[8, acc], line:0 }`

The tokenizer will also the first step to indicate compile and memory access errors:

| Pseudo OpCode | Meaning                   |
| ------------- | ------------------------- |
| 0x8000        | Illegal instruction found |
| 0x8001        | Illegal address found     |
| 0x8002        | Memory access violation   |

## Compiler

The compiler will go through all the tokenized lines and put a OpCode to it.
