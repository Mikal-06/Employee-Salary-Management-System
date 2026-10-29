;====================================================================
; Project: Employee Salary Management System (ESMS)
; Architecture: x86 (MASM / Irvine32 Library)
; Author: Mikal Abu-Baker
; Description: Modular salary management system featuring employee
;              registration with input validation, net salary
;              computations, department-level statistical metrics,
;              and terminal-based distribution histograms.
;====================================================================

INCLUDE Irvine32.inc

;--------------------------------------------------------------------
; CONSTANTS
;--------------------------------------------------------------------
MAX_EMPLOYEES   EQU 50
NAME_SIZE       EQU 21
RECORD_SIZE     EQU 44
MIN_ID          EQU 100000
MAX_ID          EQU 999999
MIN_SALARY      EQU 500
MAX_SALARY      EQU 20000
MIN_ALLOW       EQU 0
MAX_ALLOW       EQU 5000
MIN_DEDUCT      EQU 0
MAX_DEDUCT      EQU 3000
MIN_DEPT        EQU 1
MAX_DEPT        EQU 5
NUM_DEPT        EQU 5
NUM_BRACKETS    EQU 5

;====================================================================
; DATA SEGMENT
;====================================================================
.data

; ============================
;  EMPLOYEE STORAGE
; ============================
employeeNames   BYTE MAX_EMPLOYEES * NAME_SIZE DUP(0)
employeeIDs     DWORD MAX_EMPLOYEES DUP(0)
departments     BYTE MAX_EMPLOYEES DUP(0)
basicSalaries   DWORD MAX_EMPLOYEES DUP(0)
allowances      DWORD MAX_EMPLOYEES DUP(0)
deductions      DWORD MAX_EMPLOYEES DUP(0)
netSalaries     DWORD MAX_EMPLOYEES DUP(0)

employeeCount   DWORD 0
deptLoopCounter DWORD 0
currentIndex    DWORD 0
tempValue       DWORD 0

; ============================
;  STATISTICS ARRAYS
; ============================
deptCounts      DWORD NUM_DEPT DUP(0)
deptTotals      DWORD NUM_DEPT DUP(0)
deptMin         DWORD NUM_DEPT DUP(0FFFFFFFFh)
deptMax         DWORD NUM_DEPT DUP(0)
salaryBrackets  DWORD NUM_BRACKETS DUP(0)

; ============================
;  INPUT BUFFERS
; ============================
inputBuffer     BYTE NAME_SIZE DUP(0)
tempName        BYTE NAME_SIZE DUP(0)

; ============================
;  MENU & UI STRINGS
; ============================
str_menuHeader  BYTE "================================================",0dh,0ah
                BYTE "   EMPLOYEE SALARY MANAGEMENT SYSTEM",0dh,0ah
                BYTE "================================================",0dh,0ah,0
str_menu1       BYTE "1. Add New Employee",0dh,0ah,0
str_menu2       BYTE "2. Display Pay Slip",0dh,0ah,0
str_menu3       BYTE "3. Department Statistics",0dh,0ah,0
str_menu4       BYTE "4. Exit Program",0dh,0ah,0
str_menuChoice  BYTE "Enter your choice (1-4): ",0

; ==================================
;  INPUT PROMPTS AND ERROR STRINGS
; ==================================
str_enterName   BYTE "Enter employee name: ",0
str_enterID     BYTE "Enter employee ID (6 digits): ",0
str_enterDept   BYTE "Enter department code (1-5): ",0
str_enterSalary BYTE "Enter basic salary (500-20000 JOD): ",0
str_enterAllow  BYTE "Enter allowances (0-5000 JOD): ",0
str_enterDeduct BYTE "Enter deductions (0-3000 JOD): ",0
str_enterIDDisp BYTE "Enter employee ID to display: ",0
str_addSuccess  BYTE "Employee added successfully!",0dh,0ah,0
str_pressKey    BYTE "Press any key to continue...",0dh,0ah,0
str_errMax      BYTE "ERROR: Maximum employees reached!",0dh,0ah,0
str_errID       BYTE "ERROR: Invalid ID. Must be 6 digits (100000-999999). Try again: ",0
str_errSalary   BYTE "ERROR: Invalid salary. Must be 500-20000. Try again: ",0
str_errAllow    BYTE "ERROR: Invalid allowances. Must be 0-5000. Try again: ",0
str_errDeduct   BYTE "ERROR: Invalid deductions. Must be 0-3000. Try again: ",0
str_errDept     BYTE "ERROR: Invalid department. Must be 1-5. Try again: ",0
str_errNotFound BYTE "ERROR: Employee ID not found!",0dh,0ah,0
str_errChoice   BYTE "ERROR: Invalid choice. Enter 1-4.",0dh,0ah,0
str_errName     BYTE "ERROR: Name cannot be empty. Try again: ",0

