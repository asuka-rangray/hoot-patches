; ���h386 FMOPNA/FMOPN ���t
; ���C�����[�`�� (for pc98dos)
;
; HOOTPORT + 2~3 : �t�@�C���n���h���ԍ�
;

%include 'hoot.inc'
int_hoot	equ	0x07f
int_driver	equ	0x040

		ORG	0x0100
		USE16
		CPU	386

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

		mov	ah, 0x48		; AH=48 alloc memory
		mov	bx, 0x1000
		int	0x21
		mov	[bufseg],ax

		mov	ax, 0xf777
		mov	bx, 0x3c4b
		mov	cx, 0x4f45
		mov	dx, 0x493e
		int	0x2f			; TSRMAN

		mov	ah, 0x03		; API 03 Regist?
		mov	al, 0x10		; BGMSEQ no
		call	far [es:di]		; TSRMAN call
		jb	mainloop		; error
		mov	ax,es
		mov	[calseg],ax
		mov	[calofs],bx

		mov	ax, 0x0000		; init
		call	far [calofs]		; BGMSEQ call
		cmp	ax, 0x0000
		jz	mainloop		; error

		mov	ah, 0x25		; hoot�h���C�o�o�^
		mov	al, int_hoot
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

.stop:
.fadeout:
		mov	ah, 0x12
		mov	bl, 0x00
		call	far [cs:calofs]
		jmp	short .ed

.play:
		mov	ah, 0x12
		mov	bl, 0x00
		call	far [cs:calofs]

		push	ds
		mov	ah, 3fh
		xor	bx, bx
		mov	cx, 0xffff
		lds	dx, [cs:bufofs]
		int	0x21
		pop	ds

		les	bx, [cs:bufofs]
		mov	ah, 0x10		; set data
		call	far [cs:calofs]

		mov	ah, 0x11		; play
		mov     bl, 0x01
		call	far [cs:calofs]

		mov	dx, HOOTPORT + 4	; ���[�v�t���O
		in	al, dx
		mov	bl, al
		mov	ah, 0x14		; set loop
		call	far [cs:calofs]

		jmp	short .ed

calofs:
		dw	0x0000
calseg:
		dw	0x0000

bufofs:
		dw	0x0000
bufseg:
		dw	0x0000

		align	0x10
		times 0x100 db 0xff		; �X�^�b�N�G���A

stack:

prgend:
		ends

