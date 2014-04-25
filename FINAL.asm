Assume cs:code, ds:data, ss:stack

data segment
; All variables defined within the data segment
position db 1
direction db 1
calls db 0
output1 db 0 
output2 db 0
input db 0FFH
floors db 0
message db "How Many Floors?$"
mess db "Please enter the foor (1-5)$"
mess1 db "You have arrived at your destination.$"
inp db "CheckInput$"
movele db "Move Elevator$"
atPos db "At Position$"
resCall db "ResetCall$"
chkFLR db "Check Floor$"
numFloors db 17 dup(" ")
pickFloors db 17 dup(" ")

data ends

stack segment
; Stack size and the top of the stack defined in the stack segment
dw 100 dup(?)
stacktop:
stack ends

code segment
begin:
mov ax, data
mov ds,ax
mov ax, stack
mov ss,ax
mov sp, offset stacktop
; This is where code begins
mov DX, 143H
mov AL, 2
out DX,AL ;Place I/O chip into direction mode
mov DX, 140H
mov AL,00H
out DX,AL ;Set Port A to all inputs
mov DX,141H
mov AL,0FFH
out DX,AL ;Set Port B to all output
mov DX,142H
mov AL, 6FH
out DX,AL ;Set Port C to selected output.
mov DX, 143H
mov AL,3
out DX,AL ;Place I/O chip into operation mode

mov AH,00H
mov SI,offset position
mov [SI],AH ;Sets elevator starting location to 1st floor.

checkInput:
mov DX,140H
in AL,DX;
mov input,AL
cmp AL,0FFH
JNE prepCall
mov AL,direction
cmp AL,02H
je prepAtPosition
mov AL,calls
cmp AL,00H
jne prepMove
jmp checkInput
prepCall:
call setCall
jmp checkInput
prepMove:
call moveElevator
jmp checkInput
prepAtPosition:
call atPosition
jmp checkInput
End_prog:
mov ah,4ch
int 21h



atPosition:
push AX
push BX
push CX
push DX
mov AH,9
mov DX,offset atPos
int 21H
mov AH,2
mov DX,0dH
int 21H
mov DX,0AH
int 21H
call resetCall
reset:
mov AH,9
mov dx,offset message
int 21h
mov AH,2
mov DX,0dH
int 21H
mov DX,0AH
int 21H
endWrite:
mov DI,offset numFloors
startRead:
mov AH,1
int 21h
mov [DI],AL
inc DI
cmp AL,13
je inputFloors
jmp startRead
inputFloors:
mov AH,2
mov DX,0dH
int 21H
mov DX,0AH
int 21H
mov AH,9
mov dx,offset mess
int 21h
mov AH,2
mov DX,0dH
int 21H
mov DX,0AH
int 21H
mov DI,offset pickFloors
pkflr:
mov AH,1
int 21H
mov [DI],AL
inc DI
cmp AL,13
je checkFloor
jmp pkflr
checkFloor:
mov AH,2
mov DI,offset numFloors
mov DL,[DI]
int 21H
cmp DL,"3"
je ThreeFloors
cmp DL,"2"
je TwoFloors
cmp DL,"1"
je oneFloor
jmp endWrite
ThreeFloors:
mov CX,3
jmp checkFloor1
TwoFloors:
mov CX,2
jmp checkFloor1
oneFloor:
mov CX,1
checkFloor1:
mov DI,offset pickFloors
mov AH,2
mov DL,[DI]
int 21H
cmp DL,"1"
je setFirstFloor
cmp DL,"2"
je setSecondFloor
cmp DL,"3"
je setThirdFloor
cmp DL,"4"
je setFourthFloor
cmp DL,"5"
je setFifthFloor
jmp checkFloor1
setFirstFloor:
mov SI,offset floors
mov AL,00000001B
or [SI],AL
loop checkFloor1
jmp endAtPosition
setSecondFloor:
mov SI,offset floors
mov AL,00000010B
or [SI],AL
loop checkFloor1
jmp endAtPosition
setThirdFloor:
mov SI,offset floors
mov AL,00000100B
or [SI],AL
loop checkFloor1
jmp endAtPosition
setFourthFloor:
mov SI,offset floors
mov AL,00001000B
or [SI],AL
loop checkFloor1
jmp endAtPosition
setFifthFloor:
mov SI,offset floors
mov AL,00010000B
or [SI],AL
loop checkFloor1
endAtPosition:
mov AH,9
mov DX,offset atPos
int 21H
mov AH,2
mov DX,0dH
int 21H
mov DX,0AH
int 21H
pop DX
pop CX
pop BX
pop AX
ret



