@echo off
title MSMG Toolkit v13.7 Jerry�޸İ� V1.1-Patch1 Build20240812
:: ����Ĭ�Ͽ���̨������ǰ��ɫ
color 1f
cd /D "%~dp0" >nul
set "ROOT=%cd%"
cd /D "%ROOT%\" >nul

:: ���·��
if not "%cd%"=="%cd: =%" (
	echo.=========================================================
	echo.
	echo.��ǰ������Ŀ¼����·���а����ո�
	echo �뽫Ŀ¼�ƶ���������Ϊ�������ո��Ŀ¼��
	echo.
	echo.=========================================================
	echo.
	pause>nul|set /p=��������˳�......
	exit
)

:: ����CMD������ʽ
reg add "HKCU\Console\%%SystemRoot%%_system32_cmd.exe" /v "ScreenBufferSize" /t REG_DWORD /d "0x23290050" /f >nul
reg add "HKCU\Console\%%SystemRoot%%_system32_cmd.exe" /v "WindowSize" /t REG_DWORD /d "0x190050" /f >nul

reg add "HKU\.DEFAULT\Console" /v "FaceName" /t REG_SZ /d "Consolas" /f >nul
reg add "HKU\.DEFAULT\Console" /v "FontFamily" /t REG_DWORD /d "0x36" /f >nul
reg add "HKU\.DEFAULT\Console" /v "FontSize" /t REG_DWORD /d "0x100000" /f >nul
reg add "HKU\.DEFAULT\Console" /v "FontWeight" /t REG_DWORD /d "0x190" /f >nul
reg add "HKU\.DEFAULT\Console" /v "ScreenBufferSize" /t REG_DWORD /d "0x23290050" /f >nul

setlocal EnableExtensions EnableDelayedExpansion

:: ����·����������
set "Bin=%ROOT%\Bin"
set "DVD=%ROOT%\DVD"
set "Logs=%ROOT%\Logs"
set "Mount=%ROOT%\Mount"
set "Temp=%ROOT%\Temp"

:: ������������ϵͳ�汾����ϵ�ṹ�����Ա���
set HostArchitecture=
set HostBuild=
set HostReleaseVersion=
set HostDisplayVersion=
set HostEdition=
set HostInstallationType=
set HostOSName=
set HostServicePackBuild=
set HostVersion=
set HostUILanguage=
set HostLanguage=
set HostPartiallyLocalized=
set HostLanguageFallback=

if exist "%WinDir%\SysWOW64" (set "HostArchitecture=x64") else (set "HostArchitecture=x86")
for /f "tokens=3 delims= " %%i in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v "CurrentBuild" ^| find "REG_SZ"') do (set HostBuild=%%i)
for /f "tokens=3 delims= " %%j in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /f "ReleaseId" ^| find "REG_SZ"') do (set /A HostReleaseVersion=%%j & if "%%j" lss "2004" set /A HostDisplayVersion=%%j)
if "%HostDisplayVersion%" equ "" for /f "tokens=3 delims= " %%k in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v "DisplayVersion" ^| find "REG_SZ"') do (set "HostDisplayVersion=^(%%k^)")
for /f "tokens=3 delims= " %%l in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v "EditionID" ^| find "REG_SZ"') do (set HostEdition=%%l)
for /f "tokens=3 delims= " %%m in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v "InstallationType" ^| find "REG_SZ"') do (set HostInstallationType=%%m)
for /f "tokens=7 delims=[]. " %%r in ('ver 2^>nul') do (set /A HostServicePackBuild=%%r)
for /f "tokens=4-5 delims=[]. " %%s in ('ver 2^>nul') do (set "HostVersion=%%s.%%t" & set "HostOSVersion=%%s")
if "%HostVersion%" equ "6.1" set "HostOSVersion=7 SP1"
if "%HostVersion%" equ "6.3" set "HostOSVersion=8.1"
if "%HostVersion%" equ "10.0" if "%HostBuild%" geq "21996" set "HostOSVersion=11"
set "HostOSName=Windows %HostOSVersion% %HostEdition% %HostInstallationType%"

:: �����������ϵͳ�Ƿ��� Windows 7/8.1
if "%HostVersion%" neq "10.0" (
	echo.=========================================================
	echo.
	echo.�������޷��� Windows 7/8.1 ��������ϵͳ��ά�� Windows 10/11 Դ����ϵͳ����
	echo.
	echo.��������Ҫ��������ϵͳΪ Windows 10/11 ��ά�� Windows 10/11 Դ����ϵͳ����
	echo.
	echo.=========================================================
	echo.
	pause>nul|set /p=��������˳�......
	exit
)

for /f "tokens=3 delims=\ " %%o in ('reg query "HKCU\Control Panel\International\User Profile" /s /v "Languages" ^| findstr /I "REG_ _SZ"') do (set "HostLanguage=%%o")
for /f "tokens=6 delims= " %%o in ('DISM /Online /English /Get-Intl ^| findstr /i /C:"Default system UI language"') do (set HostUILanguage=%%o)
if "%HostLanguage%" equ "" set "HostLanguage=%HostUILanguage%"
for /f "tokens=2 delims=:, " %%l in ('DISM /Online /English /Get-Intl ^| findstr /I /C:"Partially localized language"') do (set "HostPartiallyLocalized=%%l")
if "%HostPartiallyLocalized%" equ "Partially" for /f "tokens=2 delims=:" %%t in ('DISM /Online /English /Get-Intl ^| findstr /I /C:"language fallback is"') do (set "HostLanguageFallback=%%t")
if "%HostPartiallyLocalized%" equ "Partially" if "%HostLanguageFallback%" equ "" set "HostLanguageFallback= en-US"
if "%HostLanguageFallback%" neq "" set "HostLanguageFallback=%HostLanguageFallback:~1%"

for /f "tokens=3-4 delims=:, " %%k in ('DISM /Online /English /Get-Intl ^| findstr /I /C:"Active keyboard(s)"') do (set "HostActiveKeyboard=%%k:%%l")
rem Windows Ĭ�� pt-BR ������ ABNT��0416:00000416���������еĲ����� ABNT2��0416:00010416��
if "%HostActiveKeyboard%" equ "0416:00000416" set "HostActiveKeyboard=0416:00010416"
for /f "tokens=2 delims=:" %%f in ('DISM /Online /English /Get-Intl ^| findstr /I /C:"Default time zone"') do (set "HostTimeZone=%%f")
set "HostTimeZone=%HostTimeZone:~1%"

:: ����Դ����ϵͳ����·��
set SelectedSourceOS=
set OSID=
set "InstallWim=%DVD%\sources\install.wim"
set "InstallEsd=%DVD%\sources\install.esd"
set "InstallMount=%Mount%\Install"

:: ����Դӳ����Ϣ����
set ImageCount=
set ImageIndexNo=
set ImageArchitecture=
set ImageName=
set ImageDescription=
set ImageFlag=
set ImageEdition=
set ImageInstallationType=
set ImageDefaultLanguage=
set ImageBuild=
set ImageVersion=
set ImageServicePackBuild=
set ImageServicePackLevel=
set PackageBuild=
set PackageVersion=
set PackageServicePackBuild=

:: �������״̬��ʶ
for %%i in (C_AdobeFlashForWindows,C_EdgeChromium,C_EdgeWebView,C_InternetExplorer,C_FirstLogonAnimation,C_GameExplorer,C_LockScreenBackground,C_ScreenSavers,C_SnippingTool,C_SoundThemes,C_SpeechRecognition,C_Wallpapers,C_WindowsMediaPlayer,C_WindowsPhotoViewer,C_WindowsThemes,C_WindowsTIFFIFilter,C_WinSAT,C_OfflineFiles,C_OpenSSH,C_RemoteDesktopClient,C_RemoteDifferentialCompression,C_SimpleTCPIPServices,C_TelnetClient,C_TFTPClient,C_WalletService,C_WindowsMail,C_AssignedAccess,C_CEIP,C_FaceRecognition,C_KernelDebugging,C_LocationService,C_PicturePassword,C_PinEnrollment,C_UnifiedTelemetryClient,C_WiFiNetworkManager,C_WindowsErrorReporting,C_WindowsInsiderHub,C_HomeGroup,C_MultiPointConnector,C_OneDrive,C_RemoteAssistance,C_RemoteDesktopServer,C_RemoteRegistry,C_WorkFoldersClient,C_AccessibilityTools,C_Calculator,C_DeviceLockdown,C_EaseOfAccessCursors,C_EaseOfAccessThemes,C_EasyTransfer,C_FileHistory,C_LiveCaptions,C_Magnifier,C_ManualSetup,C_Narrator,C_Notepad,C_OnScreenKeyboard,C_Paint,C_ProjFS,C_SecurityCenter,C_StepsRecorder,C_StorageSpaces,C_SystemRestore,C_VoiceAccess,C_WindowsBackup,C_WindowsFirewall,C_WindowsSubsystemForLinux,C_WindowsToGo,C_WindowsUpdate,C_Wordpad,C_AADBrokerPlugin,C_AccountsControl,C_AddSuggestedFoldersToLibraryDialog,C_AppResolverUX,C_AssignedAccessLockApp,C_AsyncTextService,C_BioEnrollment,C_CallingShellApp,C_CapturePicker,C_CBSPreview,C_ClientCBS,C_CloudExperienceHost,C_ContentDeliveryManager,C_Cortana,C_CredDialogHost,C_ECApp,C_Edge,C_EdgeDevToolsClient,C_FileExplorer,C_FilePicker,C_InputApp,C_LockApp,C_MapControl,C_NarratorQuickStart,C_NcsiUwpApp,C_OOBENetworkCaptivePortal,C_OOBENetworkConnectionFlow,C_ParentalControls,C_PeopleExperienceHost,C_PinningConfirmationDialog,C_PrintDialog,C_PPIProjection,C_QuickAssist,C_RetailDemoContent,C_SearchApp,C_SecureAssessmentBrowser,C_SettingSync,C_ShellExperienceHost,C_SkypeORTC,C_SmartScreen,C_StartMenuExperienceHost,C_UndockedDevKit,C_WebcamExperience,C_WebView2Runtime,C_Win32WebViewHost,C_WindowsDefender,C_WindowsMixedReality,C_WindowsReaderPDF,C_WindowsStoreCore,C_XboxCore,C_XboxGameCallableUI,C_XGpuEjectDialog,C_3DViewer,C_AdvertisingXaml,C_Alarms,C_BingNews,C_BingWeather,C_CalculatorApp,C_Camera,C_ClientWebExperience,C_Clipchamp,C_CommunicationsApps,C_DesktopAppInstaller,C_Family,C_FeedbackHub,C_GamingApp,C_GetHelp,C_Getstarted,C_HEIFImageExtension,C_HEVCVideoExtension,C_Maps,C_Messaging,C_MixedRealityPortal,C_NETNativeFramework16,C_NETNativeFramework17,C_NETNativeFramework22,C_NETNativeRuntime16,C_NETNativeRuntime17,C_NETNativeRuntime22) do (
	set "%%i=+"
)

:: �������������״̬��ʶ
for %%i in (CC_AdobeInstallers,CC_ApplicationGuardContainers,CC_Biometric,CC_Hyper-V,CC_MicrosoftGames,CC_MicrosoftOfice,CC_MicrosoftStore,CC_ModernAppSupport,CC_OOBE,CC_Printing,CC_Recommended,CC_ShellSearch,CC_TouchScreenDevices,CC_VisualStudio,CC_WindowsUpdate,CC_WindowsUpgrade,CC_XboxApp) do (
	set "%%i=+"
)

:: ����
cls
echo.
echo.����ִ��Ԥ������������Ժ򡭡�
call :Cleanup >nul
:: ���� DOS �ַ�����ҳ
if "%HostUILanguage%" equ "en-GB" chcp 437 >nul
if "%HostUILanguage%" equ "en-US" chcp 437 >nul
if "%HostUILanguage%" equ "zh-CN" chcp 936 >nul
if not exist "%Temp%\DISM" md "%Temp%\DISM" >nul
set "DISM=%Bin%\Dism%HostArchitecture%\Dism.exe /English /ScratchDir:%Temp%\DISM /LogPath:%Logs%\Dism.txt /LogLevel:3 /NoRestart"
cls
echo.��������ϵͳ
echo.
echo.%HostOSName% %HostDisplayVersion% - v%HostVersion%.%HostBuild%.%HostServicePackBuild% %HostArchitecture% %HostLanguage%
echo.

:: ���뾵��
:SelectSourceDVD

cls
echo.
echo.===============================================================================
echo.                                ���뾵��
echo.===============================================================================
echo.

:: ��� Windows Դ��װӳ���Ƿ����
if not exist "%InstallWim%" (
	if exist "%InstallEsd%" (
		set "InstallWimfile=%InstallEsd%"
	) else (
		echo.�� ^<DVD\Sources^> �ļ������޷��ҵ� Windows ��װ����Install.wim��ӳ��
		echo.
		echo.����Խ���Install.wim�����Ƶ� ^<DVD\Sources^> �ļ��У����س����²��ң�
		echo.
		echo.Ҳ��������1ѡ��һ��Դ�����ļ���
		echo.
		echo.��������˳�������Q��
		echo.
		choice /C:1Q /N /M "���������ѡ�� ��"
		if errorlevel 2 goto :Quit
		if errorlevel 1 (
			%~dp0UICORE.EXE importfile |MORE
			pause
		)
		goto :SelectSourceDVD
	)
) else (
	set "InstallWimfile=%InstallWim%"
)

echo.-------------------------------------------------------------------------------
echo.####���ڵ���ӳ���ļ�###########################################################
echo.-------------------------------------------------------------------------------

:: ��ȡӳ���д��ڵ�����������
set "ImageInfo=%Temp%\ImageInfo.txt"

if exist "%ImageInfo%" del /f /q "%ImageInfo%" >nul

for /f "tokens=2 delims=: " %%a in ('%DISM% /Get-ImageInfo /ImageFile:"%InstallWimfile%" ^| findstr Index') do (set ImageCount=%%a)

echo.
echo.���ڶ�ȡӳ����Ϣ����
echo.
:: �г�ӳ���е�����������
echo.===============================================================================>>%ImageInfo%
echo.^|  ����  ^| ��ϵ�ṹ    ^| ����>>%ImageInfo%
echo.===============================================================================>>%ImageInfo%
for /f "tokens=2 delims=: " %%a in ('%DISM% /Get-WimInfo /WimFile:%InstallWimfile% ^| findstr Index') do (
	for /f "tokens=2 delims=: " %%b in ('%DISM% /Get-WimInfo /WimFile:%InstallWimfile% /Index:%%a ^| findstr /i Architecture') do (
		for /f "tokens=2 delims=:" %%c in ('%DISM% /Get-WimInfo /WimFile:%InstallWimfile% /Index:%%a ^| findstr /i Name') do (
			if "%%b" neq "arm64" (
				if %%a lss 10 echo.^|    %%a   ^| %%b         ^| %%c>>%ImageInfo%
				if %%a geq 10 if %%a lss 100 echo.^|   %%a   ^| %%b         ^| %%c>>%ImageInfo%
				if %%a geq 100 echo.^|  %%a   ^| %%b         ^| %%c>>%ImageInfo%
			)
			if "%%b" equ "arm64" (
				if %%a lss 10 echo.^|    %%a   ^| %%b       ^| %%c>>%ImageInfo%
				if %%a geq 10 if %%a lss 100 echo.^|   %%a   ^| %%b       ^| %%c>>%ImageInfo%
				if %%a geq 100 echo.^|  %%a   ^| %%b       ^| %%c>>%ImageInfo%
			)
		)
	)
)

type "%ImageInfo%"
if exist "%ImageInfo%" del /f /q "%ImageInfo%" >nul

echo.===============================================================================
echo.

if "%ImageCount%" equ "1" (
	set /p ImageIndexNo=������ӳ��������� # [1 �򰴡�Q���˳�] ��
) else set /p ImageIndexNo=������ӳ��������� # �� [��Χ ��1����%ImageCount% �򰴡�Q���˳�] ��

:: ��ȡӳ������
if not defined ImageIndexNo (
	echo.
	echo.������������ # ��Ч����Ч��Χ�� [1~%ImageCount%������Q���˳�]
	echo.
	pause>nul|set /p=�����������ѡ��...
	goto :SelectSourceDVD
)

if /i "%ImageIndexNo%" equ "Q" (
	set ImageIndexNo=
	goto :Quit
)

:: ��� Windows Դ��װӳ���Ƿ�Ϊ ESD ��ʽ
if exist "%InstallEsd%" (
	echo.
    echo.-------------------------------------------------------------------------------
    echo.####����ת�� ESD ӳ��Ϊ WIM ӳ��###############################################
    echo.-------------------------------------------------------------------------------
 	echo.
   
    :: ����Դӳ��Ϊ WIM ӳ��
    "%Bin%\wimlib-imagex.exe" export "%InstallEsd%" %ImageIndexNo% "%InstallWim%" --compress=LZX
    
    :: ɾ��Դӳ���ļ�
    if exist "%InstallEsd%" del /f /q "%InstallEsd%" >nul
    
    :: ����ת�������������Ϊ1
    set "ImageIndexNo=1"
    
	echo.
    echo.-------------------------------------------------------------------------------
    echo.####ת�� WIM ӳ��Ϊ ESD ӳ�������#############################################
    echo.-------------------------------------------------------------------------------
	echo.
)

:: ��ȡӳ��������Ϣ
for /f "tokens=2 delims=:" %%a in ('%DISM% /Get-ImageInfo /ImageFile:"%InstallWim%" /Index:%ImageIndexNo% ^| findstr /i Name') do (set ImageName=%%a)
for /f "tokens=2 delims=:" %%b in ('%DISM% /Get-ImageInfo /ImageFile:"%InstallWim%" /Index:%ImageIndexNo% ^| findstr /i Description') do (set ImageDescription=%%b)
for /f "tokens=2 delims=: " %%c in ('%DISM% /Get-ImageInfo /ImageFile:"%InstallWim%" /Index:%ImageIndexNo% ^| findstr /i Architecture') do (set ImageArchitecture=%%c)
for /f "tokens=2 delims=: " %%d in ('%DISM% /Get-ImageInfo /ImageFile:"%InstallWim%" /Index:%ImageIndexNo% ^| findstr /i Version') do (set ImageVersion=%%d)
for /f "tokens=2 delims=:" %%e in ('%DISM% /Get-ImageInfo /ImageFile:"%InstallWim%" /Index:%ImageIndexNo% ^| find "ServicePack Build"') do (set ImageServicePackBuild=%%e)
for /f "tokens=2 delims=:" %%f in ('%DISM% /Get-ImageInfo /ImageFile:"%InstallWim%" /Index:%ImageIndexNo% ^| find "ServicePack Level"') do (set ImageServicePackLevel=%%f)
for /f "tokens=2 delims=: " %%g in ('%DISM% /Get-ImageInfo /ImageFile:"%InstallWim%" /Index:%ImageIndexNo% ^| findstr /i Edition') do (set ImageEdition=%%g)
for /f "tokens=2 delims=:<> " %%h in ('%Bin%\imagex.exe /info "%InstallWim%" %ImageIndexNo% ^| findstr /i Flag') do (set ImageFlag=%%h)
for /f "tokens=2 delims=:" %%i in ('%DISM% /Get-ImageInfo /ImageFile:"%InstallWim%" /Index:%ImageIndexNo% ^| findstr /i Installation') do (set ImageInstallationType=%%i)
for /f "tokens=1 delims= " %%j in ('%DISM% /Get-ImageInfo /ImageFile:"%InstallWim%" /Index:%ImageIndexNo% ^| findstr /i "Default"') do (set "ImageDefaultLanguage=%%j")

set "ImageName=%ImageName:~1%"
set "ImageDescription=%ImageDescription:~1%"

if "%ImageVersion:~0,-6%" neq "10.0" if "%ImageVersion:~0,-6%" neq "11.0" set /A ImageBuild=%ImageVersion:~4,4%
if "%ImageVersion%" neq "6.1.7601" if "%ImageVersion%" neq "6.3.9600" set /A ImageBuild=%ImageVersion:~5,5%

set "ImageServicePackBuild=%ImageServicePackBuild:~1%"
set "ImageServicePackLevel=%ImageServicePackLevel:~1%"
set "ImageInstallationType=%ImageInstallationType:~1%"
set "ImageDefaultLanguage=!ImageDefaultLanguage:~1!"

if "%ImageFlag%" equ "" set "ImageFlag=%ImageEdition%"

if "%ImageInstallationType:~,6%" equ "Server" set "ImageDescription=%ImageDescription:(=[%"
if "%ImageInstallationType:~,6%" equ "Server" set "ImageDescription=%ImageDescription:)=]%"


:: ����ѡ���Դ����ϵͳ�汾
if "%ImageVersion%" equ "6.1.7601" set "SelectedSourceOS=w7"
if "%ImageVersion%" equ "6.3.9600" set "SelectedSourceOS=w81"

if "%ImageVersion:~0,-6%" equ "10.0" (
	if "%ImageBuild%" leq "20348" (
		set "SelectedSourceOS=w10"
		set "OSID=10"
	)
	if "%ImageBuild%" geq "22000" (
		set "SelectedSourceOS=w11"
		set "OSID=11"
	)
)

if "%ImageVersion:~0,-6%" equ "11.0" (
	set "SelectedSourceOS=w11"
	set "OSID=11"
)

:: �������������ڲ��汾���汾�ͷ�����ڲ��汾
if "%SelectedSourceOS%" equ "w7" set "PackageServicePackBuild=17514"
if "%SelectedSourceOS%" equ "w81" set "PackageServicePackBuild=16384"

if "%SelectedSourceOS%" equ "w10" (
	if "%ImageBuild%" geq "10240" if "%ImageBuild%" leq "15063" (
		set "PackageBuild=%ImageBuild%"
		set "PackageVersion=10.0.%ImageBuild%"
		set "PackageServicePackBuild=0"
	)
	if "%ImageBuild%" equ "16299" (
		set "PackageBuild=16299"
		set "PackageVersion=10.0.16299"
		set "PackageServicePackBuild=15"
	)
	if "%ImageBuild%" geq "17134" if "%ImageBuild%" leq "17763" (
		set "PackageBuild=%ImageBuild%"
		set "PackageVersion=10.0.%ImageBuild%"
		set "PackageServicePackBuild=1"
	)
	if "%ImageBuild%" geq "18362" if "%ImageBuild%" leq "18363" (
		set "PackageBuild=18362"
		set "PackageVersion=10.0.18362"
		set "PackageServicePackBuild=1"
	)
	if "%ImageBuild%" geq "19041" if "%ImageBuild%" leq "19045" (
		set "PackageBuild=19041"
		set "PackageVersion=10.0.19041"
		set "PackageServicePackBuild=1"
	)
	if "%ImageBuild%" equ "20348" (
		set "PackageBuild=%ImageBuild%"
		set "PackageVersion=10.0.%ImageBuild%"
		set "PackageServicePackBuild=1"
	)
)

if "%SelectedSourceOS%" equ "w11" (
	if "%ImageBuild%" geq "22000" (
		set "PackageBuild=%ImageBuild%"
		set "PackageVersion=10.0.%ImageBuild%"
		set "PackageServicePackBuild=1"
	)
)

:: ���ó������������ϵ�ṹ
if "%ImageArchitecture%" equ "x86" (
	set "PackageIndex=1"
	set "PackageArchitecture=x86"
)
if "%ImageArchitecture%" equ "x64" (
	set "PackageIndex=2"
	set "PackageArchitecture=amd64"
)
if "%ImageArchitecture%" equ "arm" (
	set "PackageIndex=3"
	set "PackageArchitecture=arm"
)
if "%ImageArchitecture%" equ "arm64" (
	set "PackageIndex=4"
	set "PackageArchitecture=arm64"
)

::����Ƿ�֧�־���
if "%SelectedSourceOS%" neq "w7" if "%SelectedSourceOS%" neq "w81" if "%ImageBuild%" geq "17763" if "%ImageBuild%" leq "22631" if "%ImageInstallationType%" equ "Client" (
	echo.
) else (
	echo.
	echo.��ѡԴӳ��汾��֧���Զ�������Ƴ��������ع�����֧�ֵ�ϵͳ�汾��
	echo.
	echo.===============================================================================
	echo.
	pause>nul|set /p=��������˳�...
	goto :Quit
)

echo.-------------------------------------------------------------------------------
echo.####Դӳ���ļ���ϸ��Ϣ#########################################################
echo.-------------------------------------------------------------------------------
echo.
echo.    ӳ���ļ�����             �� Install.wim
echo.    ӳ���������             �� %ImageIndexNo%
echo.    ӳ����ϵ�ṹ             �� %ImageArchitecture%
echo.    ӳ��汾                 �� %ImageVersion%
echo.    ӳ�������ڲ��汾       �� %ImageServicePackBuild%
echo.    ӳ�������ȼ�           �� %ImageServicePackLevel%
echo.    ӳ���ڲ��汾             �� %ImageBuild%
echo.    ӳ��Ĭ������             �� %ImageDefaultLanguage%
echo.
echo.-------------------------------------------------------------------------------
echo.####���ڰ�װԴӳ���ļ�#########################################################
echo.-------------------------------------------------------------------------------
echo.

if not exist "%InstallMount%\%ImageIndexNo%" md "%InstallMount%\%ImageIndexNo%" >nul
:: ��װԴ��װӳ��������ά��
echo.
echo.-------------------------------------------------------------------------------
echo.���ڽ� [Install.wim������ ��%ImageIndexNo%] ӳ��װ�� ^<\Mount\Install\%ImageIndexNo%^>����
echo.-------------------------------------------------------------------------------
echo.
%DISM% /Mount-Image /ImageFile:"%InstallWim%" /Index:%ImageIndexNo% /MountDir:"%InstallMount%\%ImageIndexNo%"
echo.

echo.
echo.-------------------------------------------------------------------------------
echo.####ѡ�񲢰�װԴӳ���ļ������#################################################
echo.-------------------------------------------------------------------------------

echo.
echo.===============================================================================
echo.
:: �����������������
for %%i in (C_AADBrokerPlugin,C_AccountsControl,C_BioEnrollment,C_ClientCBS,C_CloudExperienceHost,C_Cortana,C_DesktopAppInstaller,C_EasyTransfer,C_EdgeChromium,C_EdgeWebView,C_GameExplorer,C_GamingApp,C_InputApp,C_InternetExplorer,C_KernelDebugging,C_ManualSetup,C_NETNativeFramework16,C_NETNativeFramework17,C_NETNativeFramework22,C_NETNativeRuntime16,C_NETNativeRuntime17,C_NETNativeRuntime22,C_OfflineFiles,C_PinEnrollment,C_PrintDialog,C_RemoteDesktopClient,C_RemoteDesktopServer,C_SearchApp,C_SecurityCenter,C_ShellExperienceHost,C_StartMenuExperienceHost,C_UIXaml20,C_UIXaml24,C_UIXaml27,C_UndockedDevKit,C_VCLibs140UWP,C_VCLibs140UWPDesktop,C_WindowsErrorReporting,C_WindowsFirewall,C_WindowsStore,C_WindowsStoreCore,C_WindowsUpdate,C_WinSAT,C_XboxIdentityProvider,C_XboxCore,C_XboxApp) do (
	if "%%i" equ "C_WindowsErrorReporting" if "%ImageBuild%" geq "18362" if "%ImageBuild%" leq "18363" set "%%i=*"
	if "%%i" equ "C_ClientCBS" if "%ImageBuild%" geq "19041" if "%ImageBuild%" leq "22631" set "%%i=*"
	if "%%i" neq "C_ClientCBS" if "%%i" neq "C_WindowsErrorReporting" set "%%i=*"
)

pause>nul|set /p=�밴���������ϵͳ���򡭡�
goto :ComponentsCompatibilityMenu

:: �Ƴ� Windows ��������Բ˵�
:ComponentsCompatibilityMenu
cls
echo.===============================================================================
echo.                              ��������Կ���
echo.===============================================================================
echo.
echo.  [ 1] %CC_AdobeInstallers% Adobe ��װ����
echo.  [ 2] %CC_ApplicationGuardContainers% Ӧ�ó������ / ����
echo.  [ 3] %CC_Biometric% ����ʶ��
echo.  [ 4] %CC_Hyper-V% Hyper-V
echo.  [ 5] %CC_MicrosoftGames% Microsoft ��Ϸ
echo.  [ 6] %CC_MicrosoftOfice% Microsoft Office
echo.  [ 7] %CC_MicrosoftStore% Microsoft Store
echo   [ 8] %CC_ModernAppSupport% Modern Ӧ��֧��
echo.  [ 9] %CC_OOBE% ȫ�°�װ���飨OOBE��
echo.  [10] %CC_Printing% ��ӡ
echo.  [11] %CC_Recommended% �Ƽ�
echo.  [12] %CC_ShellSearch% Shell Search
echo.  [13] %CC_TouchScreenDevices% �������豸
echo.  [14] %CC_VisualStudio% Visual Studio
echo.  [15] %CC_WindowsUpdate% Windows ����
echo.  [16] %CC_WindowsUpgrade% Windows ����
echo.  [17] %CC_XboxApp% Xbox
echo.
echo.  [A]    ѡ������
echo.  [R]    �ָ�ΪĬ��ֵ
echo.  [N]    ��һ��
echo.
echo.===============================================================================
echo.
echo.  Tips���������㲻��Ҫ�Ĺ��ܵ���ţ�ʹǰ��� + ��� - 
echo.        ��������ã��˴������Ĺ��ܽ��ᱻ�����޷�����
echo.
set /p MenuChoice=���������ѡ��󰴻س���

