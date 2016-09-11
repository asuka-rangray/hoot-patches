; Grocer SDBIOS98.EXE ���t
; ���C�����[�`�� (for pc98dos)
;
; HOOTPORT + 2~3 : �t�@�C���n���h���ԍ�
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

		mov	ah, 0x48		; AH=48 alloc memory
		mov	bx, 0x300
		int	0x21
		mov	[buf1seg],ax

		mov	ah, 0x48		; AH=48 alloc memory
		mov	bx, 0x300
		int	0x21
		mov	[buf2seg],ax

		mov	ah, 0x48		; AH=48 alloc memory
		mov	bx, 0x300
		int	0x21
		mov	[buf3seg],ax

		mov	ah, 0x00
		int	int_driver

.hoot_redist:
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
		mov	al, 0x07
		mov	ah, 0x11		; stop
		int	int_driver

		jmp	short .ed

.play:
		mov	al, 0x07
		mov	ah, 0x11		; stop
		int	int_driver

		mov	dx, HOOTPORT+2
		in	al, dx
		mov	bl ,al
		xor	bh, bh

		push	ds
		mov	al, 0x00
		lds	si, [buf1ofs]
		call	load_buf
		pop	ds
		jc	.ed

		push	ds
		add	bx, 0x01
		mov	al, 0x01
		lds	si, [buf2ofs]
		call	load_buf
		pop	ds
		jc	.ed

		push	ds
		add	bx, 0x01
		mov	al, 0x02
		lds	si, [buf3ofs]
		call	load_buf
		pop	ds
		jc	.ed

		mov	al, 0x07
		mov	ah, 0x10	; play
		int	int_driver

		jmp	.ed

; IN: BX = file handle
; IN: AL = ch no
; IN: DS:SI = buffer ptr
load_buf:
		push	ax

		push	bx
		mov	ah, 0x42
		xor	al, al
		xor	cx, cx
		xor	dx, dx
		int	0x21
		pop	bx

		push	bx
		; bx = handle
		; ds:dx = ptr
		mov	ah, 0x3f		; AH=3F file read
		mov	cx, 0xffff
		mov	dx, si
		int	0x21
		pop	bx

		pop	ax
		push	bx
		; al = no
		; ds:si = ptr
		mov	ah, 0x13
		int	int_driver
		pop	bx

		ret

buf1ofs:
		dw	0x0000
buf1seg:
		dw	0x0000

buf2ofs:
		dw	0x0000
buf2seg:
		dw	0x0000

buf3ofs:
		dw	0x0000
buf3seg:
		dw	0x0000

		align	0x10
		times 0x100 db 0xff		; �X�^�b�N�G���A

stack:

prgend:
		ends

