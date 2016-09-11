; OPNDRV.EXE (C)����V�X�e�� �p
; ���C�����[�`�� (for NASM)

%include 'hoot.inc'
int_hoot	equ	0x7f
int_driver	equ	0xd2

		ORG	0x0100
		USE16
		CPU	186

start:
		cli
		mov	ax,cs
		mov	ds,ax
		mov	es,ax

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

		xor	ax,ax			; ������
		int	int_driver

		mov	cx,0x0800		; �ȃf�[�^�o�b�t�@�m��
		mov	ax,0x0005
		int	int_driver
		mov	[buff_seg],ax		; ���ʂ�ۑ�
		mov	[buff_size],cx

		mov	dx, HOOTFUNC
		mov	al, HF_ENABLE		; hoot�Ăяo��������
		out	dx, al

		sti

mainloop:
		mov	ax,0x9801	; �_�~�[�|�[�����O
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
		mov	ax,cs
		mov	ds,ax
		mov	es,ax
		mov	dx,HOOTPORT
		in	al,dx
		cmp	al,HP_PLAY
		jz	short .play
		cmp	al,HP_STOP
		jz	short .fadeout
.ed:
		pop	es
		pop	ds
		popa
		iret

.play:
		mov	ax,0x02		; ���t��~
		int	int_driver

		push	ds
		lds	cx, [buff_size]	; �o�b�t�@
		shl	cx,4		; �o�C�g�P�ʂɕϊ�
		xor	dx,dx		; �f�[�^�I�t�Z�b�g
		xor	bx,bx		; �W������
		mov	ah,0x3f		; �ȃf�[�^�{�̂̃��[�h(DS:DX)
		cli
		int	0x21
		pop	ds
		jc	.stop

		mov	dx,HOOTPORT+4	; �Ȕԍ���ǂݍ���
		in	al,dx

		mov	cl,al
		inc	dx
		in	al,dx		; ���͓�
		mov	dl,al
		mov	ax,0x01		; ���t�J�n
		int	int_driver
		jmp	short .ed

.stop:
		mov	ax,0x02		; ���t��~
		int	int_driver
		jmp	short .ed

.fadeout:
		mov	ax,0x03		; �t�F�[�h�A�E�g
		mov	cl,8		; �t�F�[�h�A�E�g���x
		int	int_driver
		jmp	short .ed

buff_size:	dw	0000		; �o�b�t�@�T�C�Y
buff_seg:	dw	0000		; �o�b�t�@�Z�O�����g

		align	0x10
		times 0x40 db 0xff		; �X�^�b�N�G���A

stack:

prgend:
		ends