if /i "!MenuChoice!" equ "A" (
	for %%i in (CC_AdobeInstallers,CC_ApplicationGuardContainers,CC_Biometric,CC_Hyper-V,CC_MicrosoftGames,CC_MicrosoftOfice,CC_MicrosoftStore,CC_ModernAppSupport,CC_OOBE,CC_Printing,CC_Recommended,CC_ShellSearch,CC_TouchScreenDevices,CC_VisualStudio,CC_WindowsUpdate,CC_WindowsUpgrade,CC_XboxApp) do (
		set "%%i=-"
	)

	for %%i in (C_AADBrokerPlugin,C_AccountsControl,C_BioEnrollment,C_ClientCBS,C_CloudExperienceHost,C_Cortana,C_DesktopAppInstaller,C_EasyTransfer,C_EdgeChromium,C_EdgeWebView,C_GameExplorer,C_GamingApp,C_InputApp,C_InternetExplorer,C_KernelDebugging,C_ManualSetup,C_NETNativeFramework16,C_NETNativeFramework17,C_NETNativeFramework22,C_NETNativeRuntime16,C_NETNativeRuntime17,C_NETNativeRuntime22,C_OfflineFiles,C_PinEnrollment,C_PrintDialog,C_RemoteDesktopClient,C_RemoteDesktopServer,C_SearchApp,C_SecurityCenter,C_ShellExperienceHost,C_StartMenuExperienceHost,C_UIXaml20,C_UIXaml24,C_UIXaml27,C_UndockedDevKit,C_VCLibs140UWP,C_VCLibs140UWPDesktop,C_WindowsErrorReporting,C_WindowsFirewall,C_WindowsStore,C_WindowsStoreCore,C_WindowsUpdate,C_WinSAT,C_XboxIdentityProvider,C_XboxCore,C_XboxApp) do (
		if "%%i" equ "C_WindowsErrorReporting" if "%ImageBuild%" geq "18362" if "%ImageBuild%" leq "18363" set "%%i=+"
		if "%%i" equ "C_ClientCBS" if "%ImageBuild%" geq "19041" if "%ImageBuild%" leq "22631" set "%%i=+"
		if "%%i" neq "C_ClientCBS" if "%%i" neq "C_WindowsErrorReporting" set "%%i=+"
	)
)
if /i "!MenuChoice!" equ "R" (
	for %%i in (CC_AdobeInstallers,CC_ApplicationGuardContainers,CC_Biometric,CC_Hyper-V,CC_MicrosoftGames,CC_MicrosoftOfice,CC_MicrosoftStore,CC_ModernAppSupport,CC_OOBE,CC_Printing,CC_Recommended,CC_ShellSearch,CC_TouchScreenDevices,CC_VisualStudio,CC_WindowsUpdate,CC_WindowsUpgrade,CC_XboxApp) do (
		set "%%i=+"
	)

	for %%i in (C_AADBrokerPlugin,C_AccountsControl,C_BioEnrollment,C_ClientCBS,C_CloudExperienceHost,C_Cortana,C_DesktopAppInstaller,C_EasyTransfer,C_EdgeChromium,C_EdgeWebView,C_GameExplorer,C_GamingApp,C_InputApp,C_InternetExplorer,C_KernelDebugging,C_ManualSetup,C_NETNativeFramework16,C_NETNativeFramework17,C_NETNativeFramework22,C_NETNativeRuntime16,C_NETNativeRuntime17,C_NETNativeRuntime22,C_OfflineFiles,C_PinEnrollment,C_PrintDialog,C_RemoteDesktopClient,C_RemoteDesktopServer,C_SearchApp,C_SecurityCenter,C_ShellExperienceHost,C_StartMenuExperienceHost,C_UIXaml20,C_UIXaml24,C_UIXaml27,C_UndockedDevKit,C_VCLibs140UWP,C_VCLibs140UWPDesktop,C_WindowsErrorReporting,C_WindowsFirewall,C_WindowsStore,C_WindowsStoreCore,C_WindowsUpdate,C_WinSAT,C_XboxIdentityProvider,C_XboxCore,C_XboxApp) do (
		if "%%i" equ "C_WindowsErrorReporting" if "%ImageBuild%" geq "18362" if "%ImageBuild%" leq "18363" set "%%i=*"
		if "%%i" equ "C_ClientCBS" if "%ImageBuild%" geq "19041" if "%ImageBuild%" leq "22631" set "%%i=*"
		if "%%i" neq "C_ClientCBS" if "%%i" neq "C_WindowsErrorReporting" set "%%i=*"
	)
)
if /i "!MenuChoice!" neq "A" if /i "!MenuChoice!" neq "R" for %%# in (!MenuChoice!) do (
	if "%%#" equ "1" (
		if "%CC_AdobeInstallers%" equ "+" (
			set "CC_AdobeInstallers=-"
			set "C_InternetExplorer=+"
		) else (
			set "CC_AdobeInstallers=+"
			set "C_InternetExplorer=*"
		)
	)
	if "%%#" equ "2" (
		if "%CC_ApplicationGuardContainers%" equ "+" (
	        	set "CC_ApplicationGuardContainers=-"
        		set "C_KernelDebugging=+"
        		set "C_OfflineFiles=+"
	        	if "%CC_Hyper-V%" equ "-" set "C_RemoteDesktopServer=+" 
			set "C_SecurityCenter=+"
			if "%ImageBuild%" equ "17763" set "C_WindowsFirewall=+"
			if "%ImageBuild%" geq "18362" if "%ImageBuild%" leq "18363" if "%CC_Recommended%" equ "-" set "C_WindowsFirewall=+"
			if "%ImageBuild%" geq "19041" if "%ImageBuild%" leq "22631" set "C_WindowsFirewall=+"
		) else (
			set "CC_ApplicationGuardContainers=+"
			set "C_KernelDebugging=*"
			set "C_OfflineFiles=*"
			set "C_RemoteDesktopServer=*"
			set "C_SecurityCenter=*"
			set "C_WindowsFirewall=*"
		)
	)
	if "%%#" equ "3" (
		if "%CC_Biometric%" equ "+" (
			set "CC_Biometric=-"
			set "C_PinEnrollment=+"
			set "C_BioEnrollment=+"
		) else (
			set "CC_Biometric=+"
			set "C_PinEnrollment=*"
			set "C_BioEnrollment=*"
		)
	)
	if "%%#" equ "4" (
		if "%CC_Hyper-V%" equ "+" (
			set "CC_Hyper-V=-"
 			if "%CC_ApplicationGuardContainers%" equ "-" set "C_RemoteDesktopServer=+"
		) else (
        		set "CC_Hyper-V=+"
	        	set "C_RemoteDesktopServer=*"
    		)
	)
	if "%%#" equ "5" (
		if "%CC_MicrosoftGames%" equ "+" (
        		set "CC_MicrosoftGames=-"
        		set "C_GameExplorer=+"
        		set "C_WinSAT=+"
    		) else (
        		set "CC_MicrosoftGames=+"
        		set "C_GameExplorer=*"
        		set "C_WinSAT=*"
    		)
	)
	if "%%#" equ "6" (
		if "%CC_MicrosoftOfice%" equ "+" (
        		set "CC_MicrosoftOfice=-"
        		if "%ImageBuild%" geq "17763" if "%ImageBuild%" leq "18363" if "%CC_Recommended%" equ "-" if "%CC_TouchScreenDevices%" equ "-" set "C_InputApp=+"
    		) else (
        		set "CC_MicrosoftOfice=+"
        		if "%ImageBuild%" geq "17763" if "%ImageBuild%" leq "18363" set "C_InputApp=*"
    		)
	)
	if "%%#" equ "7" (
		if "%CC_MicrosoftStore%" equ "+" (
        		set "CC_MicrosoftStore=-"
        		set "C_AADBrokerPlugin=+"
        		set "C_AccountsControl=+"
        		if "%CC_OOBE%" equ "-" if "%CC_Recommended%" equ "-" if "%CC_ShellSearch%" equ "-" set "C_CloudExperienceHost=+"
        		set "C_WindowsStoreCore=+"
        		set "C_WindowsStore=+"
        		if "%CC_XboxApp%" equ "-" set "C_XboxIdentityProvider=+"
    		) else (
        		set "CC_MicrosoftStore=+"
        		set "C_AADBrokerPlugin=*"
        		set "C_AccountsControl=*"
        		set "C_CloudExperienceHost=*"
        		set "C_WindowsStoreCore=*"
        		set "C_WindowsStore=*"
        		set "C_XboxIdentityProvider=*"
    		)
	)
	if "%%#" equ "8" (
		if "%CC_ModernAppSupport%" equ "+" (
        		set "CC_ModernAppSupport=-"
	        	set "C_DesktopAppInstaller=+"
        		if "%ImageBuild%" equ "17763" set "C_NETNativeFramework16=+"
        		if "%ImageBuild%" geq "17763" if "%ImageBuild%" leq "19045" set "C_NETNativeFramework17=+"
	        	if "%ImageBuild%" geq "18362" if "%ImageBuild%" leq "22631" set "C_NETNativeFramework22=+"
        		if "%ImageBuild%" equ "17763" set "C_NETNativeRuntime16=+"
        		if "%ImageBuild%" geq "17763" if "%ImageBuild%" leq "19045" set "C_NETNativeRuntime17=+"
	        	if "%ImageBuild%" geq "18362" if "%ImageBuild%" leq "22631" set "C_NETNativeRuntime22=+"
        		if "%ImageBuild%" geq "17763" if "%ImageBuild%" leq "22000" if "%CC_TouchScreenDevices%" equ "-" set "C_VCLibs140UWP=+"
        		if "%ImageBuild%" geq "22621" if "%ImageBuild%" leq "22631" if "%CC_OOBE%" equ "-" set "C_VCLibs140UWP=+"
        		if "%ImageBuild%" geq "18362" if "%ImageBuild%" leq "19045" if "%CC_TouchScreenDevices%" equ "-" set "C_VCLibs140UWPDesktop=+"
        		if "%ImageBuild%" equ "22000" if "%CC_OOBE%" equ "-" if "%CC_TouchScreenDevices%" equ "-" set "C_VCLibs140UWPDesktop=+"
        		if "%ImageBuild%" geq "22621" if "%ImageBuild%" leq "22631" if "%CC_OOBE%" equ "-" if "%CC_TouchScreenDevices%" equ "-" set "C_VCLibs140UWPDesktop=+"
	    	) else (
        		set "CC_ModernAppSupport=+"
        		set "C_DesktopAppInstaller=*"
	        	if "%ImageBuild%" equ "17763" set "C_NETNativeFramework16=*"
        		if "%ImageBuild%" geq "17763" if "%ImageBuild%" leq "19045" set "C_NETNativeFramework17=*"
        		if "%ImageBuild%" geq "18362" if "%ImageBuild%" leq "22631" set "C_NETNativeFramework22=*"
	        	if "%ImageBuild%" equ "17763" set "C_NETNativeRuntime16=*"
        		if "%ImageBuild%" geq "17763" if "%ImageBuild%" leq "19045" set "C_NETNativeRuntime17=*"
        		if "%ImageBuild%" geq "18362" if "%ImageBuild%" leq "22631" set "C_NETNativeRuntime22=*"
	        	set "C_VCLibs140UWP=*"
        		if "%ImageBuild%" geq "18362" if "%ImageBuild%" leq "22631" set "C_VCLibs140UWPDesktop=*"
	    	)
	)
	if "%%#" equ "9" (
		if "%CC_OOBE%" equ "+" (
        		set "CC_OOBE=-"
        		if "%CC_MicrosoftStore%" equ "-" if "%CC_Recommended%" equ "-" if "%CC_ShellSearch%" equ "-" set "C_CloudExperienceHost=+"
			if "%ImageBuild%" geq "19041" if "%ImageBuild%" leq "22631" if "%CC_Recommended%" equ "-" if "%CC_ShellSearch%" equ "-" set "C_UndockedDevKit=+"
        		if "%ImageBuild%" geq "22621" if "%ImageBuild%" leq "22631" if "%CC_ModernAppSupport%" equ "-" if "%CC_TouchScreenDevices%" equ "-" set "C_VCLibs140UWP=+"
        		if "%ImageBuild%" equ "22000" if "%CC_ModernAppSupport%" equ "-" if "%CC_TouchScreenDevices%" equ "-" set "C_VCLibs140UWPDesktop=+"
	        	if "%ImageBuild%" geq "18362" if "%ImageBuild%" leq "18363" set "C_WindowsErrorReporting=+"
    		) else (
        		set "CC_OOBE=+"
	        	set "C_CloudExperienceHost=*"
        		if "%ImageBuild%" geq "19041" if "%ImageBuild%" leq "22631" set "C_UndockedDevKit=*"
			set "C_VCLibs140UWP=*"
        		if "%ImageBuild%" geq "18362" if "%ImageBuild%" leq "22631" set "C_VCLibs140UWPDesktop=*"
        		if "%ImageBuild%" geq "18362" if "%ImageBuild%" leq "18363" set "C_WindowsErrorReporting=*"
	    	)
	)
	if "%%#" equ "10" (
		if "%CC_Printing%" equ "+" (
        		set "CC_Printing=-"
        		set "C_PrintDialog=+"
	    	) else (
        		set "CC_Printing=+"
        		set "C_PrintDialog=*"
	    	)
	)
	if "%%#" equ "11" (
		if "%CC_Recommended%" equ "+" (
        		set "CC_Recommended=-"
        		if "%ImageBuild%" geq "19041" if "%ImageBuild%" leq "22631" if "%CC_ShellSearch%" equ "-" set "C_ClientCBS=+"
        		if "%CC_MicrosoftStore%" equ "-" if "%CC_OOBE%" equ "-" if "%CC_ShellSearch%" equ "-" set "C_CloudExperienceHost=+"
	        	set "C_EdgeChromium=+"
        		if "%ImageBuild%" geq "19041" if "%ImageBuild%" leq "22631" if "%CC_VisualStudio%" equ "-" set "C_EdgeWebView=+"
        		if "%ImageBuild%" geq "17763" if "%ImageBuild%" leq "18363" if "%CC_MicrosoftOfice%" equ "-" if "%CC_TouchScreenDevices%" equ "-" set "C_InputApp=+"
	        	set "C_RemoteDesktopClient=+"
 			if "%CC_ApplicationGuardContainers%" equ "-" set "C_RemoteDesktopServer=+"
        		if "%ImageBuild%" geq "19041" if "%ImageBuild%" leq "22000" if "%CC_ShellSearch%" equ "-" set "C_SearchApp=+"
        		if "%CC_ShellSearch%" equ "-" set "C_ShellExperienceHost=+"
        		if "%ImageBuild%" geq "18362" if "%ImageBuild%" leq "22631" if "%CC_ShellSearch%" equ "-" set "C_StartMenuExperienceHost=+"
	        	if "%ImageBuild%" geq "19041" if "%ImageBuild%" leq "22631" if "%CC_OOBE%" equ "-" if "%CC_ShellSearch%" equ "-" set "C_UndockedDevKit=+"
	        	if "%ImageBuild%" geq "19041" if "%ImageBuild%" leq "22631" set "C_WebView2Runtime=+"
        		if "%ImageBuild%" geq "18362" if "%ImageBuild%" leq "18363" set "C_WindowsFirewall=+"
	    	) else (
        		set "CC_Recommended=+"
        		if "%ImageBuild%" geq "19041" if "%ImageBuild%" leq "22631" set "C_ClientCBS=*"
        		set "C_CloudExperienceHost=*"
	        	set "C_EdgeChromium=*"
        		if "%ImageBuild%" geq "19041" if "%ImageBuild%" leq "22631" set "C_EdgeWebView=*"
        		if "%ImageBuild%" geq "17763" if "%ImageBuild%" leq "18363" set "C_InputApp=*"
	        	set "C_RemoteDesktopClient=*"
			set "C_RemoteDesktopServer=+"
        		if "%ImageBuild%" geq "19041" if "%ImageBuild%" leq "22000" equ "-" set "C_SearchApp=*"
        		set "C_ShellExperienceHost=*"
        		if "%ImageBuild%" geq "18362" if "%ImageBuild%" leq "22631" set "C_StartMenuExperienceHost=*"
	        	if "%ImageBuild%" geq "19041" if "%ImageBuild%" leq "22631" set "C_UndockedDevKit=*"
			if "%ImageBuild%" geq "19041" if "%ImageBuild%" leq "22631" set "C_WebView2Runtime=*"
        		if "%ImageBuild%" geq "18362" if "%ImageBuild%" leq "18363" set "C_WindowsFirewall=*"
	    	)
	)
	if "%%#" equ "12" (
		if "%CC_ShellSearch%" equ "+" (
        		set "CC_ShellSearch=-"
        		if "%ImageBuild%" geq "19041" if "%ImageBuild%" leq "22631" if "%CC_Recommended%" equ "-" set "C_ClientCBS=+"
        		if "%ImageBuild%" geq "17763" if "%ImageBuild%" leq "18363" (
				if "%CC_MicrosoftStore%" equ "-" if "%CC_OOBE%" equ "-" if "%CC_Recommended%" equ "-" set "C_CloudExperienceHost=+"
				set "C_Cortana=+"
			)
	        	if "%ImageBuild%" geq "19041" if "%ImageBuild%" leq "22631" if "%CC_Recommended%" equ "-" set "C_SearchApp=+"
        		if "%ImageBuild%" equ "17763" if "%CC_Recommended%" equ "-" set "C_ShellExperienceHost=+"
        		if "%ImageBuild%" geq "18362" if "%ImageBuild%" leq "22631" if "%CC_Recommended%" equ "-" set "C_StartMenuExperienceHost=+"
	        	if "%ImageBuild%" geq "19041" if "%ImageBuild%" leq "22631" if "%CC_OOBE%" equ "-" if "%CC_Recommended%" equ "-" set "C_UndockedDevKit=+"
	    	) else (
        		set "CC_ShellSearch=+"
			if "%ImageBuild%" geq "22000" if "%ImageBuild%" leq "22631" set "C_ClientCBS=*"
        		if "%ImageBuild%" geq "17763" if "%ImageBuild%" leq "18363" (
				set "C_CloudExperienceHost=*"
				set "C_Cortana=*"
			)
	        	if "%ImageBuild%" geq "19041" if "%ImageBuild%" leq "22631" set "C_SearchApp=*"
        		if "%ImageBuild%" equ "17763" set "C_ShellExperienceHost=*"
			if "%ImageBuild%" geq "18362" if "%ImageBuild%" leq "22631" set "C_StartMenuExperienceHost=*"
	        	if "%ImageBuild%" geq "19041" if "%ImageBuild%" leq "22631" set "C_UndockedDevKit=*"
	    	)
	)
	if "%%#" equ "13" (
		if "%CC_TouchScreenDevices%" equ "+" (
        		set "CC_TouchScreenDevices=-"
	        	if "%ImageBuild%" geq "17763" if "%ImageBuild%" leq "18363" if "%CC_MicrosoftOfice%" equ "-" if "%CC_Recommended%" equ "-" set "C_InputApp=+"
        		if "%CC_ModernAppSupport%" equ "-" set "C_VCLibs140UWP=+"
        		if "%CC_ModernAppSupport%" equ "-" if "%ImageBuild%" geq "18362" if "%ImageBuild%" leq "22631" set "C_VCLibs140UWPDesktop=+"
	    	) else (
	        	set "CC_TouchScreenDevices=+"
        		if "%ImageBuild%" geq "17763" if "%ImageBuild%" leq "18363" set "C_InputApp=*"
        		set "C_VCLibs140UWP=*"
	        	if "%ImageBuild%" geq "18362" if "%ImageBuild%" leq "22631" set "C_VCLibs140UWPDesktop=*"
    		)
	)
	if "%%#" equ "14" (
		if "%CC_VisualStudio%" equ "+" (
        		set "CC_VisualStudio=-"
        		if "%CC_Recommended%" equ "-" if "%ImageBuild%" geq "22000" if "%ImageBuild%" leq "22631" set "C_EdgeWebView=+"
	    	) else (
	        	set "CC_VisualStudio=+"
        		if "%ImageBuild%" geq "22000" if "%ImageBuild%" leq "22631" set "C_EdgeWebView=*"
	    	)
	)
	if "%%#" equ "15" (
		if "%CC_WindowsUpdate%" equ "+" (
	        	set "CC_WindowsUpdate=-"
        		set "C_WindowsUpdate=+"
		) else (
        		set "CC_WindowsUpdate=+"
	        	set "C_WindowsUpdate=*"
    		)
	)
	if "%%#" equ "16" (
		if "%CC_WindowsUpgrade%" equ "+" (
        		set "CC_WindowsUpgrade=-"
	        	set "C_EasyTransfer=+"
	        	set "C_ManualSetup=+"
    		) else (
        		set "CC_WindowsUpgrade=+"
	        	set "C_EasyTransfer=*"
        		set "C_ManualSetup=*"
	    	)
	)
	if "%%#" equ "17" (
		if "%CC_XboxApp%" equ "+" (
        		set "CC_XboxApp=-"
        		if "%ImageBuild%" geq "22000" if "%ImageBuild%" leq "22631" set "C_GamingApp=+"
	        	if "%ImageBuild%" geq "17763" if "%ImageBuild%" leq "19045" set "C_XboxApp=+"
        		set "C_XboxCore=+"
        		set "C_XboxGamingOverlay=+"
        		set "C_XboxGameOverlay=+"
        		set "C_XboxSpeechToTextOverlay=+"
        		if "%CC_MicrosoftStore%" equ "-" set "C_XboxIdentityProvider=+"
        		set "C_XboxTCUI=+"
		) else (
        		set "CC_XboxApp=+"
	        	if "%ImageBuild%" geq "22000" if "%ImageBuild%" leq "22631" set "C_GamingApp=*"
        		if "%ImageBuild%" geq "17763" if "%ImageBuild%" leq "19045" set "C_XboxApp=*"
        		set "C_XboxCore=*"
        		set "C_XboxGamingOverlay=*"
        		set "C_XboxGameOverlay=*"
        		set "C_XboxSpeechToTextOverlay=*"
        		set "C_XboxIdentityProvider=*"
        		set "C_XboxTCUI=*"
		)
	)
	if /i "%%#" equ "N" goto :RemoveInternetMenu
)

goto :ComponentsCompatibilityMenu

:RemoveInternetMenu
:: �Ƴ� Windows 10 v1809/v1903/v1909/v2004/v20H2/v21H1/v21H2/v22H2��Windows 11 v21H2/v22H2 �ͻ��� Internet �˵�
if "%SelectedSourceOS%" neq "w7" if "%SelectedSourceOS%" neq "w81" if "%ImageBuild%" geq "17763" if "%ImageBuild%" leq "22631" (
	cls
	echo.===============================================================================
	echo.                           Internet ���
	echo.===============================================================================
	echo.
	if "%SelectedSourceOS%" equ "w10" if "%ImageServicePackBuild%" equ "1" (
		echo.  [1] %C_AdobeFlashForWindows% ������ Windows �� Adobe Flash
		echo.        ������ Windows �� Adobe Flash ֧�֡�
		echo.
	)
	echo.  [2] %C_InternetExplorer% Internet Explorer
	echo.        Internet Explorer ��һ�� Web ������������û��� Internet �ϲ鿴��ҳ��
	echo.        ������        ��Adobe ��װ����
	echo.
	echo.  [3] %C_EdgeChromium% Microsoft Edge Chromium
	echo.        ���� Chromium �� Microsoft Edge web �������
	echo.        ������        ���Ƽ�
	echo.
	if "%SelectedSourceOS%" equ "w11" (
		echo.  [4] %C_EdgeWebView% Microsoft Edge WebView
		echo.        Microsoft Edge WebView �ؼ��������ڱ���Ӧ�ó�����Ƕ�� Web ����
		echo.        ��HTML��CSS �� JavaScript����
		echo.        ������        ��Microsoft Edge Chromium
		echo.        ������        ���Ƽ���Visual Studio
		echo.
	)
	echo.
	echo.
	echo.  [A]   ���� Internet ���
	echo.  [B]   �ص���һ��
	echo.  [N]   ��һ��
	echo.
	echo.===============================================================================
	echo.
	echo.  Tips���������㲻��Ҫ���������ţ�ʹǰ��� + ��� - 
	echo.        ������ǰΪ * �����������ܱ�����
	echo.
	set /p MenuChoice=���������ѡ��󰴻س���

	if /i "!MenuChoice!" neq "A" for %%# in (!MenuChoice!) do (
		if "%%#" equ "1" if "%SelectedSourceOS%" equ "w10" if "%ImageServicePackBuild%" equ "1" ( if "%C_AdobeFlashForWindows%" equ "+" ( set "C_AdobeFlashForWindows=-" ) else ( set "C_AdobeFlashForWindows=+" ) )
		if "%%#" equ "2" if "%C_InternetExplorer%" neq "*" ( if "%C_InternetExplorer%" equ "+" ( set "C_InternetExplorer=-" ) else ( set "C_InternetExplorer=+" ) )
		if "%%#" equ "3" if "%C_EdgeChromium%" neq "*" (
			if "%C_EdgeChromium%" equ "+" (
				set "C_EdgeChromium=-"
				if "%SelectedSourceOS%" equ "w11" (
					if "%C_EdgeWebView%" neq "*" set "C_EdgeWebView=-"
					set "C_ClientWebExperience=-"
				)
			) else (
				set "C_EdgeChromium=+"
			)
		)
		if "%%#" equ "4" if "%SelectedSourceOS%" equ "w11" if "%C_EdgeWebView%" neq "*" (
			if "%C_EdgeWebView%" equ "+" (
				set "C_ClientWebExperience=-"
				set "C_EdgeWebView=-"
			) else ( 
				if "%C_EdgeChromium%" neq "*" set "C_EdgeChromium=-"
				set "C_EdgeWebView=+"
			)
		)
		if /i "%%#" equ "B" goto :ComponentsCompatibilityMenu
		if /i "%%#" equ "N" goto :RemoveMultimediaMenu
	)

	if /i "!MenuChoice!" equ "A" (
		if "%SelectedSourceOS%" equ "w10" if "%ImageServicePackBuild%" equ "1" set "C_AdobeFlashForWindows=-"
		if "%C_InternetExplorer%" neq "*" set "C_InternetExplorer=-"
		if "%C_EdgeChromium%" neq "*" set "C_EdgeChromium=-"
		if "%SelectedSourceOS%" equ "w11" (
			set "C_ClientWebExperience=-"
			if "%C_EdgeWebView%" neq "*" set "C_EdgeWebView=-"
		)
	)

	goto :RemoveInternetMenu
)

:RemoveMultimediaMenu
:: �Ƴ� Windows 10 v1809/v1903/v1909/v2004/v20H2/v21H1/v21H2/v22H2��Windows 11 v21H2/v22H2 �ͻ��˶�ý��˵�
if "%SelectedSourceOS%" neq "w7" if "%SelectedSourceOS%" neq "w81" if "%ImageBuild%" geq "17763" if "%ImageBuild%" leq "22631" (
	cls
	echo.===============================================================================
	echo.                               ��ý�����
	echo.===============================================================================
	echo.
	echo.  [ 1] %C_FirstLogonAnimation% �״ε�¼����
	echo.         �״ε�¼���������ش���¡��汾���Ļ򼸸����û��ʻ����¼ʱ��ʾ����
	echo.         Ļ�ϵ�һϵ����Ϣ��
	echo.         ������        ��ȫ�°�װ���飨OOBE��
	echo.
	echo.  [ 2] %C_GameExplorer% ��Ϸ�����
	echo.         ��Ϸ�������һ��ܣ�������鿴������ϵ�ǰ��װ��������Ϸ�����߲�
	echo.         ��������Ϸ��
	echo.         ������        ��Microsoft ��Ϸ
	echo.
	echo.  [ 3] %C_LockScreenBackground% ��������
	echo.         ����������п��Զ����ǽֽ����ͼ������������ʾ��ͼ��ͬ��
	echo.
	echo.  [ 4] %C_ScreenSavers% ��Ļ��������
	echo.         ��Ļ���������Ǽ��������ּ�����㲻ʹ����Ļʱʹ��Ļ�հ׻����ƶ�ͼ
	echo.         �������Ļ��
	echo.
	if "%SelectedSourceOS%" equ "w10" (
		echo.  [ 5] %C_SnippingTool% ��ͼ����
		echo.         ��ͼ������һ����Ļ��ͼʵ�ó������ڽ�ȡ�򿪵Ĵ��ڡ�������������
		echo.         ��ʽ�����������Ļ�ľ�̬��Ļ��ͼ��
		echo.
	)
	echo.  [ 6] %C_SoundThemes% ��������
	echo.         ���� Windows �������������
	echo.
	echo.  [ 7] %C_SpeechRecognition% ����ʶ��
	echo.         ����ʶ��ʹ���������ܹ����������û����桢��д�����ĵ��͵����ʼ��е�
	echo.         �ı���������վ��ִ�м��̿�ݼ��Լ���������ꡣ
	echo.
	echo.  [ 8] %C_Wallpapers% ǽֽ
	echo.         ���� Windows ����������Ǳ�ֽ��
	echo.
	if "%ImageBuild%" geq "17763" if "%ImageBuild%" leq "22000" echo.  [ 9] %C_WindowsMediaPlayer% Windows Media Player
	if "%SelectedSourceOS%" equ "w11" if "%ImageBuild%" geq "22621" if "%ImageBuild%" leq "22631" echo.  [ 9] %C_WindowsMediaPlayer% �ɰ� Windows Media Player
	echo.         Windows Media Player ��һ���򵥵�ʵ�ù��ߣ������㲥����Ƶ����Ƶ�ļ���
	echo.
	echo.  [10] %C_WindowsPhotoViewer% Windows ��Ƭ�鿴��
	echo.         Windows ��Ƭ�鿴����һ���򵥵�ʵ�ù��ߣ���������ʾͼ���ļ���
	echo.
	echo.  [11] %C_WindowsThemes% Windows ���Ի�����
	echo.         ���� Windows ���Ի����⡣
	echo.
	echo.  [12] %C_WindowsTIFFIFilter% Windows TIFF IFilter��OCR��
	echo.         Windows TIFF IFilter ���� TIFF ͼ��Ȼ��ʶ����ı��ṩ�����÷���
	echo.         ��������������
	echo.
	echo.  [13] %C_WinSAT% Windows ϵͳ�������ߣ�WinSAT��
	echo.         �����������Ե����������͹��ܵ� Windows ���ܻ�׼���ߡ�
	echo.         ������        ��Microsoft ��Ϸ
	echo.
	echo.  [A]    ���ж�ý�����
	echo.  [B]    �ص���һ��
	echo.  [N]    ��һ��
	echo.
	echo.===============================================================================
	echo.
	echo.  Tips���������㲻��Ҫ���������ţ�ʹǰ��� + ��� - 
	echo.        ������ǰΪ * �����������ܱ�����
	echo.
	set /p MenuChoice=���������ѡ��󰴻س���

	if /i "!MenuChoice!" neq "A" for %%# in (!MenuChoice!) do (
		if "%%#" equ "1" (
			if "%C_FirstLogonAnimation%" equ "+" ( 
				set "C_FirstLogonAnimation=-"
			) else ( 
				if "%C_CloudExperienceHost%" neq "*" set "C_CloudExperienceHost=+"
				set "C_FirstLogonAnimation=+"
			)
		)
		if "%%#" equ "2" if "%C_GameExplorer%" neq "*" ( if "%C_GameExplorer%" equ "+" ( set "C_GameExplorer=-" ) else ( set "C_GameExplorer=+" ) )
		if "%%#" equ "3" ( if "%C_LockScreenBackground%" equ "+" ( set "C_LockScreenBackground=-" ) else ( set "C_LockScreenBackground=+" ) )
		if "%%#" equ "4" ( if "%C_ScreenSavers%" equ "+" ( set "C_ScreenSavers=-" ) else ( set "C_ScreenSavers=+" ) )
		if "%%#" equ "5" if "%SelectedSourceOS%" equ "w10" ( if "%C_SnippingTool%" equ "+" ( set "C_SnippingTool=-" ) else ( set "C_SnippingTool=+" ) )
		if "%%#" equ "6" ( if "%C_SoundThemes%" equ "+" ( set "C_SoundThemes=-" ) else ( set "C_SoundThemes=+" ) )
		if "%%#" equ "7" (
			if "%C_SpeechRecognition%" equ "+" ( 
				set "C_Narrator=-"
				set "C_NarratorQuickStart=-"
				set "C_SpeechRecognition=-"
				if "%SelectedSourceOS%" equ "w11" if "%ImageBuild%" geq "22621" if "%ImageBuild%" leq "22631" set "C_VoiceAccess=-"
			) else ( 
				set "C_SpeechRecognition=+"
			)
		)
		if "%%#" equ "8" ( if "%C_Wallpapers%" equ "+" ( set "C_Wallpapers=-" ) else ( set "C_Wallpapers=+" ) )
		if "%%#" equ "9" ( if "%C_WindowsMediaPlayer%" equ "+" ( set "C_WindowsMediaPlayer=-" ) else ( set "C_WindowsMediaPlayer=+" ) )
		if "%%#" equ "10" ( if "%C_WindowsPhotoViewer%" equ "+" ( set "C_WindowsPhotoViewer=-" ) else ( set "C_WindowsPhotoViewer=+" ) )
		if "%%#" equ "11" ( if "%C_WindowsThemes%" equ "+" ( set "C_WindowsThemes=-" ) else ( set "C_WindowsThemes=+" ) )
		if "%%#" equ "12" ( if "%C_WindowsTIFFIFilter%" equ "+" ( set "C_WindowsTIFFIFilter=-" ) else ( set "C_WindowsTIFFIFilter=+" ) )
		if "%%#" equ "13" if "%C_WinSAT%" neq "*" ( if "%C_WinSAT%" equ "+" ( set "C_WinSAT=-" ) else ( set "C_WinSAT=+" ) )
		if /i "%%#" equ "B" goto :RemoveInternetMenu
		if /i "%%#" equ "N" goto :RemoveNetworkMenu
	)

	if /i "!MenuChoice!" equ "A" (
		set "C_FirstLogonAnimation=-"
		if "%C_GameExplorer%" neq "*" set "C_GameExplorer=-"
		set "C_LockScreenBackground=-"
		set "C_ScreenSavers=-"
		if "%SelectedSourceOS%" equ "w10" set "C_SnippingTool=-"
		set "C_SoundThemes=-"
		set "C_SpeechRecognition=-"
		if "%SelectedSourceOS%" equ "w11" if "%ImageBuild%" geq "22621" if "%ImageBuild%" leq "22631" set "C_VoiceAccess=-"
		set "C_Wallpapers=-"
		set "C_WindowsMediaPlayer=-"
		set "C_WindowsPhotoViewer=-"
		set "C_WindowsThemes=-"
		set "C_WindowsTIFFIFilter=-"
		if "%C_WinSAT%" neq "*" set "C_WinSAT=-"
	)

	goto :RemoveMultimediaMenu
)

:RemoveNetworkMenu
:: �Ƴ� Windows 10 v1809/v1903/v1909/v2004/v20H2/v21H1/v21H2/v22H2��Windows 11 v21H2/v22H2 �ͻ�������˵�
if "%SelectedSourceOS%" neq "w7" if "%SelectedSourceOS%" neq "w81" if "%ImageBuild%" geq "17763" if "%ImageBuild%" leq "22631" (
	cls
	echo.===============================================================================
	echo.                                 �������
	echo.===============================================================================
	echo.
	echo.  [1] %C_OfflineFiles% �ѻ��ļ�
	echo.        �ѻ��ļ���ͬ�����ĵ�һ��ܣ���ʹ�����ļ��ɹ��û�ʹ�ã���ʹ������Ҳ
	echo.        ����ˡ����ʹ�ñ�Яʽ��������ӵ�������������������������ӣ��⽫��
	echo.        �����á�
	echo.        ������        ��Ӧ�ó������ / ����
	echo.
	echo.  [2] %C_OpenSSH% OpenSSH
	echo.        ����ʹ�ð�ȫ��ǣ�SSH��Э���Զ�̵�¼�Ŀ�Դ���ӹ��ߡ�
	echo.
	echo.  [3] %C_RemoteDesktopClient% Զ������ͻ���
	echo.        Microsoft Զ������ͻ���������� Windows Server ��Զ�̵������ӵ�Զ��
	echo.        ���������ʹ�úͿ��ƹ���Ա�ṩ����������Ӧ�á�
	echo.        ������        ���Ƽ�
	echo.
	echo.  [4] %C_RemoteDifferentialCompression% Զ�̲��ѹ����RDC��
	echo.        ����ʹ��ѹ��������������Զ��Դͬ���������̶ȵؼ���ͨ�����緢�͵���
	echo.        ������
	echo.
	echo.  [5] %C_SimpleTCPIPServices% �� TCP/IP ����
	echo.        �� TCP/IP ����֧������ TCP/IP ����Character Generator��Daytime��
	echo.        Discard��Echo �� Quote of the Day��
	echo.
	echo.  [6] %C_TelnetClient% Telnet �ͻ���
	echo.        Telnet �ͻ���ʹ TCP/IP �û��ܹ�ʹ�� Telnet ������Ӧ�ó����¼��ʹ��Զ
	echo.        ��ϵͳ�ϵ�Ӧ�ó���
	echo.
	echo.  [7] %C_TFTPClient% TFTP �ͻ���
	echo.        ���ļ�����Э�飨TFTP����һ���򵥵������ļ�����Э�飬������ͻ��˴�
	echo.        Զ��������ȡ�ļ����ļ��ŵ�Զ�������ϡ�
	echo.
	echo.  [8] %C_WalletService% ����Ǯ������
	echo.        Ǯ��Ӧ������ĺ�ˣ�Microsoft Windows ֧��ϵͳ��
	echo.
	echo.  [9] %C_WindowsMail% Windows �ʼ�
	echo.        Windows �ʼ���һ�������ʼ��ͻ��ˡ�
	echo.
	echo.  [A]   �����������
	echo.  [B]   �ص���һ��
	echo.  [N]   ��һ��
	echo.
	echo.===============================================================================
	echo.
	echo.  Tips���������㲻��Ҫ���������ţ�ʹǰ��� + ��� - 
	echo.        ������ǰΪ * �����������ܱ�����
	echo.
	set /p MenuChoice=���������ѡ��󰴻س���

	if /i "!MenuChoice!" neq "A" for %%# in (!MenuChoice!) do (
		if "%%#" equ "1" if "%C_OfflineFiles%" neq "*" ( if "%C_OfflineFiles%" equ "+" ( set "C_OfflineFiles=-" ) else ( set "C_OfflineFiles=+" ) )
		if "%%#" equ "2" ( if "%C_OpenSSH%" equ "+" ( set "C_OpenSSH=-" ) else ( set "C_OpenSSH=+" ) )
		if "%%#" equ "3" if "%C_RemoteDesktopClient%" neq "*" ( if "%C_RemoteDesktopClient%" equ "+" ( set "C_RemoteDesktopClient=-" ) else ( set "C_RemoteDesktopClient=+" ) )
		if "%%#" equ "4" ( if "%C_RemoteDifferentialCompression%" equ "+" ( set "C_RemoteDifferentialCompression=-" ) else ( set "C_RemoteDifferentialCompression=+" ) )
		if "%%#" equ "5" ( if "%C_SimpleTCPIPServices%" equ "+" ( set "C_SimpleTCPIPServices=-" ) else ( set "C_SimpleTCPIPServices=+" ) )
		if "%%#" equ "6" ( if "%C_TelnetClient%" equ "+" ( set "C_TelnetClient=-" ) else ( set "C_TelnetClient=+" ) )
		if "%%#" equ "7" ( if "%C_TFTPClient%" equ "+" ( set "C_TFTPClient=-" ) else ( set "C_TFTPClient=+" ) )
		if "%%#" equ "8" (
			if "%C_WalletService%" equ "+" (
				set "C_Wallet=-"
				set "C_WalletService=-"
			) else (
				set "C_WalletService=+"
			)
		)
		if "%%#" equ "9" ( if "%C_WindowsMail%" equ "+" ( set "C_WindowsMail=-" ) else ( set "C_WindowsMail=+" ) )
		if /i "%%#" equ "B" goto :RemoveMultimediaMenu
		if /i "%%#" equ "N" goto :RemovePrivacyMenu
	)

	if /i "!MenuChoice!" equ "A" (
		if "%C_OfflineFiles%" neq "*" set "C_OfflineFiles=-"
		set "C_OpenSSH=-"
		if "%C_RemoteDesktopClient%" neq "*" set "C_RemoteDesktopClient=-"
		set "C_RemoteDifferentialCompression=-"
		set "C_SimpleTCPIPServices=-"
		set "C_TelnetClient=-"
		set "C_TFTPClient=-"
		set "C_Wallet=-"
		set "C_WalletService=-"
		set "C_WindowsMail=-"
	)

	goto :RemoveNetworkMenu
)

