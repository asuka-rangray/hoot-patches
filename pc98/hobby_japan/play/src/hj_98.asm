; HOBBY JAPAN - PLAY.EXE ���t
; ���C�����[�`�� (for pc98dos)
;
;

%include 'hoot.inc'
int_hoot	equ	0x7f
int_driver	equ	0xd2

		ORG	0x0100
		USE16
		CPU	186

start:
		cli
		mov	ax, cs
		mov	ds, ax
		mov	es, ax

		mov	dx, HOOTFUNC
		mov	al, HF_DISABLE		; ����������hoot�Ăяo�����֎~
		out	dx, al

		mov	ax, cs			; �X�^�b�N�ݒ�
		mov	ss, ax
		mov	sp, stack

		mov	bx, prgend
		add	bx, 0x0f
		shr	bx, 4
		mov	ah, 0x4a		; AH=4a modify alloc memory(ES:BX)
		int	0x21

		mov	ah,0x48			; [DOS] ���[�h�o�b�t�@�̊��蓖��
		mov	bx,0x400
		int	0x21
		mov	[bufseg],ax

		mov	ah, 0x25		; hoot�h���C�o�o�^
		mov	al, int_hoot
		mov	dx, vect_hoot
		int	0x21

		mov	dx, HOOTFUNC
		mov	al, HF_ENABLE		; hoot�Ăяo��������
		out	dx, al
		sti

mainloop:
		mov	ax, 0x9801		; �_�~�[�|�[�����O
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
		mov	ax, cs
		mov	ds, ax
		mov	es, ax
		mov	dx, HOOTPORT
		in	al, dx
		cmp	al, HP_PLAY
		jz	short .play
		cmp	al, HP_STOP
		jz	short .fadeout
.ed:
		pop	es
		pop	ds
		popa
		iret

.stop:
.fadeout:
		mov	ax, 0x0200		; ���t��~
		int	int_driver
		jmp	short .ed

.play:
		mov	ax, 0x0200		; ���t��~
		int	int_driver

		push	es
		mov	ax, 0x2000
		mov	cx, 0x4000
		mov	bx, [bufseg]
		mov	es, bx
		xor	bx, bx
		int	int_driver
		pop	es

		push	ds
		mov	ah, 0x3f		; AH=3F file name read
		xor	bx, bx
		mov	cx, 0xffff
		mov	dx, filename
		int	0x21
		pop	ds
		jc	.ed
		mov	bx,ax
		mov	[filename+bx], byte 0

		mov	ah, 0x27
		mov	al, 0x00
		xor	cx, cx
		mov	bx, cs
		mov	es, bx
		mov	bx, filename
		int	int_driver

		cmp	al,0x01
		jnz	.ed

		mov	ah,0x09
		mov	dx,msg_err
		int	0x21
		jmp	.ed

filename:
		; �t�@�C�����i�[�p�o�b�t�@
		times 0x10 db 0x00
		db	'$'

bufseg:
		dw	0x0000			; �o�b�t�@�Z�O�����g

msg_err:
		db	'play err!!',0x0A,0x0D,'$'

		align	0x10
		times 0x100 db 0xff		; �X�^�b�N�G���A
stack:

prgend:
		ends

