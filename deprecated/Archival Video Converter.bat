@@ -1,378 +0,0 @@
@echo off
title Archival Video Converter
if not defined in_subprocess (cmd /k set in_subprocess=y ^& %0 %*) & exit
setlocal enabledelayedexpansion



rem ==========[ Config ]==========

rem Override userDelete variable and skip input
rem "userDeletion=" Ask for user input
rem "userDeletion=2" Skip user input and pretend user input is 2
set "userDeletion="

rem Video rotation
rem 0 = 0deg
rem 1 = 90deg
rem 2 = 180deg
rem 3 = 270deg
set "rotation="

rem Override userCodec variable and skip input
rem "userCodec=" Ask for user input
rem "userCodec=4" Skip user input and pretend user input is 4
set "userCodec="

rem =======[ Config Check ]=======

if not "!userDeletion!"=="" if not "!userDeletion!"=="!userDeletion: =!" (
	echo Invalid preset for userDeletion!
	timeout /t 999
	exit 1
)

echo "  1 2 " | find " !userDeletion! " >nul
if errorlevel 1 (
    echo Invalid preset for userDeletion!
	timeout /t 999
	exit 1
)

if not "!rotation!"=="" if not "!rotation!"=="!rotation: =!" (
    echo Invalid preset for rotation!
	timeout /t 999
	exit 1
)

echo "  1 2 3 4 " | find " !rotation! " >nul
if errorlevel 1 (
    echo Invalid preset for rotation!
	timeout /t 999
	exit 1
)

if not "!userCodec!"=="" if not "!userCodec!"=="!userCodec: =!" (
    echo Invalid preset for userCodec!
	timeout /t 999
	exit 1
)

echo "  1 2 3 4 5 6 7 8 " | find " !userCodec! " >nul
if errorlevel 1 (
    echo Invalid preset for userCodec!
	timeout /t 999
	exit 1
)

rem ========[ Config End ]========



rem	Copyright (C) 2025 Alpar Duman
rem	This file is part of archival-video-converter-batch.
rem	
rem	archival-video-converter-batch is free software: you can redistribute it and/or modify
rem	it under the terms of the GNU General Public License version 3 as
rem	published by the Free Software Foundation.
rem	
rem	archival-video-converter-batch is distributed in the hope that it will be useful,
rem	but WITHOUT ANY WARRANTY; without even the implied warranty of
rem	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
rem	GNU General Public License for more details.
rem	
rem	You should have received a copy of the GNU General Public License
rem	along with archival-video-converter-batch. If not, see
rem	<https://github.com/AlparDuman/archival-video-converter-batch/blob/main/LICENSE>
rem	else <https://www.gnu.org/licenses/>.

set "version=v1.3"
set "url=https://github.com/AlparDuman/archival-video-converter-batch"

:init
echo     _             _     _            _  __     ___     _               ____                          _            
echo    / \   _ __ ___^| ^|__ (_)_   ____ _^| ^| \ \   / (_) __^| ^| ___  ___    / ___^|___  _ ____   _____ _ __^| ^|_ ___ _ __ 
echo   / _ \ ^| '__/ __^| '_ \^| \ \ / / _` ^| ^|  \ \ / /^| ^|/ _` ^|/ _ \/ _ \  ^| ^|   / _ \^| '_ \ \ / / _ \ '__^| __/ _ \ '__^|
echo  / ___ \^| ^| ^| (__^| ^| ^| ^| ^|\ V / (_^| ^| ^|   \ V / ^| ^| (_^| ^|  __/ (_) ^| ^| ^|__^| (_) ^| ^| ^| \ V /  __/ ^|  ^| ^|^|  __/ ^|   
echo /_/   \_\_^|  \___^|_^| ^|_^|_^| \_/ \__,_^|_^|    \_/  ^|_^|\__,_^|\___^|\___/   \____\___/^|_^| ^|_^|\_/ \___^|_^|   \__\___^|_^|   
echo !version! ================================================ !url!
echo.



rem Check for dependencies
where ffmpeg >nul 2>&1 || (
	echo No ffmpeg installation found, how can this be fixed:
	echo 1^) Download from https://www.ffmpeg.org/download.html
	echo 2^) Add the folder containing ffmpeg.exe to the environment variables.
	exit /b 1
)

where ffprobe >nul 2>&1 || (
	echo No ffprobe installation found, how can this be fixed:
	echo 1^) Download from https://www.ffmpeg.org/download.html
	echo 2^) Add the folder containing ffprobe.exe to the environment variables.
	exit /b 1
)



