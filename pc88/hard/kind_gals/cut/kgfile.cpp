// Hard Kind Gal's(for PC88) ファイル抽出プログラム

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "d88.h"

static unsigned char dir[0x1000];				// Directory (2048byte)
static unsigned char buff[0x400*5*84];			// 1024byte x 5sector x 84track
char fname[FILENAME_MAX];						// 切り出しファイル名

D88 disk;
FILE *fp;

bool fcut(char *_fname, int _trk, int _C, int _H, int _R, int _N, int _offset, int _size)
{
	int rsize;
	memset(buff, 0, sizeof(buff));
	rsize = disk.ReadDATA(_trk, _C, _H, _R, _N, buff, _size+_offset);
	if (rsize == 0) {
		return false;
	}
	fp = fopen(_fname,"wb");
	fwrite(buff + _offset, 1, _size, fp);
	fclose(fp);
	return true;
}

int main(int argc, char *argv[])
{
	int fn;
	int s_trk,s_sec,size,sadr,eadr;

	if (argc != 2) {
		// オプション指定がないとき
		fprintf(stderr, "Usage: %s [d88file]\n",argv[0]);
		return 1;
	}

	// ファイルを開いたらエラーになった
	if (!disk.SetFile(argv[1])) {
		fprintf(stderr, "ファイルをオープンできません\n");
		return 1;
	}

	int numdisk = disk.GetNumDisk();	// ディスクイメージ枚数

	for (int d=0; d<numdisk; d++)		// イメージ数分の処理
	{
		disk.SelectDisk(d);

		// ディレクトリの読み込み
		disk.SetRecordRange(0x01,0x10);
		disk.ReadDATA(0x01, 0x00, 0x01, 0x01, D88::N_1024, dir, 0x1000);
		disk.SetRecordRange(0x01,0x05);
		for (fn=0; fn<sizeof(dir)/0x10; fn++)
		{
			unsigned char *ent = &dir[fn*0x10];
			if (*ent == 0xff) break;	// ディレクトリの最後

			int fnp = 0;
			for (int i = 0x00; i < 0x06; i++)
			{
				char c = ent[i];				// ファイル名を１文字ずつ取り出す
				if (c==' ') break;
				fname[fnp++] = c;				// ファイル名を構成する
			}
			if (ent[6] != ' ')			// 拡張子が必要なら付ける
			{
				fname[fnp++] = '.';
			}
			for (int i=6; i<9; i++)	// 同じように拡張子を取り出す
			{
				char c=ent[i];
				if (c==' ') break;
				fname[fnp++] = c;
			}
			fname[fnp++] = '\0';		// 文字列の最後

			s_trk  = *(ent+0x0e);	// 開始トラック
			s_sec  = *(ent+0x0f);	// 開始セクタ
			sadr = *(ent+0x0b)*0x100 + *(ent+0x0a);		// 開始アドレス
			eadr = *(ent+0x0d)*0x100 + *(ent+0x0c);		// 終了アドレス
			size = eadr - sadr + 1;

			if (fname[0]  != 0x00 && s_trk != 0xff) {
				printf("%-9s  TRACK:%02x SECTOR:%02x ADR:%04x SIZE:%04x\n",fname,s_trk,s_sec,sadr,size);
				fcut(fname, s_trk, s_trk>>1, s_trk&1, s_sec, D88::N_1024, 0x0000, size);
			}
		}
	}
	return 0;
}
