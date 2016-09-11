; NEXTON OPN Drever "NEODRV" ���t
; ���C�����[�`�� (for pc98dos)

%include 'hoot.inc'
int_hoot	equ	0x7f
int_neo		equ	0x88

		ORG	0x0100
		USE16
		CPU	186

start:
		cli
		mov	ax,cs
		mov	ds,ax
		mov	es,ax

		mov	dx,HOOTFUNC
		mov	al,HF_DISABLE		; ����������hoot�Ăяo�����֎~
		out	dx,al

		mov	ax,cs			; �X�^�b�N�ݒ�
		mov	ss,ax
		mov	sp,stack

		mov	bx,prgend
		add	bx,0x0f
		shr	bx,4
		mov	ah,0x4a			; [DOS] �������u���b�N�̏k��(ES:BX)
		int	0x21

		mov	ah,0x48			; [DOS] ���[�h�o�b�t�@�̊��蓖��
		mov	bx,0x100		; �p���O���t�T�C�Y(64K)
		int	0x21
		mov	[loadseg],ax

		mov	ah,0x25			; hoot�h���C�o�o�^
		mov	al,int_hoot
		mov	dx,vect_hoot
		int	0x21

		mov	dx,HOOTFUNC
		mov	al,HF_ENABLE		; hoot�Ăяo��������
		out	dx,al
		sti

mainloop:
		mov	ax,0x9801		; �_�~�[�|�[�����O
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
		jz	.fadeout
.ed:
		pop	es
		pop	ds
		popa
		iret

.play:
		mov	dx,HOOTPORT+4	; �Ȕԍ���ǂݍ���
		in	al,dx
		cmp	al,0x00
		jnz	.play_se

		mov	ah,0x03			; ���t��~
		int	int_neo

		call	set_data

		xor	ah,ah
		int	int_neo
		xor	dx,dx
		xor	ah,ah
		int	int_neo
		mov	ah,02
		int	int_neo
		jmp	short .ed


.stop:
		mov	ah,0x03			; ���t��~
		int	int_neo
		jmp	short .ed

.fadeout:
		mov	ah,0x04			; �t�F�[�h�A�E�g
		mov	cx,0x90
		mov	dx,0xE1
		int	int_neo
		jmp	.ed

.play_se:
		dec	al
		mov	dl,al
		mov	ah,0x01
		mov	dh,0x01
		int	int_neo
		jmp	short .ed

set_data:
		; �ȃf�[�^
		xor	ax,ax
		mov	es,ax
		lds	di,[es:0x50]
		mov	dx,[di-0x12]		; �A�h���X�Œ�
		mov	cx,0x1000
		mov	ah,0x3f			; read hundle
		xor	bx,bx			; �W�����͂���
		int	0x21			; �ȃf�[�^���[�h
		jc	.ed

		; ���F�f�[�^(tone.mtx)
		mov	ax,[cs:loadseg]
		mov	ds,ax
		xor	dx,dx
		mov	cx,0x2000
		mov	ah,0x3f			; read hundle
		mov	bx,0x09			; 9�Œ�
		int	0x21			; �ȃf�[�^���[�h
		jc	.ed

		les	bx,[es:0x50]
		mov	di,[es:bx-0x12]
		mov	bx,[es:di+0x14]
		add	bx,di
		sub	di,0x0c00
		mov	dx,0x00
; IN ES:BX
.tone_loop:
		xor	ax,ax
		mov	al,[es:bx]
		cmp	al,0xff
		jz	.play_api
		inc	bx
		shl	ax,0x05
		mov	si,dx			; si = 0
		add	si,ax			; si = ax << 5
		mov	cx,0x10
		repz
		movsw				; es:di <- ds:si
		jmp	.tone_loop
.play_api
.ed
		ret

loadseg:	dw	0			; ���[�h�Z�O�����g

		align	0x10
		times 0x100 db 0xff		; �X�^�b�N�G���A
stack:

prgend:
		ends

