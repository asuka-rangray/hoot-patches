#include <stdio.h>
#include <string.h>

#include "d88.h"

//#define STRICT_CHECK

#define D88_HEADER_SIZE (0x20 + 4 * 164)	// D88�w�b�_�̃T�C�Y
#define D88_NAME	(0)						// �f�B�X�N���̈ʒu
#define D88_PROTECT	(0x1a)					// ���C�g�v���e�N�g�̗L���̈ʒu (0:�Ȃ� 1:����)
#define D88_TYPE	(0x1b)					// �f�B�X�N�̎�ނ̈ʒu(00H:2D 10H:2DD 20H:2HD)
#define D88_SIZE	(0x1c)					// �f�B�X�N�̃T�C�Y�̈ʒu(DWORD)
#define D88_TRACK	(0x20)					// �g���b�N�f�[�^�e�[�u���̐擪�̈ʒu

// dword�l���擾
static int GetInt(unsigned char *_p)
{
	int ret;

	ret = (_p[3]<<24) + (_p[2]<<16) + (_p[1]<<8) + _p[0];

	return ret;
}

// word�l���擾
static int GetShort(unsigned char *_p)
{
	int ret;

	ret = (_p[1]<<8) + _p[0];

	return ret;
}

// �R���X�g���N�^
D88::D88()
{
	m_fp = NULL;

	m_minrec = 1;
	m_maxrec = 16;

	m_curdisk = -1;
	m_numdisk = 0;
	m_disktype = -1;

	m_diskname[16] = '\0';
}

// �f�X�g���N�^
D88::~D88()
{
	if (m_fp) fclose(m_fp);
}

// D88�t�@�C���̏���
bool D88::SetFile(char *_fname)
{
	// �����w�肪�Ȃ��Ƃ��́A�I������������
	if (_fname == NULL)
	{
		fclose(m_fp);
		m_fp = NULL;
		m_numdisk = 0;
		m_curdisk = -1;
		m_disktype = -1;
		return true;
	}

	// D88�t�@�C���I�[�v��(�o�C�i�����[�h/�ǂݍ���)
	m_fp = fopen(_fname, "rb");
	if (m_fp == NULL) return false;

	int offset = 0;

	// �f�B�X�N���������[�v
	for (m_numdisk = 0; m_numdisk < MAX_DISK; m_numdisk++)
	{
		int size;
		// D88�w�b�_���̃������m��
		unsigned char header[D88_HEADER_SIZE];
		// �f�B�X�N�ԍ����Ƃ̃I�t�Z�b�g�ʒu���i�[
		m_disk_offset[m_numdisk] = offset;

		// �e�f�B�X�N�̐擪�փV�[�N
		fseek(m_fp, offset, SEEK_SET);
		size = fread(header, 1, D88_HEADER_SIZE, m_fp);
		// D88�w�b�_�̃T�C�Y�ȉ��ɂȂ����Ƃ��ɒ��f
		if (size != D88_HEADER_SIZE) break;
		// ����D88�w�b�_�̈ʒu���v�Z
		offset += GetInt(&header[D88_SIZE]);
	}
	return true;
}

// �ŏ�/�ő�Z�N�^�ԍ����Z�b�g
void D88::SetRecordRange(int _min, int _max)
{
	m_minrec = _min;
	m_maxrec = _max;
}

// ���ݑI�𒆂�D88���̃f�B�X�N����Ԃ�
int D88::GetNumDisk() const
{
	return m_numdisk;
};

// ���ݑI�𒆂�D88���̃f�B�X�N�ԍ���Ԃ�
int D88::GetCurrentDisk() const
{
	return m_curdisk;
};