:RemovePrivacyMenu
:: �Ƴ� Windows 10 v1809/v1903/v1909/v2004/v20H2/v21H1/v21H2/v22H2��Windows 11 v21H2/v22H2 �ͻ�����˽�˵�
if "%SelectedSourceOS%" neq "w7" if "%SelectedSourceOS%" neq "w81" if "%ImageBuild%" geq "17763" if "%ImageBuild%" leq "22631" (
	cls
	echo.===============================================================================
	echo.                                 ��˽���
	echo.===============================================================================
	echo.
	echo.  [ 1] %C_AssignedAccess% ����ķ���Ȩ��
	echo.         ����Ա����ʹ�÷���ķ���Ȩ�������������û��ʻ���ʹ����ѡ���һ���Ѱ�
	echo.         װ�� Windows����������õ�һ�����豸����������˵�����ó��չ��������
	echo.         ʾ���ǳ����á�
	echo.
	echo.  [ 2] %C_CEIP% �ͻ�������Ƽƻ���SQM��
	echo.         Windows �ͻ�������Ƽƻ���SQM���ռ��йؿͻ����ʹ���й�����������ĳ
	echo.         Щ����ļƻ� Microsoft ����Ϣ��Microsoft ʹ�ô���Ϣ���Ľ��ͻ��ʹ
	echo.         �õĲ�Ʒ�͹��ܣ�������������⡣
	echo.
	echo.  [ 3] %C_FaceRecognition% ����ʶ��Windows Hello ������
	echo.         Windows Hello ������һ�ֵ�¼���豸��Ӧ�á����������������·�����
	echo.         ������ȫ����Ϊ��ʹ�á�����ʶ�������֤��ʹ������沿��¼��
	echo.
	echo.  [ 4] %C_KernelDebugging% �ں˵���
	echo.         �ں˵����������ڼ��ں˿�����Ա���Ժ��ں˿����ĵ�������
	echo.         ������        ��Windows ���󱨸�
	echo.         ������        ��Ӧ�ó������ / ����
	echo.
	echo.  [ 5] %C_LocationService% ��λ����
	echo.         �˷������ϵͳ�ĵ�ǰλ�ò��������Χ�������й����¼��ĵ���λ�ã���
	echo.
	echo.  [ 6] %C_PicturePassword% ͼƬ����
	echo.         ʹ��ϲ������Ƭ��¼�� Windows��ͼƬ������һ�ֵ�¼ Windows �ķ�������
	echo.         ��ʹ����ѡ���ͼƬ���ڸ�ͼƬ�ϻ��Ƶ����ƣ����������롣
	echo.
	echo.  [ 7] %C_PinEnrollment% Pin ��¼֧��
	echo.         Microsoft Windows Hello ��¼���˱�ʶ�ţ�PIN�������Լ�ѡ���һ������
	echo.         ����ĸ�����ֵ���ϡ�ʹ�� PIN �ǵ�¼�� Windows �豸��һ�ֿ��١���ȫ��
	echo.         ��������� PIN �밲ȫ�ش洢������豸�ϡ�
	echo.         ������        ������ʶ��
	echo.
	echo.  [ 8] %C_UnifiedTelemetryClient% ͳһң��ͻ���
	echo.         ң�������ռ����� Microsoft ���棬�ԸĽ� Windows��
	echo.
	echo.  [ 9] %C_WiFiNetworkManager% WiFi �����������WiFi ��֪��
	echo.         �ṩ�Զ������ Outlook��Skype �� Facebook ��ϵ�˹��� Wi-Fi ����Ĺ�
	echo.         �ܣ��Ӷ�ʵ������֮����޷� Wi-Fi ����ʹ�á�
	echo.
	echo.  [10] %C_WindowsErrorReporting% Windows ���󱨸�
	echo.         ���ڲ������ת����ѡ���Եؽ��䱨��� Microsoft �Ļ������ߡ�
	if "%ImageBuild%" geq "18362" if "%ImageBuild%" leq "18363" echo.         ������        ��ȫ�°�װ���飨OOBE��
	echo.
	echo.  [11] %C_WindowsInsiderHub% Windows Ԥ������ƻ�
	echo.         Windows Ԥ������ƻ���һ���������� Windows ��ʵ��˿��ɵ�����������
	echo.         ����Ԥ�� Windows ���ܡ���Ԥ�� Windows ʱ��Ԥ�������Ա�����ṩ������
	echo.         �� Microsoft ����ʦֱ�ӻ������԰������� Windows ��δ����
	echo.
	echo.  [A]   ������˽���
	echo.  [B]   �ص���һ��
	echo.  [N]   ��һ��
	echo.
	echo.===============================================================================
	echo.
	echo.  Tips���������㲻��Ҫ���������ţ�ʹǰ��� + ��� - 
	echo.        ������ǰΪ * �����������ܱ�����
	echo.
	set /p MenuChoice=���������ѡ��󰴻س���

	if /i "!MenuChoice!" neq "A" for %%# in (!MenuChoice!) do (
		if "%%#" equ "1" ( 
			if "%C_AssignedAccess%" equ "+" ( 
				set "C_AssignedAccess=-"
				if "%ImageFlag%" neq "Core" if "%ImageFlag%" neq "CoreN" if "%ImageFlag%" neq "CoreSingleLanguage" set "C_AssignedAccessLockApp=-"
			) else ( 
				set "C_AssignedAccess=+"
			)
		)
		if "%%#" equ "2" ( if "%C_CEIP%" equ "+" ( set "C_CEIP=-" ) else ( set "C_CEIP=+" ) )
		if "%%#" equ "3" ( if "%C_FaceRecognition%" equ "+" ( set "C_FaceRecognition=-" ) else ( set "C_FaceRecognition=+" ) )
		if "%%#" equ "4" if "%C_KernelDebugging%" neq "*" ( if "%C_KernelDebugging%" equ "+" ( set "C_KernelDebugging=-" ) else ( set "C_KernelDebugging=+" ) )
		if "%%#" equ "5" ( if "%C_LocationService%" equ "+" ( set "C_LocationService=-" ) else ( set "C_LocationService=+" ) )
		if "%%#" equ "6" ( if "%C_PicturePassword%" equ "+" ( set "C_PicturePassword=-" ) else ( set "C_PicturePassword=+" ) )
		if "%%#" equ "7" if "%C_PinEnrollment%" neq "*" ( if "%C_PinEnrollment%" equ "+" ( set "C_PinEnrollment=-" ) else ( set "C_PinEnrollment=+" ) )
		if "%%#" equ "8" ( if "%C_UnifiedTelemetryClient%" equ "+" ( set "C_UnifiedTelemetryClient=-" ) else ( set "C_UnifiedTelemetryClient=+" ) )
		if "%%#" equ "9" ( if "%C_WiFiNetworkManager%" equ "+" ( set "C_WiFiNetworkManager=-" ) else ( set "C_WiFiNetworkManager=+" ) )
		if "%%#" equ "10" if "%C_WindowsErrorReporting%" neq "*" ( if "%C_WindowsErrorReporting%" equ "+" ( set "C_WindowsErrorReporting=-" ) else ( set "C_WindowsErrorReporting=+" ) )
		if "%%#" equ "11" ( if "%C_WindowsInsiderHub%" equ "+" ( set "C_WindowsInsiderHub=-" ) else ( set "C_WindowsInsiderHub=+" ) )
		if /i "%%#" equ "B" goto :RemoveNetworkMenu
		if /i "%%#" equ "N" goto :RemoveRemotingMenu
	)

	if /i "!MenuChoice!" equ "A" (
		set "C_AssignedAccess=-"
		if "%ImageFlag%" neq "Core" if "%ImageFlag%" neq "CoreN" if "%ImageFlag%" neq "CoreSingleLanguage" set "C_AssignedAccessLockApp=-"
		set "C_CEIP=-"
		set "C_FaceRecognition=-"
		if "%C_KernelDebugging%" neq "*" set "C_KernelDebugging=-"
		set "C_LocationService=-"
		set "C_PicturePassword=-"
		if "%C_PinEnrollment%" neq "*" set "C_PinEnrollment=-"
		set "C_UnifiedTelemetryClient=-"
		set "C_WiFiNetworkManager=-"
		if "%C_WindowsErrorReporting%" neq "*" set "C_WindowsErrorReporting=-"
		set "C_WindowsInsiderHub=-"
	)

	goto :RemovePrivacyMenu
)

:RemoveRemotingMenu
:: �Ƴ� Windows 10 v1809/v1903/v1909/v2004/v20H2/v21H1/v21H2/v22H2��Windows 11 v21H2/v22H2 �ͻ���Զ�̴���˵�
if "%SelectedSourceOS%" neq "w7" if "%SelectedSourceOS%" neq "w81" if "%ImageBuild%" geq "17763" if "%ImageBuild%" leq "22631" (
	cls
	echo.===============================================================================
	echo.                               Զ�̴������
	echo.===============================================================================
	echo.
	if "%ImageBuild%" geq "17763" if "%ImageBuild%" leq "22000" (
		echo.  [1] %C_HomeGroup% ��ͥ��
		echo.        ��ͥ���Ǽ�ͥ�����Ͽ��Թ����ļ��ʹ�ӡ����һ����ԡ�
		echo.
	)
	echo.  [2] %C_MultiPointConnector% MultiPoint Connector
	echo.        ʹ������ܹ��� MultiPoint ���������Ǳ��Ӧ�ü��Ӻ͹���
	echo.
	echo.  [3] %C_OneDrive% OneDrive ����ͻ���
	echo.        OneDrive ��һ���ƴ洢���ļ��йܷ��������û�ͬ���ļ����Ժ�� Web ���
	echo.        �����ƶ��豸�������ǡ�
	echo.
	echo.  [4] %C_RemoteAssistance% Զ��Э��
	echo.        Ϊ�����ε����ṩ��ݵķ�ʽ���������ѻ���֧����Ա���ӵ���ļ��������
	echo.        ������ɽ��������
	echo.
	echo.  [5] %C_RemoteDesktopServer% Զ�����������
	echo.        Զ���������RDS���� Microsoft Windows Server ���ܵ��ܳƣ������û�Զ
	echo.        �̷���ͼ������� Windows Ӧ�ó���
	echo.        ������        ��Ӧ�ó������ / ������Hyper-V
	echo.
	echo.  [6] %C_RemoteRegistry% Զ��ע���
	echo.        ʹԶ���û��ܹ��޸Ĵ˼�����ϵ�ע������á�
	echo.
	echo.  [7] %C_WorkFoldersClient% �����ļ��пͻ���
	echo.        �����û������ݴ�λ�ڹ�˾�������ĵ��û��ļ���ͬ�������豸��
	echo.        ���� Active Directory ���������֤����ADFS����
	echo.
	echo.  [A]   ����Զ�̴������
	echo.  [B]   �ص���һ��
	echo.  [N]   ��һ��
	echo.
	echo.===============================================================================
	echo.
	echo.  Tips���������㲻��Ҫ���������ţ�ʹǰ��� + ��� - 
	echo.        ������ǰΪ * �����������ܱ�����
	echo.
	set /p MenuChoice=���������ѡ��󰴻س���

	if /i "!MenuChoice!" neq "A" for %%# in (!MenuChoice!) do (
		if "%%#" equ "1" if "%ImageBuild%" geq "17763" if "%ImageBuild%" leq "22000" ( if "%C_HomeGroup%" equ "+" ( set "C_HomeGroup=-" ) else ( set "C_HomeGroup=+" ) )
		if "%%#" equ "2" ( if "%C_MultiPointConnector%" equ "+" ( set "C_MultiPointConnector=-" ) else ( set "C_MultiPointConnector=+" ) )
		if "%%#" equ "3" ( if "%C_OneDrive%" equ "+" ( set "C_OneDrive=-" ) else ( set "C_OneDrive=+" ) )
		if "%%#" equ "4" ( if "%C_RemoteAssistance%" equ "+" ( set "C_RemoteAssistance=-" ) else ( set "C_RemoteAssistance=+" ) )
		if "%%#" equ "5" if "%C_RemoteDesktopServer%" neq "*" ( if "%C_RemoteDesktopServer%" equ "+" ( set "C_RemoteDesktopServer=-" ) else ( set "C_RemoteDesktopServer=+" ) )
		if "%%#" equ "6" ( if "%C_RemoteRegistry%" equ "+" ( set "C_RemoteRegistry=-" ) else ( set "C_RemoteRegistry=+" ) )
		if "%%#" equ "7" ( if "%C_WorkFoldersClient%" equ "+" ( set "C_WorkFoldersClient=-" ) else ( set "C_WorkFoldersClient=+" ) )
		if /i "%%#" equ "B" goto :RemovePrivacyMenu
		if /i "%%#" equ "N" goto :RemoveSystemMenu
	)

	if /i "!MenuChoice!" equ "A" (
		if "%SelectedSourceOS%" equ "w10" set "C_HomeGroup=-"
		set "C_MultiPointConnector=-"
		set "C_OneDrive=-"
		set "C_RemoteAssistance=-"
		if "%C_RemoteDesktopServer%" neq "*" set "C_RemoteDesktopServer=-"
		set "C_RemoteRegistry=-"
		set "C_WorkFoldersClient=-"
	)

	goto :RemoveRemotingMenu
)

:RemoveSystemMenu
:: �Ƴ� Windows 10 v1809/v1903/v1909/v2004/v20H2/v21H1/v21H2/v22H2��Windows 11 v21H2/v22H2 �ͻ���ϵͳ�˵�
if "%SelectedSourceOS%" neq "w7" if "%SelectedSourceOS%" neq "w81" if "%ImageBuild%" geq "17763" if "%ImageBuild%" leq "22631" (
	cls
	echo.===============================================================================
	echo.                                ϵͳ���
	echo.===============================================================================
	echo.
	echo.  [ 1] %C_AccessibilityTools% �������ߣ����ɷ��ʣ�
	echo.         ���������򵼺͹��߿������������ϵͳ������������Ӿ����������ƶ���
	echo.         �󡣰��������ĸ������ܣ���ɸѡ����
	echo.
	if "%ImageFlag%" equ "EnterpriseS" (
		echo.  [ 2] %C_Calculator% �ɰ������
		echo.         Windows Win32 ��������
		echo.
	)
	if "%ImageFlag%" equ "EnterpriseSN" (
		echo.  [ 2] %C_Calculator% �ɰ������
		echo.         Windows Win32 ��������
		echo.
	)
	echo.  [ 3] %C_DeviceLockdown% �豸������Ƕ��ʽ���飩
	echo.         �����Զ����¼������ɸѡ����shell ����������Ʒ��������ͳһд��ɸѡ����
	echo.
	echo.  [ 4] %C_EaseOfAccessCursors% ���ɷ��ʹ��
	echo.         ���ָ�루�������ܹ��ߣ���
	echo.         ������        ���������ߣ����ɷ��ʣ�
	echo.
	echo.  [ 5] %C_EaseOfAccessThemes% ���ɷ�������
	echo.         �������ɷ������⡢�߶Աȶȱ仯��
	echo.         ������        ���������ߣ����ɷ��ʣ�
	echo.
	echo.  [ 6] %C_EasyTransfer% ���ɴ���
	echo.         �����㽫�ļ��������ƶ����µ��ԡ�
	echo.         ������        ��Windows ����
	echo.
	echo.  [ 7] %C_FileHistory% �ļ���ʷ��¼
	echo.         �Զ����ݿ��а������ļ����޶��汾��
	echo.
	if "%SelectedSourceOS%" equ "w11" if "%ImageBuild%" geq "22621" if "%ImageBuild%" leq "22631" (
		echo.  [ 8] %C_LiveCaptions% ʵʱ��Ļ
		echo.         ʵʱ��Ļ����������չ��
		echo.         ������        ���������ߣ����ɷ��ʣ�
		echo.
	)
	echo.  [ 9] %C_Magnifier% �Ŵ�
	echo.         Microsoft �Ŵ���һ����ʾʵ�ó�����ͨ������һ�������Ĵ�������ʾ��Ļ
	echo.         �ķŴ󲿷֣��Ӷ�ʹ�������Ļ���߿ɶ��ԡ�
	echo.         ������        ���������ߣ����ɷ��ʣ�
	echo.
	echo.  [10] %C_ManualSetup% �ֶ���װ����Windows �͵�������
	echo.         �͵���������װ Windows 10/11������������ɾ���ͻ��˼�����ϵľɰ汾����
	echo.         ϵͳ���ù��̻��Զ�ά���������á���������ݡ�
	echo.         ������        ��Windows ����
	echo.
	echo.  [11] %C_Narrator% ������
	echo.         Windows ��������һ���ı�������ת��ʵ�ù��ߣ����ڶ�ȡ��Ļ����ʾ�����ݡ�
	echo.         ����ڵ����ݡ��˵�ѡ����Ѽ�����ı���
	echo.         ������        ���������ߣ����ɷ��ʣ�������ʶ��
	echo.
	if "%SelectedSourceOS%" equ "w10" echo.  [12] %C_Notepad% ���±�
	if "%SelectedSourceOS%" equ "w11" echo.  [12] %C_Notepad% �ɰ���±�
	echo.         Windows ���±��� Windows �ļ��ı��༭�������ɴ����ͱ༭���ı��ĵ���
	echo.
	echo.  [13] %C_OnScreenKeyboard% ��Ļ����
	echo.         ��Ļ�����ڼ������Ļ����ʾ������̣������û�ʹ��ָ���豸����ݸ˼���
	echo.         ���ݡ�
	echo.         ������        ���������ߣ����ɷ��ʣ�
	echo.
	if "%SelectedSourceOS%" equ "w10" (
		echo.  [14] %C_Paint% ��ͼ
		echo.         ��ͼ��һ���򵥵Ĺ�դͼ�κͱ༭���ߡ�
		echo.
	)
	if "%SelectedSourceOS%" equ "w11" if "%ImageFlag%" equ "EnterpriseS" (
		echo.  [14] %C_Paint% �ɰ滭ͼ
		echo.         ��ͼ��һ���򵥵Ĺ�դͼ�κͱ༭���ߡ�
		echo.
	)
	if "%SelectedSourceOS%" equ "w11" if "%ImageFlag%" equ "EnterpriseSN" (
		echo.  [14] %C_Paint% �ɰ滭ͼ
		echo.         ��ͼ��һ���򵥵Ĺ�դͼ�κͱ༭���ߡ�
		echo.
	)
	echo.  [15] %C_ProjFS% Projected File System��ProjFS��
	echo.         ����Ӧ�ó��򴴽������ļ�ϵͳ����Щ�ļ�ϵͳ�������뱾���ļ����޹أ���
	echo.         ���ǵ�ȫ�������ɳ���ʵʱ���ɡ�
	echo.
	echo.  [16] %C_SecurityCenter% ��ȫ����
	echo.         ��ȫ�����Ǽ��Ӽ������ȫ��ά��״̬�Ĺ��ߡ�
	echo.         ������        ��Windows Defender
	echo.         ������        ��Ӧ�ó������ / ����
	echo.
	echo.  [17] %C_StepsRecorder% �����¼��
	echo.         �����¼����һ�ֹ����ų��͸������ߣ����ڼ�¼�û��ڼ������ִ�еĲ�����
	echo.         һ����¼��������Щ��Ϣ�Ϳ�������˻�����Э�����й����ų����κ�������
	echo.         �ء�
	echo.
	echo.  [18] %C_StorageSpaces% �洢�ռ�
	echo.         �������ȡ��ͬ��С�ͽӿڵĶ�����̲������������һ���Ա����ϵͳ����
	echo.         ����Ϊһ������̡�
	echo.
	echo.  [19] %C_SystemRestore% ϵͳ��ԭ
	echo.         ��ѡ����Դ��ؽ����ʱ��㣬��Ϊϵͳ��ԭ�㡣
	echo.
	if "%SelectedSourceOS%" equ "w11" if "%ImageBuild%" geq "22621" if "%ImageBuild%" leq "22631" (
		echo.  [20] %C_VoiceAccess% ��������
		echo.         ����������չ��
		echo.         ������        ������ʶ��
		echo.
	)
	echo.  [21] %C_WindowsBackup% Windows ����
	echo.         �����Դ����ļ��л�ϵͳӳ�񱸷ݣ��Ա�����Ҫʱ���ڻָ���
	echo.
	echo.  [22] %C_WindowsFirewall% Windows ����ǽ
	echo.         Windows ����ǽ UI ���书�ܡ�
	echo.         ������        ��Ӧ�ó������ / �������Ƽ�
	echo.
	echo.  [23] %C_WindowsSubsystemForLinux% ������ Linux �� Windows ��ϵͳ��WSL��
	echo.         �ṩ������ Windows �����б����û�ģʽ Linux shell �͹��ߵķ���ͻ�����
	echo.
	echo.  [24] %C_WindowsToGo% Windows To Go
	echo.         �� USB �������洢�豸���� USB �������������ⲿӲ������������׼����Яʽ 
	echo.         Windows����������ȫ�ɹ������ҵ Windows ������
	echo.
	echo.  [25] %C_WindowsUpdate% Windows ����
	echo.         ʹ������ܹ��� Microsoft�� WSUS ��������ȡ Windows ���¡������������
	echo.         ���Լ���װ WUSA MSU ���³������
	echo.         ������        ��Windows ����
	echo.
	echo.  [26] %C_Wordpad% д�ְ�
	echo.         Microsoft д�ְ���һ�����ı��༭��������һЩ���������ִ����ܡ�
	echo.
	echo.  [A]    ����ϵͳ���
	echo.  [B]   �ص���һ��
	echo.  [N]   ��һ��
	echo.
	echo.===============================================================================
	echo.
	echo.  Tips���������㲻��Ҫ���������ţ�ʹǰ��� + ��� - 
	echo.        ������ǰΪ * �����������ܱ�����
	echo.
	set /p MenuChoice=���������ѡ��󰴻س���

	if /i "!MenuChoice!" neq "A" for %%# in (!MenuChoice!) do (
		if "%%#" equ "1" ( 
			if "%C_AccessibilityTools%" equ "+" (
				set "C_AccessibilityTools=-"
				set "C_EaseOfAccessCursors=-"
				set "C_EaseOfAccessThemes=-"
				if "%SelectedSourceOS%" equ "w11" if "%ImageBuild%" geq "22621" if "%ImageBuild%" leq "22631" set "C_LiveCaptions=-"
				set "C_Magnifier=-"
				set "C_Narrator=-"
				set "C_NarratorQuickStart=-"
				set "C_OnScreenKeyboard=-"
			) else (
				set "C_AccessibilityTools=+"
			)
		)
		if "%%#" equ "2" if "%ImageFlag%" equ "EnterpriseS" ( if "%C_Calculator%" equ "+" ( set "C_Calculator=-" ) else ( set "C_Calculator=+" ) )
		if "%%#" equ "2" if "%ImageFlag%" equ "EnterpriseSN" ( if "%C_Calculator%" equ "+" ( set "C_Calculator=-" ) else ( set "C_Calculator=+" ) )
		if "%%#" equ "3" ( if "%C_DeviceLockdown%" equ "+" ( set "C_DeviceLockdown=-" ) else ( set "C_DeviceLockdown=+" ) )
		if "%%#" equ "4" (
			if "%C_EaseOfAccessCursors%" equ "+" (
				set "C_EaseOfAccessCursors=-"
			) else (
				set "C_AccessibilityTools=+"
				set "C_EaseOfAccessCursors=+"
			)
		)
		if "%%#" equ "5" (
			if "%C_EaseOfAccessThemes%" equ "+" (
				set "C_EaseOfAccessThemes=-"
			) else (
				set "C_AccessibilityTools=+"
				set "C_EaseOfAccessThemes=+"
			)
		)
		if "%%#" equ "6" if "%C_EasyTransfer%" neq "*" ( if "%C_EasyTransfer%" equ "+" ( set "C_EasyTransfer=-" ) else ( set "C_EasyTransfer=+" ) )
		if "%%#" equ "7" ( if "%C_FileHistory%" equ "+" ( set "C_FileHistory=-" ) else ( set "C_FileHistory=+" ) )
		if "%%#" equ "8" if "%SelectedSourceOS%" equ "w11" if "%ImageBuild%" geq "22621" if "%ImageBuild%" leq "22631" (
			if "%C_LiveCaptions%" equ "+" (
				set "C_LiveCaptions=-"
			) else (
				set "C_AccessibilityTools=+"
				set "C_LiveCaptionss=+"
			)
		)
		if "%%#" equ "9" (
			if "%C_Magnifier%" equ "+" (
				set "C_Magnifier=-"
			) else (
				set "C_AccessibilityTools=+"
				set "C_Magnifier=+"
			)
		)
		if "%%#" equ "10" if "%C_ManualSetup%" neq "*" ( if "%C_ManualSetup%" equ "+" ( set "C_ManualSetup=-" ) else ( set "C_ManualSetup=+" ) )
		if "%%#" equ "11" (
			if "%C_Narrator%" equ "+" (
				set "C_Narrator=-"
				set "C_NarratorQuickStart=-"
			) else (
				set "C_AccessibilityTools=+"
				set "C_Narrator=+"
				set "C_SpeechRecognition=+"
			)
		)
		if "%%#" equ "12" ( if "%C_Notepad%" equ "+" ( set "C_Notepad=-" ) else ( set "C_Notepad=+" ) )
		if "%%#" equ "13" (
			if "%C_OnScreenKeyboard%" equ "+" (
				set "C_OnScreenKeyboard=-"
			) else (
				set "C_AccessibilityTools=+"
				set "C_OnScreenKeyboard=+"
			)
		)
		if "%%#" equ "14" if "%SelectedSourceOS%" equ "w10" ( if "%C_Paint%" equ "+" ( set "C_Paint=-" ) else ( set "C_Paint=+" ) )
		if "%%#" equ "14" if "%SelectedSourceOS%" equ "w11" if "%ImageFlag%" equ "EnterpriseS" ( if "%C_Paint%" equ "+" ( set "C_Paint=-" ) else ( set "C_Paint=+" ) )
		if "%%#" equ "14" if "%SelectedSourceOS%" equ "w11" if "%ImageFlag%" equ "EnterpriseSN" ( if "%C_Paint%" equ "+" ( set "C_Paint=-" ) else ( set "C_Paint=+" ) )
		if "%%#" equ "15" ( if "%C_ProjFS%" equ "+" ( set "C_ProjFS=-" ) else ( set "C_ProjFS=+" ) )
		if "%%#" equ "16" if "%C_SecurityCenter%" neq "*" (
			if "%C_SecurityCenter%" equ "+" ( 
				set "C_SecurityCenter=-"
			) else ( 
				set "C_SecurityCenter=+"
				if "%ImageBuild%" geq "22000" if "%ImageBuild%" leq "22631" (
					if "%C_UIXaml24%" neq "*" set "C_UIXaml24=+"
					if "%C_VCLibs140UWP%" neq "*" set "C_VCLibs140UWP=+"
				)
				set "C_WindowsDefender=+"
			)
		)
		if "%%#" equ "17" ( if "%C_StepsRecorder%" equ "+" ( set "C_StepsRecorder=-" ) else ( set "C_StepsRecorder=+" ) )
		if "%%#" equ "18" ( if "%C_StorageSpaces%" equ "+" ( set "C_StorageSpaces=-" ) else ( set "C_StorageSpaces=+" ) )
		if "%%#" equ "19" ( if "%C_SystemRestore%" equ "+" ( set "C_SystemRestore=-" ) else ( set "C_SystemRestore=+" ) )
		if "%%#" equ "20" if "%SelectedSourceOS%" equ "w11" if "%ImageBuild%" geq "22621" if "%ImageBuild%" leq "22631" (
			if "%C_VoiceAccess%" equ "+" ( 
				set "C_VoiceAccess=-"
			) else ( 
				set "C_SpeechRecognition=+"
				set "C_VoiceAccess=+"
			)
		)
		if "%%#" equ "21" ( if "%C_WindowsBackup%" equ "+" ( set "C_WindowsBackup=-" ) else ( set "C_WindowsBackup=+" ) )
		if "%%#" equ "22" if "%C_WindowsFirewall%" neq "*" ( if "%C_WindowsFirewall%" equ "+" ( set "C_WindowsFirewall=-" ) else ( set "C_WindowsFirewall=+" ) )
		if "%%#" equ "23" ( if "%C_WindowsSubsystemForLinux%" equ "+" ( set "C_WindowsSubsystemForLinux=-" ) else ( set "C_WindowsSubsystemForLinux=+" ) )
		if "%%#" equ "24" ( if "%C_WindowsToGo%" equ "+" ( set "C_WindowsToGo=-" ) else ( set "C_WindowsToGo=+" ) )
		if "%%#" equ "25" if "%C_WindowsUpdate%" neq "*" ( if "%C_WindowsUpdate%" equ "+" ( set "C_WindowsUpdate=-" ) else ( set "C_WindowsUpdate=+" ) )
		if "%%#" equ "26" ( if "%C_Wordpad%" equ "+" ( set "C_Wordpad=-" ) else ( set "C_Wordpad=+" ) )
		if /i "%%#" equ "B" goto :RemoveRemotingMenu
		if /i "%%#" equ "N" goto :RemoveSystemAppsMenu
	)

	if /i "!MenuChoice!" equ "A" (
		set "C_AccessibilityTools=-"
		if "%ImageFlag%" equ "EnterpriseS" set "C_Calculator=-"
		if "%ImageFlag%" equ "EnterpriseSN" set "C_Calculator=-"
		set "C_DeviceLockdown=-"
		set "C_EaseOfAccessCursors=-"
		set "C_EaseOfAccessThemes=-"
		if "%C_EasyTransfer%" neq "*" set "C_EasyTransfer=-"
		set "C_FileHistory=-"
		if "%SelectedSourceOS%" equ "w11" if "%ImageBuild%" geq "22621" if "%ImageBuild%" leq "22631" set "C_LiveCaptions=-"
		set "C_Magnifier=-"
		if "%C_ManualSetup%" neq "*" set "C_ManualSetup=-"
		set "C_Narrator=-"
		set "C_NarratorQuickStart=-"
		set "C_Notepad=-"
		set "C_OnScreenKeyboard=-"
		if "%SelectedSourceOS%" equ "w10" set "C_Paint=-"
		if "%SelectedSourceOS%" equ "w11" if "%ImageFlag%" equ "EnterpriseS" set "C_Paint=-"
		if "%SelectedSourceOS%" equ "w11" if "%ImageFlag%" equ "EnterpriseSN" set "C_Paint=-"
		set "C_ProjFS=-"
		if "%C_SecurityCenter%" neq "*" set "C_SecurityCenter=-"
		set "C_StepsRecorder=-"
		set "C_StorageSpaces=-"
		set "C_SystemRestore=-"
		if "%ImageBuild%" geq "22000" if "%ImageBuild%" leq "22631" (
			if "%C_UIXaml24%" neq "*" set "C_UIXaml24=+"
			if "%C_VCLibs140UWP%" neq "*" set "C_VCLibs140UWP=+"
		)
		if "%SelectedSourceOS%" equ "w11" if "%ImageBuild%" geq "22621" if "%ImageBuild%" leq "22631" set "C_VoiceAccess=-"
		set "C_WindowsBackup=-"
		if "%C_WindowsFirewall%" neq "*" set "C_WindowsFirewall=-"
		set "C_WindowsSubsystemForLinux=-"
		set "C_WindowsToGo=-"
		if "%C_WindowsUpdate%" neq "*" set "C_WindowsUpdate=-"
		set "C_Wordpad=-"
	)

	goto :RemoveSystemMenu
)

