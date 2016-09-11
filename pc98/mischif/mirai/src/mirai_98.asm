; MIRAI  Version 1.02 for PC-9801/9821
; hoot���t���[�`�� (for pc98dos)

%include 'hoot.inc'
int_hoot	equ	0x7f
int_driver	equ	0x60

		ORG	0x0100
		USE16
		CPU	186

start:
		cli
		mov	ax,cs
		mov	ds,ax
		mov	es,ax

		mov	dx,HOOTFUNC
		mov	al,HF_DISABLE		; ����������hoot�Ăяo�����֎~
		out	dx,al

		mov	bx,prgend
		add	bx,0x0f
		shr	bx,4
		mov	ah,0x4a			; [DOS] �������u���b�N�̏k��(ES:BX)
		int	0x21

		mov	ah,0x00
		int	int_driver
		mov	[loadseg],es
		mov	[loadofs],di

		mov	ax,0x257f		; hoot�h���C�o�o�^
		mov	dx,vect_hoot
		int	0x21

		mov	dx,HOOTFUNC
		mov	al,HF_ENABLE		; hoot�Ăяo��������
		out	dx,al
		sti

mainloop:
		mov	ax,0x9801		; �_�~�[�|�[�����O
		int	0x18
		jmp	short mainloop

; hoot����R�[�������
; inp8(HOOTPORT) = 0 �� PC98DOS::Play
; inp8(HOOTPORT) = 2 �� PC98DOS::Stop
; _code = inp8(HOOTPORT+2)�`inp8(HOOTPORT+5)

vect_hoot:
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
		cmp	al,HP_STOP
		jz	.fadeout
.ed:
		pop	es
		pop	ds
		popa
		iret

.fadeout:
		mov	ah,0x02			; �t�F�[�h�A�E�g
		int	int_driver
		jmp	.ed

.play:
		mov	ax,[loadseg]
		mov	ds,ax
		mov	ax,[cs:loadofs]
		mov	dx,ax
		mov	cx,-1
		mov	ah,0x3f			; [DOS] �t�@�C������̓ǂݎ��
		xor	bx,bx			; �W�����͂���
		int	0x21			; �ȃf�[�^���[�h
		jc	.ed

		mov	ah,0x01			; ���t�J�n
		int	int_driver

		jmp	.ed

loadseg:	dw	0x0			; ���[�h�Z�O�����g
loadofs:	dw	0x0			; ���[�h�I�t�Z�b�g

prgend:
		ends

