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

// dword�l��ϐ��ɑ��
static int GetInt(unsigned char *_p)
{
	int ret;

	ret = (_p[3]<<24) + (_p[2]<<16) + (_p[1]<<8) + _p[0];

	return ret;
}

// word�l��ϐ��ɑ��
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

// �f�X�N�g���N�^
D88::~D88()
{
	if (m_fp) {
		fclose(m_fp);
	}
}

/**
 * �t�@�C�����J���ă|�C���^���Z�b�g
 *
 * @param _fname [in] Input file name.
 * @return true / false
 *
 */
bool D88::SetFile(char *_fname)
{
	if (_fname == NULL) {
		fclose(m_fp);			// �����w�肪�Ȃ��Ƃ��́A�I������
		m_fp = NULL;			// �f�B�X�N�C���[�W�̃t�@�C���|�C���^

		m_numdisk = 0;			// �f�B�X�N��
		m_curdisk = -1;			// �I�𒆂̃f�B�X�N�ԍ�(0�`)
		m_disktype = -1;		// �f�B�X�N�^�C�v(2D/2DD/2HD)

		return true;
	}

	m_fp = fopen(_fname, "rb");	// �t�@�C�����J�� (rb=�ǂݏo���ACR/LF�ϊ������Ȃ�)

	if (m_fp == NULL) {			// �J���Ȃ��Ƃ�
		return false;
	}

	int offset = 0;

	for (m_numdisk = 0; m_numdisk < MAX_DISK; m_numdisk++) {	// �f�B�X�N���������J��Ԃ�
		int size;
		unsigned char header[D88_HEADER_SIZE];	// D88�w�b�_���̃������m��

		m_disk_offset[m_numdisk] = offset;	// �f�B�X�N�ԍ����Ƃ̃I�t�Z�b�g�ʒu��z��Ɋi�[

		fseek(m_fp, offset, SEEK_SET);		// �t�@�C���|�C���^���ړ�
		size = fread(header, 1, D88_HEADER_SIZE, m_fp);
		if (size != D88_HEADER_SIZE) {		// D88�w�b�_�̃T�C�Y�ȉ��ɂȂ����Ƃ��ɒ��f
			break;
		}

		offset += GetInt(&header[D88_SIZE]);	// ����D88�w�b�_�̈ʒu���v�Z
	}

	return true;
}

/**
 * 1�g���b�N���̍ŏ�/�ő�Z�N�^����ݒ�
 *
 * �ݒ肵�Ȃ��ƍŏ�1/�ő�16�œ���
 *
 * @param _min [in] �ŏ��Z�N�^
 * @param _max [in] �ő�Z�N�^
 *
 */
void D88::SetRecordRange(int _min, int _max)
{
	m_minrec = _min;
	m_maxrec = _max;
}

/**
 * ���ݑI�𒆂�D88���̃f�B�X�N����Ԃ�
 *
 * @return �f�B�X�N���� (1~)
 */
int D88::GetNumDisk() const
{
	return m_numdisk;
};

/**
 * ���ݑI�𒆂̃f�B�X�N�ԍ���Ԃ�
 *
 * @return �I���f�B�X�N�ԍ� (1~)
 */
int D88::GetCurrentDisk() const
{
	return m_curdisk;
};

/**
 * �w�肵���f�B�X�N�ԍ��̃f�B�X�N���J��
 *
 * @param _diskno [in] �f�B�X�N�ԍ�
 * @return true / false
 *
 */
bool D88::SelectDisk(int _diskno)
{
	unsigned char header[D88_HEADER_SIZE];

	if (m_fp == NULL) {		// D88�t�@�C�����I�[�v������ĂȂ��Ƃ��͏��������߂�
		return false;
	}

	m_curdisk_offset = -1;

	m_curdisk = -1;
	m_disktype = -1;	
	m_disksize = 0;
	m_diskname[0] = '\0';

	if (_diskno > m_numdisk) {	// �w�肵���f�B�X�N�����ۂ̖�����葽���Ƃ��͏��������߂�
		return false;
	}

	m_curdisk_offset = m_disk_offset[_diskno];


	fseek(m_fp, m_curdisk_offset, SEEK_SET);	// �f�B�X�N���V�[�N
	fread(header, 1, D88_HEADER_SIZE, m_fp);
//	      buffer,size(byte),�ő吔,   stream

	for (int trk = 0; trk < 164; trk++) {		// �g���b�N�ʒu��z��Ɏ�荞��
		m_trk[trk] = GetInt(&header[D88_TRACK + trk*4]);
	}

	m_disktype = header[D88_TYPE];				// �f�B�X�N�^�C�v���擾
	m_disksize = GetInt(&header[D88_SIZE]);		// �f�B�X�N�T�C�Y���擾
	strncpy(m_diskname, (char *)&header[D88_NAME], 16);	// �f�B�X�N����ϐ��ɃR�s�[

	return true;
}

