@echo off
rem This file was created by pub v2.10.4.
rem Package: devtools
rem Version: 0.9.3+4
rem Executable: devtools
rem Script: devtools
if exist "C:\dev\flutter\.pub-cache\global_packages\devtools\bin\devtools.dart-2.10.4.snapshot" (
  dart "C:\dev\flutter\.pub-cache\global_packages\devtools\bin\devtools.dart-2.10.4.snapshot" %*
  rem The VM exits with code 253 if the snapshot version is out-of-date.	
  rem If it is, we need to delete it and run "pub global" manually.	
  if not errorlevel 253 (	
    exit /b %errorlevel%	
  )
  pub global run devtools:devtools %*
) else (
  pub global run devtools:devtools %*
)
