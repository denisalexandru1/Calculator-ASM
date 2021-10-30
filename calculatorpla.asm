.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern printf: proc
extern gets: proc
extern scanf: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
s db 100 dup(0)
;s db "7+4*3=", 13, 0
v dd 50 dup(0)
op dd 50 dup(48)
contoor dd 0
val dd 100
cont dd 0
format db "%d", 13, 10, 0
formatc db "%c", 13, 10, 0
formats db "%s", 13, 10, 0
mesajexp db "Introduceti o expresie, fara spatii intre operanzi si operatori:",13, 10 
vectgoldb db 100 dup(0)
vectgoldd dd 50 dup(0)

.code

adunare proc
	push ebp
	mov ebp, esp
	sub esp, 8
	mov ebx, [ebp+8]		;al doilea termen trimis
	mov eax, [ebp+12]		;primul termen trimis
	add eax, ebx
	mov esp, ebp
	pop ebp
	ret 8
adunare endp

scadere proc
	push ebp
	mov ebp, esp
	sub esp, 8
	mov ebx, [ebp+8]   	;al doilea termen trimis
	mov eax, [ebp+12]		;primul termen trimis
	sub eax, ebx 			
	mov esp, ebp
	pop ebp
	ret 8
scadere endp

inmultire proc
	push ebp
	mov ebp, esp
	sub esp, 8
	mov ebx, [ebp+8]		;al doilea termen trimis
	mov edx, 0
	mov eax, [ebp+12]		;primul termen trimis
	imul ebx
	mov esp, ebp
	pop ebp
	ret 8
inmultire endp

impartire proc
	push ebp
	mov ebp, esp
	sub esp, 8
	mov ebx, [ebp+8]		;al doilea termen trimis
	mov eax, [ebp+12]		;primul termen trimis
	mov edx, 0
	div ebx
	mov esp, ebp
	pop ebp
	ret 8
impartire endp

write_int macro format, nr1
	push nr1
	push offset format
	call printf
	add esp, 8
endm

cerereExp macro  ;macro pentru afisarea mesajului de introducere a expresiei
	push offset mesajexp
	call printf   ;mesaj de introducere
	add esp, 4
endm	

	
shift_l macro v, op, ind
local BUCLA, END_BUCLA, addition, substraction, division, multiplication, next
	push edi
	mov edi, ind
	
	
	;o sa apelam functia
	
	xor eax, eax
	
	cmp op[edi*4], '+'
	je addition
	cmp op[edi*4], '-'
	je substraction
	cmp op[edi*4], '*'
	je multiplication
	cmp op[edi*4], '/'
	je division
	
	addition:
	push v[edi*4]
	push v[edi*4+4]
	call adunare
	jmp next
	
	substraction:
	push v[edi*4]
	push v[edi*4+4]
	call scadere
	jmp next
	
	multiplication:
	push v[edi*4]
	push v[edi*4+4]
	call inmultire
	jmp next
	
	division:
	push v[edi*4]
	push v[edi*4+4]
	call impartire
	jmp next
	
	next:
	mov v[edi*4], eax
	mov eax, op[edi*4+4]
	mov op[edi*4], eax
	inc edi
	
	BUCLA:
		cmp op[edi*4], 48
		je END_BUCLA
		
		mov eax, op[edi*4+4]
		mov op[edi*4], eax
		mov eax, v[edi*4+4]
		mov v[edi*4], eax
		
		inc edi	
		jmp BUCLA		
	END_BUCLA:
	pop edi

endm