:RemoveSystemAppsMenu
:: �Ƴ� Windows 10 v1809/v1903/v1909/v2004/v20H2/v21H1/v21H2/v22H2��Windows 11 v21H2/v22H2 �ͻ��˰汾ϵͳӦ�ò˵�
if "%SelectedSourceOS%" neq "w7" if "%SelectedSourceOS%" neq "w81" if "%ImageBuild%" geq "17763" if "%ImageBuild%" leq "22631" (
	cls
	echo.===============================================================================
	echo.                                  ϵͳӦ��
	echo.===============================================================================
	echo.
	echo.  [ 1] %C_AddSuggestedFoldersToLibraryDialog% ������ļ��н��顱�Ի���Microsoft.Windows.AddSuggestedFoldersToLibraryDialog��
	echo.         ������ļ��н��顱�Ի�����һ��ϵͳӦ�ã�������ʾһ���Ի�����ʾ�㽫��
	echo.         ����ļ�����ӵ����У��Ա�Ӧ�ÿ��Կ������ǡ�
	echo.
	echo.  [ 2] %C_AppResolverUX% App Resolver��Microsoft.Windows.AppResolverUX��
	echo.         App Resolver �����ڽ���Ӧ�ÿ�ݷ�ʽ��ϵͳӦ�á���Ӧ�ø����ڵ�����ݷ�
	echo.         ʽͼ��ʱ����Ҫ��������ȷӦ�á�
	echo.
	if "%ImageFlag%" neq "Core" if "%ImageFlag%" neq "CoreN" if "%ImageFlag%" neq "CoreSingleLanguage" (
		echo.  [ 3] %C_AssignedAccessLockApp% ��ָ������������Ӧ�ã�Microsoft.Windows.AssignedAccessLockApp��
		echo.         ָ����������Ӧ�������ڽ� Windows �豸����������Ӧ���е�ϵͳӦ�ã���Ӧ
		echo.         ���ڷ���ķ���Ȩ���û���¼ʱ��������Ӧ�����ڴ����͹������ķ���Ȩ�޻�
		echo.         �����������������豸���Ա�ֻ�����е���Ӧ�á�
		echo.         ������        ������ķ���Ȩ��
		echo.
	)
	echo.  [ 4] %C_AsyncTextService% Asynchronous Text ����Microsoft.AsyncTextService��
	echo.         Asynchronous Text ������һ��ϵͳӦ�ã����ṩ����Ӧ�ã�����ϵ�ˣ�֮���
	echo.         �໥ͨ�Ż�Ϊ������ֽ�ṩ��չ��
	echo.
	if "%ImageBuild%" geq "18362" if "%ImageBuild%" leq "22631" (
		echo.  [ 5] %C_CallingShellApp% Call��Microsoft.Windows.CallingShellApp��
		echo.         Call Progress Ӧ����һ��ϵͳӦ�ã���Ϊ����ͽ����绰�ṩ���µ����顣
		echo.         Calling Shell Ӧ���Ǿɵ绰Ӧ�õ����Ʒ������ Wi-Fi ���С�VoIP ������
		echo.         ���� Microsoft Teams ���ɵȹ��ܡ�
		echo.
	)
	echo.  [ 6] %C_OOBENetworkCaptivePortal% Captive Portal Flow��Microsoft.Windows.OOBENetworkCaptivePortal��
	echo.         Captive Portal Flow ��һ��ϵͳӦ�ã������� Windows ��װ����Ŀ��伴
	echo.         �����飨OOBE���׶δ��� Captive Portal �����֤��Captive Portal ��ĳ
	echo.         Щ Wi-Fi ������ʾ����ҳ��Ҫ���û����ܷ������������ƾ�ݣ�Ȼ����ܷ�
	echo.         �� internet��
	echo.         ������        ��ȫ�°�װ���飨OOBE��
	echo.
	echo.  [ 7] %C_CapturePicker% Capture Picker��Microsoft.Windows.CapturePicker��
	echo.         ����ѡ������һ��ϵͳӦ�ã�������ѡ����Ļ�ϵ���Ŀ�Բ����豸�ϵ���Ļ��
	echo.         ͼ����Ļ¼��
	echo.
	if "%ImageBuild%" geq "17763" if "%ImageBuild%" leq "18363" if "%ImageFlag%" neq "EnterpriseS" if "%ImageFlag%" neq "EnterpriseSN" (
		echo.  [ 8] %C_PPIProjection% ���ӣ�Microsoft.PPIProjection��
		echo.         ������һ��ϵͳӦ�ã������㽫 Windows 10 �豸����ͶӰ����һ̨�豸����
		echo.         ����ӻ�ͶӰ�ǡ������������á����á�Ӧ�ó����еġ���Ŀ���˵���
		echo.
	)
	echo.  [ 9] %C_ContentDeliveryManager% Content Delivery Manager��Microsoft.Windows.ContentDeliveryManager��
	echo.         Content Delivery Manager ��һ��ϵͳӦ�ã����ڽ����ݣ����ֽ�����⡢Ӧ
	echo.         �ú�����Ӧ�ã����������飩�����͵� Windows �豸����Ӧ�ø������غͰ�װ
	echo.         ���ݣ���ʹ�䱣������״̬��ɾ�������������ƹ��Ӧ�ã��� Candy Crush��
	echo.         Facebook �ȣ������������ֻ����á�
	echo.
	if "%ImageBuild%" geq "17763" if "%ImageBuild%" leq "18363" (
		echo.  [10] %C_Cortana% Cortana��Microsoft.Windows.Cortana��
		echo.         Cortana �� Windows 10 �豸�ϵĸ������������� Cortana UI������������ 
		echo.         Cortana ����ʱ�������û����档�������� Cortana ��ˣ�����Ϊ Cortana 
		echo.         �����ṩ֧�ֵ������Windows 10����ʼ���˵��ϵ����� UI������������������
		echo.         ������Ҫ Cortana��
		echo.         ������        ��Shell Search
		echo.
	)
	echo.  [11] %C_CredDialogHost% Credential Dialog ������Microsoft.CredDialogHost��
	echo.         ƾ�ݶԻ�����ϵͳӦ�ã���Ϊ Windows Hello �ṩ�����֤����¼�����֧�֡�
	echo.
	echo.  [12] %C_Win32WebViewHost% ����Ӧ�� Web �鿴����Microsoft.Win32WebViewHost��
	echo.         ����Ӧ�� Web �鿴����ϵͳӦ�ã������� Windows �豸���й� Web ���ݡ���
	echo.         Ӧ���������ڸ���Ӧ���в鿴��ҳ�������ļ���Դ������������Ӧ�ú͡���ʼ���˵���
	echo.
	echo.  [13] %C_AccountsControl% �����ʼ����ʻ���Microsoft.AccountsControl��
	echo.         �����ʼ����ʻ���ϵͳӦ�ã�������ӡ������ɾ�����ڵ�¼ Microsoft Ӧ�õ� 
	echo.         Microsoft �ʻ���
	echo.         ������        ��Microsoft Store
	echo.
	echo.  [14] %C_ECApp% Ŀ�ӿ��ƣ�Microsoft.ECApp��
	echo.         Ŀ�ӿ�����һ��ϵͳӦ�ã����ڹ��� Windows �豸�е�Ŀ�ӿ����豸���á�
	echo.         ������        ��Windows �����ʵ
	echo.
	echo.  [15] %C_FileExplorer% �ɰ� �ļ���Դ��������Microsoft.Windows.FileExplorer��
	echo.         �ļ���Դ��������ϵͳӦ�ã�����һ���ִ��ļ�����Ӧ�ã�������鿴����
	echo.         ֯�ͷ��ʼ�����ϵ��ļ���
	echo.
	echo.  [16] %C_FilePicker% �ļ�ѡȡ����Microsoft.Windows.FilePicker��
	echo.         �ļ�ѡȡ����ϵͳӦ�ã�����һ����һ��ͳһ���棬�����û����ļ�ϵͳ��
	echo.         ����Ӧ����ѡ���ļ����ļ��С�ʹ���ļ�ѡȡ�������Ӧ�ÿ��Է��ʡ����
	echo.         �ͱ����û�ϵͳ�ϵ��ļ����ļ��С�
	echo.
	echo.  [17] %C_MapControl% ��ͼ�ؼ�
	echo.         ��ͼ�ؼ��ǵ�ͼӦ����������ĺ��ķ���
	echo.
	echo.  [18] %C_Edge% �ɰ� Microsoft Edge��Microsoft.MicrosoftEdge��
	echo.         Microsoft Edge �� Windows �豸�д��ڵ�Ĭ�� Web �������
	echo.
	echo.  [19] %C_EdgeDevToolsClient% Microsoft Edge DevTools��Microsoft.MicrosoftEdgeDevToolsClient��
	echo.         Microsoft Edge DevTools�� Edge ���������չ���������� Web �����ߵ� Dev ���ߡ�
	echo.         ������        ���ɰ� Microsoft Edge
	echo.
	echo.  [20] %C_ParentalControls% Microsoft ��ͥ���ܣ�Microsoft.Windows.ParentalControls��
	echo.         Microsoft ��ͥ������ϵͳӦ�ã����ڹ��� Windows �豸�ϵļҳ����ơ���
	echo.         ���������ƶ���վ��Ӧ�ú���Ϸ�ķ��ʣ��Լ�������Ļʱ�����ơ�
	echo.
	echo.  [21] %C_NarratorQuickStart% �����ˣ�Microsoft.Windows.NarratorQuickStart��
	echo.         ��������ҳ��һ���ִ�������Ӧ�ã��ɴ����ʶ���Ļ�ϵ��ı���ʹä�˻�����
	echo.         ���µ��˸�����ʹ�����ǵļ������
	echo.         ������        ��������
	echo.
	echo.  [22] %C_OOBENetworkConnectionFlow% Network Connection Flow��Microsoft.Windows.OOBENetworkConnectionFlow��
	echo.         Network Connection Flow ��ϵͳӦ�ã��ɰ����û��� Windows ��װ�����
	echo.         ȫ�����飨OOBE���׶����ӵ����硣
	echo.         ������        ��ȫ�°�װ���飨OOBE��
	echo.
	if "%ImageBuild%" geq "19041" if "%ImageBuild%" leq "22631" (
		echo.  [23] %C_NcsiUwpApp% ��������״ָ̬ʾ����NCSI����NcsiUwpApp��
		echo.         ��������״ָ̬ʾ����NCSI����һ��ϵͳӦ�ã���������������ӵ�״̬����
		echo.         ����������ʾ����ͼ�ꡣ������ִ�ж��ڼ������֤������������Ƿ�������
		echo.         ����
		echo.
	)
	echo.  [24] %C_CloudExperienceHost% ȫ�°�װ���飨OOBE����Microsoft.Windows.CloudExperienceHost��
	echo.         ȫ�����飨OOBE����һ��ϵͳӦ�ã����ڿ��� Windows ��װ��������׶Σ�
	echo.         ��ʾ�û�ѡ��Ͱ�װ������ɡ�������Ϊ Microsoft �ʻ���¼�����ṩ�û���
	echo.         �棬�Լ����� Windows �Ļ����ƵĹ��ܡ�
	echo.         ��Ҳ�� sysprep ͨ�û�֮����á�
	if "%ImageBuild%" geq "17763" if "%ImageBuild%" leq "18363" (
		echo.         Windows 10 �������ϵ����� UI ����������������Ҫ��
		echo.         ������        ��Microsoft Store��ȫ�°�װ���飨OOBE�����Ƽ���Shell Search
	)
	if "%ImageBuild%" geq "19041" if "%ImageBuild%" leq "22631" echo.         ������        ��Microsoft Store��ȫ�°�װ���飨OOBE�����Ƽ�
	echo.         ����          ������ʹ����ȫ���˲�����������ڰ�װ������δ���ӵ� 
	echo.                         Internet ʱ�������� SkipMACHINE ����ֵ��ѡ���ɾ����
	echo.
	echo.  [25] %C_PinningConfirmationDialog% �̶�ȷ�϶Ի���Microsoft.Windows.PinningConfirmationDialog��
	echo.         �̶�ȷ�϶Ի�����ϵͳӦ�ã������ڳ��Խ�Ӧ�ù̶�������ʼ����Ļ��������ʱ��
	echo.         ʾȷ�϶Ի��򡣴˶Ի���Ҫ����ȷ���Ƿ�Ҫ�̶�Ӧ�ã���������ѡ��̶�Ӧ�õ�
	echo.         λ�á�
	echo.
	if "%ImageBuild%" geq "17763" if "%ImageBuild%" leq "22000" (
		echo.  [26] %C_QuickAssist% ��������
		echo.         ����������һ�����õ��ִ�Զ��Э�����ߣ��������������˹�����Ļ���Ա�����
		echo.         ��������������ṩ����֧�֡�
		echo.
	)
	echo.  [27] %C_RetailDemoContent% ������ʾ����
	echo.         ������ʾ������ Windows �豸�а�����һ���ļ������ڴ���������ʾ���顣
	echo.         �����������̵�������չʾ Windows �豸�������ݰ�����������Ǳ�ڿͻ�
	echo.         չʾ Windows �豸���ܵ���Ƶ��ͼ���Ӧ�õ����ݡ�
	echo.
	echo.
	echo.  [28] %C_XGpuEjectDialog% ��ȫ�Ƴ�Ӳ����Microsoft.Windows.XGpuEjectDialog��
	echo.         ��ȫɾ���豸��ϵͳӦ�ã���������Ҫ�Ӽ���������ⲿͼ�ο���eGPU��ʱ��ʾ��
	echo.         ����
	echo.
	echo.  [29] %C_SettingSync% ����ͬ��
	echo.         ����ͬ����һ��ܣ��������ڶ���豸֮��ͬ�����á�����ζ�ţ������������
	echo.         һ̨�豸�ϸ��������ã�����Ľ���ӳ�ڵ�¼��ͬһ Microsoft �ʻ�������������
	echo.         ���ϡ�
	echo.
	echo.  [30] %C_ShellExperienceHost% Shell ����������ShellExperienceHost��
	echo.         Windows Shell ������ Windows ϵͳ���̣������� Windows Shell��Windows ��
	echo.         Դ�����������ṩͨ��Ӧ�ü��ɣ����������������������ڴ��ڽ����г���ͨ��
	echo.         Ӧ�ã���Ϊ Windows 10/11 �ṩ�����е� GUI ���ܣ����硰��ʼ����ť�͡���ʼ��
	echo.         �˵������������Լ�ʱ�ӡ��������Ӻ͵��ͼ���Լ�����������Ԫ�صĸ�����
	echo.         ����
	if "%ImageBuild%" equ "17763" (
		echo.         Windows 10 �������ϵ����� UI ����������������Ҫ��
		echo.         ������        ���Ƽ���Shell Search
	)
	if "%ImageBuild%" equ "22000" echo.         ������        ��Microsoft Visual C++ 2015 UWP Runtime
	if "%ImageBuild%" geq "18362" if "%ImageBuild%" leq "22631" echo.         ������        ���Ƽ�
	if "%ImageBuild%" equ "17763" (
		echo.         ����          ������ʹ����������ʼ���˵������� Open Shell��Start 10/11��
		echo.                         StartIsBackAll��ʱɾ����
	)
	echo.
	if "%ImageBuild%" geq "17763" if "%ImageBuild%" leq "18363" (
		echo.  [31] %C_InputApp% �������Ӧ�ó���InputApp��
		echo.         ����Ӧ����ϵͳӦ�ã�����Ϊ�����û������ı����봦������TIP�����������ṩ
		echo.         ֧�֡���Ӧ�ó��򣨱ʺ�ī���������ȣ������ø߼��û��������
		echo.         ������        ��Microsoft Office���Ƽ����������豸
		echo.
	)
	if "%ImageBuild%" geq "19041" if "%ImageBuild%" leq "22631" (
		echo.  [32] %C_UndockedDevKit% Shell Services ^(MicrosoftWindows.UndockedDevKit^)
		echo.         Undocked Dev Kit��Shell Services����ϵͳӦ�ã����ڿ����Ͳ���ּ���ڿɲ�ж��
		echo.         ������ƽ����ԺͱʼǱ����ԣ������е� Windows Ӧ�á����� -^> ϵͳ -^> ϵͳ
		echo.         ��Ϣ������Ҫ����Windows 10/11 ��Դ���������������������ϵ����� UI ��Ҫ��
		echo.         ������        ��ȫ�°�װ���飨OOBE�����Ƽ���Shell Search
		echo.
	)
	echo.  [33] %C_SkypeORTC% Skype ORTC
	echo.         Skype ORTC ��һ�� API����������Ա����Ӧ�ó������ʵʱͨ�Ź��ܡ������ڿ���
	echo.         ʵʱͨ�ţ�ORTC����׼���˱�׼��ʵʱͨ�ŵ����˰��Դ�淶��
	echo.
	echo.
	echo.  [34] %C_SmartScreen% SmartScreen��Microsoft.Windows.AppRep.ChxApp��
	echo.         Windows Defender SmartScreen �ṩ�������Ͷ������ɸѡ����ּ��ͨ����԰���
	echo.         ��֪��в����վ������ɨ���û����ʵ� URL ��������ֹ������
	echo.
	if "%ImageBuild%" geq "18362" if "%ImageBuild%" leq "22631" (
		echo.  [35] %C_StartMenuExperienceHost% ����ʼ���˵���Microsoft.Windows.StartMenuExperienceHost��
		echo.         ����ʼ���˵�����������һ��ϵͳӦ�ã����������ʼ���˵���������̬����������
		echo.         ���͵�Դ��ť��
		if "%ImageBuild%" geq "18362" if "%ImageBuild%" leq "22000" echo.         ������        ��Shell Experience Host
		if "%ImageBuild%" equ "22000" echo.         Depends on    : Microsoft Visual C++ 2015 UWP Runtime
		echo.         ������        ���Ƽ�, Shell Search
		echo.         ����          ������ʹ��������ʼ�˵������� Open Shell��Start 10/11 �� 
		echo.                         StartIsBackAll��ʱ���Ƴ���
		echo.
	)
	if "%ImageFlag%" neq "EnterpriseS" if "%ImageFlag%" neq "EnterpriseSN" (
		echo.  [36] %C_SecureAssessmentBrowser% �μӲ��ԣ�Microsoft.Windows.SecureAssessmentBrowser��
		echo.         �μӲ�����һ������ Web ��Ӧ�ã������û��Ը�������������������簲ȫ��ʶ��
		echo.         �Ϲ��Ժ� IT �����̶ȡ�
		echo.
	)
	echo.  [37] %C_WebcamExperience% Webcam ����
	echo.         Webcam ������ý�幦�ܰ���һ���������Ϊ Windows �豸�ϵ�����������ṩ
	echo.         �û����顣���������Ӧ�ã�������������Ƭ����Ƶ���Լ�������ã��������
	echo.         ����������ͷ�����á�
	echo.
	if "%ImageBuild%" geq "19041" if "%ImageBuild%" leq "22631" (
		echo.  [38] %C_WebView2Runtime% WebView2 Runtime
		echo.         WebView2 Runtime ��һ�����ٷ��е�����ʱ������ WebView2 Ӧ�õĻ�������
		echo.         ֧�֣�Web ƽ̨������ Microsoft Edge Chromium web ������ľ���汾����
		echo.         �����ܺͰ�ȫ�Խ������Ż���WebView2 ����ʱ�ɸ���Ӧ��ʹ�ã����� Microsoft 
		echo.         Office��Microsoft Power BI �� Visual Studio������������Ա�� Web ���ݣ��� 
		echo.         HTML��CSS �� JavaScript��Ƕ�뵽�䱾��Ӧ���С���ʹ�ô������б���Ӧ�����
		echo.         �Ļ��Ӧ�ó�Ϊ���ܣ���Ҳ���Է��� Web��
		echo.         ������        ���Ƽ�
		echo.
	)
	echo.  [39] %C_CBSPreview% Windows Barcode Preview��Windows.CBSPreview��
	echo.         Windows Barcode Preview Ӧ����һ������Ӧ�ã�������Ԥ��ʹ���豸���ɨ��
	echo.         �������롣
	echo.
	echo.  [40] %C_LockApp% Windows Ĭ��������Microsoft.LockApp��
	echo.         Windows Ĭ�������������״δ򿪼���������˯��״̬����ʱ��������Ļ��
	echo.         ���������ʱҲ������ʾ����
	echo.
	if "%ImageBuild%" geq "17763" if "%ImageBuild%" leq "19045" echo.  [43] %C_WindowsDefender% Windows Defender��Microsoft.Windows.SecHealthUI��
	if "%ImageBuild%" geq "22000" if "%ImageBuild%" leq "22631" echo.  [43] %C_WindowsDefender% Windows Defender��Microsoft.SecHealthUI��
	echo.         Windows Defender ��һ�����õķ���������ּ�ڱ�����ļ�������ܶ�����
	echo.         ����������������������������������ֺ����������� Windows ��ȫ����Ӧ
	echo.         �ã�����һ�������ṩ��ȫ����״���Ǳ���ϵͳӦ�á���ȫ����״���Ǳ��
	echo.         ��һ������λ�ã������������в鿴������İ�ȫ״̬�������йط����������
	echo.         Windows Defender ��������ȫ���õ���Ϣ��
	if "%ImageBuild%" geq "22000" if "%ImageBuild%" leq "22631" echo.         ������        ��Microsoft UI Xaml 2.4��Microsoft Visual C++ 2015 UWP Runtime
	echo.
	if "%ImageBuild%" geq "19041" if "%ImageBuild%" leq "22631" (
		if "%ImageBuild%" geq "19041" if "%ImageBuild%" leq "22000" echo.  [42] %C_ClientCBS% Windows �û����飨MicrosoftWindows.Client.CBS��
		if "%ImageBuild%" geq "22621" if "%ImageBuild%" leq "22631" echo.  [42] %C_ClientCBS% Windows �����û����飨MicrosoftWindows.Client.CBS��
		echo.         Windows �û�������һ��ϵͳ���̣�������� Windows Ӧ�ú͹��ܵİ�װ�ͷ���
		echo.         ����������Ӧ�ó�����Ļ�������� Windows 11 Ϊ���ĵĿ�ʼ�˵����ܡ�
		if "%ImageBuild%" equ "22000" echo.         ������        ��Microsoft Visual C++ 2015 UWP Runtime
		echo.         ������        ��Shell Search
		echo.
	)
	echo.  [43] %C_BioEnrollment% Windows Hello ��װ����Microsoft.BioEnrollment��
	echo.         Windows Hello ��װ������һ��ϵͳӦ�ã�����ע��͹�������ʶ�����ݣ���ָ
	echo.         �ƺ��沿ɨ�裩���Ա��� Windows Hello ���ʹ�á���Ӧ�ø��𴴽��ʹ洢ָ��
	echo.         ���沿ʶ��ģ�壬�Լ������¼��������豸ʱ������������֤��
	echo.
	echo.         ������        ������ʶ��
	echo.
	echo.  [44] %C_WindowsMixedReality% Windows �����ʵ��WMR��
	echo.         Windows �����ʵ ��WMR�� ��һ��ƽ̨��ͨ�����ݵ�ͷ��ʽ��ʾ���ṩ��ǿ��ʵ
	echo.         ��������ʵ���顣����������ʵ��VR������ǿ��ʵ��AR���Ľ�ϣ����� Microsoft 
	echo.         HoloLens һ����
	echo.
	echo.  [45] %C_PrintDialog% Windows ��ӡ��Windows.PrintDialog��
	echo.         ����ӡ���Ի�����һ��Ԥ���õĶԻ��������û�ѡ���ӡ����ѡ��Ҫ��ӡ��ҳ����
	echo.         ��ȷ���������ӡ��ص����á����Ǵ�ӡ���ʹ�ӡ������õļ򵥽������������
	echo.         ���������Լ��ĶԻ���
	echo.         ������        ����ӡ
	echo.
	echo.  [46] %C_WindowsReaderPDF% Windows �Ķ�����PDF��
	echo.         Windows PDF �Ķ�����һ������ Microsoft Edge �ļ����õ� PDF �ļ��鿴����
	echo.         ������        ��Microsoft Edge
	echo.
	if "%ImageBuild%" geq "19041" if "%ImageBuild%" leq "22000" (
		echo.  [47] %C_SearchApp% Windows Search��Microsoft.Windows.Search��
		echo.         ������ϵͳӦ�ã�����Ϊ Windows �豸�е����������ṩ֧�֡�������������
		echo.         ���ļ����ļ��к�Ӧ�ã��Ա�����Կ����ҵ���������ݡ�Windows 10/11 ��
		echo.         Դ�����������������������������ϵ����� UI ��Ҫ��
		if "%ImageBuild%" equ "22000" echo.         Depends on    : Microsoft Visual C++ 2015 UWP Runtime
		echo.         ������        ���Ƽ�, Shell Search
		echo.
	)
	echo.  [48] %C_PeopleExperienceHost% Windows Shell Experience��Microsoft.Windows.PeopleExperienceHost��
	echo.         Windows �����й���������������ڹ���������Ӧ�õ�ϵͳӦ�á�����Ϊ 
	echo.         Windows �е��������ܣ��硰��ʼ���˵��еġ����������͡�������������ṩ�ײ����
	echo.         �ṹ��
	echo.
	echo.  [49] %C_AADBrokerPlugin% ������ѧУ�ʻ���Microsoft.AAD.BrokerPlugin��
	echo.         ������ѧУ�ʻ���һ�� Windows ϵͳӦ�ã��� Azure Active Directory��AAD��
	echo.         WAM �����һ���֡�AAD WAM ������������� AAD ��Ӧ�ó���������֤����
	echo.         ������������� AAD ��Ӧ�ó���ʱ��AAD WAM ������� Azure Active Directory 
	echo.         ͨ�ţ�����֤ƾ�ݲ���ȡ�������ơ����� Windows Ӧ���̵��¼��/��Ӧ�ð�װ��
	echo.         ����ģ������¼���ɰ�װ���Ӧ�ã�������ȡ���� Azure Active Directory
	echo.         ������        ��Microsoft Store
	echo.
	echo.  [50] %C_XboxGameCallableUI% Xbox Game Callable �û����棨Microsoft.XboxGameCallableUI��
	echo.         Xbox Game Callable �û�������һ��ϵͳӦ�ã�����Ϊ Xbox ��Ϸ�ṩͨ�� UI��
	echo.         �Ա��� Windows �ϵ�����Ӧ�úͷ�����н��������� Xbox Play Anywhere �ƻ�
	echo.         �ĺ���������˳��������� Windows �� Xbox ����̨������ Xbox ��Ϸ��
	echo.
	echo.  [A]    ���ж�ý�����
	echo.  [B]    �ص���һ��
	echo.  [N]    ѡ����ϣ���ʼ����
	echo.
	echo.===============================================================================
	echo.
	echo.  Tips���������㲻��Ҫ���������ţ�ʹǰ��� + ��� - 
	echo.        ������ǰΪ * �����������ܱ�����
	echo.
	set /p MenuChoice=���������ѡ�� ��

	if /i "!MenuChoice!" neq "A" for %%# in (!MenuChoice!) do (
		if "%%#" equ "1" ( if "%C_AddSuggestedFoldersToLibraryDialog%" equ "+" ( set "C_AddSuggestedFoldersToLibraryDialog=-" ) else ( set "C_AddSuggestedFoldersToLibraryDialog=+" ) )
		if "%%#" equ "2" ( if "%C_AppResolverUX%" equ "+" ( set "C_AppResolverUX=-" ) else ( set "C_AppResolverUX=+" ) )
		if "%%#" equ "3" if "%ImageFlag%" neq "Core" if "%ImageFlag%" neq "CoreN" if "%ImageFlag%" neq "CoreSingleLanguage" (
			if "%C_AssignedAccessLockApp%" equ "+" ( 
				set "C_AssignedAccessLockApp=-"
			) else ( 
				set "C_AssignedAccess=+"
				set "C_AssignedAccessLockApp=+"
			)
		)
		if "%%#" equ "4" ( if "%C_AsyncTextService%" equ "+" ( set "C_AsyncTextService=-" ) else ( set "C_AsyncTextService=+" ) )
		if "%%#" equ "5" if "%ImageBuild%" geq "18362" if "%ImageBuild%" leq "22631" ( if "%C_CallingShellApp%" equ "+" ( set "C_CallingShellApp=-" ) else ( set "C_CallingShellApp=+" ) )
		if "%%#" equ "6" (
			if "%C_OOBENetworkCaptivePortal%" equ "+" ( 
				set "C_OOBENetworkCaptivePortal=-"
			) else ( 
				if "%C_CloudExperienceHost%" neq "*" set "C_CloudExperienceHost=+"
				set "C_OOBENetworkCaptivePortal=+"
			)
		)
		if "%%#" equ "7" (
			if "%C_CapturePicker%" equ "+" (
				set "C_CapturePicker=-"
				set "C_ScreenSketch=-"
			) else (
				set "C_CapturePicker=+"
			)
		)
		if "%%#" equ "8" if "%ImageBuild%" geq "17763" if "%ImageBuild%" leq "18363" if "%ImageFlag%" neq "EnterpriseS" if "%ImageFlag%" neq "EnterpriseSN" ( if "%C_PPIProjection%" equ "+" ( set "C_PPIProjection=-" ) else ( set "C_PPIProjection=+" ) )
		if "%%#" equ "9" ( if "%C_ContentDeliveryManager%" equ "+" ( set "C_ContentDeliveryManager=-" ) else ( set "C_ContentDeliveryManager=+" ) )
		if "%%#" equ "10" if "%ImageBuild%" geq "17763" if "%ImageBuild%" leq "18363" if "%C_Cortana%" neq "*" ( if "%C_Cortana%" equ "+" ( set "C_Cortana=-" ) else ( set "C_Cortana=+" ) )
		if "%%#" equ "11" ( if "%C_CredDialogHost%" equ "+" ( set "C_CredDialogHost=-" ) else ( set "C_CredDialogHost=+" ) )
		if "%%#" equ "12" ( if "%C_Win32WebViewHost%" equ "+" ( set "C_Win32WebViewHost=-" ) else ( set "C_Win32WebViewHost=+" ) )
		if "%%#" equ "13" if "%C_AccountsControl%" neq "*" ( if "%C_AccountsControl%" equ "+" ( set "C_AccountsControl=-" ) else ( set "C_AccountsControl=+" ) )
		if "%%#" equ "14" ( 
			if "%C_ECApp%" equ "+" ( 
				set "C_ECApp=-" 
			) else ( 
				set "C_ECApp=+" 
				set "C_WindowsMixedReality=+"
			) 
		)
		if "%%#" equ "15" ( if "%C_FileExplorer%" equ "+" ( set "C_FileExplorer=-" ) else ( set "C_FileExplorer=+" ) )
		if "%%#" equ "16" ( if "%C_FilePicker%" equ "+" ( set "C_FilePicker=-" ) else ( set "C_FilePicker=+" ) )
		if "%%#" equ "17" (
			if "%C_MapControl%" equ "+" ( 
				set "C_MapControl=-"
				set "C_Maps=-"
			) else (
				set "C_MapControl=+"
			)
		)
		if "%%#" equ "18" (
			if "%C_Edge%" equ "+" ( 
				set "C_Edge=-"
				set "C_EdgeDevToolsClient=-"
			) else (
				set "C_Edge=+"
			)
		)
		if "%%#" equ "19" (
			if "%C_EdgeDevToolsClient%" equ "+" ( 
				set "C_EdgeDevToolsClient=-"
			) else (
				set "C_Edge=+"
				set "C_EdgeDevToolsClient=+"
			)
		)
		if "%%#" equ "20" ( if "%C_ParentalControls%" equ "+" ( set "C_ParentalControls=-" ) else ( set "C_ParentalControls=+" ) )
		if "%%#" equ "21" (
			if "%C_NarratorQuickStart%" equ "+" ( 
				set "C_NarratorQuickStart=-"
			) else (
				set "C_Narrator=+"
				set "C_NarratorQuickStart=+"
				set "C_SpeechRecognition=+"
			)
		)
		if "%%#" equ "22" (
			if "%C_OOBENetworkConnectionFlow%" equ "+" ( 
				set "C_OOBENetworkConnectionFlow=-"
			) else ( 
				if "%C_CloudExperienceHost%" neq "*" set "C_CloudExperienceHost=+"
				set "C_OOBENetworkConnectionFlow=+"
			)
		)
		if "%%#" equ "23" if "%ImageBuild%" geq "19041" if "%ImageBuild%" leq "22631" ( if "%C_NcsiUwpApp%" equ "+" ( set "C_NcsiUwpApp=-" ) else ( set "C_NcsiUwpApp=+" ) )
		if "%%#" equ "24" if "%C_CloudExperienceHost%" neq "*" (
			if "%C_CloudExperienceHost%" equ "+" ( 
				set "C_CloudExperienceHost=-"
				set "C_FirstLogonAnimation=-"
				set "C_OOBENetworkCaptivePortal=-"
				set "C_OOBENetworkConnectionFlow=-"
			) else ( 
				set "C_CloudExperienceHost=+"
			)
		)
		if "%%#" equ "25" ( if "%C_PinningConfirmationDialog%" equ "+" ( set "C_PinningConfirmationDialog=-" ) else ( set "C_PinningConfirmationDialog=+" ) )
		if "%%#" equ "26" if "%ImageBuild%" geq "17763" if "%ImageBuild%" leq "22000" ( if "%C_QuickAssist%" equ "+" ( set "C_QuickAssist=-" ) else ( set "C_QuickAssist=+" ) )
		if "%%#" equ "27" ( if "%C_RetailDemoContent%" equ "+" ( set "C_RetailDemoContent=-" ) else ( set "C_RetailDemoContent=+" ) )
		if "%%#" equ "28" ( if "%C_XGpuEjectDialog%" equ "+" ( set "C_XGpuEjectDialog=-" ) else ( set "C_XGpuEjectDialog=+" ) )
		if "%%#" equ "29" ( if "%C_SettingSync%" equ "+" ( set "C_SettingSync=-" ) else ( set "C_SettingSync=+" ) )
		if "%%#" equ "30" if "%C_ShellExperienceHost%" neq "*" (
			if "%C_ShellExperienceHost%" equ "+" ( 
				set "C_ShellExperienceHost=-"
				if "%ImageBuild%" geq "18362" if "%ImageBuild%" leq "19045" if "%C_StartMenuExperienceHost%" neq "*" set "C_StartMenuExperienceHost=-"
			) else ( 
				set "C_ShellExperienceHost=+"
				if "%ImageBuild%" equ "22000" if "%C_VCLibs140UWP%" neq "*" set "C_VCLibs140UWP=+"
			)
		)
		if "%%#" equ "31" if "%ImageBuild%" geq "17763" if "%ImageBuild%" leq "18363" if "%C_InputApp%" neq "*" ( if "%C_InputApp%" equ "+" ( set "C_InputApp=-" ) else ( set "C_InputApp=+" ) )
		if "%%#" equ "32" if "%ImageBuild%" geq "19041" if "%ImageBuild%" leq "22631" if "%C_UndockedDevKit%" neq "*" ( if "%C_UndockedDevKit%" equ "+" ( set "C_UndockedDevKit=-" ) else ( set "C_UndockedDevKit=+" ) )
		if "%%#" equ "33" ( if "%C_SkypeORTC%" equ "+" ( set "C_SkypeORTC=-" ) else ( set "C_SkypeORTC=+" ) )
		if "%%#" equ "34" ( if "%C_SmartScreen%" equ "+" ( set "C_SmartScreen=-" ) else ( set "C_SmartScreen=+" ) )
		if "%%#" equ "35" if "%ImageBuild%" geq "18362" if "%ImageBuild%" leq "22631" if "%C_StartMenuExperienceHost%" neq "*" (
			if "%C_StartMenuExperienceHost%" equ "+" ( 
				set "C_StartMenuExperienceHost=-"
			) else ( 
				if "%ImageBuild%" geq "18362" if "%ImageBuild%" leq "19045" if "%C_ShellExperienceHost%" neq "*" set "C_ShellExperienceHost=+"
				set "C_StartMenuExperienceHost=+"
				if "%ImageBuild%" equ "22000" if "%C_VCLibs140UWP%" neq "*" set "C_VCLibs140UWP=+"
			)
		)
		if "%%#" equ "36" if "%ImageFlag%" neq "EnterpriseS" if "%ImageFlag%" neq "EnterpriseSN" ( if "%C_SecureAssessmentBrowser%" equ "+" ( set "C_SecureAssessmentBrowser=-" ) else ( set "C_SecureAssessmentBrowser=+" ) )
		if "%%#" equ "37" ( if "%C_WebcamExperience%" equ "+" ( set "C_WebcamExperience=-" ) else ( set "C_WebcamExperience=+" ) )
		if "%%#" equ "38" if "%ImageBuild%" geq "19041" if "%ImageBuild%" leq "22631" (	if "%C_WebView2Runtime%" equ "+" ( set "C_WebView2Runtime=-" ) else ( set "C_WebView2Runtime=+" ) )
		if "%%#" equ "39" ( if "%C_CBSPreview%" equ "+" ( set "C_CBSPreview=-" ) else ( set "C_CBSPreview=+" ) )
		if "%%#" equ "40" ( if "%C_LockApp%" equ "+" ( set "C_LockApp=-" ) else ( set "C_LockApp=+" ) )
		if "%%#" equ "41" (
			if "%C_WindowsDefender%" equ "+" ( 
				if "%C_SecurityCenter%" neq "*" set "C_SecurityCenter=-"
				set "C_WindowsDefender=-"
			) else ( 
				set "C_WindowsDefender=+"
				if "%ImageBuild%" geq "22000" if "%ImageBuild%" leq "22631" (
					if "%C_UIXaml24%" neq "*" set "C_UIXaml24=+"
					if "%C_VCLibs140UWP%" neq "*" set "C_VCLibs140UWP=+"
				)
			)
		)
		if "%%#" equ "42" if "%ImageBuild%" geq "19041" if "%ImageBuild%" leq "22631" if "%C_ClientCBS%" neq "*" (
			if "%C_ClientCBS%" equ "+" (
				set "C_ClientCBS=-"
			) else (
				set "C_ClientCBS=+"
				set "C_Getstarted=-"
				if "%ImageBuild%" equ "22000" if "%C_VCLibs140UWP%" neq "*" set "C_VCLibs140UWP=+"
			)
		)
		if "%%#" equ "43" if "%C_BioEnrollment%" neq "*" (
			if "%C_BioEnrollment%" equ "+" (
				set "C_BioEnrollment=-"
			) else (
				set "C_BioEnrollment=+"
				if "%ImageBuild%" equ "22000" if "%C_VCLibs140UWP%" neq "*" set "C_VCLibs140UWP=+"
			)
		)
		if "%%#" equ "44" (
			if "%C_WindowsMixedReality%" equ "+" ( 
				if "%ImageBuild%" geq "17763" if "%ImageBuild%" leq "19041" set "C_3DViewer=-"
				set "C_ECApp=-"
				if "%ImageBuild%" geq "17763" if "%ImageBuild%" leq "19041" if "%ImageArchitecture%" equ "x64" set "C_MixedRealityPortal=-"
				set "C_WindowsMixedReality=-"
			) else ( 
				set "C_WindowsMixedReality=+"
			)
		)
		if "%%#" equ "45" if "%C_PrintDialog%" neq "*" ( if "%C_PrintDialog%" equ "+" ( set "C_PrintDialog=-" ) else ( set "C_PrintDialog=+" ) )
		if "%%#" equ "46" ( if "%C_WindowsReaderPDF%" equ "+" ( set "C_WindowsReaderPDF=-" ) else ( set "C_WindowsReaderPDF=+" ) )
		if "%%#" equ "47" if "%ImageBuild%" geq "19041" if "%ImageBuild%" leq "22000" (
			if "%C_SearchApp%" equ "+" (
				set "C_SearchApp=-"
			) else (
				set "C_SearchApp=+"
				if "%ImageBuild%" equ "22000" if "%C_VCLibs140UWP%" neq "*" set "C_VCLibs140UWP=+"
			)
		)
		if "%%#" equ "48" (
			if "%C_PeopleExperienceHost%" equ "+" ( 
				set "C_People=-"
				set "C_PeopleExperienceHost=-"
			) else (
				set "C_PeopleExperienceHost=+"
			)
		)
		if "%%#" equ "49" if "%C_AADBrokerPlugin%" neq "*" ( if "%C_AADBrokerPlugin%" equ "+" ( set "C_AADBrokerPlugin=-" ) else ( set "C_AADBrokerPlugin=+" ) )
		if "%%#" equ "50" (
			if "%C_XboxGameCallableUI%" equ "+" ( 
				set "C_SolitaireCollection=-"
				set "C_XboxGameCallableUI=-"
			) else (
				set "C_XboxGameCallableUI=+"
			)
		)
		if /i "%%#" equ "B" goto :RemoveSystemMenu
		if /i "%%#" equ "N" goto :RemoveWindowsComponents
	)

	if /i "!MenuChoice!" equ "A" (
		if "%ImageBuild%" geq "17763" if "%ImageBuild%" leq "19041" set "C_3DViewer=-"
		if "%C_AADBrokerPlugin%" neq "*" set "C_AADBrokerPlugin=-"
		if "%C_AccountsControl%" neq "*" set "C_AccountsControl=-"
		set "C_AddSuggestedFoldersToLibraryDialog=-"
		set "C_AppResolverUX=-"
		if "%ImageFlag%" neq "Core" if "%ImageFlag%" neq "CoreN" if "%ImageFlag%" neq "CoreSingleLanguage" set "C_AssignedAccessLockApp=-"
		set "C_AsyncTextService=-"
		if "%C_BioEnrollment%" neq "*" set "C_BioEnrollment=-"
		if "%ImageBuild%" geq "18362" if "%ImageBuild%" leq "22631" set "C_CallingShellApp=-"
		set "C_CapturePicker=-"
		set "C_CBSPreview=-"
		if "%ImageBuild%" geq "19041" if "%ImageBuild%" leq "22631" if "%C_ClientCBS%" neq "*" set "C_ClientCBS=-"
		if "%C_CloudExperienceHost%" neq "*" set "C_CloudExperienceHost=-"
		set "C_ContentDeliveryManager=-"
		if "%ImageBuild%" geq "17763" if "%ImageBuild%" leq "18363" if "%C_Cortana%" neq "*" set "C_Cortana=-"
		set "C_CredDialogHost=-"
		set "C_ECApp=-"
		set "C_Edge=-"
		set "C_EdgeDevToolsClient=-"
		set "C_FileExplorer=-"
		set "C_FilePicker=-"
		if "%C_CloudExperienceHost%" neq "*" set "C_FirstLogonAnimation=-"
		if "%ImageBuild%" geq "19041" if "%ImageBuild%" leq "22631" if "%C_ClientCBS%" neq "*" set "C_Getstarted=-"
		if "%ImageBuild%" geq "17763" if "%ImageBuild%" leq "18363" if "%C_InputApp%" neq "*" set "C_InputApp=-"
		set "C_LockApp=-"
		set "C_Maps=-"
		set "C_MapControl=-"
		if "%ImageBuild%" geq "17763" if "%ImageBuild%" leq "19041" if "%ImageArchitecture%" equ "x64" set "C_MixedRealityPortal=-"
		set "C_NarratorQuickStart=-"
		if "%ImageBuild%" geq "19041" if "%ImageBuild%" leq "22631" set "C_NcsiUwpApp=-"
		set "C_OOBENetworkCaptivePortal=-"
		set "C_OOBENetworkConnectionFlow=-"
		set "C_ParentalControls=-"
		set "C_People=-"
		set "C_PeopleExperienceHost=-"
		set "C_PinningConfirmationDialog=-"
		if "%ImageBuild%" geq "17763" if "%ImageBuild%" leq "18363" if "%ImageFlag%" neq "EnterpriseS" if "%ImageFlag%" neq "EnterpriseSN" set "C_PPIProjection=-"
		if "%C_PrintDialog%" neq "*" set "C_PrintDialog=-"
		if "%ImageBuild%" geq "17763" if "%ImageBuild%" leq "22000" set "C_QuickAssist=-"
		set "C_RetailDemoContent=-"
		set "C_ScreenSketch=-"
		if "%ImageBuild%" geq "19041" if "%ImageBuild%" leq "22000" set "C_SearchApp=-"
		if "%ImageFlag%" neq "EnterpriseS" if "%ImageFlag%" neq "EnterpriseSN" set "C_SecureAssessmentBrowser=-"
		if "%C_SecurityCenter%" neq "*" set "C_SecurityCenter=-"
		set "C_SettingSync=-"
		if "%C_ShellExperienceHost%" neq "*" set "C_ShellExperienceHost=-"
		set "C_SkypeORTC=-"
		set "C_SmartScreen=-"
		set "C_SolitaireCollection=-"
		if "%ImageBuild%" geq "18362" if "%ImageBuild%" leq "19045" if "%C_StartMenuExperienceHost%" neq "*" set "C_StartMenuExperienceHost=-"
		if "%ImageBuild%" geq "19041" if "%ImageBuild%" leq "22631" if "%C_UndockedDevKit%" neq "*" set "C_UndockedDevKit=-"
		set "C_WebcamExperience=-"
		if "%ImageBuild%" geq "19041" if "%ImageBuild%" leq "22631" set "C_WebView2Runtime=-"
		set "C_Win32WebViewHost=-"
		set "C_WindowsDefender=-"
		set "C_WindowsMixedReality=-"
		set "C_WindowsReaderPDF=-"
		set "C_XboxGameCallableUI=-"
		set "C_XGpuEjectDialog=-"
	)

	goto :RemoveSystemAppsMenu
)

