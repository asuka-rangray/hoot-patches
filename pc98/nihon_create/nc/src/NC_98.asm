; ���{�N���G�C�g NC.COM ���t(3x3eyes/Diadrum)
; ���C�����[�`�� (for pc98dos)

%include 'hoot.inc'
int_hoot	equ	0x07f
int_driver	equ	0x042

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

		mov	ax,0x257f		; hoot�h���C�o�o�^
		mov	dx,vect_hoot
		int	0x21

		mov	dx,HOOTFUNC
		mov	al,HF_ENABLE		; hoot�Ăяo��������
		out	dx,al
		sti

mainloop:	mov	ax,0x9801		; �_�~�[�|�[�����O
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
.ed:
		pop	es
		pop	ds
		popa
		iret

.play:
		mov	dx,HOOTPORT+2	; �Ȕԍ��w���ǂݍ���
		in	al,dx

		cmp	al,0xfe		; �Ȕԍ���0xfe�̏ꍇ�͋Ȃ����̃X�e�[�W��
		jz	.loopend

		mov	ah,0x05		; ���t��~
		int	int_driver

		mov	dx,filename
		mov	cx,0xffff
		mov	ah,0x3f		; read hundle
		xor	bx,bx		; �W�����͂���
		int	0x21		; �ȃf�[�^���[�h
		jc	.stop
		mov	bx,ax
		mov	[filename+bx], byte 0

		xor	si,dx
		mov	ax,0x00		; �f�[�^���[�h(ds:si)
		int	int_driver
		jmp	short .ed

.stop:
		mov	ax,0x05		; ���t��~
		int	int_driver
		jmp	short .ed

.fadeout:
		mov	ax,0x01		; �t�F�[�h�A�E�g
		mov	bx,0x3
		int	int_driver

		jmp	short .ed

.loopend:
		mov	ax, 0x03
		int	int_driver

		jmp	short .ed

filename:
		times 0x10 db 0x00	; �t�@�C�����i�[�p�o�b�t�@

		ends

