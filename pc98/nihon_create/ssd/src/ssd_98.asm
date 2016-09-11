; SS ���t(diadrum)
; ���C�����[�`�� (for pc98dos)

%include 'hoot.inc'
int_hoot	equ	0x07f
int_ss		equ	0x042

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
		pop	dx
		popa
		iret

.play:
		mov	ah,0x02		; ���t��~
		int	int_ss

		mov	dx,filename
		mov	cx,0xffff
		mov	ah,0x3f		; read hundle
		xor	bx,bx		; �W�����͂���
		int	0x21		; �ȃf�[�^���[�h
		jc	.stop
		mov	bx,ax
		mov	[filename+bx], byte 0

		mov	si,ds		; data segment
		xor	di,dx		; data address
		mov	ah,0x01		; �f�[�^���[�h(si:di)
		int	int_ss
		jmp	short .ed

.stop:
		mov	ah,0x02		; ���t��~
		int	int_ss
		jmp	short .ed

.fadeout:
		mov	ah,0x03		; �t�F�[�h�A�E�g
		mov	dl,0x00
		mov	dh,0x30
		int	int_ss

		jmp	short .ed

filename:
		times 0x10 db 0x00	; �t�@�C�����i�[�p�o�b�t�@

		ends