:: �Ƴ� Windows ���ģ��
:RemoveWindowsComponents

setlocal

set Components=

cls
echo.===============================================================================
echo.                               ��ʼ����ϵͳ
echo.===============================================================================
echo.

:: ��ȡ��װӳ����������ϵ�ṹ
for /f "tokens=2 delims=: " %%a in ('%DISM% /Get-ImageInfo /ImageFile:"%InstallWim%" /Index:%ImageIndexNo% ^| findstr /i Architecture') do (set ImageArchitecture=%%a)


:: �������״̬��ʶ
for %%i in (C_AdobeFlashForWindows,C_EdgeChromium,C_EdgeWebView,C_InternetExplorer,C_FirstLogonAnimation,C_GameExplorer,C_LockScreenBackground,C_ScreenSavers,C_SnippingTool,C_SoundThemes,C_SpeechRecognition,C_Wallpapers,C_WindowsMediaPlayer,C_WindowsPhotoViewer,C_WindowsThemes,C_WindowsTIFFIFilter,C_WinSAT,C_OfflineFiles,C_OpenSSH,C_RemoteDesktopClient,C_RemoteDifferentialCompression,C_SimpleTCPIPServices,C_TelnetClient,C_TFTPClient,C_WalletService,C_WindowsMail,C_AssignedAccess,C_CEIP,C_FaceRecognition,C_KernelDebugging,C_LocationService,C_PicturePassword,C_PinEnrollment,C_UnifiedTelemetryClient,C_WiFiNetworkManager,C_WindowsErrorReporting,C_WindowsInsiderHub,C_HomeGroup,C_MultiPointConnector,C_OneDrive,C_RemoteAssistance,C_RemoteDesktopServer,C_RemoteRegistry,C_WorkFoldersClient,C_AccessibilityTools,C_Calculator,C_DeviceLockdown,C_EaseOfAccessCursors,C_EaseOfAccessThemes,C_EasyTransfer,C_FileHistory,C_LiveCaptions,C_Magnifier,C_ManualSetup,C_Narrator,C_Notepad,C_OnScreenKeyboard,C_Paint,C_ProjFS,C_SecurityCenter,C_StepsRecorder,C_StorageSpaces,C_SystemRestore,C_VoiceAccess,C_WindowsBackup,C_WindowsFirewall,C_WindowsSubsystemForLinux,C_WindowsToGo,C_WindowsUpdate,C_Wordpad,C_AADBrokerPlugin,C_AccountsControl,C_AddSuggestedFoldersToLibraryDialog,C_AppResolverUX,C_AssignedAccessLockApp,C_AsyncTextService,C_BioEnrollment,C_CallingShellApp,C_CapturePicker,C_CBSPreview,C_ClientCBS,C_CloudExperienceHost,C_ContentDeliveryManager,C_Cortana,C_CredDialogHost,C_ECApp,C_Edge,C_EdgeDevToolsClient,C_FileExplorer,C_FilePicker,C_InputApp,C_LockApp,C_MapControl,C_NarratorQuickStart,C_NcsiUwpApp,C_OOBENetworkCaptivePortal,C_OOBENetworkConnectionFlow,C_ParentalControls,C_PeopleExperienceHost,C_PinningConfirmationDialog,C_PrintDialog,C_PPIProjection,C_QuickAssist,C_RetailDemoContent,C_SearchApp,C_SecureAssessmentBrowser,C_SettingSync,C_ShellExperienceHost,C_SkypeORTC,C_SmartScreen,C_StartMenuExperienceHost,C_UndockedDevKit,C_WebcamExperience,C_WebView2Runtime,C_Win32WebViewHost,C_WindowsDefender,C_WindowsMixedReality,C_WindowsReaderPDF,C_WindowsStoreCore,C_XboxCore,C_XboxGameCallableUI,C_XGpuEjectDialog,C_3DViewer,C_AdvertisingXaml,C_Alarms,C_BingNews,C_BingWeather,C_CalculatorApp,C_Camera,C_ClientWebExperience,C_Clipchamp,C_CommunicationsApps,C_DesktopAppInstaller,C_Family,C_FeedbackHub,C_GamingApp,C_GetHelp,C_Getstarted,C_HEIFImageExtension,C_HEVCVideoExtension,C_Maps,C_Messaging,C_MixedRealityPortal,C_NETNativeFramework16,C_NETNativeFramework17,C_NETNativeFramework22,C_NETNativeRuntime16,C_NETNativeRuntime17,C_NETNativeRuntime22) do (
	if "%%i" neq "C_ManualSetup" if "!%%i!" equ "-" (
		for /f "tokens=2 delims=_" %%j in ("%%i") do (
			set "Components=!Components!%%j;"
		)
	)
)

if "%Components%" equ ""  (
	echo.δѡ��Ҫ��������...
	goto :Stop
)

echo.-------------------------------------------------------------------------------
echo.####���ڿ�ʼ�Ƴ� Windows ���##################################################
echo.-------------------------------------------------------------------------------
echo.
echo.    ӳ���ļ�����             ��Install.wim
echo.    ӳ������                 ��%ImageIndexNo%
echo.    ӳ����ϵ�ṹ             ��%ImageArchitecture%
echo.    ӳ��汾                 ��%ImageVersion%.%ImageServicePackBuild%.%ImageServicePackLevel%
echo.
echo.-------------------------------------------------------------------------------
echo.####�����Ƴ� Windows ���######################################################
echo.-------------------------------------------------------------------------------

if "%Components%" neq "" (
	echo.
	echo.===========================[Install.wim������ ��%ImageIndexNo%]============================
	echo.
	:: �Ƴ� Windows ���
	if "%C_ManualSetup%" equ "-" (
		"%Bin%\ToolKitHelper.exe" "%InstallMount%\%ImageIndexNo%" "%Components%ManualSetup;"
	) else (
		"%Bin%\ToolKitHelper.exe" "%InstallMount%\%ImageIndexNo%" "%Components%"
	)
	echo.
)

echo.-------------------------------------------------------------------------------
echo.####ϵͳ�������################################################################
echo.-------------------------------------------------------------------------------
echo.
echo.MSMG�����������ͻ�ֱ����ֹ�����������������ᱻ����
echo.
echo.�����û�����������������ȫ������������1������
echo.
echo.����������������ס����ǰ���һ�����������2�ص�ѡ����棬ȡ��ѡ�񱨴������
echo.
choice /C:12 /N /M "���������ѡ�� ��"
if errorlevel 2 goto :RemoveInternetMenu
if errorlevel 1 echo.

:Stop
echo.
echo.-------------------------------------------------------------------------------
echo.####�������� DISM++ �Ծ���APPX#################################################
echo.-------------------------------------------------------------------------------
echo.
echo.����1��Dism++�����Ż�ϵͳ����APPX������2�����˲�������һ�����ڡ�
echo.
choice /C:12 /N /M "���������ѡ�� ��"
if errorlevel 2 goto :skipdism
if errorlevel 1 %Bin%\DISM++\dism++%HostArchitecture%.exe
:skipdism
echo.===============================================================================
echo.

set Components=

endlocal

:: �������״̬��ʶ
for %%i in (C_AdobeFlashForWindows,C_EdgeChromium,C_EdgeWebView,C_InternetExplorer,C_FirstLogonAnimation,C_GameExplorer,C_LockScreenBackground,C_ScreenSavers,C_SnippingTool,C_SoundThemes,C_SpeechRecognition,C_Wallpapers,C_WindowsMediaPlayer,C_WindowsPhotoViewer,C_WindowsThemes,C_WindowsTIFFIFilter,C_WinSAT,C_OfflineFiles,C_OpenSSH,C_RemoteDesktopClient,C_RemoteDifferentialCompression,C_SimpleTCPIPServices,C_TelnetClient,C_TFTPClient,C_WalletService,C_WindowsMail,C_AssignedAccess,C_CEIP,C_FaceRecognition,C_KernelDebugging,C_LocationService,C_PicturePassword,C_PinEnrollment,C_UnifiedTelemetryClient,C_WiFiNetworkManager,C_WindowsErrorReporting,C_WindowsInsiderHub,C_HomeGroup,C_MultiPointConnector,C_OneDrive,C_RemoteAssistance,C_RemoteDesktopServer,C_RemoteRegistry,C_WorkFoldersClient,C_AccessibilityTools,C_Calculator,C_DeviceLockdown,C_EaseOfAccessCursors,C_EaseOfAccessThemes,C_EasyTransfer,C_FileHistory,C_LiveCaptions,C_Magnifier,C_ManualSetup,C_Narrator,C_Notepad,C_OnScreenKeyboard,C_Paint,C_ProjFS,C_SecurityCenter,C_StepsRecorder,C_StorageSpaces,C_SystemRestore,C_VoiceAccess,C_WindowsBackup,C_WindowsFirewall,C_WindowsSubsystemForLinux,C_WindowsToGo,C_WindowsUpdate,C_Wordpad,C_AADBrokerPlugin,C_AccountsControl,C_AddSuggestedFoldersToLibraryDialog,C_AppResolverUX,C_AssignedAccessLockApp,C_AsyncTextService,C_BioEnrollment,C_CallingShellApp,C_CapturePicker,C_CBSPreview,C_ClientCBS,C_CloudExperienceHost,C_ContentDeliveryManager,C_Cortana,C_CredDialogHost,C_ECApp,C_Edge,C_EdgeDevToolsClient,C_FileExplorer,C_FilePicker,C_InputApp,C_LockApp,C_MapControl,C_NarratorQuickStart,C_NcsiUwpApp,C_OOBENetworkCaptivePortal,C_OOBENetworkConnectionFlow,C_ParentalControls,C_PeopleExperienceHost,C_PinningConfirmationDialog,C_PrintDialog,C_PPIProjection,C_QuickAssist,C_RetailDemoContent,C_SearchApp,C_SecureAssessmentBrowser,C_SettingSync,C_ShellExperienceHost,C_SkypeORTC,C_SmartScreen,C_StartMenuExperienceHost,C_UndockedDevKit,C_WebcamExperience,C_WebView2Runtime,C_Win32WebViewHost,C_WindowsDefender,C_WindowsMixedReality,C_WindowsReaderPDF,C_WindowsStoreCore,C_XboxCore,C_XboxGameCallableUI,C_XGpuEjectDialog,C_3DViewer,C_AdvertisingXaml,C_Alarms,C_BingNews,C_BingWeather,C_CalculatorApp,C_Camera,C_ClientWebExperience,C_Clipchamp,C_CommunicationsApps,C_DesktopAppInstaller,C_Family,C_FeedbackHub,C_GamingApp,C_GetHelp,C_Getstarted,C_HEIFImageExtension,C_HEVCVideoExtension,C_Maps,C_Messaging,C_MixedRealityPortal,C_NETNativeFramework16,C_NETNativeFramework17,C_NETNativeFramework22,C_NETNativeRuntime16,C_NETNativeRuntime17,C_NETNativeRuntime22) do (
	set "%%i=+"
)

:: �������������״̬��ʶ
for %%i in (CC_AdobeInstallers,CC_ApplicationGuardContainers,CC_Biometric,CC_Hyper-V,CC_MicrosoftGames,CC_MicrosoftOfice,CC_MicrosoftStore,CC_ModernAppSupport,CC_OOBE,CC_Printing,CC_Recommended,CC_ShellSearch,CC_TouchScreenDevices,CC_VisualStudio,CC_WindowsUpdate,CC_WindowsUpgrade,CC_XboxApp) do (
	set "%%i=+"
)

for %%i in (C_AADBrokerPlugin,C_AccountsControl,C_BioEnrollment,C_ClientCBS,C_CloudExperienceHost,C_Cortana,C_DesktopAppInstaller,C_EasyTransfer,C_EdgeChromium,C_EdgeWebView,C_GameExplorer,C_GamingApp,C_InputApp,C_InternetExplorer,C_KernelDebugging,C_ManualSetup,C_NETNativeFramework16,C_NETNativeFramework17,C_NETNativeFramework22,C_NETNativeRuntime16,C_NETNativeRuntime17,C_NETNativeRuntime22,C_OfflineFiles,C_PinEnrollment,C_PrintDialog,C_RemoteDesktopClient,C_RemoteDesktopServer,C_SearchApp,C_SecurityCenter,C_ShellExperienceHost,C_StartMenuExperienceHost,C_UIXaml20,C_UIXaml24,C_UIXaml27,C_UndockedDevKit,C_VCLibs140UWP,C_VCLibs140UWPDesktop,C_WindowsErrorReporting,C_WindowsFirewall,C_WindowsStore,C_WindowsStoreCore,C_WindowsUpdate,C_WinSAT,C_XboxIdentityProvider,C_XboxCore,C_XboxApp) do (
	if "%%i" equ "C_WindowsErrorReporting" if "%ImageBuild%" geq "18362" if "%ImageBuild%" leq "18363" set "%%i=*"
	if "%%i" equ "C_ClientCBS" if "%ImageBuild%" geq "19041" if "%ImageBuild%" leq "22631" set "%%i=*"
	if "%%i" neq "C_ClientCBS" if "%%i" neq "C_WindowsErrorReporting" set "%%i=*"
)

goto :ApplyTweaksMenu

:: Ӧ�õ����˵�
:ApplyTweaksMenu

setlocal
set Tweak=

echo.���ڰ�װӳ��ע�����
call :MountImageRegistry "%InstallMount%\%ImageIndexNo%"
cls
echo.===============================================================================
echo.                                  ϵͳ�Ż�
echo.===============================================================================
echo.

if "%SelectedSourceOS%" equ "w10" (
	echo.  [ 1]   ��ֹͨ�� Windows �����Զ���������
	echo.  [ 2]   �����Զ����ز���װ������Ӧ��
	echo.  [ 3]   �����Զ�ִ�� Windows ����
	echo.  [ 4]   ���� Cortana Ӧ��
	echo.  [ 5]   ���������ļ����Զ������ڷ��鲼��
	echo.  [ 6]   ���� Microsoft ���� Windows ���±����Ĵ洢�ռ�
	echo.  [ 7]   ���� Windows Defender
	echo.  [ 8]   ���� Windows ����ǽ
	echo.  [ 9]   ���� Windows SmartScreen
	echo.  [10]   ���� Windows ����
	echo.  [11]   ʹ������ ResetBase ���� DISM ӳ������
	echo.  [12]   ���� Fraunhofer MP3 Professional Codec
	echo.  [13]   ���� Windows ��Ƭ�鿴��
	echo.  [14]   ǿ���� .NET ����ʹ�����µ� .NET Framework
	echo.  [15]   ���������� Cortana ͼ��
	echo.  [16]   ������������������ͼ��
	echo.  [17]   ������������Ѷ����Ȥ
	echo   [18]   ����������������
	echo.  [19]   ����������������ͼͼ��
	echo.
	echo.  [A]    ���е���
	echo.  [X]    ��һ��
	echo.
	echo.===============================================================================
	echo.
	echo.  Tips���˽��治֧������ѡ��
	echo.
	set /p MenuChoice=���������ѡ�� ��

	if "!MenuChoice!" equ "1" set "Tweak=DisableDriversUpdates"
	if "!MenuChoice!" equ "2" set "Tweak=Disable3RDPartyApps"
	if "!MenuChoice!" equ "3" set "Tweak=DisableWindowsUpgrade"
	if "!MenuChoice!" equ "4" set "Tweak=DisableCortanaApp"
	if "!MenuChoice!" equ "5" set "Tweak=DisableDownloadsLayout"
	if "!MenuChoice!" equ "6" set "Tweak=DisableReservedStorage"
	if "!MenuChoice!" equ "7" set "Tweak=DisableWindowsDefender"
	if "!MenuChoice!" equ "8" set "Tweak=DisableWindowsFirewall"
	if "!MenuChoice!" equ "9" set "Tweak=DisableWindowsSmartScreen"
	if "!MenuChoice!" equ "10" set "Tweak=DisableWindowsUpdate"
	if "!MenuChoice!" equ "11" set "Tweak=EnableFullResetBase"
	if "!MenuChoice!" equ "12" set "Tweak=EnableFMP3ProCodec"
	if "!MenuChoice!" equ "13" set "Tweak=EnablePhotoViewer"
	if "!MenuChoice!" equ "14" set "Tweak=ForceLatestNetFramework"
	if "!MenuChoice!" equ "15" set "Tweak=HideCortanaIcon"
	if "!MenuChoice!" equ "16" set "Tweak=HideMeetNowIcon"
	if "!MenuChoice!" equ "17" set "Tweak=HideNewsAndInterests"
	if "!MenuChoice!" equ "18" set "Tweak=HideSearchBar"
	if "!MenuChoice!" equ "19" set "Tweak=HideTaskViewIcon"
	if /i "!MenuChoice!" equ "A" set "Tweak=AllTweaks"
	if /i "!MenuChoice!" equ "X" goto :ApplyMenu
)

if "%SelectedSourceOS%" equ "w11" (
	echo.  [ 1]   ��ֹͨ�� Windows �����Զ���������
	echo.  [ 2]   �����Զ����ز���װ������Ӧ��
	echo.  [ 3]   �����Զ����ز���װ Microsoft Teams Ӧ��
	echo.  [ 4]   �����Զ�ִ�� Windows ����
	echo.  [ 5]   ���� Cortana Ӧ��
	echo.  [ 6]   ���������ļ����Զ������ڷ��鲼��
	echo.  [ 7]   ���� Microsoft ���� Windows ���±����Ĵ洢�ռ�
	echo.  [ 8]   ���� Windows 11 ��װ����Ӳ�����
	echo.  [ 9]   ���� Windows Defender
	echo.  [10]   ���� Windows ����ǽ
	echo.  [11]   ���� Windows SmartScreen
	echo.  [12]   ���� Windows ����
	echo.  [13]   ʹ������ ResetBase ���� DISM ӳ������
	echo.  [14]   ���� Fraunhofer MP3 Professional Codec
	echo.  [15]   ���� Windows ���������Ĳ˵�
	echo.  [16]   ���� Windows �����ʻ�
	echo.  [17]   ���� Windows ��Ƭ�鿴��
	echo.  [18]   ǿ���� .NET ����ʹ�����µ� .NET Framework
	echo.  [19]   ��������������ͼ��
	echo.  [20]   ���������� Cortana ͼ��
	echo.  [21]   ������������������ͼ��
	echo.  [22]   ������������Ѷ����Ȥ
	echo   [23]   ����������������
	echo.  [24]   ����������������ͼͼ��
	echo.  [25]   ����������С���ͼ��
	echo.  [26]   �������������뷽ʽΪ�����
	echo.  [27]   ����ң��
	echo.
	echo.  [A]    ���е���
	echo.  [X]    ��һ��
	echo.
	echo.===============================================================================
	echo.
	echo.  Tips���˽��治֧������ѡ��
	echo.
	set /p MenuChoice=���������ѡ�� ��

	if "!MenuChoice!" equ "1" set "Tweak=DisableDriversUpdates"
	if "!MenuChoice!" equ "2" set "Tweak=Disable3RDPartyApps"
	if "!MenuChoice!" equ "3" set "Tweak=DisableTeamsApp"
	if "!MenuChoice!" equ "4" set "Tweak=DisableWindowsUpgrade"
	if "!MenuChoice!" equ "5" set "Tweak=DisableCortanaApp"
	if "!MenuChoice!" equ "6" set "Tweak=DisableDownloadsLayout"
	if "!MenuChoice!" equ "7" set "Tweak=DisableReservedStorage"
	if "!MenuChoice!" equ "8" set "Tweak=DisableW11InstHardwareCheck"
	if "!MenuChoice!" equ "9" set "Tweak=DisableWindowsDefender"
	if "!MenuChoice!" equ "10" set "Tweak=DisableWindowsFirewall"
	if "!MenuChoice!" equ "11" set "Tweak=DisableWindowsSmartScreen"
	if "!MenuChoice!" equ "12" set "Tweak=DisableWindowsUpdate"
	if "!MenuChoice!" equ "13" set "Tweak=EnableFullResetBase"
	if "!MenuChoice!" equ "14" set "Tweak=EnableFMP3ProCodec"
	if "!MenuChoice!" equ "15" set "Tweak=EnableClassicContextMenu"
	if "!MenuChoice!" equ "16" set "Tweak=EnableLocalAccount"
	if "!MenuChoice!" equ "17" set "Tweak=EnablePhotoViewer"
	if "!MenuChoice!" equ "18" set "Tweak=ForceLatestNetFramework"
	if "!MenuChoice!" equ "19" set "Tweak=HideChatIcon"
	if "!MenuChoice!" equ "20" set "Tweak=HideCortanaIcon"
	if "!MenuChoice!" equ "21" set "Tweak=HideMeetNowIcon"
	if "!MenuChoice!" equ "22" set "Tweak=HideNewsAndInterests"
	if "!MenuChoice!" equ "23" set "Tweak=HideSearchBar"
	if "!MenuChoice!" equ "24" set "Tweak=HideTaskViewIcon"
	if "!MenuChoice!" equ "25" set "Tweak=HideWidgetsIcon"
	if "!MenuChoice!" equ "26" set "Tweak=SetTaskbarAlignLeft"
	if "!MenuChoice!" equ "27" set "Tweak=Disableyc"
	if /i "!MenuChoice!" equ "A" set "Tweak=AllTweaks"
	if /i "!MenuChoice!" equ "X" goto :ApplyMenu
)

if /i "%Tweak%" equ "" goto :ApplyTweaksMenu

cls
echo.===============================================================================
echo.                                 ϵͳ�Ż�
echo.===============================================================================
echo.
:: ��ȡ���º��ӳ����Ϣ
if "%ImageBuild%" geq "18362" if "%ImageBuild%" leq "19045" (
	:: ��ȡ�Ѹ��µ�ӳ��������Ϣģ��
	for /f "tokens=3 delims= " %%x in ('reg query "HKLM\TK_SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v "CurrentBuild" ^| find "REG_SZ"') do (set /a ImageBuild=%%x)
	set "ImageVersion=10.0.%ImageBuild%"
	for /f "tokens=3 delims= " %%y in ('reg query "HKLM\TK_SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v "UBR" ^| find "REG_DWORD"') do (set /a ImageServicePackBuild=%%y)
)

:: ��ȡ��װӳ����������ϵ�ṹ
for /f "tokens=2 delims=: " %%a in ('%DISM% /Get-ImageInfo /ImageFile:"%InstallWim%" /Index:%ImageIndexNo% ^| findstr /i Architecture') do (set ImageArchitecture=%%a)


echo.-------------------------------------------------------------------------------
echo.####���ڿ�ʼӦ�õ���###########################################################
echo.-------------------------------------------------------------------------------
echo.
echo.    ӳ���ļ�����             ��Install.wim
echo.    ӳ������                 ��%ImageIndexNo%
echo.    ӳ����ϵ�ṹ             ��%ImageArchitecture%
echo.    ӳ��汾                 ��%ImageVersion%.%ImageServicePackBuild%.%ImageServicePackLevel%
echo.
echo.-------------------------------------------------------------------------------
if "%Tweak%" equ "AllTweaks" echo.####����Ӧ�����е���###########################################################
if "%Tweak%" equ "Disable3RDPartyApps" echo.####����Ӧ�ý����Զ����ز���װ������Ӧ�õ���###################################
if "%Tweak%" equ "DisableCortanaApp" echo.####����Ӧ�ý��� Cortana Ӧ�õ���##############################################
if "%Tweak%" equ "DisableDownloadsLayout" echo.####����Ӧ�ý��������ļ����Զ������ڷ��鲼�ֵ���###############################
if "%Tweak%" equ "DisableDriversUpdates" echo.####����Ӧ�ý�ֹͨ�� Windows �����Զ�������������##############################
if "%Tweak%" equ "DisableReservedStorage" echo.####����Ӧ�ý��� Microsoft ���ڽ��� Windows ���±����Ĵ洢�ռ�#################
if "%Tweak%" equ "DisableTeamsApp" echo.####����Ӧ�ý����Զ����ز���װ Teams Ӧ�õ���##################################
if "%Tweak%" equ "DisableW11InstHardwareCheck" echo.####����Ӧ�ý��� Windows 11 ��װ����Ӳ�����###################################
if "%Tweak%" equ "DisableWindowsDefender" echo.####����Ӧ�ý��� Windows Defender ����#########################################
if "%Tweak%" equ "DisableWindowsFirewall" echo.####����Ӧ�ý��� Windows ����ǽ����############################################
if "%Tweak%" equ "DisableWindowsSmartScreen" echo.####����Ӧ�ý��� Windows SmartScreen ����######################################
if "%Tweak%" equ "DisableWindowsUpdate" echo.####����Ӧ�ý��� Windows ���µ���##############################################
if "%Tweak%" equ "DisableWindowsUpgrade" echo.####����Ӧ�ý����Զ����� Windows ����ϵͳ����##################################
if "%Tweak%" equ "EnableClassicContextMenu" echo.####����Ӧ������ Windows ���������Ĳ˵�########################################
if "%Tweak%" equ "EnableFMP3ProCodec" echo.####����Ӧ������ Fraunhofer MP3 Professional Codec ����########################
if "%Tweak%" equ "EnableFullResetBase" echo.####����Ӧ��ʹ������ ResetBase ���� DISM ӳ���������##########################
if "%Tweak%" equ "EnableLocalAccount" echo.####����Ӧ������ Windows �����ʻ�����##########################################
if "%Tweak%" equ "EnablePhotoViewer" echo.####����Ӧ������ Windows ��Ƭ�鿴������########################################
if "%Tweak%" equ "ForceLatestNetFramework" echo.####����Ӧ��ǿ�� .NET ����ʹ�����µ� .NET Framework ����#######################
if "%Tweak%" equ "HideChatIcon" echo.####����Ӧ����������������ͼ�����#############################################
if "%Tweak%" equ "HideCortanaIcon" echo.####����Ӧ������������ Cortana ͼ�����########################################
if "%Tweak%" equ "HideMeetNowIcon" echo.####����Ӧ��������������������ͼ�����#########################################
if "%Tweak%" equ "HideNewsAndInterests" echo.####����Ӧ��������������Ѷ����Ȥ����###########################################
if "%Tweak%" equ "HideSearchBar" echo.####����Ӧ�������������ϵ�����������###########################################
if "%Tweak%" equ "HideTaskViewIcon" echo.####����Ӧ������������������ͼͼ�����#########################################
if "%Tweak%" equ "HideWidgetsIcon" echo.####����Ӧ������������С���ͼ�����###########################################
if "%Tweak%" equ "SetTaskbarAlignLeft" echo.####����Ӧ���������������뷽ʽΪ��������#####################################
if "%Tweak%" equ "Disableyc" echo.####����Ӧ�ý���ң��###########################################################
echo.-------------------------------------------------------------------------------

echo.
echo.==========================[Install.wim������ ��%ImageIndexNo%]============================
echo.
echo.���ڽ�ע������úϲ���ӳ��ע�����

if "%Tweak%" equ "DisableW11InstHardwareCheck" (
	Reg add "HKLM\TK_DEFAULT\Control Panel\UnsupportedHardwareNotificationCache" /v "SV1" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_DEFAULT\Control Panel\UnsupportedHardwareNotificationCache" /v "SV2" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Control Panel\UnsupportedHardwareNotificationCache" /v "SV1" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Control Panel\UnsupportedHardwareNotificationCache" /v "SV2" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SYSTEM\Setup\LabConfig" /v "BypassCPUCheck" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SYSTEM\Setup\LabConfig" /v "BypassRAMCheck" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SYSTEM\Setup\LabConfig" /v "BypassSecureBootCheck" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SYSTEM\Setup\LabConfig" /v "BypassStorageCheck" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SYSTEM\Setup\LabConfig" /v "BypassTPMCheck" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SYSTEM\Setup\MoSetup" /v "AllowUpgradesWithUnsupportedTPMOrCPU" /t REG_DWORD /d "1" /f >nul 2>&1
)

