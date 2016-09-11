; MDRV ���t
; ���C�����[�`�� (for pc98dos)

%include 'hoot.inc'
int_hoot	equ	7fh
int_mdrv	equ	0d2h

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

		mov	ax,0x257f		; hoot�h���C�o�o�^
		mov	dx,vect_hoot
		int	0x21

		mov	dx,HOOTFUNC
		mov	al,HF_ENABLE		; hoot�Ăяo��������
		out	dx,al
		sti

mainloop:	mov	ax,0x9801		; �_�~�[�|�[�����O
		int	0x18
		jmp	short mainloop

; hoot����R�[�������
; inp8(HOOTPORT) = 0 �� PC98DOS::Play
; inp8(HOOTPORT) = 2 �� PC98DOS::Stop
; _code = inp8(HOOTPORT+2)�`inp8(HOOTPORT+5)

vect_hoot:	pusha
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
.ed:		pop	es
		pop	dx
		popa
		iret

.play:
		mov	ah, 3fh		; �t�@�C�����̃��[�h(conin����擾)
		xor	bx,bx
		mov	cx, -1
		mov	dx,filename
		int	21h
		jc	.stop
		mov	bx,ax
		mov	[filename+bx], byte 0

		mov	dx,filename
		mov	cx,cs
		mov	al,0x06		; �f�[�^���[�h(cx:dx)
		int	int_mdrv

		mov	al,0x02		; ���t��~
		int	int_mdrv

		mov	al,0x01		; ���t�J�n
		int	int_mdrv
		jmp	short .ed

.stop:
		mov	al,0x02		; ���t��~
		int	int_mdrv
		jmp	short .ed

.fadeout:
		mov	al,0x02		; ���t��~(fade out����)
		int	int_mdrv
		jmp	short .ed

filename:
		; �t�@�C�����i�[�p�o�b�t�@
		times 0x10 db 0x00

prgend:
		ends