; ============================
;  PAY SLIP STRINGS
; ============================
str_slipHeader  BYTE "================================================",0dh,0ah
                BYTE "                  PAY SLIP",0dh,0ah
                BYTE "================================================",0dh,0ah,0
str_separator   BYTE "----------------------------------------",0dh,0ah,0
str_labelName   BYTE "Employee Name   : ",0
str_labelID     BYTE "Employee ID     : ",0
str_labelDept   BYTE "Department      : ",0
str_labelBasic  BYTE "Basic Salary    : ",0
str_labelAllow  BYTE "Allowances      : ",0
str_labelDeduct BYTE "Deductions      : ",0
str_labelNet    BYTE "Net Salary      : ",0
str_jod         BYTE " JOD",0dh,0ah,0

; ====================================
;  DEPT STATS AND HISTOGRAM STRINGS
; ====================================
str_deptHeader  BYTE "================================================",0dh,0ah
                BYTE "           DEPARTMENT STATISTICS",0dh,0ah
                BYTE "================================================",0dh,0ah,0
str_deptLabel   BYTE "Department ",0
str_empLabel    BYTE ": ",0
str_empSuffix   BYTE " employees",0dh,0ah,0
str_avgLabel    BYTE "  Average Salary : ",0
str_minLabel    BYTE "  Lowest Salary  : ",0
str_maxLabel    BYTE "  Highest Salary : ",0
str_noEmp       BYTE "  No employees in this department.",0dh,0ah,0
str_histHeader  BYTE "================================================",0dh,0ah
                BYTE "        SALARY DISTRIBUTION HISTOGRAM",0dh,0ah
                BYTE "================================================",0dh,0ah,0
str_bk0         BYTE "   0-499  : ",0
str_bk1         BYTE " 500-999  : ",0
str_bk2         BYTE " 1000-1499 : ",0
str_bk3         BYTE " 1500-1999 : ",0
str_bk4         BYTE " 2000+     : ",0
str_star        BYTE "*",0
str_newline     BYTE 0dh,0ah,0
str_histFooter  BYTE "================================================",0dh,0ah,0

; ============================
;  GOODBYE STRING
; ============================
str_goodbye     BYTE "Goodbye!",0dh,0ah,0

;====================================================================
; CODE SEGMENT
;====================================================================
.code

;====================================================================
; Initialize: Resets counters and statistics tracking structures
;====================================================================
Initialize PROC
    mov employeeCount, 0

    mov ecx, NUM_DEPT
    mov esi, 0
    xor eax, eax
clearDeptCounts:
    mov deptCounts[esi], eax
    add esi, TYPE deptCounts
    loop clearDeptCounts

    mov ecx, NUM_DEPT
    mov esi, 0
    xor eax, eax
clearDeptTotals:
    mov deptTotals[esi], eax
    add esi, TYPE deptTotals
    loop clearDeptTotals

    mov ecx, NUM_DEPT
    mov esi, 0
    xor eax, eax
clearDeptMax:
    mov deptMax[esi], eax
    add esi, TYPE deptMax
    loop clearDeptMax

    mov ecx, NUM_DEPT
    mov esi, 0
    mov eax, 0FFFFFFFFh
clearDeptMin:
    mov deptMin[esi], eax
    add esi, TYPE deptMin
    loop clearDeptMin

    mov ecx, NUM_BRACKETS
    mov esi, 0
    xor eax, eax
clearSalaryBrackets:
    mov salaryBrackets[esi], eax
    add esi, TYPE salaryBrackets
    loop clearSalaryBrackets

    ret
Initialize ENDP

;====================================================================
; DisplayMenu: Renders main options to console
;====================================================================
DisplayMenu PROC
    call Crlf
    mov edx, OFFSET str_menuHeader
    call WriteString
    mov edx, OFFSET str_menu1
    call WriteString
    mov edx, OFFSET str_menu2
    call WriteString
    mov edx, OFFSET str_menu3
    call WriteString
    mov edx, OFFSET str_menu4
    call WriteString
    mov edx, OFFSET str_menuChoice
    call WriteString
    ret
DisplayMenu ENDP

;====================================================================
; Validation Procedures
;====================================================================
ValidateName PROC
    mov edx, OFFSET str_enterName
    call WriteString
nameLoop:
    mov edx, OFFSET inputBuffer
    mov ecx, NAME_SIZE - 1
    call ReadString
    cmp eax, 0
    jne nameDone
    mov edx, OFFSET str_errName
    call WriteString
    jmp nameLoop
