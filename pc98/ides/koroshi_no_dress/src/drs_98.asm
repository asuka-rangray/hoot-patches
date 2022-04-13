; DRSMUS.EXE 演奏
; (C) RuRuRu
; 2008/07/02 1st Release
;
; HOOTPORT + 2‾3 : ファイルハンドル番号
; HOOTPORT + 4   : 曲番号
; HOOTPORT + 5   : ループ有無
;

%include 'hoot.inc'
int_hoot	equ	0x7F
int_driver	equ	0xF1

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

		mov	ah, 0x25		; hootドライバ登録
		mov	al, int_hoot
		mov	dx, vect_hoot
		int	0x21

		mov	dx, HOOTFUNC
		mov	al, HF_ENABLE		; hoot呼び出しを許可
		out	dx, al
		sti

mainloop:
		mov	ax, 0x9801		; ダミーポーリング
		int	0x18
		jmp	short mainloop

; hootからコールされる
; inp8(HOOTPORT) = 0 → PC98DOS::Play
; inp8(HOOTPORT) = 2 → PC98DOS::Stop
; _code = inp8(HOOTPORT+2)〜inp8(HOOTPORT+5)

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
		mov	al, 0x01		; 停止
		int	int_driver
		jmp	short .ed


.play:
		mov	al, 0x01		; 停止
		int	int_driver

		mov	ah, 0x3f		; AH=3F conin read
		xor	bx, bx
		mov	cx, 0x50-1
		mov	dx, filename
		int	0x21
		jc	.ed
		mov	bx,ax
		mov	[filename+bx], byte 0

		mov	bx, filename
		mov	al, 0x00		; ファイルロード[DS:BX] & 再生
		int	int_driver

		jmp	.ed

filename:
		times 0x50 db 0x00		; ファイル名格納用バッファ

		align	0x10
		times 0x100 db 0xff		; スタックエリア

stack:

prgend:
		ends

