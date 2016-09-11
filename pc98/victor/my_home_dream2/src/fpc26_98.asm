; FPC26.COM �p
; ���C�����[�`�� (for NASM)
; UME-3����iwaplay�̃\�[�X�����ς����Ă��炢�܂����B

%include 'hoot.inc'

		ORG	0x0100
		USE16
		CPU	186

start:		cli
		mov	ax,cs
		mov	ds,ax
		mov	es,ax
		mov	sp,stack

		mov	ah,0x08
		int	0xeb

		mov	bx,0x05		; �������F�f�[�^�o�^
		call	voiceset

		mov	ax,0x257f	; hoot�h���C�o�o�^
		mov	dx,vect_7f
		int	0x21

		sti
mainloop:	hlt
		hlt
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

.play:
		call	stop_music	; ���t��~
		mov	ah,0x3f		; [DOS] read hundle
		mov	dx,HOOTPORT+4	; ���F�f�[�^�ԍ��w���ǂݍ���
		in	al,dx
		or	al,al
		jz	.musload	; �w�肳��Ă��Ȃ���Ή��F���[�h���X�L�b�v

.voiceload:	push	ax
		mov	ax,0x0aff	; �����̉��F�f�[�^��S�č폜
		int	0xeb
		pop	ax
		mov	bl,al		; hundle�w��Ƃ���
		xor	bh,bh
		mov	dx,buff
		mov	cx,0x8000	; ���F�f�[�^�ő�T�C�Y(�K��)
		int	0x21		; ���F�f�[�^���[�h
		jc	.stop
		call	rewind		; �t�@�C���|�C���^��߂�
		jc	.stop
		mov	cx,cs
		mov	dx,buff		; ���F�f�[�^�A���o�^(CX:DX)
		mov	ah,0x09
		int	0xeb

.musload:
		mov	ax,0x06ff	; �o�^�ς݋ȃf�[�^��S�č폜
		int	0xeb
		mov	ah,0x3f		; [DOS] read hundle
		xor	bx,bx		; �W������
		mov	cx,0x8000	; �ȃf�[�^�ő�T�C�Y(�K��)
		mov	dx,buff
		int	0x21		; �ȃf�[�^���[�h
		jc	.stop

		mov	cx,cs
		mov	dx,buff
		mov	ah,0x01		; �ȃf�[�^�o�^(CX:DX)
		int	0xeb

		mov	dx,HOOTPORT+5	; BGM/SE��ʂ�ǂݍ���
		in	al,dx
		or	al,0x7f		; �~���[�g�{�����[��������
		mov	dl,al
		mov	al,[buff+2]	; ��ID
		mov	ah,0x02		; ���t�J�n
		int	0xeb
		jnc	short .ed

.stop:		call	stop_music	; �ُ펞�͉��t��~���Ė߂�
		jmp	short .ed

.fadeout:
		mov	ax,0308h	; �t�F�[�h�A�E�g(AL=���x)
		int	0xeb
		jmp	short .ed

stop_music:
		mov	ax,0x03ff	; ���t��~(����1)
		int	0xeb
		mov	ax,0x0301	; ���t��~(����2)
		int	0xeb
		mov	ah,0x08
		int	0xeb
		ret

; ���F�ݒ� BX=�t�@�C���n���h��
voiceset:	mov	ah,0x3f		; [DOS] read hundle
		mov	cx,0x8000	; ���F�f�[�^�ő�T�C�Y(�K��)
		mov	dx,buff
		int	0x21		; ���F�f�[�^���[�h
		jc	return		; �G���[�Ȃ疳������
		push	bx
		mov	cx,cs
		mov	dx,buff
		mov	ah,0x09		; ���F�f�[�^�Z�b�g(CX:DX)
		int	0xeb
		pop	bx

rewind:		push	ax		; �t�@�C���|�C���^(BX)��擪�ɖ߂�
		push	cx
		push	dx
		mov	ax,0x4200	; [DOS] move file pointer
		xor	cx,cx
		mov	dx,cx
		int	0x21
		pop	dx
		pop	cx
		pop	ax
return:		ret

		times 0x100 db 0x00	; �X�^�b�N�G���A
stack:
		align	0x10
buff:					; �ȉ��A���[�h�o�b�t�@
		ends

