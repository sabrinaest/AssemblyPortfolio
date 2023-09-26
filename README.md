# MASM String Processing & Integer Procedures Project

A comprehensive MASM project that dives deep into string processing macros, signed integer procedures, and error handling. 

<video loop src="assembly.mp4"></video>

## 📝 Program Description

This program prompts the user to enter 10 valid signed integers and dynamically displays the running subtotal, giving users a real-time glimpse of their cumulative input. Upon completion, the program presents the user with the entered set of integers, their calculated sum, and the average.

## ✨ Features

- **String Processing Macros**: Utilizes Irvine's ReadString procedure to gather user's input and deploys WriteString Procedure for visual output.
  
- **Signed Integer Procedures**: Converts the string input to signed integers utilizing string primitive instructions. Notably, this is achieved without the use of ReadInt, ReadDec, WriteInt, and WriteDec.
  
- **Error Handling**: Ensures users only input valid signed integers that fit within 32-bit registers.
  
- **User Interaction**: Collects input from user and displays the set of integers, their sum and the truncated average.

## 📚 Documentation & References

**Assembly Language for x86 Processors**
* Author: Kip R. Irvine
* Description: This textbook served as the foundational resource for the assembly language concepts implemented in this project.