if "%Tweak%" equ "DisableCortanaApp" (
	Reg add "HKLM\TK_DEFAULT\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" /v "HarvestContacts" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_DEFAULT\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "DeviceHistoryEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_DEFAULT\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "HistoryViewEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_DEFAULT\SOFTWARE\Microsoft\Windows\CurrentVersion\Windows Search" /v "CortanaConsent" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_DEFAULT\SOFTWARE\Microsoft\Windows\CurrentVersion\Windows Search" /v "CortanaIsReplaceable" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_DEFAULT\SOFTWARE\Microsoft\Windows\CurrentVersion\Windows Search" /v "CortanaIsReplaced" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_DEFAULT\SOFTWARE\Microsoft\Windows\CurrentVersion\Windows Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_DEFAULT\SOFTWARE\Policies\Microsoft\InputPersonalization" /v "RestrictImplicitInkCollection" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_DEFAULT\SOFTWARE\Policies\Microsoft\InputPersonalization" /v "RestrictImplicitTextCollection" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\ServiceUI" /v "EnableCortana" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\SOFTWARE\Microsoft\InputPersonalization" /v "RestrictImplicitInkCollection" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\SOFTWARE\Microsoft\InputPersonalization" /v "RestrictImplicitTextCollection" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" /v "HarvestContacts" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\SOFTWARE\Microsoft\Personalization\Settings" /v "AcceptedPrivacyPolicy" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "DeviceHistoryEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "HistoryViewEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\SOFTWARE\Microsoft\Windows\CurrentVersion\Windows Search" /v "CortanaConsent" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\SOFTWARE\Microsoft\Windows\CurrentVersion\Windows Search" /v "CortanaIsReplaceable" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\SOFTWARE\Microsoft\Windows\CurrentVersion\Windows Search" /v "CortanaIsReplaced" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\SOFTWARE\Microsoft\Windows\CurrentVersion\Windows Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\PolicyManager\current\device\AboveLock" /v "AllowCortanaAboveLock" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\PolicyManager\current\device\Experience" /v "AllowCortana" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Speech_OneCore\Preferences" /v "ModelDownloadAllowed" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\InputPersonalization" /v "AllowInputPersonalization" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCloudSearch" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCortana" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCortanaAboveLock" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowSearchToUseLocation" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "ConnectedSearchPrivacy" /t REG_DWORD /d "3" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "ConnectedSearchSafeSearch" /t REG_DWORD /d "3" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "ConnectedSearchUseWeb" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "ConnectedSearchUseWebOverMeteredConnections" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "DisableWebSearch" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Wow6432Node\Microsoft\Windows\Windows Search" /v "AllowCortana" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Wow6432Node\Microsoft\Windows\Windows Search" /v "AllowCortanaAboveLock" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SYSTEM\ControlSet001\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules" /v "Block Cortana ActionUriServer.exe" /t REG_SZ /d "v2.26|Action=Block|Active=TRUE|Dir=Out|RA42=IntErnet|RA62=IntErnet|App=C:\Windows\SystemApps\Microsoft.Windows.Cortana_cw5n1h2txyewy\ActionUriServer.exe|Name=Block Cortana ActionUriServer.exe|Desc=Block Cortana Outbound UDP/TCP Traffic|" /f >nul 2>&1
	Reg add "HKLM\TK_SYSTEM\ControlSet001\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules" /v "Block Cortana Package" /t REG_SZ /d "v2.26|Action=Block|Active=TRUE|Dir=Out|RA42=IntErnet|RA62=IntErnet|Name=Block Cortana Package|Desc=Block Cortana Outbound UDP/TCP Traffic|AppPkgId=S-1-15-2-1861897761-1695161497-2927542615-642690995-327840285-2659745135-2630312742|Platform=2:6:2|Platform2=GTEQ|" /f >nul 2>&1
	Reg add "HKLM\TK_SYSTEM\ControlSet001\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules" /v "Block Cortana PlacesServer.exe" /t REG_SZ /d "v2.26|Action=Block|Active=TRUE|Dir=Out|RA42=IntErnet|RA62=IntErnet|App=C:\Windows\SystemApps\Microsoft.Windows.Cortana_cw5n1h2txyewy\PlacesServer.exe|Name=Block Cortana PlacesServer.exe|Desc=Block Cortana Outbound UDP/TCP Traffic|" /f >nul 2>&1
	Reg add "HKLM\TK_SYSTEM\ControlSet001\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules" /v "Block Cortana RemindersServer.exe" /t REG_SZ /d "v2.26|Action=Block|Active=TRUE|Dir=Out|RA42=IntErnet|RA62=IntErnet|App=C:\Windows\SystemApps\Microsoft.Windows.Cortana_cw5n1h2txyewy\RemindersServer.exe|Name=Block Cortana RemindersServer.exe|Desc=Block Cortana Outbound UDP/TCP Traffic|" /f >nul 2>&1
	Reg add "HKLM\TK_SYSTEM\ControlSet001\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules" /v "Block Cortana RemindersShareTargetApp.exe" /t REG_SZ /d "v2.26|Action=Block|Active=TRUE|Dir=Out|RA42=IntErnet|RA62=IntErnet|App=C:\Windows\SystemApps\Microsoft.Windows.Cortana_cw5n1h2txyewy\RemindersShareTargetApp.exe|Name=Block Cortana RemindersShareTargetApp.exe|Desc=Block Cortana Outbound UDP/TCP Traffic|" /f >nul 2>&1
	Reg add "HKLM\TK_SYSTEM\ControlSet001\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules" /v "Block Cortana SearchUI.exe" /t REG_SZ /d "v2.26|Action=Block|Active=TRUE|Dir=Out|RA42=IntErnet|RA62=IntErnet|App=C:\Windows\SystemApps\Microsoft.Windows.Cortana_cw5n1h2txyewy\SearchUI.exe|Name=Block Cortana SearchUI.exe|Desc=Block Cortana Outbound UDP/TCP Traffic|" /f >nul 2>&1
)

if "%Tweak%" equ "DisableDownloadsLayout" (
	Reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\{885a186e-a440-4ada-812b-db871b942259}\TopViews\{00000000-0000-0000-0000-000000000000}" /v "GroupBy" /t REG_SZ /d "System.None" /f >nul 2>&1
	Reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\{885a186e-a440-4ada-812b-db871b942259}\TopViews\{00000000-0000-0000-0000-000000000000}" /v "PrimaryProperty" /t REG_SZ /d "System.Name" /f >nul 2>&1
	Reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\{885a186e-a440-4ada-812b-db871b942259}\TopViews\{00000000-0000-0000-0000-000000000000}" /v "SortByList" /t REG_SZ /d "prop:System.Name" /f >nul 2>&1
)

if "%Tweak%" equ "HideChatIcon" (
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\Windows Chat" /v "ChatIcon" /t REG_DWORD /d "3" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarMn" /t REG_DWORD /d "0" /f >nul 2>&1
)

if "%Tweak%" equ "HideCortanaIcon" Reg add "HKLM\TK_NTUSER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowCortanaButton" /t REG_DWORD /d "0" /f >nul 2>&1

if "%Tweak%" equ "HideMeetNowIcon" (
	Reg add "HKLM\TK_NTUSER\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "HideSCAMeetNow" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "HideSCAMeetNow" /t REG_DWORD /d "1" /f >nul 2>&1
)

if "%Tweak%" equ "HideNewsAndInterests" (
	Reg add "HKLM\TK_NTUSER\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds" /v "ShellFeedsTaskbarViewMode" /t REG_DWORD /d "2" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" /v "EnableFeeds" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" /v "HeadlinesOnboardingComplete" /t REG_DWORD /d "0" /f >nul 2>&1
)

if "%Tweak%" equ "HideTaskViewIcon" Reg add "HKLM\TK_NTUSER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowTaskViewButton" /t REG_DWORD /d "0" /f >nul 2>&1
if "%Tweak%" equ "HideSearchBar" Reg add "HKLM\TK_NTUSER\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d "0" /f >nul 2>&1
if "%Tweak%" equ "HideWidgetsIcon" Reg add "HKLM\TK_NTUSER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarDa" /t REG_DWORD /d "0" /f >nul 2>&1

if "%Tweak%" equ "DisableDriversUpdates" (
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\Device Metadata" /v "PreventDeviceMetadataFromNetwork" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\DriverSearching" /v "DontPromptForWindowsUpdate" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\DriverSearching" /v "DontSearchWindowsUpdate" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\DriverSearching" /v "DriverUpdateWizardWuSearchEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\DriverSearching" /v "SearchOrderConfig" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "ExcludeWUDriversInQualityUpdate" /t REG_DWORD /d "1" /f >nul 2>&1
)

if "%Tweak%" equ "Disable3RDPartyApps" (
	Reg add "HKLM\TK_NTUSER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "OemPreInstalledAppsEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "PreInstalledAppsEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SilentInstalledAppsEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v "DisableWindowsConsumerFeatures" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "ContentDeliveryAllowed" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "ContentDeliveryAllowed" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "ContentDeliveryAllowed" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "FeatureManagementEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "PreInstalledAppsEverEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SoftLandingEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContentEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-310093Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338388Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338389Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338393Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-353694Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-353696Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContentEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SystemPaneSuggestionsEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\PushToInstall" /v "DisablePushToInstall" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\MRT" /v "DontOfferThroughWUAU" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg delete "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Subscriptions" /f >nul 2>&1
	Reg delete "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\SuggestedApps" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v "DisableConsumerAccountStateContent" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v "DisableCloudOptimizedContent" /t REG_DWORD /d "1" /f >nul 2>&1

	if "%SelectedSourceOS%" equ "w11" (
		Reg add "HKLM\TK_SOFTWARE\Microsoft\PolicyManager\current\device\Start" /v "ConfigureStartPins" /t REG_SZ /d "{\"pinnedList\": [{}]}" /f >nul 2>&1
		Reg add "HKLM\TK_SOFTWARE\Microsoft\PolicyManager\current\device\Start" /v "ConfigureStartPins_ProviderSet" /t REG_DWORD /d "0" /f >nul 2>&1
	)
)

if "%Tweak%" equ "Disableyc" (
	Reg add "HKLM\zNTUSER\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\zNTUSER\Software\Microsoft\Windows\CurrentVersion\Privacy" /v "TailoredExperiencesWithDiagnosticDataEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\zNTUSER\Software\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy" /v "HasAccepted" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\zNTUSER\Software\Microsoft\Input\TIPC" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\zNTUSER\Software\Microsoft\InputPersonalization" /v "RestrictImplicitInkCollection" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\zNTUSER\Software\Microsoft\InputPersonalization" /v "RestrictImplicitTextCollection" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\zNTUSER\Software\Microsoft\InputPersonalization\TrainedDataStore" /v "HarvestContacts" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\zNTUSER\Software\Microsoft\Personalization\Settings" /v "AcceptedPrivacyPolicy" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\zSOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\zSYSTEM\ControlSet001\Services\dmwappushservice" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
)

if "%Tweak%" equ "DisableTeamsApp" Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows\CurrentVersion\Communications" /v "ConfigureChatAutoInstall" /t REG_DWORD /d "0" /f >nul 2>&1

if "%Tweak%" equ "DisableWindowsDefender" (
	Reg add "HKLM\TK_DEFAULT\SOFTWARE\Microsoft\Windows Security Health\State" /v "AccountProtection_MicrosoftAccount_Disconnected" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\SOFTWARE\Microsoft\Windows Security Health\State" /v "AccountProtection_MicrosoftAccount_Disconnected" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows Defender Security Center\Notifications" /v "DisableEnhancedNotifications" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows Defender Security Center\Notifications" /v "DisableNotifications" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows Defender" /v "DisableAntiSpyware" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows Defender" /v "DisableAntiVirus" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows Defender\Features" /v "TamperProtection" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows Defender\Features" /v "TamperProtectionSource" /t REG_DWORD /d "2" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows Defender\Signature Updates" /v "FirstAuGracePeriod" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows Defender\UX Configuration" /v "DisablePrivacyMode" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "SecurityHealth" /t REG_BINARY /d "030000000000000000000000" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\MRT" /v "DontOfferThroughWUAU" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\MRT" /v "DontReportInfectionInformation" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Systray" /v "HideSystray" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableAntiSpyware" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender" /v "PUAProtection" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender" /v "RandomizeScheduleTaskTimes" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Exclusions" /v "DisableAutoExclusions" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\MpEngine" /v "MpEnablePus" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Quarantine" /v "LocalSettingOverridePurgeItemsAfterDelay" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Quarantine" /v "PurgeItemsAfterDelay" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableBehaviorMonitoring" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableIOAVProtection" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableOnAccessProtection" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableRealtimeMonitoring" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableRoutinelyTakingAction" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableScanOnRealtimeEnable" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableScriptScanning" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Remediation" /v "Scan_ScheduleDay" /t REG_DWORD /d "8" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Remediation" /v "Scan_ScheduleTime" /t REG_DWORD /d 0 /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Reporting" /v "AdditionalActionTimeOut" /t REG_DWORD /d 0 /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Reporting" /v "CriticalFailureTimeOut" /t REG_DWORD /d 0 /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Reporting" /v "DisableEnhancedNotifications" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Reporting" /v "DisableGenericRePorts" /t REG_DWORD /d 1 /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Reporting" /v "NonCriticalTimeOut" /t REG_DWORD /d 0 /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Scan" /v "AvgCPULoadFactor" /t REG_DWORD /d "10" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Scan" /v "DisableArchiveScanning" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Scan" /v "DisableCatchupFullScan" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Scan" /v "DisableCatchupQuickScan" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Scan" /v "DisableRemovableDriveScanning" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Scan" /v "DisableRestorePoint" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Scan" /v "DisableScanningMappedNetworkDrivesForFullScan" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Scan" /v "DisableScanningNetworkFiles" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Scan" /v "PurgeItemsAfterDelay" /t REG_DWORD /d 0 /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Scan" /v "ScanOnlyIfIdle" /t REG_DWORD /d 0 /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Scan" /v "ScanParameters" /t REG_DWORD /d 0 /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Scan" /v "ScheduleDay" /t REG_DWORD /d 8 /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Scan" /v "ScheduleTime" /t REG_DWORD /d 0 /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Signature Updates" /v "DisableUpdateOnStartupWithoutEngine" /t REG_DWORD /d 1 /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Signature Updates" /v "ScheduleDay" /t REG_DWORD /d 8 /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Signature Updates" /v "ScheduleTime" /t REG_DWORD /d 0 /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Signature Updates" /v "SignatureUpdateCatchupInterval" /t REG_DWORD /d 0 /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\SpyNet" /v "DisableBlockAtFirstSeen" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v "LocalSettingOverrideSpynetReporting" /t REG_DWORD /d 0 /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v "SpyNetReporting" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v "SpyNetReportingLocation" /t REG_MULTI_SZ /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v "SubmitSamplesConsent" /t REG_DWORD /d "2" /f >nul 2>&1
	if "%SelectedSourceOS%" equ "w11" Reg add "HKLM\TK_SYSTEM\ControlSet001\Control\CI\Policy" /v "VerifiedAndReputablePolicyState" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SYSTEM\ControlSet001\Services\EventLog\System\Microsoft-Antimalware-ShieldProvider" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
	Reg add "HKLM\TK_SYSTEM\ControlSet001\Services\EventLog\System\WinDefend" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
	Reg add "HKLM\TK_SYSTEM\ControlSet001\Services\MsSecFlt" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
	Reg add "HKLM\TK_SYSTEM\ControlSet001\Services\SecurityHealthService" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
	Reg add "HKLM\TK_SYSTEM\ControlSet001\Services\Sense" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
	Reg add "HKLM\TK_SYSTEM\ControlSet001\Services\WdBoot" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
	Reg add "HKLM\TK_SYSTEM\ControlSet001\Services\WdFilter" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
	Reg add "HKLM\TK_SYSTEM\ControlSet001\Services\WdNisDrv" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
	Reg add "HKLM\TK_SYSTEM\ControlSet001\Services\WdNisSvc" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
	Reg add "HKLM\TK_SYSTEM\ControlSet001\Services\WinDefend" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
	Reg add "HKLM\TK_SYSTEM\ControlSet001\Control\WMI\Autologger\DefenderApiLogger" /v "Start" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SYSTEM\ControlSet001\Control\WMI\Autologger\DefenderAuditLogger" /v "Start" /t REG_DWORD /d "0" /f >nul 2>&1
)

if "%Tweak%" equ "DisableWindowsFirewall" (
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile" /v "EnableFirewall" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile" /v "EnableFirewall" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile" /v "EnableFirewall" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\WindowsFirewall\StandardProfile" /v "EnableFirewall" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" /v "DisableFirewall" /t REG_SZ /d "%%windir%%\System32\netsh.exe advfirewall set allprofiles state off" /f >nul 2>&1
)

if "%Tweak%" equ "DisableWindowsSmartScreen" (
	Reg add "HKLM\TK_DEFAULT\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" /v "EnableWebContentEvaluation" /t REG_DWORD /d 0 /f >nul 2>&1
	Reg add "HKLM\TK_DEFAULT\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" /v "PreventOverride" /t REG_DWORD /d 0 /f >nul 2>&1
	Reg add "HKLM\TK_DEFAULT\SOFTWARE\Policies\Microsoft\Edge" /v "SmartScreenEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" /v "EnableWebContentEvaluation" /t REG_DWORD /d 0 /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" /v "PreventOverride" /t REG_DWORD /d 0 /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\SOFTWARE\Policies\Microsoft\Edge" /v "SmartScreenEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows Security Health\State" /v "AppAndBrowser_StoreAppsSmartScreenOff" /t REG_DWORD /d 0 /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" /v "SmartScreenEnabled" /t REG_SZ /d "Off" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "SmartScreenEnabled" /t REG_SZ /d "Off" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Internet Explorer\PhishingFilter" /v "EnabledV9" /t REG_DWORD /d 0 /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Internet Explorer\PhishingFilter" /v "PreventOverride" /t REG_DWORD /d 0 /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\MicrosoftEdge\PhishingFilter" /v "EnabledV9" /t REG_DWORD /d 0 /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\MicrosoftEdge\PhishingFilter" /v "PreventOverride" /t REG_DWORD /d 0 /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\System" /v "EnableSmartScreen" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\SmartScreen" /v "ConfigureAppInstallControl" /t REG_SZ /d "Anywhere" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\SmartScreen" /v "ConfigureAppInstallControlEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
)

if "%Tweak%" equ "DisableWindowsUpgrade" (
	if "%SelectedSourceOS%" neq "w10" if "%SelectedSourceOS%" neq "w11" (
		Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\Gwx" /v "DisableGwx" /t REG_DWORD /d "1" /f >nul 2>&1
		Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DisableOSUpgrade" /t REG_DWORD /d "1" /f >nul 2>&1
	)

	if "%SelectedSourceOS%" neq "w7" if "%SelectedSourceOS%" neq "w81" (
		Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "AUOptions" /t REG_DWORD /d "2" /f >nul 2>&1
		Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoUpdate" /t REG_DWORD /d "1" /f >nul 2>&1
		Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DeferUpdatePeriod" /t REG_DWORD /d "1" /f >nul 2>&1
		Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DeferUpgrade" /t REG_DWORD /d "1" /f >nul 2>&1
		Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DeferUpgradePeriod" /t REG_DWORD /d "1" /f >nul 2>&1
		Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "TargetReleaseVersion" /t REG_DWORD /d "1" /f >nul 2>&1
		if "%ImageBuild%" geq "17134" if "%ImageBuild%" leq "20348" Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "ProductVersion" /t REG_SZ /d "Windows 10" /f >nul 2>&1
		if "%ImageBuild%" equ "17134" Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "TargetReleaseVersionInfo" /t REG_SZ /d "1803" /f >nul 2>&1
		if "%ImageBuild%" equ "17763" Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "TargetReleaseVersionInfo" /t REG_SZ /d "1809" /f >nul 2>&1
		if "%ImageBuild%" equ "18362" Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "TargetReleaseVersionInfo" /t REG_SZ /d "1903" /f >nul 2>&1
		if "%ImageBuild%" equ "18363" Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "TargetReleaseVersionInfo" /t REG_SZ /d "1909" /f >nul 2>&1
		if "%ImageBuild%" equ "19041" Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "TargetReleaseVersionInfo" /t REG_SZ /d "2004" /f >nul 2>&1
		if "%ImageBuild%" equ "19042" Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "TargetReleaseVersionInfo" /t REG_SZ /d "2009" /f >nul 2>&1
		if "%ImageBuild%" equ "19043" Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "TargetReleaseVersionInfo" /t REG_SZ /d "21H1" /f >nul 2>&1
		if "%ImageBuild%" equ "19044" Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "TargetReleaseVersionInfo" /t REG_SZ /d "21H2" /f >nul 2>&1
		if "%ImageBuild%" equ "19045" Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "TargetReleaseVersionInfo" /t REG_SZ /d "22H2" /f >nul 2>&1
		if "%ImageBuild%" equ "20348" Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "TargetReleaseVersionInfo" /t REG_SZ /d "21H2" /f >nul 2>&1
		if "%ImageBuild%" equ "22000" Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "TargetReleaseVersionInfo" /t REG_SZ /d "21H2" /f >nul 2>&1
		if "%ImageBuild%" geq "22621" if "%ImageBuild%" leq "22631" Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "TargetReleaseVersionInfo" /t REG_SZ /d "22H2" /f >nul 2>&1
	)
)

if "%Tweak%" equ "DisableWindowsUpdate" (
	Reg add "HKLM\TK_NTUSER\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization" /v "SystemSettingsDownloadMode" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Speech_OneCore\Preferences" /v "ModelDownloadAllowed" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization" /v "OptInOOBE" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" /v "DODownloadMode" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsStore\WindowsUpdate" /v "AutoDownload" /t REG_DWORD /d "5" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Services\7971f918-a847-4430-9279-4a52d1efe18d" /v "RegisteredWithAU" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-DeviceUpdateAgent/Operational" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-WindowsUpdateClient/Operational" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v "HideMCTLink" /t REG_DWORD /d "1" /f >nul 2>&1

	if "%ImageDefaultLanguage%" equ "zh-CN" Reg add "HKLM\TK_SOFTWARE\Microsoft\LexiconUpdate\loc_0804" /v "HapDownloadEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	if "%ImageDefaultLanguage%" equ "zh-HK" Reg add "HKLM\TK_SOFTWARE\Microsoft\LexiconUpdate\loc_0804" /v "HapDownloadEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	if "%ImageDefaultLanguage%" equ "zh-TW" Reg add "HKLM\TK_SOFTWARE\Microsoft\LexiconUpdate\loc_0804" /v "HapDownloadEnabled" /t REG_DWORD /d "0" /f >nul 2>&1

	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Speech" /v "AllowSpeechModelUpdate" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /v "DODownloadMode" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DoNotConnectToWindowsUpdateInternetLocations" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DisableWindowsUpdateAccess" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "WUServer" /t REG_SZ /d " " /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "WUStatusServer" /t REG_SZ /d " " /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "UpdateServiceUrlAlternate" /t REG_SZ /d " " /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "AUOptions" /t REG_DWORD /d "2" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoUpdate" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "UseWUServer" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SYSTEM\ControlSet001\Services\wuauserv" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
)

if "%Tweak%" equ "DisableReservedStorage" Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows\CurrentVersion\ReserveManager" /v "ShippedWithReserves" /t REG_DWORD /d "0" /f >nul 2>&1
if "%Tweak%" equ "ForceLatestNetFramework" Reg add "HKLM\TK_SOFTWARE\Microsoft\.NETFramework" /v "OnlyUseLatestCLR" /t REG_DWORD /d "1" /f >nul 2>&1
if "%Tweak%" equ "EnableLocalAccount" Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" /v "BypassNRO" /t REG_DWORD /d "1" /f >nul 2>&1

if "%Tweak%" equ "EnablePhotoViewer" (
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\ApplicationAssociationToasts" /v "emffile_.emf" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\ApplicationAssociationToasts" /v "rlefile_.rle" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\ApplicationAssociationToasts" /v "wmffile_.wmf" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer" /v "GlobalAssocChangedCounter" /t REG_DWORD /d "13" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.bmp\OpenWithList" /v "a" /t REG_SZ /d "PhotoViewer.dll" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.bmp\OpenWithList" /v "MRUList" /t REG_SZ /d "a" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.bmp\UserChoice" /v "Hash" /t REG_SZ /d "TDU75KWAGi4=" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.bmp\UserChoice" /v "ProgId" /t REG_SZ /d "PhotoViewer.FileAssoc.Bitmap" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.dib\OpenWithList" /v "a" /t REG_SZ /d "PhotoViewer.dll" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.dib\OpenWithList" /v "MRUList" /t REG_SZ /d "a" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.dib\UserChoice" /v "Hash" /t REG_SZ /d "hAQpLYJfRYE=" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.dib\UserChoice" /v "ProgId" /t REG_SZ /d "PhotoViewer.FileAssoc.Bitmap" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.gif\OpenWithList" /v "a" /t REG_SZ /d "PhotoViewer.dll" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.gif\OpenWithList" /v "MRUList" /t REG_SZ /d "a" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.gif\UserChoice" /v "Hash" /t REG_SZ /d "1in4hcmDrB4=" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.gif\UserChoice" /v "ProgId" /t REG_SZ /d "PhotoViewer.FileAssoc.Gif" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jfif\OpenWithList" /v "a" /t REG_SZ /d "PhotoViewer.dll" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jfif\OpenWithList" /v "MRUList" /t REG_SZ /d "a" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jfif\UserChoice" /v "Hash" /t REG_SZ /d "Y5upkzp3g5E=" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jfif\UserChoice" /v "ProgId" /t REG_SZ /d "PhotoViewer.FileAssoc.JFIF" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jpe\OpenWithList" /v "a" /t REG_SZ /d "PhotoViewer.dll" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jpe\OpenWithList" /v "MRUList" /t REG_SZ /d "a" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jpe\UserChoice" /v "Hash" /t REG_SZ /d "ZIeqfdrNtFk=" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jpe\UserChoice" /v "ProgId" /t REG_SZ /d "PhotoViewer.FileAssoc.Jpeg" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jpeg\OpenWithList" /v "a" /t REG_SZ /d "PhotoViewer.dll" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jpeg\OpenWithList" /v "MRUList" /t REG_SZ /d "a" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jpeg\UserChoice" /v "Hash" /t REG_SZ /d "iVWM3EAePKw=" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jpeg\UserChoice" /v "ProgId" /t REG_SZ /d "PhotoViewer.FileAssoc.Jpeg" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jpg\OpenWithList" /v "a" /t REG_SZ /d "PhotoViewer.dll" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jpg\OpenWithList" /v "MRUList" /t REG_SZ /d "a" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jpg\UserChoice" /v "Hash" /t REG_SZ /d "Xq9gH4jXoFM=" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jpg\UserChoice" /v "ProgId" /t REG_SZ /d "PhotoViewer.FileAssoc.Jpeg" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jxr\OpenWithList" /v "a" /t REG_SZ /d "PhotoViewer.dll" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jxr\OpenWithList" /v "MRUList" /t REG_SZ /d "a" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jxr\UserChoice" /v "Hash" /t REG_SZ /d "ahz7f/Yl09M=" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jxr\UserChoice" /v "ProgId" /t REG_SZ /d "PhotoViewer.FileAssoc.Wdp" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.png\OpenWithList" /v "a" /t REG_SZ /d "PhotoViewer.dll" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.png\OpenWithList" /v "MRUList" /t REG_SZ /d "a" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.png\UserChoice" /v "Hash" /t REG_SZ /d "Evm7jp++AWA=" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.png\UserChoice" /v "ProgId" /t REG_SZ /d "PhotoViewer.FileAssoc.Png" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.tif\OpenWithList" /v "a" /t REG_SZ /d "PhotoViewer.dll" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.tif\OpenWithList" /v "MRUList" /t REG_SZ /d "a" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.tif\UserChoice" /v "Hash" /t REG_SZ /d "wEj9gLqtYH4=" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.tif\UserChoice" /v "ProgId" /t REG_SZ /d "TIFImage.Document" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.tiff\OpenWithList" /v "a" /t REG_SZ /d "PhotoViewer.dll" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.tiff\OpenWithList" /v "MRUList" /t REG_SZ /d "a" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.tiff\UserChoice" /v "Hash" /t REG_SZ /d "/r2V12Yryig=" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.tiff\UserChoice" /v "ProgId" /t REG_SZ /d "TIFImage.Document" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.wdp\OpenWithList" /v "a" /t REG_SZ /d "PhotoViewer.dll" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.wdp\OpenWithList" /v "MRUList" /t REG_SZ /d "a" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.wdp\UserChoice" /v "Hash" /t REG_SZ /d "/qcrPB0bhuI=" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.wdp\UserChoice" /v "ProgId" /t REG_SZ /d "PhotoViewer.FileAssoc.Wdp" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\Roaming\OpenWith\FileExts\.bmp\UserChoice" /v "Hash" /t REG_SZ /d "rEigxhAPyos=" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\Roaming\OpenWith\FileExts\.bmp\UserChoice" /v "ProgId" /t REG_SZ /d "PhotoViewer.FileAssoc.Bitmap" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\Roaming\OpenWith\FileExts\.dib\UserChoice" /v "Hash" /t REG_SZ /d "R60f5QZs3Hg=" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\Roaming\OpenWith\FileExts\.dib\UserChoice" /v "ProgId" /t REG_SZ /d "PhotoViewer.FileAssoc.Bitmap" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\Roaming\OpenWith\FileExts\.gif\UserChoice" /v "Hash" /t REG_SZ /d "YcQO9pssSPU=" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\Roaming\OpenWith\FileExts\.gif\UserChoice" /v "ProgId" /t REG_SZ /d "PhotoViewer.FileAssoc.Gif" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\Roaming\OpenWith\FileExts\.jfif\UserChoice" /v "Hash" /t REG_SZ /d "5yjvWKb+Jns=" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\Roaming\OpenWith\FileExts\.jfif\UserChoice" /v "ProgId" /t REG_SZ /d "PhotoViewer.FileAssoc.JFIF" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\Roaming\OpenWith\FileExts\.jpe\UserChoice" /v "Hash" /t REG_SZ /d "TujD2rCi+po=" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\Roaming\OpenWith\FileExts\.jpe\UserChoice" /v "ProgId" /t REG_SZ /d "PhotoViewer.FileAssoc.Jpeg" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\Roaming\OpenWith\FileExts\.jpeg\UserChoice" /v "Hash" /t REG_SZ /d "wdZ9wQI4vW8=" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\Roaming\OpenWith\FileExts\.jpeg\UserChoice" /v "ProgId" /t REG_SZ /d "PhotoViewer.FileAssoc.Jpeg" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\Roaming\OpenWith\FileExts\.jpg\UserChoice" /v "Hash" /t REG_SZ /d "3xY0V0JOiFc=" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\Roaming\OpenWith\FileExts\.jpg\UserChoice" /v "ProgId" /t REG_SZ /d "PhotoViewer.FileAssoc.Jpeg" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\Roaming\OpenWith\FileExts\.jxr\UserChoice" /v "Hash" /t REG_SZ /d "ENXEd5Uzg84=" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\Roaming\OpenWith\FileExts\.jxr\UserChoice" /v "ProgId" /t REG_SZ /d "PhotoViewer.FileAssoc.Wdp" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\Roaming\OpenWith\FileExts\.png\UserChoice" /v "Hash" /t REG_SZ /d "SPesrUKrIFE=" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\Roaming\OpenWith\FileExts\.png\UserChoice" /v "ProgId" /t REG_SZ /d "PhotoViewer.FileAssoc.Png" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\Roaming\OpenWith\FileExts\.tif\UserChoice" /v "Hash" /t REG_SZ /d "bCXQRSAHD/I=" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\Roaming\OpenWith\FileExts\.tif\UserChoice" /v "ProgId" /t REG_SZ /d "TIFImage.Document" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\Roaming\OpenWith\FileExts\.tiff\UserChoice" /v "Hash" /t REG_SZ /d "7F/LfjhVnes=" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\Roaming\OpenWith\FileExts\.tiff\UserChoice" /v "ProgId" /t REG_SZ /d "TIFImage.Document" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\Roaming\OpenWith\FileExts\.wdp\UserChoice" /v "Hash" /t REG_SZ /d "tu0JqOen+Es=" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\Roaming\OpenWith\FileExts\.wdp\UserChoice" /v "ProgId" /t REG_SZ /d "PhotoViewer.FileAssoc.Wdp" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\Applications\photoviewer.dll\shell\open" /v "MuiVerb" /t REG_SZ /d "@photoviewer.dll,-3043" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\Applications\photoviewer.dll\shell\open\command" /ve /t REG_EXPAND_SZ /d "%%SystemRoot%%\System32\rundll32.exe \"%%ProgramFiles%%\Windows Photo Viewer\PhotoViewer.dll\", ImageView_Fullscreen %%1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\Applications\photoviewer.dll\shell\open\DropTarget" /v "Clsid" /t REG_SZ /d "{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\Applications\photoviewer.dll\shell\print\command" /ve /t REG_EXPAND_SZ /d "%%SystemRoot%%\System32\rundll32.exe \"%%ProgramFiles%%\Windows Photo Viewer\PhotoViewer.dll\", ImageView_Fullscreen %%1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\Applications\photoviewer.dll\shell\print\DropTarget" /v "Clsid" /t REG_SZ /d "{60fd46de-f830-4894-a628-6fa81bc0190d}" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Bitmap" /v "FriendlyTypeName" /t REG_EXPAND_SZ /d "@%%ProgramFiles%%\Windows Photo Viewer\PhotoViewer.dll,-3056" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Bitmap" /v "ImageOptionFlags" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Bitmap\DefaultIcon" /ve /t REG_SZ /d "%%SystemRoot%%\System32\imageres.dll,-70" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Bitmap\shell\open\command" /ve /t REG_EXPAND_SZ /d "%%SystemRoot%%\System32\rundll32.exe \"%%ProgramFiles%%\Windows Photo Viewer\PhotoViewer.dll\", ImageView_Fullscreen %%1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Bitmap\shell\open\DropTarget" /v "Clsid" /t REG_SZ /d "{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Gif" /v "FriendlyTypeName" /t REG_EXPAND_SZ /d "@%%ProgramFiles%%\Windows Photo Viewer\PhotoViewer.dll,-3057" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Gif" /v "ImageOptionFlags" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Gif\DefaultIcon" /ve /t REG_SZ /d "%%SystemRoot%%\System32\imageres.dll,-83" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Gif\shell\open\command" /ve /t REG_EXPAND_SZ /d "%%SystemRoot%%\System32\rundll32.exe \"%%ProgramFiles%%\Windows Photo Viewer\PhotoViewer.dll\", ImageView_Fullscreen %%1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Gif\shell\open\DropTarget" /v "Clsid" /t REG_SZ /d "{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.JFIF" /v "EditFlags" /t REG_DWORD /d "65536" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.JFIF" /v "FriendlyTypeName" /t REG_EXPAND_SZ /d "@%%ProgramFiles%%\Windows Photo Viewer\PhotoViewer.dll,-3055" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.JFIF" /v "ImageOptionFlags" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.JFIF\DefaultIcon" /ve /t REG_SZ /d "%%SystemRoot%%\System32\imageres.dll,-72" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.JFIF\shell\open" /v "MuiVerb" /t REG_EXPAND_SZ /d "@%%ProgramFiles%%\Windows Photo Viewer\photoviewer.dll,-3043" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.JFIF\shell\open\command" /ve /t REG_EXPAND_SZ /d "%%SystemRoot%%\System32\rundll32.exe \"%%ProgramFiles%%\Windows Photo Viewer\PhotoViewer.dll\", ImageView_Fullscreen %%1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.JFIF\shell\open\DropTarget" /v "Clsid" /t REG_SZ /d "{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Jpeg" /v "EditFlags" /t REG_DWORD /d "65536" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Jpeg" /v "FriendlyTypeName" /t REG_EXPAND_SZ /d "@%%ProgramFiles%%\Windows Photo Viewer\PhotoViewer.dll,-3055" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Jpeg" /v "ImageOptionFlags" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Jpeg\DefaultIcon" /ve /t REG_SZ /d "%%SystemRoot%%\System32\imageres.dll,-72" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Jpeg\shell\open" /v "MuiVerb" /t REG_EXPAND_SZ /d "@%%ProgramFiles%%\Windows Photo Viewer\photoviewer.dll,-3043" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Jpeg\shell\open\command" /ve /t REG_EXPAND_SZ /d "%%SystemRoot%%\System32\rundll32.exe \"%%ProgramFiles%%\Windows Photo Viewer\PhotoViewer.dll\", ImageView_Fullscreen %%1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Jpeg\shell\open\DropTarget" /v "Clsid" /t REG_SZ /d "{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Png" /v "FriendlyTypeName" /t REG_EXPAND_SZ /d "@%%ProgramFiles%%\Windows Photo Viewer\PhotoViewer.dll,-3057" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Png" /v "ImageOptionFlags" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Png\DefaultIcon" /ve /t REG_SZ /d "%%SystemRoot%%\System32\imageres.dll,-71" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Png\shell\open\command" /ve /t REG_EXPAND_SZ /d "%%SystemRoot%%\System32\rundll32.exe \"%%ProgramFiles%%\Windows Photo Viewer\PhotoViewer.dll\", ImageView_Fullscreen %%1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Png\shell\open\DropTarget" /v "Clsid" /t REG_SZ /d "{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Tiff" /v "FriendlyTypeName" /t REG_EXPAND_SZ /d "@%%ProgramFiles%%\Windows Photo Viewer\PhotoViewer.dll,-3058" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Tiff" /v "ImageOptionFlags" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Tiff\DefaultIcon" /ve /t REG_SZ /d "%%SystemRoot%%\System32\imageres.dll,-122" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Tiff\shell\open" /v "MuiVerb" /t REG_EXPAND_SZ /d "@%%ProgramFiles%%\Windows Photo Viewer\photoviewer.dll,-3043" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Tiff\shell\open\command" /ve /t REG_EXPAND_SZ /d "%%SystemRoot%%\System32\rundll32.exe \"%%ProgramFiles%%\Windows Photo Viewer\PhotoViewer.dll\", ImageView_Fullscreen %%1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Tiff\shell\open\DropTarget" /v "Clsid" /t REG_SZ /d "{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Wdp" /v "EditFlags" /t REG_DWORD /d "65536" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Wdp" /v "ImageOptionFlags" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Wdp\DefaultIcon" /ve /t REG_SZ /d "%%SystemRoot%%\System32\wmphoto.dll,-400" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Wdp\shell\open" /v "MuiVerb" /t REG_EXPAND_SZ /d "@%%ProgramFiles%%\Windows Photo Viewer\photoviewer.dll,-3043" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Wdp\shell\open\command" /ve /t REG_EXPAND_SZ /d "%%SystemRoot%%\System32\rundll32.exe \"%%ProgramFiles%%\Windows Photo Viewer\PhotoViewer.dll\", ImageView_Fullscreen %%1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Wdp\shell\open\DropTarget" /v "Clsid" /t REG_SZ /d "{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities" /v "ApplicationDescription" /t REG_SZ /d "@%%ProgramFiles%%\Windows Photo Viewer\photoviewer.dll,-3069" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities" /v "ApplicationName" /t REG_SZ /d "@%%ProgramFiles%%\Windows Photo Viewer\photoviewer.dll,-3009" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations" /v ".bmp" /t REG_SZ /d "PhotoViewer.FileAssoc.Bitmap" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations" /v ".dib" /t REG_SZ /d "PhotoViewer.FileAssoc.Bitmap" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations" /v ".gif" /t REG_SZ /d "PhotoViewer.FileAssoc.Gif" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations" /v ".jfif" /t REG_SZ /d "PhotoViewer.FileAssoc.JFIF" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations" /v ".jpe" /t REG_SZ /d "PhotoViewer.FileAssoc.Jpeg" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations" /v ".jpeg" /t REG_SZ /d "PhotoViewer.FileAssoc.Jpeg" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations" /v ".jpg" /t REG_SZ /d "PhotoViewer.FileAssoc.Jpeg" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations" /v ".jxr" /t REG_SZ /d "PhotoViewer.FileAssoc.Wdp" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations" /v ".png" /t REG_SZ /d "PhotoViewer.FileAssoc.Png" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations" /v ".tif" /t REG_SZ /d "PhotoViewer.FileAssoc.Tiff" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations" /v ".tiff" /t REG_SZ /d "PhotoViewer.FileAssoc.Tiff" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations" /v ".wdp" /t REG_SZ /d "PhotoViewer.FileAssoc.Wdp" /f >nul 2>&1
)

