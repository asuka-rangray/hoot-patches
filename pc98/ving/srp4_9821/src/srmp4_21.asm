; SuperRealMajang P4 FINAL MUSIC.COM ���t
; ���C�����[�`�� (for pc98dos)
;
; 01�łƔ�r���Ĕ�����API���قȂ�B
;
; HOOTPORT + 2~3 : �t�@�C���n���h���ԍ�
; HOOTPORT + 4   : ���[�v�t���O
;

%include 'hoot.inc'
int_hoot	equ	0x7f
int_driver	equ	0x7e

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

		mov	ax, 0x07		; load
		int	int_driver

		mov	ah, 0x48		; AH=48 alloc memory
		mov	bx, 0x900
		int	0x21
		mov	[bufseg],ax

		mov	ah, 0x48		; AH=48 alloc memory
		mov	bx, 0x100
		int	0x21
		mov	[opnseg],ax

		mov	ah, 0x48		; AH=48 alloc memory
		mov	bx, 0x100
		int	0x21
		mov	[ssgseg],ax

		push	ds
		mov	ah, 0x3f		; AH=3F file read
		mov	bx, 0x07
		mov	cx, 0xffff
		lds	dx, [bufofs]
		int	0x21
		pop	ds
		jc	.ed

		push	ds
		mov	ah, 0x3f		; AH=3F file read
		mov	bx, 0x08
		mov	cx, 0xffff
		lds	dx, [opnofs]
		int	0x21
		pop	ds
		jc	.ed

		push	ds
		mov	ah, 0x3f		; AH=3F file read
		mov	bx, 0x09
		mov	cx, 0xffff
		lds	dx, [ssgofs]
		int	0x21
		pop	ds
		jc	.ed

		push	ds
		mov	dx, [ssgseg]
		xor	bx,bx
		les	di, [opnofs]
		lds	si, [bufofs]
		mov	ax, 0x00		; load
		int	int_driver
		pop	ds

.ed:
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
		mov	ax, 0x02		; STOP
		int	int_driver
		jmp	short .ed

.play:
		mov	ax, 0x001		; play
		int	int_driver

		jmp	.ed

bufofs:
		dw	0x0000
bufseg:
		dw	0x0000
opnofs:
		dw	0x0000
opnseg:
		dw	0x0000
ssgofs:
		dw	0x0000
ssgseg:
		dw	0x0000


		align	0x10
		times 0x100 db 0xff		; �X�^�b�N�G���A

stack:

prgend:
		ends

