rem Connects slave VM to NB Jenkins, using slave.jar downloaded from this Jenkins host
@echo off

for %%? in ("%~dp0..") do set parent_dir=%%~f?
set jenkins_jars_dir=%parent_dir%\jenkins_slave_jars
if not exist "%jenkins_jars_dir%" goto NO_JENKINS_JARS

set nb_jenkins_slave_jar=%jenkins_jars_dir%\nb_slave.jar
set java_classpath=%jenkins_jars_dir%\commons-codec-1.5.jar


java -jar "%nb_jenkins_slave_jar%" -cp "%java_classpath%" %*
goto END

:NO_JENKINS_JARS
echo Cannot locate directory with Jenkins JAR files required to establish connection: '%jenkins_jars_dir%'.
echo This may happen because your vdiclient is old and needs to be updated. 
echo Please run 'svn update' on vdiclient root directory and try re-running the script.
exit /b 1

:END
