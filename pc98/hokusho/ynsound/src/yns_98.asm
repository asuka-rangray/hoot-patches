; HOKUSHO YNSOUND.COM
; hoot���t���[�`�� (for pc98dos)
;
; hootport + 6����0�Ȃ�A�[�J�C�o�ǂݍ���
;
; [�A�[�J�C�o�`��]
;  DWORD offset
;  DWORD size
; �̗񋓂�offset��0�Ńw�b�_�I��
;

%include 'hoot.inc'
int_hoot	equ	0x7f
int_driver	equ	0x40

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

		mov	bx,prgend
		add	bx,0x0f
		shr	bx,4
		mov	ah,0x4a			; [DOS] �������u���b�N�̏k��(ES:BX)
		int	0x21

		mov	ah, 0x48		; AH=48 alloc memory
		mov	bx, 0x1000
		int	0x21
		mov	[bufseg],ax

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
		jz	.fadeout
.ed:
		pop	es
		pop	ds
		popa
		iret

.stop:
		mov	ah,0x04		; ���t��~
		int	int_driver
		jmp	.ed

.fadeout:
		mov	ah,0x09		; ���t��~
		mov	al,0x91		; speed
		int	int_driver
		jmp	.ed

.play:
		mov	ah,0x00
		int	int_driver

		mov	ax,0x0101
		int	int_driver

		mov	ah,0x03
		int	int_driver

; single / arc check
		mov	dx, HOOTPORT + 4
		in	al, dx
		cmp	al, 0x00
		jz	.single

; archiver type
		dec	al
		xor	ah, ah
		xor	cx, cx
		shl	ax, 3
		mov	dx, ax
		mov	ax, 0x4200		; AH=42 file seek
		xor	bx, bx
		int	0x21
		jb	.ed

		mov	ah, 0x3f		; AH=3F file read
		xor	bx, bx
		mov	cx, 0x0008		; 8byte
		mov	dx, fileinfo
		int	0x21
		jb	.ed

		mov	ax, 0x4200		; AH=42 file seek
		mov	cx, [fileofs+2]
		mov	dx, [fileofs]
		xor	bx, bx
		int	0x21
		jb	.ed

		push	ds
		mov	cx,[filesize]
		lds	dx,[bufofs]
		xor	bx,bx
		call	.fileload
		pop	ds
		jc	.ed
		jmp	.loaded

; single type
.single:
		push	ds
		lds	dx,[bufofs]
		xor	bx,bx
		mov	cx,0xffff
		call	.fileload
		pop	ds
		jc	.ed

.loaded:
		push	ds
		lds	si,[bufofs]
		mov	ax,0x0606			; Set buffer(DS:SI)
		int	int_driver
		pop	ds

		mov	ax,0x0b04
		int	int_driver

		mov	ah,0x07		; ���t�J�n
		int	int_driver

		jmp	.ed

; in: ds:dx = buffer segment
; in: bx = handle number
.fileload:
		mov	ah,0x3f		; [DOS] read hundle
		int	0x21
		jc	.loadend
		mov	ax,0x4200	; [DOS] �擪�փV�[�N
		mov	cx,0x0000
		mov	dx,0x0000
		int	0x21
.loadend:
		ret

bufofs:
		dw	0x0000
bufseg:
		dw	0x0000

fileinfo:
fileofs:
		dw	0x0000
		dw	0x0000
filesize:
		dw	0x0000
		dw	0x0000

prgend:
		ends

