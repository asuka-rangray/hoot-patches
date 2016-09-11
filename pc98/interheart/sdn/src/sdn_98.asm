; SDN.com
; ���C�����[�`�� (for pc98dos)

%include 'hoot.inc'
int_hoot	equ	07fh
int_sdn		equ	050h

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
		mov	bx, 0x250
		int	0x21
		mov	[drvseg], ax

		push	ds
		mov	ds,[drvseg]
		mov	dx,0x100
		mov	cx,0xffff
		mov	ah,0x3f			; read hundle
		mov	bx,0x09			; �n���h��9�ԌŒ�
		int	0x21			; �v���O�������[�h
		pop	ds
		jc	resist

		call	far [drvofs]		; �������N��

		mov	ah,0x48			; [DOS] ���[�h�o�b�t�@�̊��蓖��
		mov	bx,0x400
		int	0x21
		mov	[loadseg],ax

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
		mov	ah,0x05		; ���t��~
		int	int_sdn

		mov	ax,[cs:loadseg]
		mov	ds,ax
		xor	dx,dx
		mov	cx,0xffff
		mov	ah,0x3f		; read hundle
		xor	bx,bx		; �W�����͂���
		int	0x21		; �ȃf�[�^���[�h
		jc	.ed

		mov	si,ds		; data segment
		mov	es,si
		xor	di,dx		; data address
		mov	ah,0x01		; �f�[�^���[�h(ES:DI)
		mov	al,0x00
		int	int_sdn
		jmp	short .ed

.stop:
		mov	ah,0x05		; ���t��~
		int	int_sdn

		jmp	short .ed

.fadeout:
		mov	cx,0x19
		mov	dl,0x00
		mov	dh,0x0f
		mov	ah,0x07		; �t�F�[�h�A�E�g
		int	int_sdn
		jmp	short .ed

loadseg:	dw	0		; ���[�h�Z�O�����g
drvofs:		dw	0x100
drvseg:		dw	0x0		; �h���C�o�Z�O�����g

		align	0x10
		times 0x100 db 0xff	; �X�^�b�N�G���A

stack:

prgend:
		ends

