; DRSMUS.EXE ���t
; ���C�����[�`�� (for pc98dos)
;
; HOOTPORT + 2~3 : �t�@�C���n���h���ԍ�
; HOOTPORT + 4   : �Ȕԍ�
; HOOTPORT + 5   : ���[�v�L��
;

%include 'hoot.inc'
int_hoot	equ	0x7F
int_driver	equ	0xF1

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
		mov	al, 0x01		; ��~
		int	int_driver
		jmp	short .ed


.play:
		mov	al, 0x01		; ��~
		int	int_driver

		mov	ah, 0x3f		; AH=3F conin read
		xor	bx, bx
		mov	cx, 0x50-1
		mov	dx, filename
		int	0x21
		jc	.ed
		mov	bx,ax
		mov	[filename+bx], byte 0

		mov	bx, filename
		mov	al, 0x00		; �t�@�C�����[�h[DS:BX] & �Đ�
		int	int_driver

		jmp	.ed

filename:
		times 0x50 db 0x00		; �t�@�C�����i�[�p�o�b�t�@

		align	0x10
		times 0x100 db 0xff		; �X�^�b�N�G���A

stack:

prgend:
		ends
