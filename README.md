# Employee Salary Management System (ESMS) 💼🖥️

A robust, console-based application written entirely in **x86 Assembly (MASM)** utilizing the **Irvine32 library**. This project demonstrates low-level memory addressing, data validation, array manipulation, and terminal-based data visualization.

## 🚀 Features

- **Employee Record Management**: Captures and stores employee IDs, names, departments, basic salaries, allowances, and deductions.
- **Strict Input Validation**: Enforces bounds for numeric ranges (e.g., salaries within limits, strictly 6-digit IDs, department codes 1-5).
- **Pay Slip Generation**: Computes net earnings dynamically and generates formatted, easy-to-read salary breakdown slips.
- **Departmental Analytics**: Dynamically tracks headcount, salary averages, minima, and maxima per department.
- **Terminal Histogram**: Renders visual ASCII-based distribution charts for salary tiers directly in the command prompt.

## 🛠️ Tech Stack & Prerequisites

- **Language**: x86 Assembly Language
- **Assembler**: Microsoft Macro Assembler (MASM / ML.EXE)
- **Library**: [Irvine32 Library](http://kipirvine.com/asm/gettingStartedVS2019/index.htm) (Required for I/O operations)
- **Environment**: Windows OS (Required for x86 console execution)

## 📥 How to Run

### Method 1: The Easy Way (Pre-compiled)
If you just want to see the program in action without setting up an Assembly environment:
1. Go to the **[Releases](../../releases)** tab on this repository.
2. Download the `ESMS_Project.exe` file.
3. Double-click to run! *(Note: Windows might show a SmartScreen warning since the exe is unsigned. Click "More info" -> "Run anyway").*

### Method 2: Build from Source
If you are a developer and have MASM and Irvine32 set up:
1. Clone the repository:
   ```bash
   git clone https://github.com/YourUsername/YourRepoName.git
   ```
2. Navigate to the project folder.
3. Double click the `build.bat` file to automatically compile, link, and run the project. 

*Alternatively, run via developer command prompt:*
```bash
ml /c /coff /Cp Project.asm
link /subsystem:console Project.obj Irvine32.lib Kernel32.lib User32.lib
Project.exe
```


## 👨‍💻 Author

**Mikal Abu-Baker**

---
*This project was developed as a comprehensive implementation phase for an Assembly Language Programming coursework.*