nameDone:
    mov ecx, NAME_SIZE
    mov esi, 0
copyTempName:
    mov al, inputBuffer[esi]
    mov tempName[esi], al
    inc esi
    loop copyTempName
    ret
ValidateName ENDP

ValidateID PROC
    mov edx, OFFSET str_enterID
    call WriteString
idLoop:
    call ReadInt
    cmp eax, MIN_ID
    jl  idError
    cmp eax, MAX_ID
    jg  idError
    ret
idError:
    mov edx, OFFSET str_errID
    call WriteString
    jmp idLoop
ValidateID ENDP

ValidateDept PROC
    mov edx, OFFSET str_enterDept
    call WriteString
deptValLoop:
    call ReadInt
    cmp eax, MIN_DEPT
    jl  deptValError
    cmp eax, MAX_DEPT
    jg  deptValError
    ret
deptValError:
    mov edx, OFFSET str_errDept
    call WriteString
    jmp deptValLoop
ValidateDept ENDP

ValidateSalary PROC
    mov edx, OFFSET str_enterSalary
    call WriteString
salLoop:
    call ReadInt
    cmp eax, MIN_SALARY
    jl  salError
    cmp eax, MAX_SALARY
    jg  salError
    ret
salError:
    mov edx, OFFSET str_errSalary
    call WriteString
    jmp salLoop
ValidateSalary ENDP

ValidateAllowances PROC
    mov edx, OFFSET str_enterAllow
    call WriteString
allowLoop:
    call ReadInt
    cmp eax, MIN_ALLOW
    jl  allowError
    cmp eax, MAX_ALLOW
    jg  allowError
    ret
allowError:
    mov edx, OFFSET str_errAllow
    call WriteString
    jmp allowLoop
ValidateAllowances ENDP

ValidateDeductions PROC
    mov edx, OFFSET str_enterDeduct
    call WriteString
deductLoop:
    call ReadInt
    cmp eax, MIN_DEDUCT
    jl  deductError
    cmp eax, MAX_DEDUCT
    jg  deductError
    ret
deductError:
    mov edx, OFFSET str_errDeduct
    call WriteString
    jmp deductLoop
ValidateDeductions ENDP

;====================================================================
; AddEmployee: Appends new employee record and invokes statistics
;====================================================================
AddEmployee PROC
    mov eax, employeeCount
    cmp eax, MAX_EMPLOYEES
    jl  canAdd
    mov edx, OFFSET str_errMax
    call WriteString
    ret
canAdd:
    mov eax, employeeCount
    mov currentIndex, eax

    ;--- Name ---
    call ValidateName
    mov eax, currentIndex
    imul eax, NAME_SIZE
    lea edi, employeeNames
    add edi, eax
    lea esi, tempName
    mov ecx, NAME_SIZE
copyEmployeeName:
    mov al, [esi]
    mov [edi], al
    inc esi
    inc edi
    loop copyEmployeeName

    ;--- ID ---
    call ValidateID
    mov ecx, currentIndex
    shl ecx, 2
    lea edi, employeeIDs
    mov [edi + ecx], eax

    ;--- Department ---
    call ValidateDept
    mov ecx, currentIndex
    lea edi, departments
    mov [edi + ecx], al

    ;--- Basic Salary ---
    call ValidateSalary
    mov ecx, currentIndex
    shl ecx, 2
    lea edi, basicSalaries
    mov [edi + ecx], eax

    ;--- Allowances ---
    call ValidateAllowances
    mov ecx, currentIndex
    shl ecx, 2
    lea edi, allowances
    mov [edi + ecx], eax

    ;--- Deductions ---
    call ValidateDeductions
    mov ecx, currentIndex
    shl ecx, 2
    lea edi, deductions
    mov [edi + ecx], eax

    ;--- Calculate Net Salary ---
    mov ecx, currentIndex
    shl ecx, 2
    lea edi, basicSalaries
    mov eax, [edi + ecx]
    lea edi, allowances
    mov ebx, [edi + ecx]
    lea edi, deductions
    mov edx, [edi + ecx]
    mov ecx, edx
    call CalcNetSalary

    ;--- Store Net Salary ---
    mov ecx, currentIndex
    shl ecx, 2
    lea edi, netSalaries
    mov [edi + ecx], eax

    ;--- Update Statistics ---
    mov ecx, currentIndex
    lea edi, departments
    movzx ebx, byte ptr [edi + ecx]
    call UpdateStatistics

    inc employeeCount
    mov edx, OFFSET str_addSuccess
    call WriteString
    ret
