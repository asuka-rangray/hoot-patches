// Firecracker Vol.39 (PC88) �t�@�C�����o�v���O����

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "d88.h"

static unsigned char dir[0x100];				// Directory (256byte x 16sector)
static unsigned char buff[0x100*16*80];			// 256byte x 16sector x 80track
static char fname[FILENAME_MAX];				// �؂�o���t�@�C����

D88 disk;
FILE *fp;

bool fcut(char *_fname, int _trk, int _C, int _H, int _R, int _N, int _offset, int _size) {
	if (!disk.ReadDATA(_trk, _C, _H, _R, _N, buff, _size+_offset)) return false;
	fp = fopen(_fname,"wb");
	fwrite(buff + _offset, 1, _size, fp);
	fclose(fp);
	return true;
}

int main(int argc, char *argv[]) {
	int fn;
	int trk,sec,size;

	if (argc < 2) {
		// �I�v�V�����w�肪�Ȃ��Ƃ�
		fprintf(stderr, "Usage: %s [d88file]\n",argv[0]);
		return 1;
	}

	// �t�@�C�����J������G���[�ɂȂ���
	if (!disk.SetFile(argv[1])) {
		fprintf(stderr, "�t�@�C�����I�[�v���ł��܂���\n");
		return 1;
	}

	disk.SelectDisk(0);
	disk.SetRecordRange(0x01,0x10);

	// �h���C�o�EADPCM�؂�o��
	fcut("PMD",   35, 17, 1, 1, 1, 0, 0x2000);
	fcut("ADPCM",  1,  0, 1, 1, 1, 0, 0x13000);

	// �f�B���N�g���̓ǂݍ���
	memset(dir, 0, sizeof(dir));
	if (disk.ReadDATA(0x24, 0x12, 0x00, 0x0f, 0x01, dir, sizeof(dir)) != sizeof(dir)) {
		fprintf(stderr, "�f�B���N�g���̓ǂݍ��݂Ɏ��s���܂���.\n");
		return 1;
	}

	for (fn=0; fn<(sizeof(dir)/4); fn++) {
		unsigned char *ent = &dir[fn*4];
		if (ent[0] == 0x00) break;		// �f�B���N�g���̍Ō�

		char fname[FILENAME_MAX];		// �t�@�C����
		sprintf(fname,"MUS%03d",fn);

		trk  = ent[0x00];
		sec  = ent[0x01];
		size = ent[0x02]*0x100;

		// �؂�o��
		if (fcut(fname, trk, trk>>1, trk&1, sec, 0x01, 0, size)) {
			printf("%6s TRK:%02X SEC:%02X SIZE:%04X\n",fname,trk,sec,size);
		}
	}
	return 0;
}
