; BNN mdr.exe ���t
; ���C�����[�`�� (for pc98dos)
;
; ��{�I�Ƀg���L���n�E�X�̕��Ɠ��������A�f�[�^������
;

%include 'hoot.inc'
int_hoot	equ	0x7f
int_driver	equ	0x2f

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
		mov	ax, 0x879B
		mov	bx, 0x05		; ���t��~
		mov	cx, 0x1e
		int	int_driver

		mov	ax, 0x879B
		mov	bx, 0x06		; Fadeout�w��
		mov	si, 0x03
		int	int_driver

		jmp	short .ed

.play:
		mov	ax, 0x879B
		mov	bx, 0x05		; ���t��~
		mov	cx, 0x1e
		int	int_driver

		mov	ax, 0x879B
		xor	cx, cx
		xor	dx, dx
		mov	bx, 0x01		; ���F�o�^1
		int	int_driver

		mov	ax, 0x879B
		xor	cx, cx
		xor	dx, dx
		mov	bx, 0x02		; ���F�o�^2
		int	int_driver

		mov	dx, HOOTPORT + 2	; �Đ��Ȕԍ�
		in	al, dx
		xor	ch, ch
		mov	cl, al
		mov	ax, 0x879B
		xor	dx, dx
		mov	si,0x01
		mov	bx,0x03			; �Đ�
		int	int_driver

		jmp	.ed

patchmsg:
		db	0x0D,0x0A,'MDR driver for hoot ver 1.0 by RuRuRu',0x0D,0x0A,'$'

		align	0x10
		times 0x100 db 0xff		; �X�^�b�N�G���A
stack:

prgend:
		ends

