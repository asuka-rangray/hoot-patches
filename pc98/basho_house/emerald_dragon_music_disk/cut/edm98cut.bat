@echo off 

rem EMERALD DRAGON MUSIC DISK (PC98) �h���C�o�؂�o���pBAT�t�@�C��
 
if "%1"=="" goto usage
d88cut %1 MAIN 0 1 1 0x3000
goto fin

:usage
echo EMERALD DRAGON(PC98)�h���C�o�؂�o���p�o�b�`�t�@�C��
echo ed98cut [Visual Disk D88 image]
echo ���ȃf�[�^�� vdcuth [D88 image]�Ƃ��Đ؂�o���Ă��������B

:fin
