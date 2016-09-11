; emd.com ���t
; ���C�����[�`�� (for pc98dos)

%include 'hoot.inc'
int_hoot	equ	0x07f
int_emd		equ	0x0d2

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

		mov	ah,0x00			; ������
		int	int_emd

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
		jz	short .fadeout
.ed:		pop	es
		pop	dx
		popa
		iret

.play:
		mov	ah,0x04			; ���t��~
		mov	cx,0xffff
		int	int_emd

		mov	dx,filename
		mov	cx,0xffff
		mov	ah,0x3f			; [DOS] �t�@�C������̓ǂݎ��
		xor	bx,bx			; �W�����͂���
		int	0x21			; �Ȗ����[�h
		jc	.stop
		mov	bx,ax
		mov	[filename+bx], byte 0


		mov	ah,0x01			; �f�[�^���[�h(ds:dx)
		int	int_emd
		cmp	al,00
		jnz	.ed

		mov	ah,0x03			; ���t�J�n
		mov	cx,0xffff
		int	int_emd

		jmp	short .ed

.stop:
		mov	ah,0x04			; ���t��~
		mov	cx,0xffff
		int	int_emd
		jmp	short .ed

.fadeout:
		mov	ah,0x04			; �t�F�[�h�A�E�g
		mov	ch,0x3f			; �t�F�[�h����
		mov	cl,0xff			; �t�F�[�h�`�����l��
		int	int_emd

		jmp	short .ed

filename:
		; �t�@�C�����i�[�p�o�b�t�@
		times 0x10 db 0x00

		ends