// �w�肵���f�B�X�N�ԍ��̃f�B�X�N���J��
bool D88::SelectDisk(int _diskno)
{
	unsigned char header[D88_HEADER_SIZE];

	// D88�t�@�C�����J���Ă��邩?
	if (m_fp == NULL) return false;

	m_curdisk_offset = -1;

	m_curdisk = -1;
	m_disktype = -1;
	m_disksize = 0;
	m_diskname[0] = '\0';

	// �w�肵���f�B�X�N�����ۂ̖�����葽���ꍇ�͒��f
	if (_diskno > m_numdisk) return false;

	m_curdisk_offset = m_disk_offset[_diskno];

	// �V�[�N
	fseek(m_fp, m_curdisk_offset, SEEK_SET);

	// D88�w�b�_���ǂݍ���
	fread(header, 1, D88_HEADER_SIZE, m_fp);
	// �e�g���b�N�̃I�t�Z�b�g�ʒu���擾
	for (int trk = 0; trk<164; trk++)
	{
		m_trk[trk] = GetInt(&header[D88_TRACK + trk*4]);
	}

	// �f�B�X�N�^�C�v���擾
	m_disktype = header[D88_TYPE];
	// �f�B�X�N�T�C�Y���擾
	m_disksize = GetInt(&header[D88_SIZE]);
	// �f�B�X�N�����R�s�[
	strncpy(m_diskname, (char *)&header[D88_NAME], 16);

	return true;
}

// �f�B�X�N����Ԃ�
const char *D88::GetDiskName() const
{
	return m_diskname;
}

// �f�B�X�N�^�C�v��Ԃ�
int D88::GetDiskType() const
{
	return m_disktype;
}

// ReadDATA1
// �w�肵��1�Z�N�^��ǂݍ���
int D88::ReadDATA1(int _trk, int _C, int _H, int _R, int _N, unsigned char *_buffer, int _size)
{
	// �t�@�C�����J���ĂȂ��ꍇ�͖߂�
	if (m_fp == NULL) return 0;

	// �g���b�N�w�肪���������Ƃ��͖߂�
	if (_trk >= 164 || m_trk[_trk] == 0 || m_trk[_trk] > m_disksize) return 0;

	// �t�@�C���V�[�N
	fseek(m_fp, m_curdisk_offset + m_trk[_trk], SEEK_SET);

	// �Z�N�^�������[�v
	for (int sec = 0;; sec++)
	{
		unsigned char header[16];

		// ID���ǂݎ��
		fread(header, 1, 16, m_fp);

#ifdef STRICT_CHECK
		for (int i = 0x09; i <= 0x0e; i++)
		{
			if (header[i] != 0) return 0;
		}
#endif

		int C = header[0];
		int H = header[1];
		int R = header[2];
		int N = header[3];
		int maxsec = GetShort(&header[0x04]);	// �ő�Z�N�^��
		int size = GetShort(&header[0x0e]);		// �Z�N�^�T�C�Y

		// �ЂƂ��Z�N�^���Ȃ��ꍇ
		if (maxsec == 0) break;

		// �w�肵���Z�N�^�����������Ƃ�
		if (C == _C && H == _H && R == _R && N == _N)
		{
		 	// ���ۂ̃Z�N�^���w�肳�ꂽ�T�C�Y���傫�������ꍇ�́A�w�肳�ꂽ�T�C�Y�܂œǂݍ���
			if (size > _size) size = _size;

			// �f�B�X�N�C���[�W����ǂݍ���
			fread(_buffer, 1, size, m_fp);
			// ���ۂɓǂݍ��񂾃T�C�Y��Ԃ��Ă����
			return size;
		}
		else
		{
			// ���̃Z�N�^�փV�[�N���p��
			fseek(m_fp, size, SEEK_CUR);
		}
		// ����ȏ�Z�N�^���Ȃ��Ƃ��͒��f
		if (sec == maxsec - 1) break;
	}
	return 0;
}

