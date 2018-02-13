// FireHawk (for MSX) �t�@�C�����o�v���O����

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "d88.h"

static unsigned char dir[0x200*3];				// Directory (512byte x 3sector)
static unsigned char buff[0x200*9*160];			// 512byte x 9sector x 160track
char fname[FILENAME_MAX];						// �؂�o���t�@�C����

D88 disk;
FILE *fp;

bool fcut(char *_fname, int _trk, int _C, int _H, int _R, int _N, int _offset, int _size)
{
	if (!disk.ReadDATA(_trk, _C, _H, _R, _N, buff, _size+_offset)) return false;
	fp = fopen(_fname,"wb");
	fwrite(buff + _offset, 1, _size, fp);
	fclose(fp);
	return true;
}

int main(int argc, char *argv[])
{
	int i,c,fn;
	int s_trk,s_sec,size;

	if (argc != 2) {
		// �I�v�V�����w�肪�Ȃ��Ƃ�
		fprintf(stderr, "Usage: %s [d88file]\n",argv[0]);
		return 1;
	}

	// �t�@�C�����J������G���[�ɂȂ���
	if (!disk.SetFile(argv[1])) {
		fprintf(stderr, "�t�@�C�����I�[�v���ł��܂���\n");
		return 1;
	}

	int numdisk = disk.GetNumDisk();	// �f�B�X�N�C���[�W����

	for (int d=0; d<numdisk; d++)		// �C���[�W�����̏���
	{
		disk.SelectDisk(d);

		// �f�B���N�g���̓ǂݍ���
		disk.SetRecordRange(0x01,0x09);
		// trk:0 c:0 h:0 r:2 n:0
		int size;
		size = disk.ReadDATA(0x00, 0x00, 0x00, 0x05, D88::N_512, dir, sizeof(dir));

		for (fn=0; fn<sizeof(dir)/0x10; fn++)
		{
			unsigned char *ent = &dir[fn*0x10];
			if (*ent == 0xff) break;	// �f�B���N�g���̍Ō�

			if (*ent == 0x00) {
				if (dir[fn*0x10 + 1] == 0x00) {
					continue;
				} else {
					*ent = '_';			// �B���t�@�C���ɂ͐擪��_��ǉ�
				}
			}

			int i;
			int fnp = 0;
			for (i = 0x00; i < 0x08; i++)
			{
				char c = ent[i];				// �t�@�C�������P���������o��
				if (c==' ') break;
				fname[fnp++] = c;				// �t�@�C�������\������
			}
			if (ent[8] != ' ')			// �g���q���K�v�Ȃ�t����
			{
				fname[fnp++] = '.';
			}
			for (i=8; i<0xb; i++)	// �����悤�Ɋg���q�����o��
			{
				char c=ent[i];
				if (c==' ') break;
				fname[fnp++] = c;
			}
			fname[fnp++] = '\0';		// ������̍Ō�

			s_trk  = (*(ent+0x0e) * 2) + (*(ent+0x0f) >> 4);		// �J�n�g���b�N
			s_sec  = (*(ent+0x0f) & 0xf);							// �J�n�Z�N�^
			size   = (*(ent+0x0c) + (*(ent+0x0d) << 8) ) * 0x200;	// �T�C�Y

			printf("%-12s  TRACK:%02x SECTOR:%02x SIZE:%04x\n",fname,s_trk,s_sec,size);
			fcut(fname, s_trk, s_trk>>1, s_trk&1, s_sec, D88::N_512, 0x0000, size);
		}
	}
	return 0;
}
