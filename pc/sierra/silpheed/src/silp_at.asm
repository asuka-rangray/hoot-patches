; SILPHEED (PC/AT) driver
; ���C�����[�`�� (for pcatdos)

%include 'hoot.inc'
int_hoot	equ	07fh

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

		mov	ah, 0x48		; [DOS] �h���C�o�o�b�t�@�̊��蓖��
		mov	bx, 0xfff
		int	0x21
		mov	[drvseg], ax

		mov	ah, 0x48		; [DOS] Patch�o�b�t�@�̊��蓖��
		mov	bx, 0xff
		int	0x21
		mov	[patseg], ax

		mov	ah, 0x48		; [DOS] Resource�o�b�t�@�̊��蓖��
		mov	bx, 0x8ca
		int	0x21
		mov	[resseg], ax

		push	ds
		mov	ds,[drvseg]
		mov	dx,0x0000
		mov	cx,0xffff
		mov	bx,0x08
		mov	ah,0x3f			; [DOS] �t�@�C�����[�h
		int	0x21
		pop	ds

		push	ds
		mov	ds,[patseg]
		mov	dx,0x0000
		mov	cx,0xffff
		mov	bx,0x09
		mov	ah,0x3f			; [DOS] �t�@�C�����[�h
		int	0x21
		jc	.patread_err

		xor	bx,bx			; Header���
		mov	bl, [0x001]
		add	bx, 0x02
		mov	[cs:patofs], bx

.patread_err:
		pop	ds

		pusha
		mov	ax,0x02			; API 01
		mov	bp,ax
		mov	ax,patofs
		mov	[sndwork+8],ax
		mov	si,sndwork;
		call	far [drvofs]
		popa

		mov	ax,0x3508
		int	0x21
		mov	[timseg],es
		mov	[timofs],bx

		mov	ax,0x2508
		mov	dx,timercb
		int	0x21

		mov	ax,0x0a			; API 05 Volume
		mov	bp,ax
		mov	si,sndwork;
		mov	ax,0x0f			; Max
		mov	[sndwork+0x18],ax
		call	far [drvofs]

resist:
		mov	ax,0x257f		; hoot�h���C�o�o�^
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
		jz	short .fadeout
.ed:
		pop	es
		pop	ds
		popa
		iret

.play:
		cli

		mov	ax,0x04			; API 02 ����
		mov	bp,ax
		mov	si,sndwork;
		call	far [drvofs]

		push	ds
		mov	ds,[resseg]
		mov	dx,0x0000
		mov	cx,0xffff
		xor	bx,bx
		mov	ah,0x3f			; [DOS] �t�@�C�����[�h
		int	0x21
		jc	.resread_err

		xor	bx,bx			; Header���
		mov	bl, [0x001]
		add	bx, 0x02
		mov	[cs:resofs], bx

.resread_err:
		pop	ds

		mov	ax,resofs
		mov	[sndwork+8],ax
		mov	si,sndwork;
		mov	ax,0x06			; API 03 Resorce Load
		mov	bp,ax
		call	far [drvofs]

		mov	al, 0x36		; PIT�ݒ�
		out	0x43, al
;		mov	ax, 0x19e5
		mov	ax, 0x4DAE		; 1/60
		out	0x40, al
		xchg	ah, al
		out	0x40, al

		mov	byte [playflg],01

		sti
		jmp	short .ed

.stop:
.fadeout:
		mov	ax,0x0e			; API 07 Stop
		mov	bp,ax
		mov	si,sndwork;
		call	far [drvofs]

		mov	byte [playflg],00
		jmp	short .ed

timercb:
		pushf
		pusha
		push	ds
		push	es

		cmp	byte [playflg],0x00
		jz	.noplay

		mov	ax,0x08			; API 04 Update
		mov	bp,ax
		mov	si,sndwork;
		call	far [drvofs]

;		call	far [timofs]

.noplay:
		pop	es
		pop	ds
		mov	al,20h
		out	20h,al
		popa
		popf
		iret

drvofs:		dw	0x0
drvseg:		dw	0x0			; �h���C�o�Z�O�����g
patofs:		dw	0x12			; 
patseg:		dw	0x0			; �p�b�`�Z�O�����g
resofs:		dw	0x02
resseg:		dw	0x0			; ���\�[�X�Z�O�����g
timofs:		dw	0x0
timseg:		dw	0x0
playflg		db	0x0

sndwork:	dw	0x0			; �T�E���h���[�N
		dw	0x0
		dw	0x0
		dw	0x0
		dw	0x0
		dw	0x0
		dw	0x0
		dw	0x0
		dw	0x0
		dw	0x0
		dw	0x0
		dw	0x0
		dw	0x0

		align	0x10
		times 0x100 db 0xff		; �X�^�b�N�G���A

stack:

prgend:
		ends

