; Humming bird MUSDRV3 ���t
; ���C�����[�`�� (for pc98dos)
; ���[�h�XCD ���F�f�[�^�ύX�Ή���

%include 'hoot.inc'
int_hoot	equ	0x7f
int_drv		equ	0x43

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

		mov	ax,cs			; �X�^�b�N�ݒ�
		mov	ss,ax
		mov	sp,stack

		mov	bx,prgend
		add	bx,0x0f
		shr	bx,4
		mov	ah,0x4a			; [DOS] �������u���b�N�̏k��(ES:BX)
		int	0x21

		mov	ah,0x48			; [DOS] ���[�h�o�b�t�@�̊��蓖��
		mov	bx,0xfff		; �p���O���t�T�C�Y(64K)
		int	0x21
		mov	[loadseg],ax

		mov	ah,0x48			; [DOS] ���[�h�o�b�t�@�̊��蓖��
		mov	bx,0x060		; �p���O���t�T�C�Y(15K)
		int	0x21
		mov	[toneseg],ax

		mov	al,00			; ������
		int	int_drv

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

.ed:
		pop	es
		pop	ds
		popa
		iret

.play:
		mov	al,0x04			; ���t��~
		int	int_drv

		call	toneload

		push	ds
		mov	ax,[cs:loadseg]
		mov	ds,ax
		xor	dx,dx
		mov	cx,0xffff
		mov	ah,0x3f			; read hundle
		xor	bx,bx			; �W�����͂���
		int	0x21			; �ȃf�[�^���[�h
		pop	ds
		jc	.ed

		push	ds
		mov	ax,[cs:loadseg]
		mov	ds,ax
		xor	dx, dx
		mov	al,0x01			; ���t�J�n(ds:dx)
		int	int_drv
		pop	ds
		jmp	short .ed

.stop:
		mov	al,0x04			; ���t��~
		int	int_drv
		jmp	short .ed

.fadeout:
		mov	al,0x02			; ���t��~
		mov	dl,0x0f
		int	int_drv
		jmp	short .ed

toneload:
		mov	dx,HOOTPORT+4		; ���F�n���h���擾
		xor	ah,ah
		in	al,dx
		mov	bx,ax

		mov	ah,0x42			; seek
		mov	al,0			; �擪
		xor	cx,cx
		xor	dx,dx
		int	0x21

		push	ds
		mov	ax,[cs:toneseg]
		mov	ds,ax
		xor	dx,dx
		mov	cx,0xffff
		mov	ah,0x3f			; read hundle

		int	0x21			; ���F���[�h

		xor	dx, dx
		mov	ax, [cs:toneseg]
		mov	ds, ax
		mov	al,0x07			; ���F���[�h
		int	int_drv
		pop	ds
		ret

loadseg:	dw	0			; ���[�h�Z�O�����g
toneseg:	dw	0			; ���F�Z�O�����g

		align	0x10
		times 0x100 db 0xff		; �X�^�b�N�G���A
stack:

prgend:
		ends