moveElevator: ;Change delay1sec subroutine to check for input as delay
push AX
push DX
mov AH,9
mov DX,offset movele
int 21H
mov AH,2
mov DX,0dH
int 21H
mov DX,0AH
int 21H
call checkCalls
call checkFloorChe
mov SI,offset direction
mov AL,[SI]
mov DL,[SI]
ADD DL,48
mov AH,2
int 21H
cmp AL,00H
je moveDown
cmp AL,01H
je moveUp
jmp endMove
moveUp:
mov AL,output2
and AL,10011111B
OR AL,01000000B
mov output2,AL
mov DX,142H
out DX,AL
mov AL,position
cmp AL,05H
je endMove
inc AL
mov position,AL
call displayPosition
call delay1sec
call delay1sec
jmp endMove
moveDown:
mov AL,output2
and AL,10011111B
OR AL,00100000B
mov output2,AL
mov DX,142H
out DX,AL
mov AL,position
cmp AL,01H
je endMove
dec AL
mov position,AL
call displayPosition
call delay1sec
call delay1sec
endMove:
pop DX
pop AX
ret


setCall:
push AX
mov AH,calls
mov AL,input
not AL
OR AH,AL
mov calls,AH
call displayCall
pop AX
ret

checkFloorChe:
push AX
push DX
mov AH,9
mov DX,offset chkFLR
int 21H
mov AH,2
mov DX,0dH
int 21H
mov DX,0AH
int 21H
mov AL,floors
and AL,00000001B
cmp AL,00000001B
je firstFloorChe
mov AL,floors
and AL,00000010B
cmp AL,00000010B
je secondFloorChe
mov AL,floors
and AL,00000100B
cmp AL,00000100B
je thirdFloorChe
mov AL,floors
and AL,00001000B
cmp AL,00001000B
je fourthFloorChe
mov AL,floors
and AL,00010000B
cmp AL,00010000B
je fifthFloorChe
jmp endCheckFloor
firstFloorChe:
mov AH,position
cmp AH,1
jl setUp
mov AL,floors
and AL,00011110B
mov floors,AL
je setHere
secondFloorChe:
mov AH,position
cmp AH,2
jg setDown
jl setUp
mov AL,floors
and AL,00011101B
mov floors,AL
je setHere
thirdFloorChe:
mov AH,position
cmp AH,3
jg setDown
jl setUp
mov AL,floors
and AL,00011011B
mov floors,AL
je setHere
fourthFloorChe:
mov AH,position
cmp AH,4
jg setDown
jl setUp
mov AL,floors
and AL,00010111B
mov floors,AL
je setHere
fifthFloorChe:
mov AH,position
cmp AH,5
jg setDown
mov AL,floors
and AL,00001111B
mov floors,AL
je setHere
jmp endCheckFloor
setUp:
mov AH,1
mov direction,AH
jmp endCheckFloor
setDown:
mov AH,0
mov direction,AH
jmp endCheckFloor
setHere:
mov AH,2
mov direction,AH
mov AH,9
mov DX,offset mess1
int 21H
mov DL,position
ADD DL,30
mov AH,2
int 21H
mov DX,0dH
int 21H
mov DX,0AH
int 21H

