; HardRank (C)Group246 �p
; ���C�����[�`�� (for NASM)

%include 'hoot.inc'

		ORG	0x0000
		USE16
		CPU	186

OPNSEG		EQU	0x2000			; �h���C�o�Z�O�����g

start:
		cli
		cld
		mov	dx,HOOTFUNC
		mov	al,HF_DISABLE		; ����������hoot�Ăяo�����֎~
		out	dx,al

		xor	ax,ax
		mov	ss,ax
		mov	sp,0x1000
		mov	ax,cs
		mov	ds,ax
		mov	es,ax

		; hoot �h���C�o�o�^
		xor	ax,ax
		mov	ds,ax
		mov	word [0x7f*4+0],hf_entry
		mov	[0x7f*4+2],cs

		; dummy int 40h
		mov	word [0x40*4+0], dummy
		mov	[0x40*4+2],cs

		mov	dx,HOOTFUNC
		mov	al,HF_ENABLE		; hoot�Ăяo��������
		out	dx,al
		sti

mainloop:
		mov	ax,0x9801
		int	0x18
		jmp	short mainloop

; hoot����R�[�������
; inp8(HOOTPORT) = 0 �� PC98VX::Play  ���[�h�O
; inp8(HOOTPORT) = 1 �� PC98VX::Play  ���[�h��
; inp8(HOOTPORT) = 2 �� PC98VX::Stop
; _code = inp8(HOOTPORT+2)�`inp8(HOOTPORT+5)

hf_entry:
		pusha
		push	ds
		push	es
		mov	ax,cs
		mov	ds,ax
		mov	es,ax
		mov	dx,HOOTPORT
		in	al,dx
		cmp	al,HP_PLAY
		jz	short .play
		cmp	al,HP_LOADPLAY
		jz	short .play2
		cmp	al,HP_STOP
		jz	short .stop
.ed:
		pop	es
		pop	ds
		popa
		iret

.play:
		pushf
		call	word OPNSEG:0x0002	; Stop

		mov	dx,HOOTPORT+2
		in	al,dx
		out	dx,al

		jmp	short .ed

.play2:
		pushf
		call	word OPNSEG:0x0000	; Requst
		jmp	short .ed

.stop:
		mov	ax, 0x2000
		mov	es, ax
		mov	al, 0x06
		mov	[es:0x0A24],al
		jmp	short .ed

dummy:
		mov	dx,0x0100
		iret

;		.ends