// Read DATA
// �f�B�X�N�C���[�W����̓ǂݍ���
int D88::ReadDATA(int _trk, int _C, int _H, int _R, int _N, unsigned char *_buffer, int _size)
{
	int trk = _trk;		// �g���b�N�ԍ�
	int C = _C;			// C
	int H = _H;			// H
	int R = _R;			// R
	int N = _N;			// N
	unsigned char *buffer = _buffer;	// �΂��ӂ�
	int size = 0;		// ���ۂɓǂݍ��߂��T�C�Y

	// �Z�N�^�T�C�Y��N�̒l����v�Z (N=1�̂Ƃ�256)
	int secsize = 0x80 << _N;
	int r;

	// �w�肵���T�C�Y��ǂނ܂ŌJ��Ԃ�
	while (size < _size)
	{
		// �Ō�̒[���̓ǂݍ��ރo�C�g�����v�Z
		if (secsize > _size - size) secsize = _size - size;
		// 1�Z�N�^���ǂݍ���
		r = ReadDATA1(trk, C, H, R, N, buffer, secsize);
		// �Ō�̒[�������܂œǂݍ��݂��������A���ۂɓǂݎ�����T�C�Y��Ԃ��Ă����
		if (r < secsize) return size;

		// �o�b�t�@�̈ʒu���X�V
		buffer += secsize;
		// ���ۂɓǂݍ��񂾃T�C�Y���X�V
		size += secsize;

		// ���̃Z�N�^���Z�N�^�����z���Ă����ꍇ
		if (R == m_maxrec)
		{
			trk++;			// ���̃g���b�N��
			if (H == 0)
			{
				H = 1;		// ���ʂ�
			}
			else
			{
				H = 0;		// �\�ʂɂ���C�̒l��+1
				C++;
			}
			R = m_minrec;	// R���ŏ��̃Z�N�^�ԍ��ɂ��킹��
		}
		else
		{
			R++;			// ���̃Z�N�^��
		}
	}
	// �ǂݍ��񂾃T�C�Y��Ԃ��Ă����
	return size;
}

// Read ID
// �w��g���b�N��ID����S�ēǂݍ���
int D88::ReadID(int _trk, unsigned char *_buffer, int _size)
{
	// �t�@�C�����J���ĂȂ��ꍇ�͖߂�
	if (m_fp == NULL) return 0;

	// �g���b�N�w�肪���������Ƃ��͖߂�
	if (_trk >= 164 || m_trk[_trk] == 0 || m_trk[_trk] > m_disksize) return 0;

	// �f�B�X�N�̃V�[�N
	fseek(m_fp, m_curdisk_offset + m_trk[_trk], SEEK_SET);

	int ret = 0;

	// �w��T�C�Y�ɂȂ�܂ŌJ��Ԃ�
	for (int sec = 0; sec*4 < _size; sec++)
	{
		unsigned char header[16];

		// ID���ǂݎ��
		fread(header, 1, 16, m_fp);

#ifdef STRICT_CHECK
		for (int i = 0x09; i <= 0x0e; i++)
		{
			if (header[i] != 0) return 0;
		}
#endif
		// �ǂݎ����ID���擾
		int C = header[0];
		int H = header[1];
		int R = header[2];
		int N = header[3];
		int maxsec = GetShort(&header[0x04]);
		int size = GetShort(&header[0x0e]);

		// ���ꂼ��̒l���o�b�t�@�ɏ�������
		_buffer[sec*4 + 0] = C;
		_buffer[sec*4 + 1] = H;
		_buffer[sec*4 + 2] = R;
		_buffer[sec*4 + 3] = N;

		// �ǂݍ��񂾃T�C�Y���J�E���g
		ret += 4;

		// ���݈ʒu���擾
		fseek(m_fp, size, SEEK_CUR);

		// �ŏI�Z�N�^�̏ꍇ�̓��[�v�𔲂���
		if (sec == maxsec - 1)
		{
			break;
		}
	}
	// �ǂݍ��񂾃T�C�Y��Ԃ��Ă����
	return ret;
}