jmp endCheckFloor
endCheckFloor:
mov DL,position
add DL,48
mov AH,2
int 21H
mov DX,0dH
int 21H
mov DX,0AH
int 21H
pop DX
pop AX
ret

checkCalls:
push AX
push BX
push CX
push DX
mov AH,position
call parseCall
cmp AH,AL
jl up
cmp AH,AL
jg down
cmp AH,AL
je here

up:
mov SI,offset direction
mov AL,01H
mov [SI],AL
jmp endDir
down:
mov SI,offset direction
mov AL,00H
mov [SI],AL
jmp endDir
here:
mov SI,offset direction
mov AL,02H
mov [SI],AL
endDir:
pop DX
pop CX
pop BX
pop AX
ret

parseCall:
mov AL,calls
and AL,00000001B
cmp AL,00000001B
JE first
mov AL,calls
and AL,00000110B
cmp AL,00000010B
JE second
cmp AL,00000100B
je second
mov AL,calls
and AL,00011000B
cmp AL,00001000B
JE third
cmp AL,00010000B
JE third
mov AL,calls
and AL,01100000B
cmp AL,00100000B
je fourth
cmp AL,01000000B
je fourth
mov AL,calls
and AL,10000000B
cmp AL,10000000B
je fifth
first:
mov AL,01H
jmp endParseCall
second:
mov AL,02H
jmp endParseCall
third:
mov AL,03H
jmp endParseCall
fourth:
mov AL,04H
jmp endParseCall
fifth:
mov AL,05H
endParseCall:
ret

delay1sec:
push AX
push BX
push CX
push DX
mov BX,0F803H
mov CX,001EH
waste:
NOP
dec BX
jne waste
mov BX,0F803H
dec CX
loop waste
pop DX
pop CX
pop BX
pop AX
ret

displayPosition:
push AX
push BX
push CX
push DX
mov SI,offset position
mov AL,[SI]
cmp AL,01H
je firstFloor
cmp AL,02H
je secondFloor
cmp AL,03H
je thirdFloor
cmp AL,04H
je fourthFloor
cmp AL,05H
je fifthFloor

firstFloor:
mov AL,output2
and AL,11101101B
mov output2,AL
mov DX,142H
out DX,AL
mov AL,output1
AND AL,10110110B
OR AL,01H
mov output1,AL
mov DX,141H
out DX,AL
jmp endDisp
secondFloor:
mov AL,output2
and AL,11101101B
mov output2,AL
mov DX,142H
out DX,AL
mov AL,output1
AND AL,10110110B
OR AL,08H
mov output1,AL
mov DX,141H
out DX,AL
jmp endDisp
thirdFloor:
mov AL,output2
and AL,11101101B
mov output2,AL
mov DX,142H
out DX,AL
mov AL,output1
AND AL,10110110B
OR AL,01000000B
mov output1,AL
mov DX,141H
out DX,AL
jmp endDisp
fourthFloor:
mov AL,output1
and AL,10110110B
mov output1,AL
mov DX,141H
out DX,AL
mov AL,output2
and AL,11101101B
OR AL,02H
mov output2,AL
mov DX,142H
out DX,AL
jmp endDisp
fifthFloor:
mov AL,output1
and AL,10110110B
mov output1,AL
mov DX,141H
out DX,AL
mov AL,output2
and AL,11101101B
OR AL,10H
mov output2,AL
mov DX,142H
out DX,AL
jmp endDisp
endDisp:
pop DX
pop CX
pop BX
pop AX
ret

displayCall:
push AX
push BX
push CX
push DX
mov AL,input
not AL
cmp AL,00000001B
je upFirst
cmp AL,00000100B
je upSecond
cmp AL,00000010B
je downSecond
cmp AL,00010000B
je upThird
cmp AL,00001000B
je downThird
cmp AL,01000000B
je upFourth
cmp AL,00100000B
je downFourth
cmp AL,10000000B
je downFifth
jmp endDispCall