rem hint for internal config
echo ^+----------------------------------------------------------------------+
echo ^| Only video and audio streams are encoded, other metadata is ignored. ^|
echo ^| To skip user input, edit internal config.                            ^|
echo ^+----------------------------------------------------------------------+
echo.

rem Ask user what to do with original video file after successful convertion
echo What to do with original video file after successful convertion:
echo [1] Keep
echo [2] Delete

if "!userDeletion!"=="" (
	set /p userDeletion=Select number: 
) else (
	echo Select number: !userDeletion!
)
echo.

if not "!userDeletion!"=="!userDeletion: =!" (
	set "userDeletion="
    cls
    goto :init
)

echo " 1 2 " | find " !userDeletion! " >nul
if errorlevel 1 (
	set "userDeletion="
    cls
    goto :init
)

rem Ask user if video should be rotated
echo By how many degrees should the video be rotated clockwise:
echo [1] 0deg
echo [2] 90deg
echo [3] 180deg
echo [4] 270deg

if "!rotation!"=="" (
	set /p rotation=Select number: 
) else (
	echo Select number: !rotation!
)
echo.

if not "!rotation!"=="!rotation: =!" (
	set "rotation="
    cls
    goto :init
)

echo " 1 2 3 4 " | find " !rotation! " >nul
if errorlevel 1 (
	set "rotation="
    cls
    goto :init
)

if "!rotation!"=="1" set "rotation="
if "!rotation!"=="2" set "rotation=-vf "transpose=1" "
if "!rotation!"=="3" set "rotation=-vf "transpose=1,transpose=1" "
if "!rotation!"=="4" set "rotation=-vf "transpose=2" "

rem Ask user video codec
echo Choose a supported video codec:
echo ^+-----+------------+-------+--------+---------+--------+---------------+
echo ^|     ^| Device     ^| Codec ^| Speed  ^| Quality ^| Size   ^| Compatibility ^|
echo ^+-----+------------+-------+--------+---------+--------+---------------+
echo ^| [1] ^| CPU        ^| x264  ^| medium ^| best    ^| medium ^| best          ^|
echo ^| [2] ^| CPU        ^| x265  ^| slow   ^| best    ^| small  ^| good          ^|
echo ^| [3] ^| GPU Nvidia ^| h264  ^| fast   ^| better  ^| big    ^| better        ^|
echo ^| [4] ^| GPU Nvidia ^| h265  ^| fast   ^| better  ^| medium ^| good          ^|
echo ^| [5] ^| GPU Amd    ^| h264  ^| fast   ^| good    ^| big    ^| better        ^|
echo ^| [6] ^| GPU Amd    ^| h265  ^| fast   ^| good    ^| medium ^| good          ^|
echo ^| [7] ^| GPU Intel  ^| h264  ^| fast   ^| medium  ^| big    ^| better        ^|
echo ^| [8] ^| GPU Intel  ^| h265  ^| medium ^| medium  ^| medium ^| good          ^|
echo ^+-----+------------+-------+--------+---------+--------+---------------+

if "!userCodec!"=="" (
	set /p userCodec=Select number: 
) else (
	echo Select number: !userCodec!
)

if not "!userCodec!"=="!userCodec: =!" (
	set "userCodec="
    cls
    goto :init
)

echo " 1 2 3 4 5 6 7 8 " | find " !userCodec! " >nul
if errorlevel 1 (
	set "userCodec="
    cls
    goto :init
)

rem Go through each argument, could be a folder or a file
for %%F in (%*) do (
	if exist "%%~F\" (
		call :process_folder "%%~F\"
	) else (
		call :process_file "%%~F"
	)
)

rem Finished
endlocal
timeout /t 999
exit 0



:process_folder

for /R "%~1" %%I in (*) do (
	call :process_file "%%~I"
)
exit /b 0



:process_file

echo.

rem Escape file name, path & extension
set "filePathNameExtension=%~dpnx1"
set "filePathName=%~dpn1"
set "fileName=%~n1"

rem Input & wip file path and name
set "input=!filePathNameExtension!"
set "wip=!filePathName!.wip.mp4"
set "archival=!fileName!.archive.mp4"

rem Skip if output already exists
if exist "!filePathName!.archive.mp4" (
	echo Skip !input!
	exit /b 0
)

rem Check if file is not from previous Run
if not "!fileName!"=="!fileName:.wip=!" (
	echo Skip !input!
	exit /b 0
)

