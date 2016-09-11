; NATTEL.COM ���t
; ���C�����[�`�� (for pc98dos)
;
; HOOTPORT + 2 : �t�@�C���n���h���ԍ�
; HOOTPORT + 3 : !00 ���ʉ�
;
; PiaCarrot��EXE�����h���C�o�[�Ɠ�����
;

%include 'hoot.inc'
int_hoot	equ	0x7F
int_driver	equ	0x61

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

		push	ds
		mov	ah, 0x3f		; AH=3F file read
		mov	bx, 0x08
		mov	cx, 0xffff
		push	cs
		pop	ds
		lds	dx, [bufofs]
		int	0x21
		pop	ds
		jc	.redist

		push	cs
		pop	es
		les	si, [bufofs]
		mov	ah, 0x09		; Load buffer (SE)
		call	call_driver

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
		mov	ah, 0x03		; Stop
		call	call_driver
		jmp	short .ed

.play:
		mov	dx, HOOTPORT + 3
		in	al, dx
		cmp	al, 0x00
		jnz	.play_se

		push	ds
		mov	ah, 0x3f		; AH=3F file read
		xor	bx, bx
		mov	cx, 0xffff
		lds	dx, [bufofs]
		int	0x21
		pop	ds
		jc	.ed

		les	si, [bufofs]
		mov	ah, 0x04		; Load buffer
		call	call_driver

		mov	ah, 0x02		; Play
		call	call_driver

		jmp	.ed

.play_se:
		mov	dx, HOOTPORT + 2
		in	al, dx
		mov	ah, 0x07		; Play SE
		call	call_driver

		jmp	.ed


call_driver:
		push	ds
		push	ax
		xor	ax, ax
		mov	ds, ax
		pop	ax
		call	far [0x184]				; Int 61h
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

