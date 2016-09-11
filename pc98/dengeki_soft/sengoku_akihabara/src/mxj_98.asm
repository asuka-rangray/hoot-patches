; MDRVMXJ.SYS ���t
; ���C�����[�`�� (for pc98dos)
;
; HOOTPORT + 2~3 : �t�@�C���n���h���ԍ�
;

%include 'hoot.inc'
int_hoot	equ	0x7f
int_driver	equ	0x60

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

		mov	ah, 0x48		; AH=48 alloc memory
		mov	bx, 0x1000
		int	0x21
		mov	[bufseg],ax

		mov	ah, 0x00		; initialize
		mov	cl, 0x00
		mov	dx, 0x188
		int	int_driver

		mov	bx, 0x08
		call	load_file
		jc	.init_err

		push	ds
		lds	si, [bufofs]
		mov	ah, 0x02
		int	int_driver
		pop	ds

		mov	bx, 0x09
		call	load_file
		jc	.init_err

		push	ds
		lds	si, [bufofs]
		mov	ah, 0x0e
		int	int_driver
		pop	ds

		mov	bx, 0x0a
		call	load_file
		jc	.init_err

		push	ds
		lds	si, [bufofs]
		mov	ah, 0x05
		int	int_driver
		pop	ds

.init_err:
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
		mov	ah, 0x0c		; STOP
		int	int_driver
		jmp	short .ed

.play:
		mov	ah, 0x0c		; STOP
		int	int_driver

		xor	bx, bx
		call	load_file
		jc	.ed

		lds	si, [bufofs]
		mov	ah, 0x01		; load
		int	int_driver

		mov	ah, 0x06		; play
		mov	cx, 0x00c8
		mov	dx, 0x0000
		int	int_driver

		jmp	.ed

load_file:
		push	ds
		mov	ah, 0x3f		; AH=3F file read
		mov	cx, 0xffff
		lds	dx, [bufofs]
		int	0x21
		pop	ds
		ret


bufofs:
		dw	0x0000
bufseg:
		dw	0x0000

		align	0x10
		times 0x100 db 0xff		; �X�^�b�N�G���A

stack:

prgend:
		ends

