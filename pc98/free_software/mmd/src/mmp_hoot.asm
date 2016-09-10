; MIDI Music Driver M.M.D.
; ���C�����[�`�� (for NASM)

%include 'hoot.inc'

		ORG		0x0100
		USE16
		CPU		186

start:
		cli
		mov		ax,cs
		mov		ds,ax
		mov		es,ax
		mov		ax,cs
		mov		ds,ax

		mov		ax,0x257f	; hoot�h���C�o�o�^
		mov		dx,vect_7f
		int		0x21

		sti
mainloop:
		mov		ax,0x9801		; �_�~�[�|�[�����O
		int		0x18
		jmp		short mainloop

; hoot����R�[�������
; inp8(HOOTPORT) = 0 �� PC98DOS::Play
; inp8(HOOTPORT) = 2 �� PC98DOS::Stop
; _code = inp8(HOOTPORT+2)�`inp8(HOOTPORT+5)

vect_7f:
		pusha
		push	ds
		push	es
		mov		ax,cs
		mov		ds,ax
		mov		es,ax
		mov		dx,HOOTPORT
		in		al,dx
		cmp		al,HP_PLAY
		jz		short .play
		cmp		al,HP_STOP
		jz		short .fadeout
.ed:
		pop		es
		pop		ds
		popa
		iret

.play:	
		mov		ah,0x01		; ���t��~
		int		0x61

		mov		cx,0x60		; vsync�҂��ŃE�F�C�g
.lp:
		nop
		call	.waitvsync
		loop	.lp

		mov		ah,0x06		; �ȃf�[�^�o�b�t�@�A�h���X���擾(DS:DX)
		int		0x61
		xor		bx,bx		; �W������
		mov		cx,0xffff	; �f�[�^�T�C�Y
		mov		ah,0x3f		; [DOS] read hundle
		int		0x21
		jc		.stop

		xor		ah,ah		; ���t�J�n
		int		0x61
		jmp		short .ed

.stop:
		mov		ah,0x01		; ���t��~
		int		0x61
		jmp		short .ed

.fadeout:
		mov		ax,0x0208	; �t�F�[�h�A�E�g
		int		0x61
		jmp		short .ed

.waitvsync:
		push	ax
		push	dx
		mov		dx,0xa0

.waitvsync_1:
		in		al,dx
		test	al,0x20
		jnz		.waitvsync_1

.waitvsync_2:
		in		al,dx
		test	al,0x20
		jz		.waitvsync_2
		pop		dx
		pop		ax
		ret

		ends
