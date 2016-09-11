; Microcabin Music Driver �u�����݂����v(MMD2.SYS/MMD.SYS)�p
; ���C�����[�`�� (for NASM)

%include 'hoot.inc'

		ORG	0x0100
		USE16
		CPU	186

start:		cli
		mov	ax,cs
		mov	ds,ax
		mov	es,ax

		mov	dx,HOOTFUNC
		mov	al,HF_DISABLE		; ����������hoot�Ăяo�����֎~
		out	dx,al

		mov	ax,0x257f		; hoot�h���C�o�o�^
		mov	dx,vect_7f
		int	0x21

		xor	ax,ax			; �h���C�o������
		int	0x48
		mov	[musbuf_size],cx	; �o�b�t�@�T�C�Y��ۑ�

		mov	dx,HOOTFUNC
		mov	al,HF_ENABLE		; hoot�Ăяo��������
		out	dx,al

		sti
mainloop:	hlt
		hlt
		hlt
		hlt
		jmp	short mainloop

; hoot����R�[�������
; inp8(HOOTPORT) = 0 �� PC98DOS::Play
; inp8(HOOTPORT) = 2 �� PC98DOS::Stop
; _code = inp8(HOOTPORT+2)�`inp8(HOOTPORT+5)

vect_7f:	pusha
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
		pop	ds
		popa
		iret

.play:		mov	dx,HOOTPORT+3	; �Ȕԍ��w���ǂݍ���
		in	al,dx
		mov	ah,al
		dec	dx
		in	al,dx		; �Ȕԍ���0xffff�̏ꍇ�̓��[�v�����o��
		inc	ax
		jz	.sync
		mov	ah,0x03		; ���t��~
		int	0x48
		cli
		mov	ah,0x3f		; [DOS] read hundle
		mov	dx,HOOTPORT+4	; ���F�f�[�^�ԍ��w���ǂݍ���
		in	al,dx
		or	al,al
		jz	.musload	; �w�肳��Ă��Ȃ���Ή��F���[�h���X�L�b�v
		mov	bl,al		; hundle�w��Ƃ���
		xor	bh,bh
		mov	dx,buff
		mov	cx,0x0c00	; ���F�f�[�^�ő�T�C�Y
		int	0x21		; ���F�f�[�^���[�h
		jc	.stop
		call	rewind		; �t�@�C���|�C���^��߂�
		jc	.stop
		mov	dx,ds
		mov	bx,buff
		mov	cx,ax		; ���F�f�[�^�̎��ۂ̃T�C�Y
		mov	ah,0x11
		int	0x48		; ���F�f�[�^�Z�b�g

.musload:	mov	ah,0x3f		; [DOS] read hundle
		xor	bx,bx		; �W������
		mov	cx,[musbuf_size]
		mov	dx,buff
		int	0x21		; �ȃf�[�^���[�h
		jc	.stop

		mov	dx,ds
		mov	bx,buff
		mov	cx,ax		; �ȃf�[�^�̎��ۂ̃T�C�Y
		mov	ah,0x10		; �ȃf�[�^�Z�b�g
		int	0x48

		mov	ah,0x01
		int	0x48		; ���t�J�n
		jmp	short .ed

.sync:		mov	ax,0x0a01	; ���[�v�����o��
		int	0x48
		jmp	short .ed

.stop:		mov	ah,0x03		; ���t��~
		int	0x48
		jmp	short .ed

.fadeout:	mov	ax,0x0608	; �t�F�[�h�A�E�g
		int	0x48
		jmp	short .ed

; �t�@�C���|�C���^(BX)��擪�ɖ߂�
;
rewind:		push	ax
		push	cx
		push	dx
		mov	ax,0x4200	; [DOS] move file pointer
		xor	cx,cx
		mov	dx,cx
		int	0x21
		pop	dx
		pop	cx
		pop	ax
		ret

musbuf_size:	dw	0		; �ȃf�[�^�o�b�t�@�T�C�Y

buff:					; �f�[�^���[�h�p�o�b�t�@

		ends

