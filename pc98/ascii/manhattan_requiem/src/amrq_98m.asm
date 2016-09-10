; PLAY.com(ASCII MRQ)
; ���C�����[�`�� (for pc98dos)

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

		mov	ah,0x3d			; [DOS] �t�@�C���I�[�v��
		mov	dx,drvname
		int	0x21
		jc	resist

		push	ds
		mov	ds,[drvseg]
		mov	dx,0x0000
		mov	cx,0xffff
		mov	bx,ax
		mov	ah,0x3f			; [DOS] �t�@�C�����[�h
		int	0x21
		pop	ds

		mov	ah,0x3e			; [DOS] �t�@�C���N���[�Y
		int	0x21

		push	ds			; int d2�o�^
		xor	dx,dx
		mov	ax,[drvseg]
		mov	ds,ax
		mov	ax,0x25d2
		int	0x21
		pop	ds

;		mov	al,0x01			; ������
;		mov	ah,0x02			; MIDI����
;		int	0xd2

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
		mov	al,0x00			; �o�b�t�@�|�C���^�擾
		int	0xd2

		push	ds
		mov	ax,[drvseg]
		mov	ds,ax
		mov	dx,cx
		mov	cx,0xffff
		mov	ah,0x3f			; read hundle
		xor	bx,bx			; �W�����͂���
		int	0x21			; �ȃf�[�^���[�h
		pop	ds
		jc	.ed

		mov	al,0x01			; ������
		mov	ah,0x02			; MIDI����
		int	0xd2

		mov	al,0x02			; ���t
		int	0xd2
		jmp	short .ed

.stop:
		mov	ah,0x00
		mov	al,0x03			; ���t��~
		int	0xd2

		jmp	short .ed

.fadeout:
		mov	ah,0x01
		mov	al,0x03			; ���t��~
		int	0xd2
		jmp	short .ed

drvofs:		dw	0x0
drvseg:		dw	0x0			; �h���C�o�Z�O�����g
drvname		db	'PLAY.COM',00,'$'

		align	0x10
		times 0x100 db 0xff		; �X�^�b�N�G���A

stack:

prgend:
		ends