/**
 * �f�B�X�N����Ԃ�
 *
 * @return �f�B�X�N��
 *
 */
const char *D88::GetDiskName() const
{
	return m_diskname;
}

/**
 * �f�B�X�N�^�C�v��Ԃ�
 *
 * @return �f�B�X�N�^�C�v
 *
 */
int D88::GetDiskType() const
{
	return m_disktype;
}

/**
 * ReadDATA1
 * �g���b�N���w�肵��1�Z�N�^��ǂݍ���
 *
 * @param _trk [in] Track number.
 * @param _C [in] Cyrinder
 * @param _H [in] Head
 * @param _N [in] Num of sector.
 * @parma _buffer [out] Buffer pointer.
 * @param _size [in] Buffer size.
 * @return Read size.
 *
 */
int D88::ReadDATA1(int _trk, int _C, int _H, int _R, int _N, unsigned char *_buffer, int _size)
{
	if (m_fp == NULL) {		// �t�@�C�����J���ĂȂ��ꍇ�͖߂�
		return 0;
	}

	if (_trk >= 164 || m_trk[_trk] == 0 || m_trk[_trk] > m_disksize) {
		return 0;			// �g���b�N�w�肪���������Ƃ��͖߂�
	}

	fseek(m_fp, m_curdisk_offset + m_trk[_trk], SEEK_SET);	// �t�@�C���V�[�N

	for (int sec = 0;; sec++) {		// �Z�N�^�����J��Ԃ�
		unsigned char header[16];

		fread(header, 1, 16, m_fp);	// ID���ǂݎ��

#ifdef STRICT_CHECK
		for (int i = 0x09; i <= 0x0e; i++) {
			if (header[i] != 0) {
				return 0;
			}
		}
#endif

		int C = header[0];
		int H = header[1];
		int R = header[2];
		int N = header[3];
		int maxsec = GetShort(&header[0x04]);	// �ő�Z�N�^��
		int size = GetShort(&header[0x0e]);		// �Z�N�^�T�C�Y

		if (maxsec == 0) {		// �ЂƂ��Z�N�^������܂���
			break;
		}

		if (C == _C && H == _H && R == _R && N == _N) { // �w�肵���Z�N�^�ɓ��B�����Ƃ�
			if (size > _size) {	// ���ۂ̃Z�N�^���w�肳�ꂽ�ǂݎ��f�[�^�����傫�������ꍇ��
				size = _size;	// �Z�N�^�T�C�Y�܂œǂݍ���
			}

			fread(_buffer, 1, size, m_fp);	// �f�B�X�N�C���[�W����ǂ��_buffer�Ɋi�[

			return size;					// ���ۂɓǂݍ��񂾃T�C�Y��Ԃ��Ă����
		} else {
			fseek(m_fp, size, SEEK_CUR);	// ���ۂ̃Z�N�^�܂œ��B���ĂȂ����̓V�[�N���p��
		}

		if (sec == maxsec - 1) {	// ����ȏ�Z�N�^���Ȃ��Ƃ��͒��f
			break;
		}
	}

	return 0;
}

/**
 * ReadDATA
 * �w�肵���ʒu����]���o�b�t�@�֎w�肵���T�C�Y��ǂݍ���
 *
 * @param _trk [in] Track number
 * @param _C [in] Cyrinder
 * @param _H [in] Head
 * @param _R [in] Record
 * @param _N [in] Num of sector
 * @param _buffer [out] Buffer pointer
 * @param _size [in] Buffer size
 * @return Read size.
 *
 */
