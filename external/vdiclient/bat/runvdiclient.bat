rem Define runvdiclient_log_file variable
for %%? in ("%~dp0..") do set parent_dir=%%~f?
set runvdiclient_log_file=%parent_dir%\runvdiclient.log

echo Will download user data from VDI config srever > %runvdiclient_log_file%
curl --retry 15 --retry-delay 20 http://169.254.169.254/latest/user-data 1> vdiuserdata.bat 2>> %runvdiclient_log_file%
if %ERRORLEVEL% neq 0 (
	echo curl failed to fetch user data from server. >> %runvdiclient_log_file%
	echo 'runvdiclient.bat' script FAILED. >> %runvdiclient_log_file%
	start "VDI Client Error" type %runvdiclient_log_file%
	exit /b 1
)

echo Running unix2dos on downloaded command >> %runvdiclient_log_file%
unix2dos vdiuserdata.bat >> %runvdiclient_log_file%
echo Will run the following VDI user commands: >> %runvdiclient_log_file%
echo ========================================= >> %runvdiclient_log_file%
type vdiuserdata.bat >> %runvdiclient_log_file%
echo ========================================= >> %runvdiclient_log_file%
start "VDI Client" vdiuserdata.bat