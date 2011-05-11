org 100h
JMP debut

include "nbalea.asm"
include "motaleatoire.asm"
include "affipendu.asm" 





string_size db 0
perdu db 0        
gagne db 0         
lettre db 0
pp db 1
lettres db  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0} 
temp dw 0
temp2 dw 0
string db "          $"
            
handle dw ?

dico1 db "dico1.txt", 0
dico2 db "dico2.txt", 0
dico3 db "dico3.txt", 0
dico4 db "dico4.txt", 0
dico5 db "dico5.txt", 0
dico6 db "dico6.txt", 0
dico7 db "dico7.txt", 0
dico8 db "dico8.txt", 0
dico9 db "dico9.txt", 0
dico10 db "dico10.txt", 0

t2 db 100 dup(' ')
mot db 20 dup(' ') 
nombrealea db ?
modulo EQU 10                   
                      
;m1:                    
;string db 'bonjour'     
;string_size = $ - m1     
;  db 0Dh,0Ah,'$'

 
 
 
;affichage un caractere (DL) a la position BX
affi PROC                 
MOV AX, 0B800h               
MOV DS, AX                    
mov [BX], DL                   
MOV AX, 0700h                   
MOV DS, AX                      
ret                               
affi ENDP   

 
 
;affichage des caracteres qui ne sont pas dans le mot 
affi_lettre_perdu PROC
mov AX, temp     
mov temp2, BX

MOV BX, 0
MOV BL, perdu
ADD BX, BX
ADD BX, 1F4h
MOV DL, AL
CALL affi
MOV BX, temp2
MOV temp, AX                     

ret                                          
affi_lettre_perdu ENDP








debut:
CALL nbalea
mov nombrealea, DL
CALL nbalea
CALL motalea 

MOV AX, 0600h
MOV CX, 100h
DIV CX
mov cx, 0
MOV CL, string_size
MOV BX, 04h
MOV DL, '_'

;boucle affichage des _
boucle_affi:
CALL affi
INC BX
INC BX
LOOP boucle_affi
                    
                    
;boucle du jeu                    
boucle:
    JMP entrerchar
    rejout:
    
    entrerchar:
    mov AH, 0h                   ;on rentre un charactere
    int 16h
    PUSH AX
    
    POP AX
    MOV BX, 0
                                 ;on verifie qu il n'est pas deja jouer
    LEA SI, lettres
    mov BL, AL
    SUB BL, 61h
    ADD SI, BX
    CMP [SI], 1
    JE rejout                    ;on rejoue si le char a deja ete jouer
    MOV [SI], 1                  ;sinon on continue et on dit que le char est jouer
    
    
    
    LEA SI, string
    MOV temp, AX
          
    mov CX, 0    
    MOV CL, string_size                                           
    MOV lettre, 0
    
    ;boucle pour verifier si char est donc le mot
    boucle2:
         MOV AX, temp
         MOV AH, [SI]            ;[SI] est l'emplacement d une lettre du mot a trouver
         CMP AH, AL              ;AL est le char jouer
         MOV temp, AX
         JE egual
         JMP nonegual
         
              
                                 
         egual:                  ;si le char jouer est le char que l on verifie
         MOV lettre, 1           ;on dit qu il est dans le mot
         INC gagne               ;on dit que l on a trouver un char de plus
         mov AX, 0
         MOV AL, string_size
         ADD AX, 3
         SUB AX, CX
         ADD AX, AX
         SUB AX, 2
         MOV BX, AX
         MOV DL, [SI]
         CALL affi               ;on affiche le char au bon endroit
         
         MOV AL, gagne
         MOV AH, string_size
         CMP AL, AH  ;si le nb char trouver est egual au nb de char du mot on a gagner
         JE gagner
         
         
         JMP finverif
         
         nonegual:               ;si le char n est pas a l emplacement 
         CMP lettre, 1           ;on verifie s il est deja a un autre emplacement
         JE finverif
         CMP CX, 1               ;on verifie si c est le dernier emplacement du mot
         JNE finverif            
         INC perdu               ;si le char n est pas dans le mot on dit que l'on a perdu un point
         CALL affi_perdu         ;on affiche le pendu
         CALL affi_lettre_perdu  ;on affiche la lettre qui n est pas dans le mot
         
         CMP pp, 0               ;on verifie si on a perdu
         JE perd                 ;si on a perdu on arrete
         JMP finverif
         
         finverif:
         
         INC SI
         
    LOOP boucle2                 
    
   
JMP boucle 
JMP perd
 
gagner:
mov ah, 9
mov dx, offset msg1
int 21h
JMP fin

perd:
mov ah, 9
mov dx, offset msg2
int 21h
JMP fin 
 
 
fin:
mov AH, 0h                  
int 16h

ret 


msg1 db " BRAVO tu as gagne!!!$"
msg2 db " Tu es un loser!!!$"   