if "%Tweak%" equ "EnableClassicContextMenu" Reg add "HKLM\TK_SOFTWARE\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /ve /f >nul 2>&1

if "%Tweak%" equ "EnableFMP3ProCodec" (
	Reg delete "HKLM\TK_SOFTWARE\Microsoft\Windows NT\CurrentVersion\drivers.desc" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows NT\CurrentVersion\drivers.desc" /v "%%SystemRoot%%\System32\l3codecp.acm" /t REG_SZ /d "Fraunhofer IIS MPEG Layer-3 Codec (Professional)" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows NT\CurrentVersion\Drivers32" /v "msacm.l3acm" /t REG_EXPAND_SZ /d "%%SystemRoot%%\System32\l3codecp.acm" /f >nul 2>&1

	if "%ImageArchitecture%" equ "x64" (
		Reg delete "HKLM\TK_SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\drivers.desc" /f >nul 2>&1
		Reg add "HKLM\TK_SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\drivers.desc" /v "%%SystemRoot%%\SysWOW64\l3codecp.acm" /t REG_SZ /d "Fraunhofer IIS MPEG Layer-3 Codec (Professional)" /f >nul 2>&1
		Reg add "HKLM\TK_SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Drivers32" /v "msacm.l3acm" /t REG_EXPAND_SZ /d "%%SystemRoot%%\SysWOW64\l3codecp.acm" /f >nul 2>&1
	)
)

if "%Tweak%" equ "EnableFullResetBase" Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows\CurrentVersion\SideBySide\Configuration" /v "DisableResetbase" /t REG_DWORD /d "0" /f >nul 2>&1
if "%Tweak%" equ "SetTaskbarAlignLeft" Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarAl" /t REG_DWORD /d "0" /f >nul 2>&1

