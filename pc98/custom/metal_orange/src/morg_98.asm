; Terpsichorean98 (C) Metal Orange専用
; メインルーチン (for NASM)
;
; 黒羽氏のTRPSCR98.ASMを改変しました

%include 'hoot.inc'
int_hoot	equ	0x7F
int_driver	equ	0x2f

		ORG	0x0100
		USE16
		CPU	186

start:
		cli
		mov	ax,cs
		mov	ds,ax
		mov	es,ax

		mov	ah, 0x25		; hootドライバ登録
		mov	al, int_hoot
		mov	dx, vect_hoot
		int	0x21
		sti

mainloop:
		mov	ax, 0x9801		; ダミーポーリング
		int	0x18
		jmp	short mainloop

; hootからコールされる
; inp8(HOOTPORT) = 0 → PC98DOS::Play
; inp8(HOOTPORT) = 2 → PC98DOS::Stop
; _code = inp8(HOOTPORT+2)～inp8(HOOTPORT+5)

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

		mov	ax,0x5934
		mov	bx, 0x03		; 状態変更
		mov	dx, 0x03		; 演奏停止
		int	int_driver

		mov	dx,buff			; ロードアドレス
		xor	bx,bx			; 標準入力
		mov	cx,0xffff		; サイズ
		mov	ah,0x3f			; 曲データ本体のロード (DS:DX)
		int	0x21
		jc	.stop

		mov	ax,0x5934
		mov	bx,0x0002		; 曲データロード (DS:DX)
		mov	dx,buff
		int	int_driver

		mov	ax,0x5934
		mov	bx,0x0003		; 状態変更
		mov	dx,0x0002		; 演奏開始
		int	int_driver

		jmp	short .ed

.play_se:
		mov	dx, HOOTPORT + 2
		in	al, dx

		mov	dl, al
		mov	ax,0x5934
		mov	bx,0x0005		; SE再生
		int	int_driver

		jmp	short .ed

.stop:
		mov	ax,0x5934
		mov	bx,0x03			; 状態変更
		mov	dx,0x03			; 演奏停止
		int	int_driver

		jmp	short .ed

.fadeout:
		mov	ax,0x5934
		mov	bx,0x03		; 状態変更
		mov	dx,0x01		; フェードアウト
		int	int_driver

		jmp	short .ed

buff:					; 以下、曲データバッファ

		ends

