; MDRVV107A.COM ���t
; ���C�����[�`�� (for pc98dos)
;
; HOOTPORT + 2~3 : �t�@�C���n���h���ԍ�
;

%include 'hoot.inc'
int_hoot	equ	0x7f
int_driver	equ	0x51

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

		push	ds
		mov	ah, 0x3f		; AH=3F file read
		mov	bx, 0x08
		mov	cx, 0x10
		push	cs
		pop	ds
		mov	dx, namebuf
		int	0x21
		pop	ds
		jc	.redist

		mov	bx, namebuf
		add	bx, ax
		mov	byte [bx], 0x00

		push	ds
		push	cs
		pop	ds
		mov	dx, namebuf
		mov	ah, 0x06		; load efc
		int	int_driver
		pop	ds

.redist:
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
		mov	ah, 0x02		; STOP
		int	int_driver
		jmp	short .ed

.play:
		mov	dx, HOOTPORT + 5
		in	al, dx
		cmp	al, 0x01
		jz	.play_se

		push	ds
		mov	ah, 0x3f		; AH=3F file read
		xor	bx, bx
		mov	cx, 0x10
		push	cs
		pop	ds
		mov	dx, namebuf
		int	0x21
		pop	ds
		jc	.ed

		mov	bx, namebuf
		add	bx, ax
		mov	byte [bx], 0x00

		push	ds
		push	cs
		pop	ds
		mov	dx, namebuf
		mov	ah, 0x00		; play
		int	int_driver
		pop	ds

		mov	ah, 0x01
		int	int_driver

		jmp	.ed

.play_se:
		mov	dx, HOOTPORT + 2
		in	al, dx
		mov	dl, al

		mov	ah, 0x07
		int	int_driver

		jmp	.ed

namebuf:
		times 0x10 db 0x00		; �t�@�C�����o�b�t�@

		align	0x10
		times 0x100 db 0xff		; �X�^�b�N�G���A

stack:

prgend:
		ends

