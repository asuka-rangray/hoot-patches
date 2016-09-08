// ����̂��������킬�I(PC88) �t�@�C���J�b�^�[

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "d88.h"
#define	getword(x)	(buff[x]+buff[x+1]*0x100)

static unsigned char dir[0x800];				// Directory (2048byte)
static unsigned char buff[0x100*16*80];

D88 disk;
FILE *fp;

bool fcut(char *_fname, int _trk, int _C, int _H, int _R, int _N, int _offset, int _size) {
	if (!disk.ReadDATA(_trk, _C, _H, _R, _N, buff, _size+_offset)) return false;
//	printf ("cutting ... %s\n",_fname);
	fp = fopen(_fname,"wb");
	fwrite(buff + _offset, 1, _size, fp);
	fclose(fp);
	return true;
}

bool msave(char *_fname, unsigned char *_adr, int _size) {
	printf ("cutting ... %s\n",_fname);
	fp = fopen(_fname,"wb");
	fwrite(_adr, 1, _size, fp);
	fclose(fp);
	return true;
}

struct fpos {
	int trk;
	int sec;
	int size;
};

int main(int argc, char *argv[])
{
	char fname[FILENAME_MAX];
	int i,d;
	unsigned char id[]="HARE88:";

	if (argc != 2) {
		// �I�v�V�����w�肪�Ȃ��Ƃ�
		fprintf(stderr, "Usage: %s [d88file]\n",argv[0]);
		return 1;
	}

	if (!disk.SetFile(argv[1])) {
		fprintf(stderr, "�t�@�C�����I�[�v���ł��܂���.\n");
		return 1;
	}

	int numdisk = disk.GetNumDisk();
	for (d=0; d<numdisk; d++) {
		disk.SelectDisk(d);
		disk.SetRecordRange(0x01,0x10);
		// �f�B�X�N����
		disk.ReadDATA(0x00, 0x00, 0x00, 0x01, 0x01, buff, 0x100);
		if (!memcmp(&buff[0xf8], id, sizeof(id)-1)) {
			int adr,HL,DE,H,L,A;
			switch (buff[0xff]) {
			case 'A':
				printf("Disk A��F�����܂���.");
				// �o�[�W��������
				disk.ReadDATA(0x00, 0x00, 0x00, 0x03, 0x01, buff, 0x0d00);
				switch (getword(0x0117)) {
				case 0x6265:
					printf("(Type A)\n");
					DE = 0xe9eb;							// �f�R�[�h�L�[�����l(Type A)
					break;

				case 0x2a08:
					printf("(Type B)\n");
					DE = 0x1cdb;							// �f�R�[�h�L�[�����l(Type B)
					break;

				default:
					printf("\n���Ή��̃o�[�W�����ł�.");
					return 2;
				}

				// Track 76�`78��ǂݍ���
				disk.ReadDATA(0x4c, 0x26, 0x00, 0x01, 0x01, buff, 0x2400);

				for (adr=0; adr<0x2400; adr++) {
					HL = (DE*7) & 0xffff;					// ADD HL,HL/ADD HL,DE/ADD HL,HL/ADD HL,DE
					H = HL >> 8;
					L = HL & 0xff;
					DE = L*0x100+H;							// LD E,H / LD D,L
					H = ((H << 2) & 0xfc) | (H >> 6);		// RLC H x2
					L = (L >> 1) | ((L & 1) << 7);			// RRC L
					HL = H*0x100+L;
					DE = (HL + DE + 0x1119) & 0xffff;		// ADD HL,DE / LD DE,1119H / ADD HL,DE
					A = DE>>8;
					buff[adr] ^= A;							// �f�R�[�h
				}
				// �T�E���h�h���C�o�����o��
				msave("driver.bin", &buff[0x700], 0x600*2);
				break;

			case 'B':
				printf("Disk B��F�����܂���.\n");
				break;

			case 'C':
				printf("Disk C��F�����܂���.\n");
				break;

			default:
				break;
			}
		}

		// �f�B���N�g���̓ǂݍ���
        int fn;
        int s_trk,s_sec,size;
		disk.SetRecordRange(0x01,0x10);
		disk.ReadDATA(0x01, 0x00, 0x01, 0x01, 0x01, dir, 0x0800);
        for (fn=0; fn<sizeof(dir)/0x10; fn++) {
			unsigned char *ent = &dir[fn*0x10];
			if (*ent == 0xff) break;	// �f�B���N�g���̍Ō�

			int i;
			int fnp = 0;
			for (i = 0x00; i < 0x06; i++)
			{
				char c = ent[i];				// �t�@�C�������P���������o��
				if (c==' ') break;
				fname[fnp++] = c;				// �t�@�C�������\������
			}
			if (ent[6] != ' ')			// �g���q���K�v�Ȃ�t����
			{
				fname[fnp++] = '.';
			}
			for (i=6; i<9; i++)	// �����悤�Ɋg���q�����o��
			{
				char c=ent[i];
				if (c==' ') break;
				fname[fnp++] = c;
			}
			fname[fnp++] = '\0';		// ������̍Ō�

			s_trk  = *(ent+0x09);		// �J�n�g���b�N
			s_sec  = *(ent+0x0a);		// �J�n�Z�N�^
			size   = *(ent+0x0e)*0x100 + *(ent+0x0d);	// �T�C�Y

			printf("cutting ... %-9s\n",fname);
//			printf("%-9s  TRACK:%02x SECTOR:%02x SIZE:%04x\n",fname,s_trk,s_sec,size);
			fcut(fname, s_trk, s_trk>>1, s_trk&1, s_sec, 0x01, 0x0000, size);
		}
    }
	return 0;
}