AddEmployee ENDP

;====================================================================
; CalcNetSalary
; Inputs: EAX=basic, EBX=allowances, ECX=deductions
; Output: EAX=net
;====================================================================
CalcNetSalary PROC
    add eax, ebx
    sub eax, ecx
    ret
CalcNetSalary ENDP

;====================================================================
; UpdateStatistics
; Inputs: EAX=net salary, EBX=dept code (1-5)
;====================================================================
UpdateStatistics PROC
    mov     tempValue, eax
    push    ebx
    dec     ebx
    shl     ebx, 2
    mov     eax, tempValue
    inc     DWORD PTR deptCounts[ebx]
    add     DWORD PTR deptTotals[ebx], eax
    cmp     eax, DWORD PTR deptMin[ebx]
    jge     skipMin
    mov     DWORD PTR deptMin[ebx], eax
skipMin:
    cmp     eax, DWORD PTR deptMax[ebx]
    jle     skipMax
    mov     DWORD PTR deptMax[ebx], eax
skipMax:
    pop     ebx
    mov     eax, tempValue
    cmp     eax, 500
    jl      bracket0
    cmp     eax, 1000
    jl      bracket1
    cmp     eax, 1500
    jl      bracket2
    cmp     eax, 2000
    jl      bracket3
    jmp     bracket4
bracket0:
    inc DWORD PTR salaryBrackets[0]
    jmp bracketDone
bracket1:
    inc DWORD PTR salaryBrackets[4]
    jmp bracketDone
bracket2:
    inc DWORD PTR salaryBrackets[8]
    jmp bracketDone
bracket3:
    inc DWORD PTR salaryBrackets[12]
    jmp bracketDone
bracket4:
    inc DWORD PTR salaryBrackets[16]
bracketDone:
    ret
UpdateStatistics ENDP

;====================================================================
; PrintStars
;====================================================================
PrintStars PROC
    cmp ecx, 0
    je  noPrint
starLoop:
    mov al, '*'
    call WriteChar
    loop starLoop
noPrint:
    call Crlf
    ret
PrintStars ENDP

;====================================================================
; DisplayHistogram
;====================================================================
DisplayHistogram PROC
    call Crlf
    mov edx, OFFSET str_histHeader
    call WriteString
    mov edx, OFFSET str_bk0
    call WriteString
    mov ecx, salaryBrackets[0]
    call PrintStars
    mov edx, OFFSET str_bk1
    call WriteString
    mov ecx, salaryBrackets[4]
    call PrintStars
    mov edx, OFFSET str_bk2
    call WriteString
    mov ecx, salaryBrackets[8]
    call PrintStars
    mov edx, OFFSET str_bk3
    call WriteString
    mov ecx, salaryBrackets[12]
    call PrintStars
    mov edx, OFFSET str_bk4
    call WriteString
    mov ecx, salaryBrackets[16]
    call PrintStars
    mov edx, OFFSET str_histFooter
    call WriteString
    ret
DisplayHistogram ENDP

;====================================================================
; DisplayDepartmentStats
;====================================================================
DisplayDepartmentStats PROC
    call Crlf
    mov edx, OFFSET str_deptHeader
    call WriteString
    mov deptLoopCounter, 5
    mov currentIndex, 0
deptLoop:
    mov ebx, currentIndex
    mov edx, OFFSET str_deptLabel
    call WriteString
    mov eax, ebx
    inc eax
    call WriteDec
    mov edx, OFFSET str_empLabel
    call WriteString
    mov ebx, currentIndex
    mov ecx, ebx
    shl ecx, 2
    mov eax, deptCounts[ecx]
    call WriteDec
    mov edx, OFFSET str_empSuffix
    call WriteString
    mov ebx, currentIndex
    mov ecx, ebx
    shl ecx, 2
    cmp deptCounts[ecx], 0
    je  noEmployeesInDept
    mov eax, deptTotals[ecx]
    mov edx, 0
    mov edi, deptCounts[ecx]
    div edi
    mov edx, OFFSET str_avgLabel
    call WriteString
    call WriteDec
    mov edx, OFFSET str_jod
    call WriteString
    mov ebx, currentIndex
    mov ecx, ebx
    shl ecx, 2
    mov edx, OFFSET str_minLabel
    call WriteString
    mov eax, deptMin[ecx]
    call WriteDec
    mov edx, OFFSET str_jod
    call WriteString
    mov ebx, currentIndex
    mov ecx, ebx
    shl ecx, 2
    mov edx, OFFSET str_maxLabel
    call WriteString
    mov eax, deptMax[ecx]
    call WriteDec
    mov edx, OFFSET str_jod
    call WriteString
    jmp nextDept