int D88::ReadDATA(int _trk, int _C, int _H, int _R, int _N, unsigned char *_buffer, int _size)
{
	int trk = _trk;		// �g���b�N�ԍ�
	int C = _C;			// C
	int H = _H;			// H
	int R = _R;			// R
	int N = _N;			// N
	unsigned char *buffer = _buffer;	// �΂��ӂ�
	int size = 0;		// ���ۂɓǂݍ��߂��T�C�Y

	int secsize = 0x80 << _N;	// �Z�N�^�T�C�Y��N�̒l����v�Z N=1�̂Ƃ�256
	int r;

	while (size < _size) {		// �w�肵���T�C�Y��ǂނ܂ŌJ��Ԃ�
		// �Ō�̒[���̓ǂݍ��ރo�C�g�����v�Z
		if (secsize > _size - size) {
			secsize = _size - size;
		}
		// 1�Z�N�^���ǂݍ���
		r = ReadDATA1(trk, C, H, R, N, buffer, secsize);
		// �Ō�̒[�������܂œǂݍ��݂��������A���ۂɓǂݎ�����T�C�Y��Ԃ��Ă����
		if (r < secsize) {
			return size;
		}

		buffer += secsize;	// �o�b�t�@�̈ʒu���X�V
		size += secsize;	// ���ۂɓǂݍ��񂾃T�C�Y���X�V

		// ���̃Z�N�^���Z�N�^���̍ő�g���b�N�����z���Ă����ꍇ
		if (R == m_maxrec) {
			trk++;			// ���̃g���b�N
			if (H == 0) {
				H = 1;		// ���ʂ�
			} else {
				H = 0;		// �\�ʂɂ���C�̒l��+1
				C++;
			}
			R = m_minrec;	// R���ŏ��̃Z�N�^�ԍ��ɂ��킹��
		} else {
			R++;			// ���̃Z�N�^�ɂ��킹��
		}
	}

	return size;			// �ǂݍ��񂾃o�C�g����Ԃ��Ă����
}

/**
 * ReadID
 * �w��g���b�N��ID����S�ēǂݍ���
 *
 * @param _trk [in] Track number
 * @param _buffer [out] Buffer pointer
 * @param _size [in] Buffer size
 * @return
 *
 */
int D88::ReadID(int _trk, unsigned char *_buffer, int _size)
{
	// �w��Ȃ��̂Ƃ�
	if (m_fp == NULL) {
		return 0;
	}

	// �w�肵���g���b�N�̃G���[�`�F�b�N
	if (_trk >= 164 || m_trk[_trk] == 0 || m_trk[_trk] > m_disksize) {
		return 0;
	}

	// �f�B�X�N�̃V�[�N
	fseek(m_fp, m_curdisk_offset + m_trk[_trk], SEEK_SET);

	int ret = 0;

	// �w��T�C�Y�ɂȂ�܂ŌJ��Ԃ�
	for (int sec = 0; sec*4 < _size; sec++) {
		unsigned char header[16];

		// ID���ǂݎ��
		fread(header, 1, 16, m_fp);

#ifdef STRICT_CHECK
		for (int i = 0x09; i <= 0x0e; i++) {
			if (header[i] != 0) {
				return 0;
			}
		}
#endif
		// �ǂݎ�����l��ϐ��ɃZ�b�g
		int C = header[0];
		int H = header[1];
		int R = header[2];
		int N = header[3];
		int maxsec = GetShort(&header[0x04]);
		int size = GetShort(&header[0x0e]);

		// ���ꂼ��̒l���o�b�t�@�ɃZ�b�g
		_buffer[sec*4 + 0] = C;
		_buffer[sec*4 + 1] = H;
		_buffer[sec*4 + 2] = R;
		_buffer[sec*4 + 3] = N;

		// �ǂݍ��񂾃T�C�Y���J�E���g
		ret += 4;

		// ���݈ʒu���擾
		fseek(m_fp, size, SEEK_CUR);

		// �ŏI�Z�N�^�̏ꍇ�͔�����
		if (sec == maxsec - 1) {
			break;
		}
	}

	// �ǂݍ��񂾃T�C�Y��Ԃ��Ă����
	return ret;
}
