; pmdl.com for PM2AT
; ���C�����[�`�� (for pcatdos)

%include 'hoot.inc'
int_hoot	equ	0x07f
int_driver	equ	0x060

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

		mov	ah,0x48			; [DOS] �h���C�o�o�b�t�@�̊��蓖��
		mov	bx,0x280
		int	0x21
		mov	[drvseg], ax

		push	ds
		mov	ds,[drvseg]
		mov	dx,0x100		; offset 100h
		mov	bx,0x09			; �n���h��9�ԌŒ�
		mov	cx,0xffff		; �f�[�^�T�C�Y
		mov	ah,0x3f			; [DOS] read hundle
		int	0x21			; �v���O�������[�h
		pop	ds
		jc	resist

		push	ds
		mov	ds,[drvseg]
		mov	bx, word [0x102]
		mov	[drvofs],bx

		mov	ax,0x02
		mov	[0x10a],ax
		call	far [cs:drvofs]		; FM���ʉ�������

		mov	ax,0x00
		mov	[0x10a],ax
		call	far [cs:drvofs]		; �������N��

		mov	ah,0x0b			; [PMD] FM effect buffer(DS:DX)
		int	int_driver
		mov	bx,0x05			; �n���h��5�ԌŒ�
		mov	cx,0xffff		; �f�[�^�T�C�Y
		mov	ah,0x3f			; [DOS] read hundle
		int	0x21
		pop	ds

resist:
		mov	ah,0x25			; hoot�h���C�o�o�^
		mov	al,int_hoot
		mov	dx,vect_hoot
		int	0x21

		mov	dx,HOOTFUNC
		mov	al,HF_ENABLE		; hoot�Ăяo��������
		out	dx,al
		sti

mainloop:
		mov	ax,0x9801
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
		jz	short .check
		cmp	al,HP_STOP
		jz	short .fadeout

.ed:
		pop	es
		pop	ds
		popa
		iret

.check:
		mov	dx,HOOTPORT+2
		in	al,dx
		xchg	ah,al
		inc	dx
		in	al,dx
		xchg	ah,al
		inc	ax
		inc	ax
		jz	.fmeffect		; ����16bit��0xfffe�̎���FM���ʉ�

.play:
		mov	ah,0x01			; ���t��~
		int	int_driver

		mov	ah,0x06			; �ȃf�[�^�o�b�t�@�A�h���X���擾(DS:DX)
		int	int_driver
		xor	bx,bx			; �W������
		mov	cx,0xffff		; �f�[�^�T�C�Y
		mov	ah,0x3f			; [DOS] read hundle
		int	0x21
		jc	.stop

		xor	ah,ah			; ���t�J�n
		int	int_driver
		jmp	short .ed

.stop:
		mov	ah,0x01			; ���t��~
		int	int_driver

		jmp	short .ed

.fmeffect:
		inc	dx
		in	al,dx			; ���ʉ��ԍ��擾
		mov	ah,0x0c			; ���ʉ����t
		int	0x60
		jmp	short .ed

.fadeout:
		mov	ax,0x0208		; �t�F�[�h�A�E�g
		int	int_driver
		jmp	short .ed

drvofs:		dw	0x011D
drvseg:		dw	0x0000			; �h���C�o�Z�O�����g

		align	0x10
		times 0x100 db 0xff
stack:

prgend:
		ends