if "%Tweak%" equ "AllTweaks" (
		Reg add "HKLM\zNTUSER\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
		Reg add "HKLM\zNTUSER\Software\Microsoft\Windows\CurrentVersion\Privacy" /v "TailoredExperiencesWithDiagnosticDataEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
		Reg add "HKLM\zNTUSER\Software\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy" /v "HasAccepted" /t REG_DWORD /d "0" /f >nul 2>&1
		Reg add "HKLM\zNTUSER\Software\Microsoft\Input\TIPC" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
		Reg add "HKLM\zNTUSER\Software\Microsoft\InputPersonalization" /v "RestrictImplicitInkCollection" /t REG_DWORD /d "1" /f >nul 2>&1
		Reg add "HKLM\zNTUSER\Software\Microsoft\InputPersonalization" /v "RestrictImplicitTextCollection" /t REG_DWORD /d "1" /f >nul 2>&1
		Reg add "HKLM\zNTUSER\Software\Microsoft\InputPersonalization\TrainedDataStore" /v "HarvestContacts" /t REG_DWORD /d "0" /f >nul 2>&1
		Reg add "HKLM\zNTUSER\Software\Microsoft\Personalization\Settings" /v "AcceptedPrivacyPolicy" /t REG_DWORD /d "0" /f >nul 2>&1
		Reg add "HKLM\zSOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "0" /f >nul 2>&1
		Reg add "HKLM\zSYSTEM\ControlSet001\Services\dmwappushservice" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
	
	if "%SelectedSourceOS%" equ "w11" (
		Reg add "HKLM\TK_DEFAULT\Control Panel\UnsupportedHardwareNotificationCache" /v "SV1" /t REG_DWORD /d "0" /f >nul 2>&1
		Reg add "HKLM\TK_DEFAULT\Control Panel\UnsupportedHardwareNotificationCache" /v "SV2" /t REG_DWORD /d "0" /f >nul 2>&1
		Reg add "HKLM\TK_NTUSER\Control Panel\UnsupportedHardwareNotificationCache" /v "SV1" /t REG_DWORD /d "0" /f >nul 2>&1
		Reg add "HKLM\TK_NTUSER\Control Panel\UnsupportedHardwareNotificationCache" /v "SV2" /t REG_DWORD /d "0" /f >nul 2>&1
		Reg add "HKLM\TK_SYSTEM\Setup\LabConfig" /v "BypassCPUCheck" /t REG_DWORD /d "1" /f >nul 2>&1
		Reg add "HKLM\TK_SYSTEM\Setup\LabConfig" /v "BypassRAMCheck" /t REG_DWORD /d "1" /f >nul 2>&1
		Reg add "HKLM\TK_SYSTEM\Setup\LabConfig" /v "BypassSecureBootCheck" /t REG_DWORD /d "1" /f >nul 2>&1
		Reg add "HKLM\TK_SYSTEM\Setup\LabConfig" /v "BypassStorageCheck" /t REG_DWORD /d "1" /f >nul 2>&1
		Reg add "HKLM\TK_SYSTEM\Setup\LabConfig" /v "BypassTPMCheck" /t REG_DWORD /d "1" /f >nul 2>&1
		Reg add "HKLM\TK_SYSTEM\Setup\MoSetup" /v "AllowUpgradesWithUnsupportedTPMOrCPU" /t REG_DWORD /d "1" /f >nul 2>&1
	)

	if "%SelectedSourceOS%" neq "w7" if "%SelectedSourceOS%" neq "w81" (
		Reg add "HKLM\TK_DEFAULT\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" /v "HarvestContacts" /t REG_DWORD /d "0" /f >nul 2>&1
		Reg add "HKLM\TK_DEFAULT\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "DeviceHistoryEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
		Reg add "HKLM\TK_DEFAULT\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "HistoryViewEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
		Reg add "HKLM\TK_DEFAULT\SOFTWARE\Microsoft\Windows\CurrentVersion\Windows Search" /v "CortanaConsent" /t REG_DWORD /d "0" /f >nul 2>&1
		Reg add "HKLM\TK_DEFAULT\SOFTWARE\Microsoft\Windows\CurrentVersion\Windows Search" /v "CortanaIsReplaceable" /t REG_DWORD /d "1" /f >nul 2>&1
		Reg add "HKLM\TK_DEFAULT\SOFTWARE\Microsoft\Windows\CurrentVersion\Windows Search" /v "CortanaIsReplaced" /t REG_DWORD /d "1" /f >nul 2>&1
		Reg add "HKLM\TK_DEFAULT\SOFTWARE\Microsoft\Windows\CurrentVersion\Windows Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d "0" /f >nul 2>&1
		Reg add "HKLM\TK_DEFAULT\SOFTWARE\Policies\Microsoft\InputPersonalization" /v "RestrictImplicitInkCollection" /t REG_DWORD /d "1" /f >nul 2>&1
		Reg add "HKLM\TK_DEFAULT\SOFTWARE\Policies\Microsoft\InputPersonalization" /v "RestrictImplicitTextCollection" /t REG_DWORD /d "1" /f >nul 2>&1
		Reg add "HKLM\TK_NTUSER\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\ServiceUI" /v "EnableCortana" /t REG_DWORD /d "0" /f >nul 2>&1
		Reg add "HKLM\TK_NTUSER\SOFTWARE\Microsoft\InputPersonalization" /v "RestrictImplicitInkCollection" /t REG_DWORD /d "1" /f >nul 2>&1
		Reg add "HKLM\TK_NTUSER\SOFTWARE\Microsoft\InputPersonalization" /v "RestrictImplicitTextCollection" /t REG_DWORD /d "1" /f >nul 2>&1
		Reg add "HKLM\TK_NTUSER\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" /v "HarvestContacts" /t REG_DWORD /d "0" /f >nul 2>&1
		Reg add "HKLM\TK_NTUSER\SOFTWARE\Microsoft\Personalization\Settings" /v "AcceptedPrivacyPolicy" /t REG_DWORD /d "0" /f >nul 2>&1
		Reg add "HKLM\TK_NTUSER\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "DeviceHistoryEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
		Reg add "HKLM\TK_NTUSER\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "HistoryViewEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
		Reg add "HKLM\TK_NTUSER\SOFTWARE\Microsoft\Windows\CurrentVersion\Windows Search" /v "CortanaConsent" /t REG_DWORD /d "0" /f >nul 2>&1
		Reg add "HKLM\TK_NTUSER\SOFTWARE\Microsoft\Windows\CurrentVersion\Windows Search" /v "CortanaIsReplaceable" /t REG_DWORD /d "1" /f >nul 2>&1
		Reg add "HKLM\TK_NTUSER\SOFTWARE\Microsoft\Windows\CurrentVersion\Windows Search" /v "CortanaIsReplaced" /t REG_DWORD /d "1" /f >nul 2>&1
		Reg add "HKLM\TK_NTUSER\SOFTWARE\Microsoft\Windows\CurrentVersion\Windows Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d "0" /f >nul 2>&1
		Reg add "HKLM\TK_SOFTWARE\Microsoft\PolicyManager\current\device\AboveLock" /v "AllowCortanaAboveLock" /t REG_DWORD /d "0" /f >nul 2>&1
		Reg add "HKLM\TK_SOFTWARE\Microsoft\PolicyManager\current\device\Experience" /v "AllowCortana" /t REG_DWORD /d "0" /f >nul 2>&1
		Reg add "HKLM\TK_SOFTWARE\Microsoft\Speech_OneCore\Preferences" /v "ModelDownloadAllowed" /t REG_DWORD /d "0" /f >nul 2>&1
		Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d "1" /f >nul 2>&1
		Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\InputPersonalization" /v "AllowInputPersonalization" /t REG_DWORD /d "0" /f >nul 2>&1
		Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCloudSearch" /t REG_DWORD /d "0" /f >nul 2>&1
		Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCortana" /t REG_DWORD /d "0" /f >nul 2>&1
		Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCortanaAboveLock" /t REG_DWORD /d "0" /f >nul 2>&1
		Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowSearchToUseLocation" /t REG_DWORD /d "0" /f >nul 2>&1
		Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "ConnectedSearchPrivacy" /t REG_DWORD /d "3" /f >nul 2>&1
		Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "ConnectedSearchSafeSearch" /t REG_DWORD /d "3" /f >nul 2>&1
		Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "ConnectedSearchUseWeb" /t REG_DWORD /d "0" /f >nul 2>&1
		Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "ConnectedSearchUseWebOverMeteredConnections" /t REG_DWORD /d "0" /f >nul 2>&1
		Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "DisableWebSearch" /t REG_DWORD /d "1" /f >nul 2>&1
		Reg add "HKLM\TK_SOFTWARE\Policies\Wow6432Node\Microsoft\Windows\Windows Search" /v "AllowCortana" /t REG_DWORD /d "0" /f >nul 2>&1
		Reg add "HKLM\TK_SOFTWARE\Policies\Wow6432Node\Microsoft\Windows\Windows Search" /v "AllowCortanaAboveLock" /t REG_DWORD /d "0" /f >nul 2>&1
		Reg add "HKLM\TK_SYSTEM\ControlSet001\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules" /v "Block Cortana ActionUriServer.exe" /t REG_SZ /d "v2.26|Action=Block|Active=TRUE|Dir=Out|RA42=IntErnet|RA62=IntErnet|App=C:\Windows\SystemApps\Microsoft.Windows.Cortana_cw5n1h2txyewy\ActionUriServer.exe|Name=Block Cortana ActionUriServer.exe|Desc=Block Cortana Outbound UDP/TCP Traffic|" /f >nul 2>&1
		Reg add "HKLM\TK_SYSTEM\ControlSet001\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules" /v "Block Cortana Package" /t REG_SZ /d "v2.26|Action=Block|Active=TRUE|Dir=Out|RA42=IntErnet|RA62=IntErnet|Name=Block Cortana Package|Desc=Block Cortana Outbound UDP/TCP Traffic|AppPkgId=S-1-15-2-1861897761-1695161497-2927542615-642690995-327840285-2659745135-2630312742|Platform=2:6:2|Platform2=GTEQ|" /f >nul 2>&1
		Reg add "HKLM\TK_SYSTEM\ControlSet001\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules" /v "Block Cortana PlacesServer.exe" /t REG_SZ /d "v2.26|Action=Block|Active=TRUE|Dir=Out|RA42=IntErnet|RA62=IntErnet|App=C:\Windows\SystemApps\Microsoft.Windows.Cortana_cw5n1h2txyewy\PlacesServer.exe|Name=Block Cortana PlacesServer.exe|Desc=Block Cortana Outbound UDP/TCP Traffic|" /f >nul 2>&1
		Reg add "HKLM\TK_SYSTEM\ControlSet001\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules" /v "Block Cortana RemindersServer.exe" /t REG_SZ /d "v2.26|Action=Block|Active=TRUE|Dir=Out|RA42=IntErnet|RA62=IntErnet|App=C:\Windows\SystemApps\Microsoft.Windows.Cortana_cw5n1h2txyewy\RemindersServer.exe|Name=Block Cortana RemindersServer.exe|Desc=Block Cortana Outbound UDP/TCP Traffic|" /f >nul 2>&1
		Reg add "HKLM\TK_SYSTEM\ControlSet001\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules" /v "Block Cortana RemindersShareTargetApp.exe" /t REG_SZ /d "v2.26|Action=Block|Active=TRUE|Dir=Out|RA42=IntErnet|RA62=IntErnet|App=C:\Windows\SystemApps\Microsoft.Windows.Cortana_cw5n1h2txyewy\RemindersShareTargetApp.exe|Name=Block Cortana RemindersShareTargetApp.exe|Desc=Block Cortana Outbound UDP/TCP Traffic|" /f >nul 2>&1
		Reg add "HKLM\TK_SYSTEM\ControlSet001\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules" /v "Block Cortana SearchUI.exe" /t REG_SZ /d "v2.26|Action=Block|Active=TRUE|Dir=Out|RA42=IntErnet|RA62=IntErnet|App=C:\Windows\SystemApps\Microsoft.Windows.Cortana_cw5n1h2txyewy\SearchUI.exe|Name=Block Cortana SearchUI.exe|Desc=Block Cortana Outbound UDP/TCP Traffic|" /f >nul 2>&1
		Reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\{885a186e-a440-4ada-812b-db871b942259}\TopViews\{00000000-0000-0000-0000-000000000000}" /v "GroupBy" /t REG_SZ /d "System.None" /f >nul 2>&1
		Reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\{885a186e-a440-4ada-812b-db871b942259}\TopViews\{00000000-0000-0000-0000-000000000000}" /v "PrimaryProperty" /t REG_SZ /d "System.Name" /f >nul 2>&1
		Reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\{885a186e-a440-4ada-812b-db871b942259}\TopViews\{00000000-0000-0000-0000-000000000000}" /v "SortByList" /t REG_SZ /d "prop:System.Name" /f >nul 2>&1
	)

	if "%SelectedSourceOS%" equ "w11" (
		Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\Windows Chat" /v "ChatIcon" /t REG_DWORD /d "3" /f >nul 2>&1
		Reg add "HKLM\TK_NTUSER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarMn" /t REG_DWORD /d "0" /f >nul 2>&1
	)

	if "%SelectedSourceOS%" neq "w7"  if "%SelectedSourceOS%" neq "w81" (
		Reg add "HKLM\TK_NTUSER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowCortanaButton" /t REG_DWORD /d "0" /f >nul 2>&1
	)

	if "%SelectedSourceOS%" equ "w10" (
		Reg add "HKLM\TK_NTUSER\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "HideSCAMeetNow" /t REG_DWORD /d "1" /f >nul 2>&1
		Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "HideSCAMeetNow" /t REG_DWORD /d "1" /f >nul 2>&1
		Reg add "HKLM\TK_NTUSER\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds" /v "ShellFeedsTaskbarViewMode" /t REG_DWORD /d "2" /f >nul 2>&1
		Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" /v "EnableFeeds" /t REG_DWORD /d "0" /f >nul 2>&1
		Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" /v "HeadlinesOnboardingComplete" /t REG_DWORD /d "0" /f >nul 2>&1
	)

	if "%SelectedSourceOS%" neq "w7"  if "%SelectedSourceOS%" neq "w81" (
		Reg add "HKLM\TK_NTUSER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowTaskViewButton" /t REG_DWORD /d "0" /f >nul 2>&1
		Reg add "HKLM\TK_NTUSER\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d "0" /f >nul 2>&1
	)

	if "%SelectedSourceOS%" equ "w11" (
		Reg add "HKLM\TK_NTUSER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarDa" /t REG_DWORD /d "0" /f >nul 2>&1
	)

	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\Device Metadata" /v "PreventDeviceMetadataFromNetwork" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\DriverSearching" /v "DontPromptForWindowsUpdate" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\DriverSearching" /v "DontSearchWindowsUpdate" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\DriverSearching" /v "DriverUpdateWizardWuSearchEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\DriverSearching" /v "SearchOrderConfig" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "ExcludeWUDriversInQualityUpdate" /t REG_DWORD /d "1" /f >nul 2>&1


	if "%SelectedSourceOS%" neq "w7"  if "%SelectedSourceOS%" neq "w81" (
		Reg add "HKLM\TK_NTUSER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "OemPreInstalledAppsEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
		Reg add "HKLM\TK_NTUSER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "PreInstalledAppsEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
		Reg add "HKLM\TK_NTUSER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SilentInstalledAppsEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
		Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v "DisableWindowsConsumerFeatures" /t REG_DWORD /d "1" /f >nul 2>&1
	)

	if "%SelectedSourceOS%" equ "w11" (
		Reg add "HKLM\TK_SOFTWARE\Microsoft\PolicyManager\current\device\Start" /v "ConfigureStartPins" /t REG_SZ /d "{\"pinnedList\": [{}]}" /f >nul 2>&1
		Reg add "HKLM\TK_SOFTWARE\Microsoft\PolicyManager\current\device\Start" /v "ConfigureStartPins_ProviderSet" /t REG_DWORD /d "0" /f >nul 2>&1
		Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows\CurrentVersion\Communications" /v "ConfigureChatAutoInstall" /t REG_DWORD /d "0" /f >nul 2>&1
	)

	Reg add "HKLM\TK_DEFAULT\SOFTWARE\Microsoft\Windows Security Health\State" /v "AccountProtection_MicrosoftAccount_Disconnected" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\SOFTWARE\Microsoft\Windows Security Health\State" /v "AccountProtection_MicrosoftAccount_Disconnected" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows Defender Security Center\Notifications" /v "DisableEnhancedNotifications" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows Defender Security Center\Notifications" /v "DisableNotifications" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows Defender" /v "DisableAntiSpyware" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows Defender" /v "DisableAntiVirus" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows Defender\Features" /v "TamperProtection" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows Defender\Features" /v "TamperProtectionSource" /t REG_DWORD /d "2" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows Defender\Signature Updates" /v "FirstAuGracePeriod" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows Defender\UX Configuration" /v "DisablePrivacyMode" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "SecurityHealth" /t REG_BINARY /d "030000000000000000000000" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\MRT" /v "DontOfferThroughWUAU" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\MRT" /v "DontReportInfectionInformation" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Systray" /v "HideSystray" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableAntiSpyware" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender" /v "PUAProtection" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender" /v "RandomizeScheduleTaskTimes" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Exclusions" /v "DisableAutoExclusions" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\MpEngine" /v "MpEnablePus" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Quarantine" /v "LocalSettingOverridePurgeItemsAfterDelay" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Quarantine" /v "PurgeItemsAfterDelay" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableBehaviorMonitoring" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableIOAVProtection" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableOnAccessProtection" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableRealtimeMonitoring" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableRoutinelyTakingAction" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableScanOnRealtimeEnable" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableScriptScanning" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Remediation" /v "Scan_ScheduleDay" /t REG_DWORD /d "8" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Remediation" /v "Scan_ScheduleTime" /t REG_DWORD /d 0 /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Reporting" /v "AdditionalActionTimeOut" /t REG_DWORD /d 0 /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Reporting" /v "CriticalFailureTimeOut" /t REG_DWORD /d 0 /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Reporting" /v "DisableEnhancedNotifications" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Reporting" /v "DisableGenericRePorts" /t REG_DWORD /d 1 /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Reporting" /v "NonCriticalTimeOut" /t REG_DWORD /d 0 /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Scan" /v "AvgCPULoadFactor" /t REG_DWORD /d "10" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Scan" /v "DisableArchiveScanning" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Scan" /v "DisableCatchupFullScan" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Scan" /v "DisableCatchupQuickScan" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Scan" /v "DisableRemovableDriveScanning" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Scan" /v "DisableRestorePoint" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Scan" /v "DisableScanningMappedNetworkDrivesForFullScan" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Scan" /v "DisableScanningNetworkFiles" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Scan" /v "PurgeItemsAfterDelay" /t REG_DWORD /d 0 /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Scan" /v "ScanOnlyIfIdle" /t REG_DWORD /d 0 /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Scan" /v "ScanParameters" /t REG_DWORD /d 0 /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Scan" /v "ScheduleDay" /t REG_DWORD /d 8 /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Scan" /v "ScheduleTime" /t REG_DWORD /d 0 /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Signature Updates" /v "DisableUpdateOnStartupWithoutEngine" /t REG_DWORD /d 1 /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Signature Updates" /v "ScheduleDay" /t REG_DWORD /d 8 /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Signature Updates" /v "ScheduleTime" /t REG_DWORD /d 0 /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Signature Updates" /v "SignatureUpdateCatchupInterval" /t REG_DWORD /d 0 /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\SpyNet" /v "DisableBlockAtFirstSeen" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v "LocalSettingOverrideSpynetReporting" /t REG_DWORD /d 0 /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v "SpyNetReporting" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v "SpyNetReportingLocation" /t REG_MULTI_SZ /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v "SubmitSamplesConsent" /t REG_DWORD /d "2" /f >nul 2>&1
	if "%SelectedSourceOS%" equ "w11" Reg add "HKLM\TK_SYSTEM\ControlSet001\Control\CI\Policy" /v "VerifiedAndReputablePolicyState" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SYSTEM\ControlSet001\Services\EventLog\System\Microsoft-Antimalware-ShieldProvider" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
	Reg add "HKLM\TK_SYSTEM\ControlSet001\Services\EventLog\System\WinDefend" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
	Reg add "HKLM\TK_SYSTEM\ControlSet001\Services\MsSecFlt" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
	Reg add "HKLM\TK_SYSTEM\ControlSet001\Services\SecurityHealthService" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
	Reg add "HKLM\TK_SYSTEM\ControlSet001\Services\Sense" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
	Reg add "HKLM\TK_SYSTEM\ControlSet001\Services\WdBoot" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
	Reg add "HKLM\TK_SYSTEM\ControlSet001\Services\WdFilter" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
	Reg add "HKLM\TK_SYSTEM\ControlSet001\Services\WdNisDrv" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
	Reg add "HKLM\TK_SYSTEM\ControlSet001\Services\WdNisSvc" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
	Reg add "HKLM\TK_SYSTEM\ControlSet001\Services\WinDefend" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
	Reg add "HKLM\TK_SYSTEM\ControlSet001\Control\WMI\Autologger\DefenderApiLogger" /v "Start" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SYSTEM\ControlSet001\Control\WMI\Autologger\DefenderAuditLogger" /v "Start" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile" /v "EnableFirewall" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile" /v "EnableFirewall" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile" /v "EnableFirewall" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\WindowsFirewall\StandardProfile" /v "EnableFirewall" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" /v "DisableFirewall" /t REG_SZ /d "%%windir%%\System32\netsh.exe advfirewall set allprofiles state off" /f >nul 2>&1
	Reg add "HKLM\TK_DEFAULT\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" /v "EnableWebContentEvaluation" /t REG_DWORD /d 0 /f >nul 2>&1
	Reg add "HKLM\TK_DEFAULT\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" /v "PreventOverride" /t REG_DWORD /d 0 /f >nul 2>&1
	Reg add "HKLM\TK_DEFAULT\SOFTWARE\Policies\Microsoft\Edge" /v "SmartScreenEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" /v "EnableWebContentEvaluation" /t REG_DWORD /d 0 /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" /v "PreventOverride" /t REG_DWORD /d 0 /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\SOFTWARE\Policies\Microsoft\Edge" /v "SmartScreenEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows Security Health\State" /v "AppAndBrowser_StoreAppsSmartScreenOff" /t REG_DWORD /d 0 /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" /v "SmartScreenEnabled" /t REG_SZ /d "Off" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "SmartScreenEnabled" /t REG_SZ /d "Off" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Internet Explorer\PhishingFilter" /v "EnabledV9" /t REG_DWORD /d 0 /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Internet Explorer\PhishingFilter" /v "PreventOverride" /t REG_DWORD /d 0 /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\MicrosoftEdge\PhishingFilter" /v "EnabledV9" /t REG_DWORD /d 0 /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\MicrosoftEdge\PhishingFilter" /v "PreventOverride" /t REG_DWORD /d 0 /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\System" /v "EnableSmartScreen" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\SmartScreen" /v "ConfigureAppInstallControl" /t REG_SZ /d "Anywhere" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows Defender\SmartScreen" /v "ConfigureAppInstallControlEnabled" /t REG_DWORD /d "0" /f >nul 2>&1

	if "%SelectedSourceOS%" neq "w10" if "%SelectedSourceOS%" neq "w11" (
		Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\Gwx" /v "DisableGwx" /t REG_DWORD /d "1" /f >nul 2>&1
		Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DisableOSUpgrade" /t REG_DWORD /d "1" /f >nul 2>&1
	)

	if "%SelectedSourceOS%" neq "w7" if "%SelectedSourceOS%" neq "w81" (
		Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "AUOptions" /t REG_DWORD /d "2" /f >nul 2>&1
		Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoUpdate" /t REG_DWORD /d "1" /f >nul 2>&1
		Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DeferUpdatePeriod" /t REG_DWORD /d "1" /f >nul 2>&1
		Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DeferUpgrade" /t REG_DWORD /d "1" /f >nul 2>&1
		Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DeferUpgradePeriod" /t REG_DWORD /d "1" /f >nul 2>&1
		Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "TargetReleaseVersion" /t REG_DWORD /d "1" /f >nul 2>&1
		if "%ImageBuild%" geq "17134" if "%ImageBuild%" leq "20348" Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "ProductVersion" /t REG_SZ /d "Windows 10" /f >nul 2>&1
		if "%ImageBuild%" equ "17134" Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "TargetReleaseVersionInfo" /t REG_SZ /d "1803" /f >nul 2>&1
		if "%ImageBuild%" equ "17763" Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "TargetReleaseVersionInfo" /t REG_SZ /d "1809" /f >nul 2>&1
		if "%ImageBuild%" equ "18362" Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "TargetReleaseVersionInfo" /t REG_SZ /d "1903" /f >nul 2>&1
		if "%ImageBuild%" equ "18363" Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "TargetReleaseVersionInfo" /t REG_SZ /d "1909" /f >nul 2>&1
		if "%ImageBuild%" equ "19041" Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "TargetReleaseVersionInfo" /t REG_SZ /d "2004" /f >nul 2>&1
		if "%ImageBuild%" equ "19042" Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "TargetReleaseVersionInfo" /t REG_SZ /d "2009" /f >nul 2>&1
		if "%ImageBuild%" equ "19043" Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "TargetReleaseVersionInfo" /t REG_SZ /d "21H1" /f >nul 2>&1
		if "%ImageBuild%" equ "19044" Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "TargetReleaseVersionInfo" /t REG_SZ /d "21H2" /f >nul 2>&1
		if "%ImageBuild%" equ "19045" Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "TargetReleaseVersionInfo" /t REG_SZ /d "22H2" /f >nul 2>&1
		if "%ImageBuild%" equ "20348" Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "TargetReleaseVersionInfo" /t REG_SZ /d "21H2" /f >nul 2>&1
		if "%ImageBuild%" equ "22000" Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "TargetReleaseVersionInfo" /t REG_SZ /d "21H2" /f >nul 2>&1
		if "%ImageBuild%" geq "22621" if "%ImageBuild%" leq "22631" Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "TargetReleaseVersionInfo" /t REG_SZ /d "22H2" /f >nul 2>&1
	)

	Reg add "HKLM\TK_NTUSER\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization" /v "SystemSettingsDownloadMode" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Speech_OneCore\Preferences" /v "ModelDownloadAllowed" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization" /v "OptInOOBE" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" /v "DODownloadMode" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsStore\WindowsUpdate" /v "AutoDownload" /t REG_DWORD /d "2" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Services\7971f918-a847-4430-9279-4a52d1efe18d" /v "RegisteredWithAU" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-DeviceUpdateAgent/Operational" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-WindowsUpdateClient/Operational" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v "HideMCTLink" /t REG_DWORD /d "1" /f >nul 2>&1
	if "%ImageDefaultLanguage%" equ "zh-CN" Reg add "HKLM\TK_SOFTWARE\Microsoft\LexiconUpdate\loc_0804" /v "HapDownloadEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	if "%ImageDefaultLanguage%" equ "zh-HK" Reg add "HKLM\TK_SOFTWARE\Microsoft\LexiconUpdate\loc_0804" /v "HapDownloadEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	if "%ImageDefaultLanguage%" equ "zh-TW" Reg add "HKLM\TK_SOFTWARE\Microsoft\LexiconUpdate\loc_0804" /v "HapDownloadEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Speech" /v "AllowSpeechModelUpdate" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /v "DODownloadMode" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DoNotConnectToWindowsUpdateInternetLocations" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DisableWindowsUpdateAccess" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "WUServer" /t REG_SZ /d " " /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "WUStatusServer" /t REG_SZ /d " " /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "UpdateServiceUrlAlternate" /t REG_SZ /d " " /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "AUOptions" /t REG_DWORD /d "2" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoUpdate" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "UseWUServer" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SYSTEM\ControlSet001\Services\wuauserv" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
	if "%SelectedSourceOS%" neq "w7" if "%SelectedSourceOS%" neq "w81" Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows\CurrentVersion\ReserveManager" /v "ShippedWithReserves" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\.NETFramework" /v "OnlyUseLatestCLR" /t REG_DWORD /d "1" /f >nul 2>&1
	if "%SelectedSourceOS%" equ "w11" Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" /v "BypassNRO" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\ApplicationAssociationToasts" /v "emffile_.emf" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\ApplicationAssociationToasts" /v "rlefile_.rle" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\ApplicationAssociationToasts" /v "wmffile_.wmf" /t REG_DWORD /d "0" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer" /v "GlobalAssocChangedCounter" /t REG_DWORD /d "13" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.bmp\OpenWithList" /v "a" /t REG_SZ /d "PhotoViewer.dll" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.bmp\OpenWithList" /v "MRUList" /t REG_SZ /d "a" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.bmp\UserChoice" /v "Hash" /t REG_SZ /d "TDU75KWAGi4=" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.bmp\UserChoice" /v "ProgId" /t REG_SZ /d "PhotoViewer.FileAssoc.Bitmap" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.dib\OpenWithList" /v "a" /t REG_SZ /d "PhotoViewer.dll" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.dib\OpenWithList" /v "MRUList" /t REG_SZ /d "a" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.dib\UserChoice" /v "Hash" /t REG_SZ /d "hAQpLYJfRYE=" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.dib\UserChoice" /v "ProgId" /t REG_SZ /d "PhotoViewer.FileAssoc.Bitmap" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.gif\OpenWithList" /v "a" /t REG_SZ /d "PhotoViewer.dll" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.gif\OpenWithList" /v "MRUList" /t REG_SZ /d "a" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.gif\UserChoice" /v "Hash" /t REG_SZ /d "1in4hcmDrB4=" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.gif\UserChoice" /v "ProgId" /t REG_SZ /d "PhotoViewer.FileAssoc.Gif" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jfif\OpenWithList" /v "a" /t REG_SZ /d "PhotoViewer.dll" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jfif\OpenWithList" /v "MRUList" /t REG_SZ /d "a" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jfif\UserChoice" /v "Hash" /t REG_SZ /d "Y5upkzp3g5E=" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jfif\UserChoice" /v "ProgId" /t REG_SZ /d "PhotoViewer.FileAssoc.JFIF" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jpe\OpenWithList" /v "a" /t REG_SZ /d "PhotoViewer.dll" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jpe\OpenWithList" /v "MRUList" /t REG_SZ /d "a" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jpe\UserChoice" /v "Hash" /t REG_SZ /d "ZIeqfdrNtFk=" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jpe\UserChoice" /v "ProgId" /t REG_SZ /d "PhotoViewer.FileAssoc.Jpeg" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jpeg\OpenWithList" /v "a" /t REG_SZ /d "PhotoViewer.dll" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jpeg\OpenWithList" /v "MRUList" /t REG_SZ /d "a" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jpeg\UserChoice" /v "Hash" /t REG_SZ /d "iVWM3EAePKw=" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jpeg\UserChoice" /v "ProgId" /t REG_SZ /d "PhotoViewer.FileAssoc.Jpeg" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jpg\OpenWithList" /v "a" /t REG_SZ /d "PhotoViewer.dll" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jpg\OpenWithList" /v "MRUList" /t REG_SZ /d "a" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jpg\UserChoice" /v "Hash" /t REG_SZ /d "Xq9gH4jXoFM=" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jpg\UserChoice" /v "ProgId" /t REG_SZ /d "PhotoViewer.FileAssoc.Jpeg" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jxr\OpenWithList" /v "a" /t REG_SZ /d "PhotoViewer.dll" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jxr\OpenWithList" /v "MRUList" /t REG_SZ /d "a" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jxr\UserChoice" /v "Hash" /t REG_SZ /d "ahz7f/Yl09M=" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jxr\UserChoice" /v "ProgId" /t REG_SZ /d "PhotoViewer.FileAssoc.Wdp" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.png\OpenWithList" /v "a" /t REG_SZ /d "PhotoViewer.dll" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.png\OpenWithList" /v "MRUList" /t REG_SZ /d "a" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.png\UserChoice" /v "Hash" /t REG_SZ /d "Evm7jp++AWA=" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.png\UserChoice" /v "ProgId" /t REG_SZ /d "PhotoViewer.FileAssoc.Png" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.tif\OpenWithList" /v "a" /t REG_SZ /d "PhotoViewer.dll" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.tif\OpenWithList" /v "MRUList" /t REG_SZ /d "a" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.tif\UserChoice" /v "Hash" /t REG_SZ /d "wEj9gLqtYH4=" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.tif\UserChoice" /v "ProgId" /t REG_SZ /d "TIFImage.Document" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.tiff\OpenWithList" /v "a" /t REG_SZ /d "PhotoViewer.dll" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.tiff\OpenWithList" /v "MRUList" /t REG_SZ /d "a" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.tiff\UserChoice" /v "Hash" /t REG_SZ /d "/r2V12Yryig=" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.tiff\UserChoice" /v "ProgId" /t REG_SZ /d "TIFImage.Document" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.wdp\OpenWithList" /v "a" /t REG_SZ /d "PhotoViewer.dll" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.wdp\OpenWithList" /v "MRUList" /t REG_SZ /d "a" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.wdp\UserChoice" /v "Hash" /t REG_SZ /d "/qcrPB0bhuI=" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.wdp\UserChoice" /v "ProgId" /t REG_SZ /d "PhotoViewer.FileAssoc.Wdp" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\Roaming\OpenWith\FileExts\.bmp\UserChoice" /v "Hash" /t REG_SZ /d "rEigxhAPyos=" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\Roaming\OpenWith\FileExts\.bmp\UserChoice" /v "ProgId" /t REG_SZ /d "PhotoViewer.FileAssoc.Bitmap" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\Roaming\OpenWith\FileExts\.dib\UserChoice" /v "Hash" /t REG_SZ /d "R60f5QZs3Hg=" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\Roaming\OpenWith\FileExts\.dib\UserChoice" /v "ProgId" /t REG_SZ /d "PhotoViewer.FileAssoc.Bitmap" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\Roaming\OpenWith\FileExts\.gif\UserChoice" /v "Hash" /t REG_SZ /d "YcQO9pssSPU=" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\Roaming\OpenWith\FileExts\.gif\UserChoice" /v "ProgId" /t REG_SZ /d "PhotoViewer.FileAssoc.Gif" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\Roaming\OpenWith\FileExts\.jfif\UserChoice" /v "Hash" /t REG_SZ /d "5yjvWKb+Jns=" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\Roaming\OpenWith\FileExts\.jfif\UserChoice" /v "ProgId" /t REG_SZ /d "PhotoViewer.FileAssoc.JFIF" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\Roaming\OpenWith\FileExts\.jpe\UserChoice" /v "Hash" /t REG_SZ /d "TujD2rCi+po=" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\Roaming\OpenWith\FileExts\.jpe\UserChoice" /v "ProgId" /t REG_SZ /d "PhotoViewer.FileAssoc.Jpeg" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\Roaming\OpenWith\FileExts\.jpeg\UserChoice" /v "Hash" /t REG_SZ /d "wdZ9wQI4vW8=" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\Roaming\OpenWith\FileExts\.jpeg\UserChoice" /v "ProgId" /t REG_SZ /d "PhotoViewer.FileAssoc.Jpeg" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\Roaming\OpenWith\FileExts\.jpg\UserChoice" /v "Hash" /t REG_SZ /d "3xY0V0JOiFc=" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\Roaming\OpenWith\FileExts\.jpg\UserChoice" /v "ProgId" /t REG_SZ /d "PhotoViewer.FileAssoc.Jpeg" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\Roaming\OpenWith\FileExts\.jxr\UserChoice" /v "Hash" /t REG_SZ /d "ENXEd5Uzg84=" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\Roaming\OpenWith\FileExts\.jxr\UserChoice" /v "ProgId" /t REG_SZ /d "PhotoViewer.FileAssoc.Wdp" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\Roaming\OpenWith\FileExts\.png\UserChoice" /v "Hash" /t REG_SZ /d "SPesrUKrIFE=" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\Roaming\OpenWith\FileExts\.png\UserChoice" /v "ProgId" /t REG_SZ /d "PhotoViewer.FileAssoc.Png" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\Roaming\OpenWith\FileExts\.tif\UserChoice" /v "Hash" /t REG_SZ /d "bCXQRSAHD/I=" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\Roaming\OpenWith\FileExts\.tif\UserChoice" /v "ProgId" /t REG_SZ /d "TIFImage.Document" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\Roaming\OpenWith\FileExts\.tiff\UserChoice" /v "Hash" /t REG_SZ /d "7F/LfjhVnes=" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\Roaming\OpenWith\FileExts\.tiff\UserChoice" /v "ProgId" /t REG_SZ /d "TIFImage.Document" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\Roaming\OpenWith\FileExts\.wdp\UserChoice" /v "Hash" /t REG_SZ /d "tu0JqOen+Es=" /f >nul 2>&1
	Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\Roaming\OpenWith\FileExts\.wdp\UserChoice" /v "ProgId" /t REG_SZ /d "PhotoViewer.FileAssoc.Wdp" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\Applications\photoviewer.dll\shell\open" /v "MuiVerb" /t REG_SZ /d "@photoviewer.dll,-3043" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\Applications\photoviewer.dll\shell\open\command" /ve /t REG_EXPAND_SZ /d "%%SystemRoot%%\System32\rundll32.exe \"%%ProgramFiles%%\Windows Photo Viewer\PhotoViewer.dll\", ImageView_Fullscreen %%1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\Applications\photoviewer.dll\shell\open\DropTarget" /v "Clsid" /t REG_SZ /d "{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\Applications\photoviewer.dll\shell\print\command" /ve /t REG_EXPAND_SZ /d "%%SystemRoot%%\System32\rundll32.exe \"%%ProgramFiles%%\Windows Photo Viewer\PhotoViewer.dll\", ImageView_Fullscreen %%1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\Applications\photoviewer.dll\shell\print\DropTarget" /v "Clsid" /t REG_SZ /d "{60fd46de-f830-4894-a628-6fa81bc0190d}" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Bitmap" /v "FriendlyTypeName" /t REG_EXPAND_SZ /d "@%%ProgramFiles%%\Windows Photo Viewer\PhotoViewer.dll,-3056" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Bitmap" /v "ImageOptionFlags" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Bitmap\DefaultIcon" /ve /t REG_SZ /d "%%SystemRoot%%\System32\imageres.dll,-70" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Bitmap\shell\open\command" /ve /t REG_EXPAND_SZ /d "%%SystemRoot%%\System32\rundll32.exe \"%%ProgramFiles%%\Windows Photo Viewer\PhotoViewer.dll\", ImageView_Fullscreen %%1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Bitmap\shell\open\DropTarget" /v "Clsid" /t REG_SZ /d "{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Gif" /v "FriendlyTypeName" /t REG_EXPAND_SZ /d "@%%ProgramFiles%%\Windows Photo Viewer\PhotoViewer.dll,-3057" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Gif" /v "ImageOptionFlags" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Gif\DefaultIcon" /ve /t REG_SZ /d "%%SystemRoot%%\System32\imageres.dll,-83" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Gif\shell\open\command" /ve /t REG_EXPAND_SZ /d "%%SystemRoot%%\System32\rundll32.exe \"%%ProgramFiles%%\Windows Photo Viewer\PhotoViewer.dll\", ImageView_Fullscreen %%1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Gif\shell\open\DropTarget" /v "Clsid" /t REG_SZ /d "{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.JFIF" /v "EditFlags" /t REG_DWORD /d "65536" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.JFIF" /v "FriendlyTypeName" /t REG_EXPAND_SZ /d "@%%ProgramFiles%%\Windows Photo Viewer\PhotoViewer.dll,-3055" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.JFIF" /v "ImageOptionFlags" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.JFIF\DefaultIcon" /ve /t REG_SZ /d "%%SystemRoot%%\System32\imageres.dll,-72" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.JFIF\shell\open" /v "MuiVerb" /t REG_EXPAND_SZ /d "@%%ProgramFiles%%\Windows Photo Viewer\photoviewer.dll,-3043" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.JFIF\shell\open\command" /ve /t REG_EXPAND_SZ /d "%%SystemRoot%%\System32\rundll32.exe \"%%ProgramFiles%%\Windows Photo Viewer\PhotoViewer.dll\", ImageView_Fullscreen %%1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.JFIF\shell\open\DropTarget" /v "Clsid" /t REG_SZ /d "{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Jpeg" /v "EditFlags" /t REG_DWORD /d "65536" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Jpeg" /v "FriendlyTypeName" /t REG_EXPAND_SZ /d "@%%ProgramFiles%%\Windows Photo Viewer\PhotoViewer.dll,-3055" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Jpeg" /v "ImageOptionFlags" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Jpeg\DefaultIcon" /ve /t REG_SZ /d "%%SystemRoot%%\System32\imageres.dll,-72" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Jpeg\shell\open" /v "MuiVerb" /t REG_EXPAND_SZ /d "@%%ProgramFiles%%\Windows Photo Viewer\photoviewer.dll,-3043" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Jpeg\shell\open\command" /ve /t REG_EXPAND_SZ /d "%%SystemRoot%%\System32\rundll32.exe \"%%ProgramFiles%%\Windows Photo Viewer\PhotoViewer.dll\", ImageView_Fullscreen %%1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Jpeg\shell\open\DropTarget" /v "Clsid" /t REG_SZ /d "{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Png" /v "FriendlyTypeName" /t REG_EXPAND_SZ /d "@%%ProgramFiles%%\Windows Photo Viewer\PhotoViewer.dll,-3057" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Png" /v "ImageOptionFlags" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Png\DefaultIcon" /ve /t REG_SZ /d "%%SystemRoot%%\System32\imageres.dll,-71" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Png\shell\open\command" /ve /t REG_EXPAND_SZ /d "%%SystemRoot%%\System32\rundll32.exe \"%%ProgramFiles%%\Windows Photo Viewer\PhotoViewer.dll\", ImageView_Fullscreen %%1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Png\shell\open\DropTarget" /v "Clsid" /t REG_SZ /d "{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Tiff" /v "FriendlyTypeName" /t REG_EXPAND_SZ /d "@%%ProgramFiles%%\Windows Photo Viewer\PhotoViewer.dll,-3058" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Tiff" /v "ImageOptionFlags" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Tiff\DefaultIcon" /ve /t REG_SZ /d "%%SystemRoot%%\System32\imageres.dll,-122" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Tiff\shell\open" /v "MuiVerb" /t REG_EXPAND_SZ /d "@%%ProgramFiles%%\Windows Photo Viewer\photoviewer.dll,-3043" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Tiff\shell\open\command" /ve /t REG_EXPAND_SZ /d "%%SystemRoot%%\System32\rundll32.exe \"%%ProgramFiles%%\Windows Photo Viewer\PhotoViewer.dll\", ImageView_Fullscreen %%1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Tiff\shell\open\DropTarget" /v "Clsid" /t REG_SZ /d "{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Wdp" /v "EditFlags" /t REG_DWORD /d "65536" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Wdp" /v "ImageOptionFlags" /t REG_DWORD /d "1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Wdp\DefaultIcon" /ve /t REG_SZ /d "%%SystemRoot%%\System32\wmphoto.dll,-400" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Wdp\shell\open" /v "MuiVerb" /t REG_EXPAND_SZ /d "@%%ProgramFiles%%\Windows Photo Viewer\photoviewer.dll,-3043" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Wdp\shell\open\command" /ve /t REG_EXPAND_SZ /d "%%SystemRoot%%\System32\rundll32.exe \"%%ProgramFiles%%\Windows Photo Viewer\PhotoViewer.dll\", ImageView_Fullscreen %%1" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Classes\PhotoViewer.FileAssoc.Wdp\shell\open\DropTarget" /v "Clsid" /t REG_SZ /d "{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities" /v "ApplicationDescription" /t REG_SZ /d "@%%ProgramFiles%%\Windows Photo Viewer\photoviewer.dll,-3069" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities" /v "ApplicationName" /t REG_SZ /d "@%%ProgramFiles%%\Windows Photo Viewer\photoviewer.dll,-3009" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations" /v ".bmp" /t REG_SZ /d "PhotoViewer.FileAssoc.Bitmap" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations" /v ".dib" /t REG_SZ /d "PhotoViewer.FileAssoc.Bitmap" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations" /v ".gif" /t REG_SZ /d "PhotoViewer.FileAssoc.Gif" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations" /v ".jfif" /t REG_SZ /d "PhotoViewer.FileAssoc.JFIF" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations" /v ".jpe" /t REG_SZ /d "PhotoViewer.FileAssoc.Jpeg" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations" /v ".jpeg" /t REG_SZ /d "PhotoViewer.FileAssoc.Jpeg" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations" /v ".jpg" /t REG_SZ /d "PhotoViewer.FileAssoc.Jpeg" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations" /v ".jxr" /t REG_SZ /d "PhotoViewer.FileAssoc.Wdp" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations" /v ".png" /t REG_SZ /d "PhotoViewer.FileAssoc.Png" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations" /v ".tif" /t REG_SZ /d "PhotoViewer.FileAssoc.Tiff" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations" /v ".tiff" /t REG_SZ /d "PhotoViewer.FileAssoc.Tiff" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations" /v ".wdp" /t REG_SZ /d "PhotoViewer.FileAssoc.Wdp" /f >nul 2>&1
	if "%SelectedSourceOS%" equ "w11" Reg add "HKLM\TK_SOFTWARE\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /ve /f >nul 2>&1
	Reg delete "HKLM\TK_SOFTWARE\Microsoft\Windows NT\CurrentVersion\drivers.desc" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows NT\CurrentVersion\drivers.desc" /v "%%SystemRoot%%\System32\l3codecp.acm" /t REG_SZ /d "Fraunhofer IIS MPEG Layer-3 Codec (Professional)" /f >nul 2>&1
	Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows NT\CurrentVersion\Drivers32" /v "msacm.l3acm" /t REG_EXPAND_SZ /d "%%SystemRoot%%\System32\l3codecp.acm" /f >nul 2>&1

	if "%ImageArchitecture%" equ "x64" (
		Reg delete "HKLM\TK_SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\drivers.desc" /f >nul 2>&1
		Reg add "HKLM\TK_SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\drivers.desc" /v "%%SystemRoot%%\SysWOW64\l3codecp.acm" /t REG_SZ /d "Fraunhofer IIS MPEG Layer-3 Codec (Professional)" /f >nul 2>&1
		Reg add "HKLM\TK_SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Drivers32" /v "msacm.l3acm" /t REG_EXPAND_SZ /d "%%SystemRoot%%\SysWOW64\l3codecp.acm" /f >nul 2>&1
	)

	if "%SelectedSourceOS%" neq "w7" if "%SelectedSourceOS%" neq "w81" Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows\CurrentVersion\SideBySide\Configuration" /v "DisableResetbase" /t REG_DWORD /d "0" /f >nul 2>&1
	if "%SelectedSourceOS%" equ "w11" Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarAl" /t REG_DWORD /d "0" /f >nul 2>&1
)

echo.
echo.-------------------------------------------------------------------------------
echo.####Ӧ�õ��������#############################################################
echo.-------------------------------------------------------------------------------

:Stop
echo.
echo.===============================================================================
echo.
pause>nul|set /p=�밴���������ִ�С���

set Tweaks=

endlocal

:: ���ص�Ӧ�õ����˵�
goto :ApplyTweaksMenu

:: �����޸�
:ApplyMenu

echo.����ж��ӳ��ע�����
call :UnMountImageRegistry
cls
echo.===============================================================================
echo.                                 �����޸�
echo.===============================================================================
echo.
echo.  [1]   Ӧ�ò����浽Դӳ���ļ�
echo.
echo.  [2]   �������Ĳ�ж��Դӳ���ļ�
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.===============================================================================
echo.

choice /C:12 /N /M "���������ѡ�� ��"
if errorlevel 2 goto :DiscardSource
if errorlevel 1 goto :SaveSource

:: ����ӳ��
:SaveSource

setlocal

set "TrimEditions=No"

cls
echo.===============================================================================
echo.                           Ӧ�ò�������ĵ�Դӳ��
echo.===============================================================================
echo.
:: ����ӳ��
echo.-------------------------------------------------------------------------------
echo.####���ڿ�ʼʹ���������� ResetBase ����Դӳ��################################
echo.-------------------------------------------------------------------------------
echo.
:: ʹ�� ResetBase ѡ��ִ�ж� [Install.wim] ��ӳ���������
echo.-------------------------------------------------------------------------------
echo.����ִ�ж� [Install.wim������ ��%ImageIndexNo%] ��ӳ�����������
echo.-------------------------------------------------------------------------------
if exist "%InstallMount%\%ImageIndexNo%\Windows\WinSxS\pending.xml" (
	echo.
	echo.�� Pending.xml ����ʱ�޷�ִ��ӳ�����������
	echo.
) else (
	%DISM% /Image:"%InstallMount%\%ImageIndexNo%" /Cleanup-Image /StartComponentCleanup /ResetBase
)

echo.-------------------------------------------------------------------------------
echo.####ʹ���������� ResetBase ����Դӳ�������##################################
echo.-------------------------------------------------------------------------------
echo.
echo.-------------------------------------------------------------------------------
echo.####��������ӳ���ļ���########################################################
echo.-------------------------------------------------------------------------------
echo.
echo.��������ӳ�� Windows ��ʱ����־�ļ����ļ��С�
if exist "%InstallMount%\%ImageIndexNo%\$Recycle.Bin" rd /q /s "%InstallMount%\%ImageIndexNo%\$Recycle.Bin" >nul
if exist "%InstallMount%\%ImageIndexNo%\PerfLogs" rd /q /s "%InstallMount%\%ImageIndexNo%\PerfLogs" >nul
if exist "%InstallMount%\%ImageIndexNo%\Users\Default\*.LOG1" del /f /q "%InstallMount%\%ImageIndexNo%\Users\Default\*.LOG1" >nul 2>&1
if exist "%InstallMount%\%ImageIndexNo%\Users\Default\*.LOG2" del /f /q "%InstallMount%\%ImageIndexNo%\Users\Default\*.LOG2" >nul 2>&1
if exist "%InstallMount%\%ImageIndexNo%\Users\Default\*.TM.blf" del /f /q "%InstallMount%\%ImageIndexNo%\Users\Default\*.TM.blf" >nul 2>&1
if exist "%InstallMount%\%ImageIndexNo%\Users\Default\*.regtrans-ms" del /f /q "%InstallMount%\%ImageIndexNo%\Users\Default\*.regtrans-ms" >nul 2>&1
if exist "%InstallMount%\%ImageIndexNo%\Windows\inf\*.log" del /f /q "%InstallMount%\%ImageIndexNo%\Windows\inf\*.log" >nul 2>&1

if exist "%InstallMount%\%ImageIndexNo%\Windows\CbsTemp\*" (
	for /f %%i in ('"dir /s /b /ad "%InstallMount%\%ImageIndexNo%\Windows\CbsTemp\*"" 2^>nul') do (if exist "%%i" rd /q /s "%%i" >nul)
	del /s /f /q "%InstallMount%\%ImageIndexNo%\Windows\CbsTemp\*" >nul 2>&1
)

if exist "%InstallMount%\%ImageIndexNo%\Windows\System32\config\*.LOG1" del /f /q "%InstallMount%\%ImageIndexNo%\Windows\System32\config\*.LOG1" >nul 2>&1
if exist "%InstallMount%\%ImageIndexNo%\Windows\System32\config\*.LOG2" del /f /q "%InstallMount%\%ImageIndexNo%\Windows\System32\config\*.LOG2" >nul 2>&1
if exist "%InstallMount%\%ImageIndexNo%\Windows\System32\config\*.TM.blf" del /f /q "%InstallMount%\%ImageIndexNo%\Windows\System32\config\*.TM.blf" >nul 2>&1
if exist "%InstallMount%\%ImageIndexNo%\Windows\System32\config\*.regtrans-ms" del /f /q "%InstallMount%\%ImageIndexNo%\Windows\System32\config\*.regtrans-ms" >nul 2>&1
if exist "%InstallMount%\%ImageIndexNo%\Windows\System32\SMI\Store\Machine\*.LOG1" del /f /q "%InstallMount%\%ImageIndexNo%\Windows\System32\SMI\Store\Machine\*.LOG1" >nul 2>&1
if exist "%InstallMount%\%ImageIndexNo%\Windows\System32\SMI\Store\Machine\*.LOG2" del /f /q "%InstallMount%\%ImageIndexNo%\Windows\System32\SMI\Store\Machine\*.LOG2" >nul 2>&1
if exist "%InstallMount%\%ImageIndexNo%\Windows\System32\SMI\Store\Machine\*.TM.blf" del /f /q "%InstallMount%\%ImageIndexNo%\Windows\System32\SMI\Store\Machine\*.TM.blf" >nul 2>&1
if exist "%InstallMount%\%ImageIndexNo%\Windows\System32\SMI\Store\Machine\*.regtrans-ms" del /f /q "%InstallMount%\%ImageIndexNo%\Windows\System32\SMI\Store\Machine\*.regtrans-ms" >nul 2>&1
if exist "%InstallMount%\%ImageIndexNo%\Windows\WinSxS\Backup\*" del /f /q "%InstallMount%\%ImageIndexNo%\Windows\WinSxS\Backup\*" >nul 2>&1
if exist "%InstallMount%\%ImageIndexNo%\Windows\WinSxS\ManifestCache\*.bin" del /f /q "%InstallMount%\%ImageIndexNo%\Windows\WinSxS\ManifestCache\*.bin" >nul 2>&1
if exist "%InstallMount%\%ImageIndexNo%\Windows\WinSxS\Temp\PendingDeletes\*" del /f /q "%InstallMount%\%ImageIndexNo%\Windows\WinSxS\Temp\PendingDeletes\*" >nul 2>&1
if exist "%InstallMount%\%ImageIndexNo%\Windows\WinSxS\Temp\TransformerRollbackData\*" del /f /q "%InstallMount%\%ImageIndexNo%\Windows\WinSxS\Temp\TransformerRollbackData\*" >nul 2>&1
::��������
for %%i in (ar-SA,bg-BG,cs-CZ,da-DK,de-DE,el-GR,en-GB,es-ES,es-MX,et-EE,fi-FI,fr-CA,fr-FR,he-IL,hr-HR,hu-HU,it-IT,ja-JP,ko-KR,lt-LT,lv-LV,nb-NO,nl-NL,pl-PL,pt-BR,pt-PT,ro-RO,ru-RU,sk-SK,sl-SI,sr-Latn-RS,sv-SE,th-TH,tr-TR,uk-UA,zh-TW) do (
	if exist %InstallMount%\%ImageIndexNo%\Windows\BitLockerDiscoveryVolumeContents\%%i_BitLockerToGo.exe.mui del /f /s /q %InstallMount%\%ImageIndexNo%\Windows\BitLockerDiscoveryVolumeContents\%%i_BitLockerToGo.exe.mui 1>nul
	if exist %InstallMount%\%ImageIndexNo%\Windows\System32\%%i rd /s /q %InstallMount%\%ImageIndexNo%\Windows\System32\%%i 1>nul
)
if exist %InstallMount%\%ImageIndexNo%\Windows\IME\IMEJP\Assets rd /s /q %InstallMount%\%ImageIndexNo%\Windows\IME\IMEJP\Assets 1>nul
if exist %InstallMount%\%ImageIndexNo%\Windows\IME\IMEJP\help rd /s /q %InstallMount%\%ImageIndexNo%\Windows\IME\IMEJP\help 1>nul
if exist %InstallMount%\%ImageIndexNo%\Windows\IME\IMEKR\HELP rd /s /q %InstallMount%\%ImageIndexNo%\Windows\IME\IMEKR\HELP 1>nul
if exist %InstallMount%\%ImageIndexNo%\Windows\IME\IMETC\HELP rd /s /q %InstallMount%\%ImageIndexNo%\Windows\IME\IMETC\HELP 1>nul
echo.
echo.-------------------------------------------------------------------------------
echo.####��������ӳ���ļ��������###################################################
echo.-------------------------------------------------------------------------------
echo.

::����SXS
echo.-------------------------------------------------------------------------------
echo.####��������WinSXS�ļ���######################################################
echo.-------------------------------------------------------------------------------
echo.
echo.  [1]   ��������
echo.  [2]   ��Ⱦ���
echo.
echo.  ��Ⱦ�����Ա�֤ϵͳ�ȶ�����Ⱦ�����ܻᵼ��ϵͳ���⣬����������Ժ��ٰ�װ��
echo.  ��֪�����ѡ��ģ���ѡ��1��
echo.
choice /C:12 /N /M "���������ѡ�� ��"
if errorlevel 2 (
	%~dp0UICORE.EXE winsxs2 "%InstallMount%\%ImageIndexNo%" |MORE
	pause
)
if errorlevel 1 (
	%~dp0UICORE.EXE winsxs1 "%InstallMount%\%ImageIndexNo%" |MORE
	pause
)

echo.
echo.-------------------------------------------------------------------------------
echo.####���ڿ�ʼӦ�ò�������ĵ�Դӳ��#############################################
echo.-------------------------------------------------------------------------------
echo.
if %ImageCount% neq 1 (
	choice /C:NY /N /M "����Ҫȥ��δѡ���ӳ��汾�� �� [�ǡ�Y��/��N��] ��"
	if errorlevel 2 set "TrimEditions=Yes"
	echo.
)

:: ���沢ж��Դ��װ�ͻָ�ӳ��
echo.-------------------------------------------------------------------------------
echo.����Ӧ�ø��Ĳ�ж�� [Install.wim������ ��%ImageIndexNo%] ӳ�񡭡�
echo.-------------------------------------------------------------------------------
%DISM% /Unmount-Image /MountDir:"%InstallMount%\%ImageIndexNo%" /Commit
echo.
if exist "%InstallMount%\%ImageIndexNo%" rd /q /s "%InstallMount%\%ImageIndexNo%" >nul

:: ʹ�����ѹ���ؽ�Դ��װӳ��
echo.-------------------------------------------------------------------------------
echo.����ʹ�����ѹ���Ż�Դ [Install.wim] ӳ�񡭡�
echo.-------------------------------------------------------------------------------

if "%TrimEditions%" equ "Yes" (
	%~dp0UICORE.EXE exportonly %ImageIndexNo% "%DISM%"
)

if "%TrimEditions%" equ "No" (
	echo.
	"%Bin%\wimlib-imagex.exe" optimize "%InstallWim%"
	echo.
	start explorer.exe %DVD%\sources
)

echo.-------------------------------------------------------------------------------
echo.####Ӧ�ò�������ĵ�Դӳ�������###############################################
echo.-------------------------------------------------------------------------------
echo.

:Stop
echo.===============================================================================
echo.
pause>nul|set /p=�밴���������ִ�С���

set TrimEditions=

endlocal

set SelectedSourceOS=

goto :Quit

:: �������Ĳ�ж��
:DiscardSource

cls
echo.===============================================================================
echo.                            �������Ĳ�ж��Դӳ��
echo.===============================================================================
echo.
echo.-------------------------------------------------------------------------------
echo.####���ڿ�ʼ�������Ĳ�ж��Դӳ��###############################################
echo.-------------------------------------------------------------------------------
echo.
echo.-------------------------------------------------------------------------------
echo.����ж�� [Install.wim������ ��%ImageIndexNo%] ӳ�񡭡�
echo.-------------------------------------------------------------------------------
%DISM% /Unmount-Image /MountDir:"%InstallMount%\%ImageIndexNo%" /"Discard"
echo.
if exist "%InstallMount%\%ImageIndexNo%" rd /q /s "%InstallMount%\%ImageIndexNo%" >nul
echo.-------------------------------------------------------------------------------
echo.####�������Ĳ�ж��Դӳ�������#################################################
echo.-------------------------------------------------------------------------------
echo.

set SelectedSourceOS=

:Stop
echo.===============================================================================
echo.
pause>nul|set /p=�밴���������ִ�С���

goto :Quit

:: �˳�
:Quit

cls
echo.===============================================================================
echo. 	                                �˳�
echo.===============================================================================
echo.
echo.����ִ�к���������������Ժ�...
echo.
call :CleanUp
echo.
echo.
echo.�����˳�...
echo.
echo.===============================================================================
echo.
pause>nul|set /p=��������˳�...

:: �ָ� DOS ���ڴ�С
reg delete "HKCU\Console\%%SystemRoot%%_system32_cmd.exe" /f >nul

reg add "HKU\.DEFAULT\Console" /v "FaceName" /t REG_SZ /d "Consolas" /f
reg add "HKU\.DEFAULT\Console" /v "FontFamily" /t REG_DWORD /d "0x36" /f
reg add "HKU\.DEFAULT\Console" /v "FontSize" /t REG_DWORD /d "0x100000" /f
reg add "HKU\.DEFAULT\Console" /v "FontWeight" /t REG_DWORD /d "0x190" /f
reg add "HKU\.DEFAULT\Console" /v "ScreenBufferSize" /t REG_DWORD /d "0x12c0050" /f

endlocal
exit



:: ############################################################################################
:: �Ӻ���
:: ############################################################################################

::-------------------------------------------------------------------------------------------
:: ��װӳ��ע���ģ��
:: ������� [ %~1 ��ӳ��װ·�� ]
::-------------------------------------------------------------------------------------------
:MountImageRegistry

:: ��װӳ��ע��������ѻ��༭
reg load HKLM\TK_COMPONENTS "%~1\Windows\System32\config\COMPONENTS" >nul
reg load HKLM\TK_DEFAULT "%~1\Windows\System32\config\default" >nul
reg load HKLM\TK_NTUSER "%~1\Users\Default\ntuser.dat" >nul
reg load HKLM\TK_SOFTWARE "%~1\Windows\System32\config\SOFTWARE" >nul
reg load HKLM\TK_SYSTEM "%~1\Windows\System32\config\SYSTEM" >nul

goto :eof
::-------------------------------------------------------------------------------------------

::-------------------------------------------------------------------------------------------
:: ж��ӳ��ע���ģ��
:: ������� [ None ]
::-------------------------------------------------------------------------------------------
:UnMountImageRegistry

:: ж��ӳ��ע���
for /f "tokens=* delims=" %%a in ('reg query "HKLM" ^| findstr "{"') do (
	reg unload "%%a" >nul 2>&1
)

reg unload HKLM\TK_COMPONENTS >nul 2>&1
reg unload HKLM\TK_DEFAULT >nul 2>&1
reg unload HKLM\TK_DRIVERS >nul 2>&1
reg unload HKLM\TK_NTUSER >nul 2>&1
reg unload HKLM\TK_SCHEMA >nul 2>&1
reg unload HKLM\TK_SOFTWARE >nul 2>&1
reg unload HKLM\TK_SYSTEM >nul 2>&1

goto :eof
::-------------------------------------------------------------------------------------------

::-------------------------------------------------------------------------------------------
:: ���� MSMG ���������ʱ�ļ����ļ���
::-------------------------------------------------------------------------------------------
:CleanUp

echo.���ڿ�ʼ������
echo.
echo.��������ӳ��ע���װ�㡭��
call :UnMountImageRegistry

echo.
echo.��������ӳ��װ�㡭��
for /l %%i in (1, 1, 100) do (
	if exist "%InstallMount%\%%i\Windows" Dism.exe /English /Unmount-Wim /MountDir:"%InstallMount%\%%i" /Discard >nul
)

:: ����ӳ��װ���ļ���
if exist "%InstallMount%" rd /q /s "%InstallMount%" >nul
if not exist "%InstallMount%" md "%InstallMount%" >nul
echo.

:: ������־�ļ���
echo.����������־�ļ�����
if exist "%Logs%" rd /q /s "%Logs%" >nul
if not exist "%Logs%" md "%Logs%" >nul
echo.

:: ������ʱ�ļ����ļ���
echo.����������ʱ�ļ�����
if exist "%Temp%" rd /q /s "%Temp%" >nul
if not exist "%Temp%" md "%Temp%" >nul

echo.
echo.�����������
echo.

goto :eof
::-------------------------------------------------------------------------------------------

