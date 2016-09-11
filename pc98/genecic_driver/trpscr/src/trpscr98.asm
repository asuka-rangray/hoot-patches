; Terpsichorean98 (C)
; ���C�����[�`�� (for NASM)
;
; �x�[�X�쐬     : ���H���쏊
; ���ʉ��Đ��Ή� : RuRuRu
;

%include 'hoot.inc'
int_hoot	equ	0x7F
int_driver	equ	0xf1

		ORG	0x0100
		USE16
		CPU	186

start:
		cli
		mov	ax,cs
		mov	ds,ax
		mov	es,ax

		mov	ah, 0x25		; hoot�h���C�o�o�^
		mov	al, int_hoot
		mov	dx, vect_hoot
		int	0x21

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
		mov	dx, HOOTPORT + 3
		in	al, dx
		cmp	al, 0x00
		jnz	.play_se

		xor	ax, ax
		mov	bx, 0x03		; ��ԕύX
		mov	dx, 0x03		; ���t��~
		int	int_driver

		; �t�@�C���I�[�v��
		mov	dx,buff			; ���[�h�A�h���X
		xor	bx,bx			; �W������
		mov	cx,0xffff		; �T�C�Y
		mov	ah,0x3f			; �ȃf�[�^�{�̂̃��[�h (DS:DX)
		int	0x21
		jc	.stop

		xor	ax, ax
		mov	bx, 0x0002		; �ȃf�[�^���[�h (CX:DX)
		mov	cx, ds
		mov	dx, buff
		int	int_driver

		xor	ax, ax
		mov	bx,0x0003		; ��ԕύX
		mov	dx,0x0002		; ���t�J�n
		int	int_driver

		jmp	short .ed

.play_se:
		mov	dx, HOOTPORT + 2
		in	al, dx

		mov	dl, al
		xor	ax, ax
		mov	bx,0x0005		; SE�Đ�
		int	int_driver

		jmp	short .ed

.stop:
		xor	ax, ax
		mov	bx, 0x03		; ��ԕύX
		mov	dx, 0x03		; ���t��~
		int	int_driver

		jmp	short .ed

.fadeout:
		xor	ax, ax
		mov	bx, 0x03		; ��ԕύX
		mov	dx, 0x01		; �t�F�[�h�A�E�g
		int	int_driver

		jmp	short .ed

buff:						; �ȉ��A�ȃf�[�^�o�b�t�@

		ends

