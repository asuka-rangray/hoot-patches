// BirdySoft�n (for MSX) �t�@�C�����o�v���O����

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "d88.h"

static unsigned char dir[0x200*5];				// Directory (512yte x 5sector)
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
		size = disk.ReadDATA(0x00, 0x00, 0x00, 0x02, 0x2, dir, 0x0a00);

		int count = 1;
		for (fn=0; fn<sizeof(dir)/0x0a; fn++)
		{
			unsigned char *ent = &dir[count];
			if (*ent == 0xff) break;	// �f�B���N�g���̍Ō�

			int i;
			int fnp = 0;
			for (i = 0x00; i < 0x06; i++)		// �ő�6
			{
				char c = ent[i];				// �t�@�C�������P���������o��
				if (c==' ') {
				} else {
					fname[fnp++] = c;				// �t�@�C�������\������
				}
			}
			count += i;
			fname[fnp] = '\0';		// ������̍Ō�

			s_trk  = *(ent+0x06) + (*(ent+0x07) << 8);	// �J�n�g���b�N
			s_sec  = s_trk % 9 + 1;						// �J�n�Z�N�^
			s_trk  = s_trk / 9;
			size   = *(ent+0x08) * 0x200;				// �T�C�Y

			printf("%02x %02x %02x\n", *(ent+6), *(ent+7), *(ent+8) );
			count += 3;
			printf("%-12s  TRACK:%02x SECTOR:%02x SIZE:%04x\n",fname,s_trk,s_sec,size);
			fcut(fname, s_trk, s_trk>>1, s_trk&1, s_sec, D88::N_512, 0x0000, size);
		}
	}
	return 0;
}
