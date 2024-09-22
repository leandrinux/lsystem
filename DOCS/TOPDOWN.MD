# Top down compiler changes document

This document describes the new top-down, tokenized approach to compiling and the previous method (old way) used in Ragamuffin and early Snowshoe implementations.

## Old way compiler (Ragamuffin)

The compiler program uses the BUILDER class to set two streams: an input stream with the source code, and an output stream where the binary generated code and data are written.

BUILDER has the in and out file streams. It calls a data parser to work on the streams, and then a code parser to do the same. Each parser work with each section of the file. The code parser extracts information about each sentence. The sentence data is passed to a binary builder. 

When all the code has been parsed, the BINARY class is used to convert each sentence into its binary representation and each one of them is saved in the output stream

When the binary class has saved all the binary info without any issues, the compilation is done.

## New way

The compiler will be split in two main components. One component reads and processes the input stream of source code and creates a memory special representation of this code. The second component takes this representation and creates the binary representation of the code. This is similar to what the BUILDER and BINARY classes did in the old compiler implementation.

The first component is the assembly parser, contained in the file ASMSCP.PAS. The second component is the binary generator, contained in the BINGEN.PAS file. The intermediate, special representation of the code is implemented in the IR.PAS file

## The assembly source code parser

The assembly source code parser works in the following way

* Tokenization: The source code is split in tokens. The analysis will later be performed over these tokens, not on a character by character basis. This simplifies the parsing.

* Top-down analysis: the entire language is expressed in elements. Each element can be a simple data like a number, a string or a comma, or a more complex construction of other elements. The parser starts from the root element and gradually decompones it into its constituents. As it does this process, it analyzes the text and generates the intermediate representation

The purpose of the assembly source code parser is to read human written code and use it to create the IR (intermediate code representation )

## The intermediate code representation

This class contains all the info that is necessary to describe a program. Based on the contents of this class and this class alone, any number of generators could be make to produce different outputs. We are only interested in binary outputs for the lsystem architecture. Once this representation is completed, the parsing ends and is no longer needed.

## The binary generator

The binary generator uses the info from the intermediate code representation to write the binary code that the lsystem interpreter understands and is able to run. 