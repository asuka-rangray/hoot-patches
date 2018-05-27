// THEXDER (for FM7) �t�@�C�����o�v���O����

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "d88.h"

static unsigned char dir[0x800];				// Directory (2048byte)
static unsigned char head[0x100];				// File Header (256byte)
static unsigned char buff[0x200*10*80];			// 512byte x 10sector x 80track
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
	int fn;
	int s_trk,s_sec,size,offs;

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
		disk.SetRecordRange(0x01,0x10);
		disk.ReadDATA(0x02, 0x01, 0x00, 0x04, 0x01, dir, 0x0800);
		for (fn=0; fn<sizeof(dir)/0x20; fn++)
		{
			unsigned char *ent = &dir[fn*0x20];
			if (*ent == 0xff) break;	// �f�B���N�g���̍Ō�

			int i;
			int fnp = 0;
			for (i = 0x00; i < 0x08; i++)
			{
				char c = ent[i];				// �t�@�C�������P���������o��
				if (c==' ') break;
				if (c==00) c='_';
				fname[fnp++] = c;				// �t�@�C�������\������
			}
			fname[fnp++] = '\0';		// ������̍Ō�

			s_trk  = *(ent+0x0e)/2+4;		// �J�n�g���b�N
			s_sec  = *(ent+0x0e)%2*8+1;		// �J�n�Z�N�^

			disk.ReadDATA(s_trk, s_trk>>1, s_trk&1, s_sec, 0x01, head, 0x100);

			int fileofs;
			if ( head[0] ) {
				size   = *(head+0x02)*0x100 + *(head+0x03);	// �T�C�Y
				offs   = 0;								   	// �������I�t�Z�b�g
				fileofs = 6;
			} else {
				size   = *(head+0x01)*0x100 + *(head+0x02);	// �T�C�Y
				offs   = *(head+0x03)*0x100 + *(head+0x04);	// �������I�t�Z�b�g
				fileofs = 5;
			}
			if (size == 0xffff) size = 0x100;

			printf("%-9s  TRACK:%02x SECTOR:%02x SIZE:%04x MEMOFS:%04x\n",fname,s_trk,s_sec,size,offs);
			fcut(fname, s_trk, s_trk>>1, s_trk&1, s_sec, 0x01, fileofs, size);
		}
	}
	return 0;
}
