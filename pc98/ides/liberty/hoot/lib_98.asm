; Liberty (C)Cocktail Soft �p
; ���C�����[�`�� (for NASM)

%include 'hoot.inc'

		ORG	0x0000
		USE16
		CPU	186

OPNSEG		EQU	0x1ed6		; �I�[�v�j���O�p�Z�O�����g

start:		cli
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

		mov	dx,HOOTFUNC		; hoot�Ăяo��������
		mov	al,HF_ENABLE
		out	dx,al
		sti

mainloop:	mov	ax,0x9801
		int	0x18
		jmp	short mainloop

; hoot����R�[�������
; inp8(HOOTPORT) = 0 �� PC98VX::Play  ���[�h�O
; inp8(HOOTPORT) = 1 �� PC98VX::Play  ���[�h��
; inp8(HOOTPORT) = 2 �� PC98VX::Stop
; _code = inp8(HOOTPORT+2)�`inp8(HOOTPORT+5)

hf_entry:	push	ds
		push	es
		pusha
		mov	ax,cs
		mov	ds,ax
		mov	es,ax
		mov	dx,HOOTPORT
		in	al,dx
		cmp	al,HP_PLAY
		jz	short .play
		cmp	al,HP_STOP
		jz	short .stop
.ed:		popa
		pop	es
		pop	ds
		iret

.check:
		mov	dx,HOOTPORT+3		; �I�[�v�j���O/�G���f�B���O�w��̔���
		in	al,dx
		cmp	al,1
		ret

.play:	
		call	.check
		jz	.seplay

		mov	dx,HOOTPORT+2
		in	al,dx
		call	word OPNSEG:0x0086	; Request
		jmp	short .ed

.seplay:
		mov	dx,HOOTPORT+2
		in	al,dx
		call	word OPNSEG:0x029a	; S.E.
		jmp	short .ed

.stop:
		call	word OPNSEG:0x017c	; �t�F�[�h�A�E�g
		jmp	short .ed

		ends

