rem sleep 60 to wait the machine stable
sleep 60
sc config ec2config start= disabled
sleep 60
rem initiate retry number
set retryNumber=0
rem check svn
cd bat
svn sw https://subversion.devfactory.com/repos/webeeh/gdevVDI/trunk/external/vdiclient/bat --username vdiclient --password HqqRSNb5tKL9 --non-interactive
if %errorlevel% neq 0 GOTO RETRY
GOTO RUN_VDICLIENT

GOTO END

:SVN_RETRY
sleep 30
svn sw https://subversion.devfactory.com/repos/webeeh/gdevVDI/trunk/external/vdiclient/bat --username vdiclient --password HqqRSNb5tKL9 --non-interactive
if %errorlevel% neq 0 GOTO RETRY
GOTO RUN_VDICLIENT

:RETRY
rem increase retry number
set /a retryNumber=%retryNumber%+1
if %retryNumber% LSS 20 (GOTO SVN_RETRY)
if %retryNumber% EQU 20 (GOTO END)

:RUN_VDICLIENT
cd..
rem run vdiclient
bat\runvdiclient.bat

:END
cd..