noEmployeesInDept:
    mov edx, OFFSET str_noEmp
    call WriteString
nextDept:
    inc currentIndex
    dec deptLoopCounter
    jnz deptLoop
    call DisplayHistogram
    ret
DisplayDepartmentStats ENDP

;====================================================================
; FindEmployeeByID
; Input:  EAX = ID to search
; Output: EAX = index if found, -1 if not found
;====================================================================
FindEmployeeByID PROC
    mov ecx, employeeCount
    cmp ecx, 0
    je  notFound
    mov ebx, 0
searchLoop:
    push eax
    mov eax, ebx
    shl eax, 2
    lea edi, employeeIDs
    mov edi, [edi + eax]
    pop eax
    cmp edi, eax
    je  foundEmp
    inc ebx
    dec ecx
    cmp ecx, 0
    jne searchLoop
notFound:
    mov eax, -1
    ret
foundEmp:
    mov eax, ebx
    ret
FindEmployeeByID ENDP

;====================================================================
; DisplayPaySlip
;====================================================================
DisplayPaySlip PROC
    mov edx, OFFSET str_enterIDDisp
    call WriteString
    call ReadInt
    call FindEmployeeByID
    cmp eax, -1
    jne showSlip
    mov edx, OFFSET str_errNotFound
    call WriteString
    ret
showSlip:
    mov currentIndex, eax
    mov ecx, eax
    shl ecx, 2
    mov tempValue, ecx

    call Crlf
    mov edx, OFFSET str_slipHeader
    call WriteString
    mov edx, OFFSET str_separator
    call WriteString

    ;--- Name ---
    mov edx, OFFSET str_labelName
    call WriteString
    mov eax, currentIndex
    imul eax, NAME_SIZE
    lea edx, employeeNames
    add edx, eax
    call WriteString
    call Crlf

    ;--- ID ---
    mov edx, OFFSET str_labelID
    call WriteString
    mov ecx, tempValue
    lea edi, employeeIDs
    mov eax, [edi + ecx]
    call WriteDec
    call Crlf

    ;--- Department ---
    mov edx, OFFSET str_labelDept
    call WriteString
    mov ecx, currentIndex
    lea edi, departments
    movzx eax, byte ptr [edi + ecx]
    call WriteDec
    call Crlf

    ;--- Basic Salary ---
    mov edx, OFFSET str_labelBasic
    call WriteString
    mov ecx, tempValue
    lea edi, basicSalaries
    mov eax, [edi + ecx]
    call WriteDec
    mov edx, OFFSET str_jod
    call WriteString

    ;--- Allowances ---
    mov edx, OFFSET str_labelAllow
    call WriteString
    mov ecx, tempValue
    lea edi, allowances
    mov eax, [edi + ecx]
    call WriteDec
    mov edx, OFFSET str_jod
    call WriteString

    ;--- Deductions ---
    mov edx, OFFSET str_labelDeduct
    call WriteString
    mov ecx, tempValue
    lea edi, deductions
    mov eax, [edi + ecx]
    call WriteDec
    mov edx, OFFSET str_jod
    call WriteString

    ;--- Net Salary ---
    mov edx, OFFSET str_separator
    call WriteString
    mov edx, OFFSET str_labelNet
    call WriteString
    mov ecx, tempValue
    lea edi, netSalaries
    mov eax, [edi + ecx]
    call WriteDec
    mov edx, OFFSET str_jod
    call WriteString
    mov edx, OFFSET str_separator
    call WriteString
    ret
DisplayPaySlip ENDP

;====================================================================
; MAIN PROCEDURE
;====================================================================
main PROC
    call Initialize
mainLoop:
    call DisplayMenu
    call ReadInt
    cmp eax, 1
    je  doAdd
    cmp eax, 2
    je  doSlip
    cmp eax, 3
    je  doStats
    cmp eax, 4
    je  doExit
    mov edx, OFFSET str_errChoice
    call WriteString
    jmp mainLoop
doAdd:
    call AddEmployee
    mov edx, OFFSET str_pressKey
    call WriteString
    call ReadChar
    jmp mainLoop
doSlip:
    call DisplayPaySlip
    mov edx, OFFSET str_pressKey
    call WriteString
    call ReadChar
    jmp mainLoop
doStats:
    call DisplayDepartmentStats
    mov edx, OFFSET str_pressKey
    call WriteString
    call ReadChar
    jmp mainLoop
doExit:
    mov edx, OFFSET str_goodbye
    call WriteString
    exit
main ENDP
END main