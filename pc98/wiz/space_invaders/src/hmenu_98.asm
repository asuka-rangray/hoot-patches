; HMENU.COM(CRC32:0xdee5cb3e) (c)Wiz
;

%include 'hoot.inc'
int_hoot	equ	0x7f
int_driver	equ	0xfe

		ORG	0x0100
		USE16
		CPU	186

start:
		cli
		mov	ax, cs
		mov	ds, ax
		mov	es, ax

		mov	dx, HOOTFUNC
		mov	al, HF_DISABLE		; 初期化中はhoot呼び出しを禁止
		out	dx, al

		mov	ax, cs			; スタック設定
		mov	ss, ax
		mov	sp, stack

		mov	bx, prgend
		add	bx, 0x0f
		shr	bx, 4
		mov	ah, 0x4a		; AH=4a modify alloc memory(ES:BX)
		int	0x21

		mov	ah,0x48			; [DOS] ロードバッファの割り当て
		mov	bx,0x100		; パラグラフサイズ(64K)
		int	0x21
		mov	[cs:bufseg],ax
		mov	[cs:iniseg],ax
		mov	[cs:plyseg],ax
		mov	[cs:stpseg],ax
		push	ax
		pop	es

		push	ds
		lds	dx, [cs:bufofs]
		mov	cx, 0xffff
		mov	ah, 0x3f		; [DOS] ファイルからの読み取り
		mov	bx, 0x09		; code 9
		int	0x21

		mov	al, 0CBh
		mov	[0178h], al		; Patch: ret -> retf
		mov	[0190h], al		; Patch: ret -> retf
		pop	ds

		push	ds
		mov	ax, [cs:bufseg]
		mov	ds, ax
		call	far [cs:iniofs]

		cmp	byte [0x91E3],0xFF
		jz	nofm

		mov	al, 0x01
		jmp	chkend
nofm:
		mov	al, 0x02
chkend:
		mov	[0x0DF8], al		; Sound Kind Work
		pop	ds


		mov	ah, 0x25		; hootドライバ登録
		mov	al, int_hoot
		mov	dx, vect_hoot
		int	0x21

		mov	dx, HOOTFUNC
		mov	al, HF_ENABLE		; hoot呼び出しを許可
		out	dx, al
		sti

mainloop:
;		mov	ax, 0x9801		; ダミーポーリング
;		int	0x18
		jmp	short mainloop

; hootからコールされる
; inp8(HOOTPORT) = 0 → PC98DOS::Play
; inp8(HOOTPORT) = 2 → PC98DOS::Stop
; _code = inp8(HOOTPORT+2)～inp8(HOOTPORT+5)

vect_hoot:
		pusha
		push	ds
		push	es
		mov	ax, cs
		mov	ds, ax
		mov	es, ax
		mov	dx, HOOTPORT
		in	al, dx
		cmp	al, HP_PLAY
		jz	short .play
		cmp	al, HP_STOP
		jz	short .fadeout
.ed:
		pop	es
		pop	ds
		popa
		iret

.stop:
.fadeout:
		push	ds
		mov	ax, [cs:bufseg]
		mov	ds, ax
		call	far [cs:stpofs]
		pop	ds
		jmp	short .ed

.play:
		mov	ax, [cs:bufseg]
		mov	es, ax
		mov	ds, ax

		xor	ax,ax
		mov	dx,HOOTPORT+2		; 曲番号
		in	al,dx

		push	ds
		call	far [cs:plyofs]
		pop	ds

		jmp	.ed

bufofs:
		dw	0x0100
bufseg:
		dw	0x0000
iniofs:
		dw	0x0132
iniseg:
		dw	0x0000
plyofs:
		dw	0x013D
plyseg:
		dw	0x0000
stpofs:
		dw	0x0186
stpseg:
		dw	0x0000

		align	0x10
		times 0x100 db 0xff		; スタックエリア
stack:

prgend:
;		.ends
