; �������L�����p�X�ԗ��� (C)ComputerBrain �p
; ���C�����[�`�� (for NASM)

%include 'hoot.inc'

		ORG	0x0000
		USE16
		CPU	186

OPNSEG		EQU	0x8000			; �h���C�o�Z�O�����g

start:
		cli
		cld
		mov	dx,HOOTFUNC
		mov	al,HF_DISABLE		; ����������hoot�Ăяo�����֎~
		out	dx,al

		xor	ax,ax
		mov	ss,ax
		mov	sp,0x4000
		mov	ax,cs
		mov	ds,ax
		mov	es,ax

		mov	di, apitbl
		mov	[di+02], cs
		mov	[di+06], cs

		; hoot �h���C�o�o�^
		xor	ax,ax
		mov	ds,ax
		mov	word [0x7f*4+0],hf_entry
		mov	[0x7f*4+2],cs

		pushf
		call	word OPNSEG:0x0000	; Initialize

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
;		pusha
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
;		popa
		iret

.play:
;		pushf
;		call	word OPNSEG:0x0006	; Stop

		xor	ax,ax
		mov	dx,HOOTPORT+2
		in	al,dx
;		out	dx,al

		shl	ax, 2
		mov	di, sndtbl
		add	di, ax

		mov	bx, apitbl
		mov	[bx+00], di
		add	di,2
		mov	[bx+04], di

		pushf
		call	word OPNSEG:0x0003	; Requst
		jmp	short .ed

.play2:
		jmp	short .ed

.stop:
		pushf
		call	word OPNSEG:0x0006	; Stop
		jmp	short .ed

apitbl:
		dw	0000			; ofs - tempo
		dw	0000			; seg - tempo
		dw	0000			; ofs - code no
		dw	0000			; seg - code no

sndtbl:
		dw	0x00e4
		dw	0x0000
		dw	0x00e4
		dw	0x0001
		dw	0x00e4
		dw	0x0002
		dw	0x00e4
		dw	0x0003
		dw	0x00e4
		dw	0x0004
		dw	0x00e4
		dw	0x0005
		dw	0x00e4
		dw	0x0006
		dw	0x00e4
		dw	0x0007

		.ends

