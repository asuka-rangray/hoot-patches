; �O���u opn.com ���t
; ���C�����[�`�� (for pc98dos)
;
; HOOTPORT + 2   : �Ȕԍ�
; HOOTPORT + 3   : ���[�v�L��
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
		mov	bx, 0xfff
		int	0x21
		mov	[bufseg],ax

		push	ds
		mov	ds,[bufseg]
		mov	dx,0x100
		mov	cx,0xfff
		mov	ah,0x3f			; read hundle
		mov	bx,0x0a			; �n���h��10�ԌŒ�
		int	0x21			; �v���O�������[�h
		pop	ds
		jc	resist

		push	ds			; �o�b�t�@�o�^
		xor	ax, ax
		lds	dx, [bufofs]
		int	int_driver
		pop	ds

resist:
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
		mov	ah, 0x02		; ���t��~
		int	int_driver
		jmp	short .ed

.play:
		mov	ah, 0x02		; ���t��~
		int	int_driver

		mov	cx, 0x20
.wait
		call	.waitvsync
		loop	.wait

		mov	dx, HOOTPORT + 2	; �Đ��Ȕԍ�
		in	al, dx
		inc	al
		mov	ah, 0x01		; �Đ�
		int	int_driver

		mov	dx, HOOTPORT + 3	; ���[�v�t���O
		in	al, dx
		mov	ah, 0x04
		int	int_driver
		jmp	.ed

.waitvsync:
		push	ax
		push	dx
		mov	dx,0xa0

.waitvsync_1:
		in	al,dx
		test	al,0x20
		jnz	.waitvsync_1

.waitvsync_2:
		in	al,dx
		test	al,0x20
		jz	.waitvsync_2
		pop	dx
		pop	ax
		ret

bufofs:
		dw	0x0103
bufseg:
		dw	0x0000

patchmsg:
		db	0x0D,0x0A,'SANGOKUSHI driver for hoot ver 1.0 by RuRuRu',0x0D,0x0A,'$'

		align	0x10
		times 0x100 db 0xff		; �X�^�b�N�G���A
stack:

prgend:
		ends