start:
	
	mov esi, 0
	mov edi, 0
	
	xor eax, eax
	
	introd_exp:
	
	cerereExp
	; mov ecx, 100				;incercare de golire a vectorilor
	; mov esi, 0
	
	; golire_vect:
	; mov s[esi], 0
	; mov v[4*esi], 0
	; mov op[4*esi], 0
	; loop golire_vect
	
	
	push offset s
	call gets   ;introducem expresia sub forma de string
	add esp, 4 
	
	
	xor eax, eax
	
	GET_CHARACTER:
	
		cmp s[esi], '='
		je NUMAR_NEGASIT
		
		cmp s[esi], '0'   	;verificam daca am introdus un numar
		jge NUMAR_POS
		
		jmp NUMAR_NEGASIT
		
		NUMAR_POS:			;este vorba de un numar daca el se afla intre 0 si 9
			cmp s[esi], '9'
			jle NUMAR_GASIT
			
		jmp NUMAR_NEGASIT
		
		NUMAR_GASIT: 			
			imul eax, eax, 10	;pentru numere de mai multe cifre
			add al, s[esi]
			sub eax, 48
			
			inc esi
			jmp GET_CHARACTER
			
		NUMAR_NEGASIT:			;in cazul in care am dat de un semn, plasam in V numarul citit pana la acest semn
			push ecx
			push esi
			
			mov esi, contoor
			
			mov v[4*esi], eax
			xor eax, eax
			
			inc esi
			mov contoor, esi
			
			;pana aici am pus in V
			
			pop esi				
			
			mov edi, cont		;punem semnul in vectorul de semne
			
			cmp s[esi], '+'
			je PLUS
			
			cmp s[esi], '-'
			je MINUS
			
			cmp s[esi], '*'
			je ORI
			
			cmp s[esi], '/'
			je SLASH
			
			jmp EGAL			;in cazul in care nu este vorba de niciun operator, inseamna ca am ajuns la finalul sirului
			
			PLUS:
				mov eax, '+'
				mov op[edi*4], eax 
				inc edi
				jmp EGAL
			
			MINUS:
				mov eax, '-'
				mov op[edi*4], eax 
				inc edi
				jmp EGAL
			
			ORI:
				mov eax, '*'
				mov op[edi*4], eax 
				inc edi
				jmp EGAL
			
			SLASH:
				mov eax, '/'
				mov op[edi*4], eax 
				inc edi
				jmp EGAL
			
			EGAL:		
			mov cont, edi
			
			pop ecx
			
			cmp s[esi], '='
			je SFARSIT
			
			inc esi
			
			xor eax, eax
			
			jmp GET_CHARACTER
		
			SFARSIT:
		
			write_int format, v[0]
			write_int format, v[4]
			write_int format, v[8]
			write_int format, v[12]
			write_int format, v[16]
			write_int format, v[20]
			write_int formatc, op[0]
			write_int formatc, op[4]
			write_int formatc, op[8]
			write_int formatc, op[12]
			write_int formatc, op[16]
	
	push edi
	xor edi, edi
	
	BUCLA2:	;parcurgem vectorul de operanzi si facem doar operatiile prioritare
		
		cmp op[edi*4], "*"
		je BUCLA_SHIFT
		
		cmp op[edi*4], "/"
		je BUCLA_SHIFT
		
		cmp op[edi*4], 48
		je END_BUCLA2
		
		inc edi
		
		jmp BUCLA2
		
		BUCLA_SHIFT:
			shift_l v, op, edi
			; write_int format, v[0]
			; write_int format, v[4]
			; write_int format, v[8]
			; write_int format, v[12]
			; write_int format, v[16]
			; write_int format, v[20]
			; write_int formatc, op[0]
			; write_int formatc, op[4]
			; write_int formatc, op[8]
			; write_int formatc, op[12]
			; write_int formatc, op[16]
			jmp BUCLA2
	
	END_BUCLA2:
	pop edi
	
	xor edi, edi
	
	BUCLA3:
		cmp op[edi*4], '0'
		je END_BUCLA3
		
		shift_l v, op, edi
		
		jmp BUCLA3
	END_BUCLA3:
	
	pop edi
	
	mov eax, v[0]
	
	write_int format, eax
	; write_int format, v[0]
	; write_int format, v[4]
	; write_int format, v[8]
	; write_int format, v[12]
	; write_int format, v[16]
	; write_int formatc, op[0]
	; write_int formatc, op[4]
	; write_int formatc, op[8]
	; write_int formatc, op[12]
	
	jmp introd_exp
	
	
	push 0
	call exit
end start
