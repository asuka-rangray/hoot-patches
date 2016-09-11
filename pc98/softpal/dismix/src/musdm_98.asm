; music.com(DISMIX)���t
; ���C�����[�`�� (for pc98dos)

%include 'hoot.inc'
int_hoot	equ	0x07f
int_drv		equ	0x040

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
		mov	bx,0x100		; �p���O���t�T�C�Y(64K)
		int	0x21
		mov	[loadseg],ax

		mov	ax,0x257f		; hoot�h���C�o�o�^
		mov	dx,vect_hoot
		int	0x21

		mov	ax,[cs:loadseg]
		mov	ds,ax
		xor	dx,dx
		mov	cx,0x400
		mov	ah,0x3f			; [DOS] �t�@�C������̓ǂݎ��
		mov	bx,0x08			; 8�ԌŒ�
		int	0x21			; ���f�[�^���[�h
		jc	.enable_hoot

		mov	ds,ax
		mov	bx,ds
		xor	cx,cx
		mov	al,0x07			; �����[�h(bx:cx)
		int	int_drv

.enable_hoot:
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
		jz	short .stop
.ed:
		pop	es
		pop	dx
		popa
		iret

.stop:
		mov	al,0x02			; ���t��~
		int	int_drv
		jmp	.ed

.play:
		mov	al,0x02			; ���t��~
		int	int_drv

		mov	ax,[cs:loadseg]
		mov	ds,ax
		mov	dx,0x400
		mov	cx,0x2000
		mov	ah,0x3f			; [DOS] �t�@�C������̓ǂݎ��
		xor	bx,bx			; �W�����͂���
		int	0x21			; �ȃf�[�^���[�h
		jc	.ed

		mov	bx,dx
		cmp	byte [ds:bx],0x08	; ���F�t���f�[�^?
		jnz	.tone_load

		mov	bx,ds
		mov	cx,dx

		add	cx,0x50
		mov	al,0x05			; ���F���[�h(bx:cx)
		int	int_drv

		add	cx,0x750
.play_start:
		mov	al,0x00			; ���[�h(bx:cx)
		int	int_drv

		mov	al,0x01			; ���t�J�n
		int	int_drv

		jmp	short .ed

.tone_load
		mov	ax,[cs:loadseg]
		mov	ds,ax
		mov	dx,0x2400
		mov	cx,0x800
		mov	ah,0x3f			; [DOS] �t�@�C������̓ǂݎ��
		mov	bx,0x09			; 9�ԌŒ�
		int	0x21			; �ȃf�[�^���[�h
		jc	.tone_err

		mov	bx,ds
		mov	cx,dx
		mov	al,0x05			; ���F���[�h(bx:cx)
		int	int_drv
		jmp	.tone_ok

.tone_err:
		mov	bx,ds

.tone_ok:
		mov	cx,0x400
		jmp	.play_start

loadseg:	dw	0			; ���[�h�Z�O�����g

		align	0x10
		times 0x100 db 0xff		; �X�^�b�N�G���A

stack:

prgend:
		ends