upFirst:
mov SI,offset output1
mov AL,[SI]
or AL,00000010B
mov DX,141H
out DX,AL
jmp endDispCall
upSecond:
mov SI,offset output1
mov AL,[SI]
or AL,00010000B
mov DX,141H
out DX,AL
jmp endDispCall
downSecond:
mov SI,offset output1
mov AL,[SI]
or AL,00000100B
mov DX,141H
out DX,AL
jmp endDispCall
upThird:
mov SI,offset output1
mov AL,[SI]
or AL,10000000B
mov DX,141H
out DX,AL
jmp endDispCall
downThird:
mov SI,offset output1
mov AL,[SI]
or AL,00100000B
mov DX,141H
out DX,AL
jmp endDispCall
upFourth:
mov SI,offset output2
mov AL,[SI]
or AL,00000100B
mov DX,142H
out DX,AL
jmp endDispCall
downFourth:
mov SI,offset output2
mov AL,[SI]
or AL,00000001B
mov DX,142H
out DX,AL
jmp endDispCall
downFifth:
mov SI,offset output2
mov AL,[SI]
or AL,00001000B
mov DX,142H
out DX,AL
endDispCall:
mov [SI],AL
pop DX
pop CX
pop BX
pop AX
ret

resetCall:
push AX
push BX
push CX
push DX
mov AH,9
mov DX,offset resCall
int 21H
mov AH,2
mov DX,0dH
int 21H
mov DX,0AH
int 21H
mov AL,position
cmp AL,01H
jmp FirstFloorUp
cmp AL,02H
jmp SecondFloor1
cmp AL,03H
jmp ThirdFloor1
cmp AL,04H
jmp FourthFloor1
cmp AL,05H
jmp FifthFloorDown
SecondFloor1:
mov AH,calls
and AH,00000110B
mov AL,00000010B
cmp AL,AH
je SecondFloorDown
mov AL,00000100B
cmp AL,AH
je SecondFloorUp
ThirdFloor1:
mov AH,calls
and AH,00011000B
mov AL,00001000B
cmp AL,AH
je ThirdFloorDown
mov AL,00010000B
je ThirdFloorUp
FourthFloor1:
mov AH,calls
mov AL,01100000B
mov AL,00100000B
cmp AL,AH
je FourthFloorDown
mov AL,01000000B
je FourthFloorUp
FirstFloorUp:
mov AL,calls
and AL,11111110B
mov calls,AL
mov SI,offset direction
mov AH,01H
mov [SI],AH
jmp endResetCall
SecondFloorUp:
mov AL,calls
and AL,11111001B
mov calls,AL
mov SI,offset direction
mov AH,01H
mov [SI],AH
jmp endResetCall
SecondFloorDown:
mov AL,calls
and AL,11111001B
mov calls,AL
mov SI,offset direction
mov AH,00H
mov [SI],AH
jmp endResetCall
ThirdFloorUp:
mov AL,calls
and AL,11100111B
mov calls,AL
mov SI,offset direction
mov AH,01H
mov [SI],AH
jmp endResetCall
ThirdFloorDown:
mov AL,calls
and AL,11100111B
mov calls,AL
mov SI,offset direction
mov AH,00H
mov [SI],AH
jmp endResetCall
FourthFloorUp:
mov AL,calls
and AL,10011111B
mov calls,AL
mov SI,offset direction
mov AH,01H
mov [SI],AH
jmp endResetCall
FourthFloorDown:
mov AL,calls
and AL,10011111B
mov calls,AL
mov SI,offset direction
mov AH,00H
mov [SI],AH
jmp endResetCall
FifthFloorDown:
mov AL,calls
and AL,01111111B
mov calls,AL
mov SI,offset direction
mov AH,00H
mov [SI],AH
endResetCall:
call displayCall
mov AH,9
mov DX,offset resCall
int 21H
mov AH,2
mov DX,0dH
int 21H
mov DX,0AH
int 21H
pop DX
pop CX
pop BX
pop AX
ret
;This is where your code ends
code ends
end begin