; FMDRV86.com ���t
; ���C�����[�`�� (for pc98dos)
;
; (��������/�O���uIV�A�[�J�C�u�^�C�v)
;
; HOOTPORT + 2~3 : �t�@�C���n���h���ԍ�
; HOOTPORT + 4   : �Ȕԍ�
; HOOTPORT + 5   : ���[�v�L��(bit7) �ő�Ȑ�(bit0~6)
;

%include 'hoot.inc'
int_hoot	equ	0x40
int_driver	equ	0x7f

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
		mov	ax, 0x0200		; ���t��~
		int	int_driver
		jmp	short .ed

.fadeout:
		mov	ax, 0x0228		; �t�F�[�h�A�E�g
		int	int_driver
		jmp	short .ed

.play:
		mov	ax, 0x0200		; ���t��~
		int	int_driver

		push	ds			; �o�b�t�@�o�^
		xor	ax, ax
		lds	dx, [bufofs]
		int	int_driver
		pop	ds

		mov	ax, cs
		mov	ds, ax
		mov	dx, HOOTPORT + 5	; ���Ȑ��擾(0~6bit)
		in	al, dx
		and	al, 0x7f
		xor	ah, ah
		mov	[allsong], ax
		cmp	al, 00
		jz	.ed

		mov	dx, HOOTPORT + 4	; �Đ��Ȕԍ�
		in	al, dx
		mov	ah, 0x00
		cmp	ax, [allsong]
		jnb	.ed

		xor	cx, cx
		add	ax, ax
		mov	dx, ax
		add	ax, ax
		add	dx, ax
		mov	ax, 0x4201		; AH=42 file seek
		xor	bx, bx
		int	0x21
		jb	.ed

		mov	ah, 0x3f		; AH=3F file read
		xor	bx, bx
		mov	cx, 0x0006		; 6byte
		mov	dx, fileinfo
		int	0x21
		jb	.ed

		mov	ax, [allsong]		; (6byte * songs)
		add	ax, ax
		mov	dx, ax
		add	ax, ax
		add	dx, ax
		xor	cx, cx
		add	dx, [fileinfo]
		adc	cx, [fileinfo + 2]
		mov	ax, 0x4200		; AH=42 file seek
		xor	bx, bx
		int	0x21
		jb	.ed

		push	ds
		mov	ah, 0x3f		; AH=3F file read
		xor	bx, bx
		mov	cx, [fileinfo + 4]
		lds	dx, [bufofs]
		int	0x21
		pop	ds
		jb	.playerr

		mov	ax, 0x0101		; �Đ�
		int	int_driver

		mov	dx, HOOTPORT + 5	; ���[�v�t���O(7bit)
		in	al, dx
		shr	al, 0x07
		mov	ah, 0x04
		int	int_driver
.playerr:
		jmp	.ed

bufofs:
		dw	0x0000
bufseg:
		dw	0x0000

allsong:
		dw	0x0000

fileinfo:
		times	0x00 db 0x06

		align	0x10
		times 0x100 db 0xff		; �X�^�b�N�G���A

stack:

prgend:
		ends