if not "!fileName!"=="!fileName:.archive=!" (
	echo Skip !input!
	exit /b 0
)

rem Detect audio & video streams
echo Convert !input!
set "has_audio=0"
set "has_video=0"

for /f "delims=" %%A in ('start "" /b /belownormal /wait ffprobe -v quiet -show_entries stream^=codec_type -of default^=nw^=1:nk^=1 "!input!" 2^>nul') do (
	if /i "%%A"=="audio" (
		set "has_audio=1"
	)
	if /i "%%A"=="video" (
		set "has_video=1"
	)
)

rem Count frames for mute videos
if !has_audio! equ 0 (
	for /f "tokens=1" %%B in ('start "" /b /belownormal /wait ffprobe -v quiet -select_streams v:0 -show_entries stream^=nb_frames -of default^=nokey^=1:noprint_wrappers^=1 "!input!" 2^>nul') do (
		set "has_video=%%B"
	)
	
	if "!has_video!"=="N/A" (
		for /f "tokens=1" %%B in ('start "" /b /belownormal /wait ffprobe -v quiet -select_streams v:0 -count_frames -show_entries stream^=nb_read_frames -of default^=nokey^=1:noprint_wrappers^=1 "!input!" 2^>nul') do (
			set "has_video=%%B"
		)
	)
	
	rem Check for video
	for /f "delims=0123456789" %%A in ("!has_video!") do (
		echo Skip, not a video file
		exit /b 0
	)
	
	if !has_video! leq 1 (
		echo Skip, not a video file
		exit /b 0
	)
) else (
	rem Check for video
	if !has_video! equ 0 (
		echo Skip, not a video file
		exit /b 0
	)
)

rem Detect bitdepth of video stream
set "pix_fmt=yuv420p"
for /f "tokens=*" %%a in ('start "" /b /belownormal /wait ffprobe -v error -select_streams v:0 -show_entries stream^=bits_per_raw_sample -of default^=noprint_wrappers^=1:nokey^=1 "!input!" 2^>nul') do (
	if "%%a"=="10" set "pix_fmt=yuv420p10le"
)

rem encode with cpu
if "!userCodec!"=="1" set "query=-map 0:v -c:v libx264 -tag:v avc1 -crf 18 -preset placebo -x264-params ref=4:log-level=error"
if "!userCodec!"=="2" set "query=-map 0:v -c:v libx265 -tag:v hvc1 -crf 23 -preset placebo -x265-params ref=4:log-level=error"
rem encode with nvidia
if "!userCodec!"=="3" set "query=-map 0:v -c:v h264_nvenc -tag:v avc1 -cq 18 -preset p7 -rc vbr"
if "!userCodec!"=="4" set "query=-map 0:v -c:v hevc_nvenc -tag:v hvc1 -cq 23 -preset p7 -rc vbr"
rem encode with amd
if "!userCodec!"=="5" set "query=-map 0:v -c:v h264_amf -tag:v avc1 -rc cqp -cqp 18 -quality_best"
if "!userCodec!"=="6" set "query=-map 0:v -c:v hevc_amf -tag:v hvc1 -rc cqp -cqp 23 -quality_best"
rem encode with intel
if "!userCodec!"=="7" set "query=-map 0:v -c:v h264_qsv -tag:v avc1 -global_quality 18 -preset 1 -look_ahead 1"
if "!userCodec!"=="8" set "query=-map 0:v -c:v hevc_qsv -tag:v hvc1 -global_quality 23 -preset 1 -look_ahead 1"

rem finish query
set "query=!rotation!!query! -fps_mode cfr -g 60 -map 0:a? -c:a aac -tag:a mp4a -b:a 192k -pix_fmt !pix_fmt! -movflags +faststart"
set "query=-metadata comment="!version! !url! !query!" !query!"

rem do encoding
start "" /b /belownormal /wait ffmpeg -hide_banner -y -v error -stats -i "!input!" !query! "!wip!"

rem on error
if not errorlevel 0 (
	del "!wip!"
	color 0C
    echo Encoding failed
    pause
	color 07
    exit /b 1
)

rem Rename .wip to .archive
ren "!wip!" "!archival!"
if not errorlevel 0 (
	del "!wip!"
	color 0C
    echo Renaming failed
    pause
	color 07
    exit /b 1
)

rem Delete input file
if "!userDeletion!"=="2" (
	del /f "!input!"
	if not errorlevel 0 (
		color 0C
		echo Failed to delete source file
		pause
		color 07
		exit /b 1
	)
)

exit /b 0

