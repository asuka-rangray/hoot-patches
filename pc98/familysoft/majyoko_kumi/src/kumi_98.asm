; �������q�N�~ �p
; ���C�����[�`�� (for NASM)

%include 'hoot.inc'

		ORG	0x0000
		USE16
		CPU	186

DRIVERSEG	equ	0x1000			; �h���C�o�z�u�Z�O�����g

start:
		cli
		cld
		mov	dx,HOOTFUNC
		mov	al,HF_DISABLE		; ����������hoot�Ăяo�����֎~
		out	dx,al

		mov	ax,0x6000		; �K���ɃX�^�b�N�G���A���m��
		mov	ss,ax
		mov	sp,0x1000

		xor	ax,ax
		mov	ds,ax

		; int 40h �t�b�N
		mov	word [0x40*4+0],0x0000
		mov	word [0x40*4+2],DRIVERSEG

		; hoot �h���C�o�o�^
		mov	word [0x7f*4+0],hf_entry
		mov	[0x7f*4+2],cs

		mov	dx,HOOTFUNC		; hoot�Ăяo��������
		mov	al,HF_ENABLE
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
		push	ds
		push	es
		pusha
		mov	ax,cs
		mov	ds,ax
		mov	es,ax
		mov	dx,HOOTPORT
		in	al,dx
		cmp	al,HP_PLAY
		jz	short .check
		cmp	al,HP_LOADPLAY
		jz	short .play
		cmp	al,HP_STOP
;		jz	short .fadeout
		jz	short .stop
.ed:		popa
		pop	es
		pop	ds
		iret

.check:
		mov	dx,HOOTPORT+2
		in	al,dx
		mov	ah,al
;		mov	ah, 0x0d
		int	0x40
		jmp	short .ed

.stop:
;		mov	ah, 0x0d
		mov	ah, 0x00
		int	0x40
		jmp	short .ed

.play:
		jmp	short .ed

		ends

