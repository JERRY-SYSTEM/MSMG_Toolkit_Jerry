@echo off
title MSMG Toolkit v13.7 Jerry修改版 V1.1-Patch1 Build20240812
:: 设置默认控制台背景和前景色
color 1f
cd /D "%~dp0" >nul
set "ROOT=%cd%"
cd /D "%ROOT%\" >nul

:: 检查路径
if not "%cd%"=="%cd: =%" (
	echo.=========================================================
	echo.
	echo.当前工具箱目录在其路径中包含空格。
	echo 请将目录移动或重命名为不包含空格的目录。
	echo.
	echo.=========================================================
	echo.
	pause>nul|set /p=按任意键退出......
	exit
)

:: 设置CMD窗口样式
reg add "HKCU\Console\%%SystemRoot%%_system32_cmd.exe" /v "ScreenBufferSize" /t REG_DWORD /d "0x23290050" /f >nul
reg add "HKCU\Console\%%SystemRoot%%_system32_cmd.exe" /v "WindowSize" /t REG_DWORD /d "0x190050" /f >nul

reg add "HKU\.DEFAULT\Console" /v "FaceName" /t REG_SZ /d "Consolas" /f >nul
reg add "HKU\.DEFAULT\Console" /v "FontFamily" /t REG_DWORD /d "0x36" /f >nul
reg add "HKU\.DEFAULT\Console" /v "FontSize" /t REG_DWORD /d "0x100000" /f >nul
reg add "HKU\.DEFAULT\Console" /v "FontWeight" /t REG_DWORD /d "0x190" /f >nul
reg add "HKU\.DEFAULT\Console" /v "ScreenBufferSize" /t REG_DWORD /d "0x23290050" /f >nul

setlocal EnableExtensions EnableDelayedExpansion

:: 设置路径环境变量
set "Bin=%ROOT%\Bin"
set "DVD=%ROOT%\DVD"
set "Logs=%ROOT%\Logs"
set "Mount=%ROOT%\Mount"
set "Temp=%ROOT%\Temp"

:: 声明主机操作系统版本、体系结构和语言变量
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

:: 检查主机操作系统是否是 Windows 7/8.1
if "%HostVersion%" neq "10.0" (
	echo.=========================================================
	echo.
	echo.工具箱无法在 Windows 7/8.1 主机操作系统上维护 Windows 10/11 源操作系统……
	echo.
	echo.工具箱需要主机操作系统为 Windows 10/11 以维护 Windows 10/11 源操作系统……
	echo.
	echo.=========================================================
	echo.
	pause>nul|set /p=按任意键退出......
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
rem Windows 默认 pt-BR 布局是 ABNT“0416:00000416”。但流行的布局是 ABNT2“0416:00010416”
if "%HostActiveKeyboard%" equ "0416:00000416" set "HostActiveKeyboard=0416:00010416"
for /f "tokens=2 delims=:" %%f in ('DISM /Online /English /Get-Intl ^| findstr /I /C:"Default time zone"') do (set "HostTimeZone=%%f")
set "HostTimeZone=%HostTimeZone:~1%"

:: 设置源操作系统镜像路径
set SelectedSourceOS=
set OSID=
set "InstallWim=%DVD%\sources\install.wim"
set "InstallEsd=%DVD%\sources\install.esd"
set "InstallMount=%Mount%\Install"

:: 声明源映像信息变量
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

:: 设置组件状态标识
for %%i in (C_AdobeFlashForWindows,C_EdgeChromium,C_EdgeWebView,C_InternetExplorer,C_FirstLogonAnimation,C_GameExplorer,C_LockScreenBackground,C_ScreenSavers,C_SnippingTool,C_SoundThemes,C_SpeechRecognition,C_Wallpapers,C_WindowsMediaPlayer,C_WindowsPhotoViewer,C_WindowsThemes,C_WindowsTIFFIFilter,C_WinSAT,C_OfflineFiles,C_OpenSSH,C_RemoteDesktopClient,C_RemoteDifferentialCompression,C_SimpleTCPIPServices,C_TelnetClient,C_TFTPClient,C_WalletService,C_WindowsMail,C_AssignedAccess,C_CEIP,C_FaceRecognition,C_KernelDebugging,C_LocationService,C_PicturePassword,C_PinEnrollment,C_UnifiedTelemetryClient,C_WiFiNetworkManager,C_WindowsErrorReporting,C_WindowsInsiderHub,C_HomeGroup,C_MultiPointConnector,C_OneDrive,C_RemoteAssistance,C_RemoteDesktopServer,C_RemoteRegistry,C_WorkFoldersClient,C_AccessibilityTools,C_Calculator,C_DeviceLockdown,C_EaseOfAccessCursors,C_EaseOfAccessThemes,C_EasyTransfer,C_FileHistory,C_LiveCaptions,C_Magnifier,C_ManualSetup,C_Narrator,C_Notepad,C_OnScreenKeyboard,C_Paint,C_ProjFS,C_SecurityCenter,C_StepsRecorder,C_StorageSpaces,C_SystemRestore,C_VoiceAccess,C_WindowsBackup,C_WindowsFirewall,C_WindowsSubsystemForLinux,C_WindowsToGo,C_WindowsUpdate,C_Wordpad,C_AADBrokerPlugin,C_AccountsControl,C_AddSuggestedFoldersToLibraryDialog,C_AppResolverUX,C_AssignedAccessLockApp,C_AsyncTextService,C_BioEnrollment,C_CallingShellApp,C_CapturePicker,C_CBSPreview,C_ClientCBS,C_CloudExperienceHost,C_ContentDeliveryManager,C_Cortana,C_CredDialogHost,C_ECApp,C_Edge,C_EdgeDevToolsClient,C_FileExplorer,C_FilePicker,C_InputApp,C_LockApp,C_MapControl,C_NarratorQuickStart,C_NcsiUwpApp,C_OOBENetworkCaptivePortal,C_OOBENetworkConnectionFlow,C_ParentalControls,C_PeopleExperienceHost,C_PinningConfirmationDialog,C_PrintDialog,C_PPIProjection,C_QuickAssist,C_RetailDemoContent,C_SearchApp,C_SecureAssessmentBrowser,C_SettingSync,C_ShellExperienceHost,C_SkypeORTC,C_SmartScreen,C_StartMenuExperienceHost,C_UndockedDevKit,C_WebcamExperience,C_WebView2Runtime,C_Win32WebViewHost,C_WindowsDefender,C_WindowsMixedReality,C_WindowsReaderPDF,C_WindowsStoreCore,C_XboxCore,C_XboxGameCallableUI,C_XGpuEjectDialog,C_3DViewer,C_AdvertisingXaml,C_Alarms,C_BingNews,C_BingWeather,C_CalculatorApp,C_Camera,C_ClientWebExperience,C_Clipchamp,C_CommunicationsApps,C_DesktopAppInstaller,C_Family,C_FeedbackHub,C_GamingApp,C_GetHelp,C_Getstarted,C_HEIFImageExtension,C_HEVCVideoExtension,C_Maps,C_Messaging,C_MixedRealityPortal,C_NETNativeFramework16,C_NETNativeFramework17,C_NETNativeFramework22,C_NETNativeRuntime16,C_NETNativeRuntime17,C_NETNativeRuntime22) do (
	set "%%i=+"
)

:: 设置组件兼容性状态标识
for %%i in (CC_AdobeInstallers,CC_ApplicationGuardContainers,CC_Biometric,CC_Hyper-V,CC_MicrosoftGames,CC_MicrosoftOfice,CC_MicrosoftStore,CC_ModernAppSupport,CC_OOBE,CC_Printing,CC_Recommended,CC_ShellSearch,CC_TouchScreenDevices,CC_VisualStudio,CC_WindowsUpdate,CC_WindowsUpgrade,CC_XboxApp) do (
	set "%%i=+"
)

:: 启动
cls
echo.
echo.正在执行预清理操作，请稍候……
call :Cleanup >nul
:: 设置 DOS 字符代码页
if "%HostUILanguage%" equ "en-GB" chcp 437 >nul
if "%HostUILanguage%" equ "en-US" chcp 437 >nul
if "%HostUILanguage%" equ "zh-CN" chcp 936 >nul
if not exist "%Temp%\DISM" md "%Temp%\DISM" >nul
set "DISM=%Bin%\Dism%HostArchitecture%\Dism.exe /English /ScratchDir:%Temp%\DISM /LogPath:%Logs%\Dism.txt /LogLevel:3 /NoRestart"
cls
echo.主机操作系统
echo.
echo.%HostOSName% %HostDisplayVersion% - v%HostVersion%.%HostBuild%.%HostServicePackBuild% %HostArchitecture% %HostLanguage%
echo.

:: 导入镜像
:SelectSourceDVD

cls
echo.
echo.===============================================================================
echo.                                导入镜像
echo.===============================================================================
echo.

:: 检查 Windows 源安装映像是否存在
if not exist "%InstallWim%" (
	if exist "%InstallEsd%" (
		set "InstallWimfile=%InstallEsd%"
	) else (
		echo.在 ^<DVD\Sources^> 文件夹中无法找到 Windows 安装程序“Install.wim”映像。
		echo.
		echo.你可以将“Install.wim”复制到 ^<DVD\Sources^> 文件夹，按回车重新查找；
		echo.
		echo.也可以输入1选择一个源镜像文件；
		echo.
		echo.如果你想退出，输入Q。
		echo.
		choice /C:1Q /N /M "请输入你的选项 ："
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
echo.####正在导入映像文件###########################################################
echo.-------------------------------------------------------------------------------

:: 获取映像中存在的索引总数。
set "ImageInfo=%Temp%\ImageInfo.txt"

if exist "%ImageInfo%" del /f /q "%ImageInfo%" >nul

for /f "tokens=2 delims=: " %%a in ('%DISM% /Get-ImageInfo /ImageFile:"%InstallWimfile%" ^| findstr Index') do (set ImageCount=%%a)

echo.
echo.正在读取映像信息……
echo.
:: 列出映像中的所有索引。
echo.===============================================================================>>%ImageInfo%
echo.^|  索引  ^| 体系结构    ^| 名称>>%ImageInfo%
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
	set /p ImageIndexNo=请输入映像索引编号 # [1 或按‘Q’退出] ：
) else set /p ImageIndexNo=请输入映像索引编号 # 的 [范围 ：1、…%ImageCount% 或按‘Q’退出] ：

:: 获取映像索引
if not defined ImageIndexNo (
	echo.
	echo.输入的索引编号 # 无效，有效范围是 [1~%ImageCount%，按“Q”退出]
	echo.
	pause>nul|set /p=按任意键重新选择...
	goto :SelectSourceDVD
)

if /i "%ImageIndexNo%" equ "Q" (
	set ImageIndexNo=
	goto :Quit
)

:: 检查 Windows 源安装映像是否为 ESD 格式
if exist "%InstallEsd%" (
	echo.
    echo.-------------------------------------------------------------------------------
    echo.####正在转换 ESD 映像为 WIM 映像###############################################
    echo.-------------------------------------------------------------------------------
 	echo.
   
    :: 导出源映像为 WIM 映像
    "%Bin%\wimlib-imagex.exe" export "%InstallEsd%" %ImageIndexNo% "%InstallWim%" --compress=LZX
    
    :: 删除源映像文件
    if exist "%InstallEsd%" del /f /q "%InstallEsd%" >nul
    
    :: 设置转换后镜像里的索引为1
    set "ImageIndexNo=1"
    
	echo.
    echo.-------------------------------------------------------------------------------
    echo.####转换 WIM 映像为 ESD 映像已完成#############################################
    echo.-------------------------------------------------------------------------------
	echo.
)

:: 获取映像索引信息
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


:: 设置选择的源操作系统版本
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

:: 设置软件服务包内部版本、版本和服务包内部版本
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

:: 设置程序包索引和体系结构
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

::检查是否支持精简
if "%SelectedSourceOS%" neq "w7" if "%SelectedSourceOS%" neq "w81" if "%ImageBuild%" geq "17763" if "%ImageBuild%" leq "22631" if "%ImageInstallationType%" equ "Client" (
	echo.
) else (
	echo.
	echo.所选源映像版本不支持自定义组件移除，请下载工具箱支持的系统版本。
	echo.
	echo.===============================================================================
	echo.
	pause>nul|set /p=按任意键退出...
	goto :Quit
)

echo.-------------------------------------------------------------------------------
echo.####源映像文件详细信息#########################################################
echo.-------------------------------------------------------------------------------
echo.
echo.    映像文件名称             ： Install.wim
echo.    映像索引编号             ： %ImageIndexNo%
echo.    映像体系结构             ： %ImageArchitecture%
echo.    映像版本                 ： %ImageVersion%
echo.    映像服务包内部版本       ： %ImageServicePackBuild%
echo.    映像服务包等级           ： %ImageServicePackLevel%
echo.    映像内部版本             ： %ImageBuild%
echo.    映像默认语言             ： %ImageDefaultLanguage%
echo.
echo.-------------------------------------------------------------------------------
echo.####正在安装源映像文件#########################################################
echo.-------------------------------------------------------------------------------
echo.

if not exist "%InstallMount%\%ImageIndexNo%" md "%InstallMount%\%ImageIndexNo%" >nul
:: 安装源安装映像索引以维护
echo.
echo.-------------------------------------------------------------------------------
echo.正在将 [Install.wim，索引 ：%ImageIndexNo%] 映像安装在 ^<\Mount\Install\%ImageIndexNo%^>……
echo.-------------------------------------------------------------------------------
echo.
%DISM% /Mount-Image /ImageFile:"%InstallWim%" /Index:%ImageIndexNo% /MountDir:"%InstallMount%\%ImageIndexNo%"
echo.

echo.
echo.-------------------------------------------------------------------------------
echo.####选择并安装源映像文件已完成#################################################
echo.-------------------------------------------------------------------------------

echo.
echo.===============================================================================
echo.
:: 重置组件兼容性设置
for %%i in (C_AADBrokerPlugin,C_AccountsControl,C_BioEnrollment,C_ClientCBS,C_CloudExperienceHost,C_Cortana,C_DesktopAppInstaller,C_EasyTransfer,C_EdgeChromium,C_EdgeWebView,C_GameExplorer,C_GamingApp,C_InputApp,C_InternetExplorer,C_KernelDebugging,C_ManualSetup,C_NETNativeFramework16,C_NETNativeFramework17,C_NETNativeFramework22,C_NETNativeRuntime16,C_NETNativeRuntime17,C_NETNativeRuntime22,C_OfflineFiles,C_PinEnrollment,C_PrintDialog,C_RemoteDesktopClient,C_RemoteDesktopServer,C_SearchApp,C_SecurityCenter,C_ShellExperienceHost,C_StartMenuExperienceHost,C_UIXaml20,C_UIXaml24,C_UIXaml27,C_UndockedDevKit,C_VCLibs140UWP,C_VCLibs140UWPDesktop,C_WindowsErrorReporting,C_WindowsFirewall,C_WindowsStore,C_WindowsStoreCore,C_WindowsUpdate,C_WinSAT,C_XboxIdentityProvider,C_XboxCore,C_XboxApp) do (
	if "%%i" equ "C_WindowsErrorReporting" if "%ImageBuild%" geq "18362" if "%ImageBuild%" leq "18363" set "%%i=*"
	if "%%i" equ "C_ClientCBS" if "%ImageBuild%" geq "19041" if "%ImageBuild%" leq "22631" set "%%i=*"
	if "%%i" neq "C_ClientCBS" if "%%i" neq "C_WindowsErrorReporting" set "%%i=*"
)

pause>nul|set /p=请按任意键进行系统精简……
goto :ComponentsCompatibilityMenu

:: 移除 Windows 组件兼容性菜单
:ComponentsCompatibilityMenu
cls
echo.===============================================================================
echo.                              组件兼容性开关
echo.===============================================================================
echo.
echo.  [ 1] %CC_AdobeInstallers% Adobe 安装程序
echo.  [ 2] %CC_ApplicationGuardContainers% 应用程序防护 / 容器
echo.  [ 3] %CC_Biometric% 生物识别
echo.  [ 4] %CC_Hyper-V% Hyper-V
echo.  [ 5] %CC_MicrosoftGames% Microsoft 游戏
echo.  [ 6] %CC_MicrosoftOfice% Microsoft Office
echo.  [ 7] %CC_MicrosoftStore% Microsoft Store
echo   [ 8] %CC_ModernAppSupport% Modern 应用支持
echo.  [ 9] %CC_OOBE% 全新安装体验（OOBE）
echo.  [10] %CC_Printing% 打印
echo.  [11] %CC_Recommended% 推荐
echo.  [12] %CC_ShellSearch% Shell Search
echo.  [13] %CC_TouchScreenDevices% 触摸屏设备
echo.  [14] %CC_VisualStudio% Visual Studio
echo.  [15] %CC_WindowsUpdate% Windows 更新
echo.  [16] %CC_WindowsUpgrade% Windows 升级
echo.  [17] %CC_XboxApp% Xbox
echo.
echo.  [A]    选择所有
echo.  [R]    恢复为默认值
echo.  [N]    下一步
echo.
echo.===============================================================================
echo.
echo.  Tips：请输入你不需要的功能的序号，使前面的 + 变成 - 
echo.        请谨慎设置，此处保留的功能将会被锁定无法精简！
echo.
set /p MenuChoice=请输入你的选项后按回车：

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
:: 移除 Windows 10 v1809/v1903/v1909/v2004/v20H2/v21H1/v21H2/v22H2、Windows 11 v21H2/v22H2 客户端 Internet 菜单
if "%SelectedSourceOS%" neq "w7" if "%SelectedSourceOS%" neq "w81" if "%ImageBuild%" geq "17763" if "%ImageBuild%" leq "22631" (
	cls
	echo.===============================================================================
	echo.                           Internet 组件
	echo.===============================================================================
	echo.
	if "%SelectedSourceOS%" equ "w10" if "%ImageServicePackBuild%" equ "1" (
		echo.  [1] %C_AdobeFlashForWindows% 适用于 Windows 的 Adobe Flash
		echo.        适用于 Windows 的 Adobe Flash 支持。
		echo.
	)
	echo.  [2] %C_InternetExplorer% Internet Explorer
	echo.        Internet Explorer 是一个 Web 浏览器，允许用户在 Internet 上查看网页。
	echo.        兼容性        ：Adobe 安装程序
	echo.
	echo.  [3] %C_EdgeChromium% Microsoft Edge Chromium
	echo.        基于 Chromium 的 Microsoft Edge web 浏览器。
	echo.        兼容性        ：推荐
	echo.
	if "%SelectedSourceOS%" equ "w11" (
		echo.  [4] %C_EdgeWebView% Microsoft Edge WebView
		echo.        Microsoft Edge WebView 控件允许你在本机应用程序中嵌入 Web 技术
		echo.        （HTML、CSS 和 JavaScript）。
		echo.        依赖于        ：Microsoft Edge Chromium
		echo.        兼容性        ：推荐、Visual Studio
		echo.
	)
	echo.
	echo.
	echo.  [A]   所有 Internet 组件
	echo.  [B]   回到上一步
	echo.  [N]   下一步
	echo.
	echo.===============================================================================
	echo.
	echo.  Tips：请输入你不需要的组件的序号，使前面的 + 变成 - 
	echo.        如果组件前为 * ，则该组件不能被精简。
	echo.
	set /p MenuChoice=请输入你的选项后按回车：

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
:: 移除 Windows 10 v1809/v1903/v1909/v2004/v20H2/v21H1/v21H2/v22H2、Windows 11 v21H2/v22H2 客户端多媒体菜单
if "%SelectedSourceOS%" neq "w7" if "%SelectedSourceOS%" neq "w81" if "%ImageBuild%" geq "17763" if "%ImageBuild%" leq "22631" (
	cls
	echo.===============================================================================
	echo.                               多媒体组件
	echo.===============================================================================
	echo.
	echo.  [ 1] %C_FirstLogonAnimation% 首次登录动画
	echo.         首次登录动画是在重大更新、版本更改或几个新用户帐户后登录时显示在屏
	echo.         幕上的一系列消息。
	echo.         依赖于        ：全新安装体验（OOBE）
	echo.
	echo.  [ 2] %C_GameExplorer% 游戏浏览器
	echo.         游戏浏览器是一项功能，可让你查看计算机上当前安装的所有游戏并在线查
	echo.         找其他游戏。
	echo.         兼容性        ：Microsoft 游戏
	echo.
	echo.  [ 3] %C_LockScreenBackground% 锁屏背景
	echo.         锁屏界面具有可自定义的墙纸，其图像与桌面上显示的图像不同。
	echo.
	echo.  [ 4] %C_ScreenSavers% 屏幕保护程序
	echo.         屏幕保护程序是计算机程序，旨在在你不使用屏幕时使屏幕空白或用移动图
	echo.         像填充屏幕。
	echo.
	if "%SelectedSourceOS%" equ "w10" (
		echo.  [ 5] %C_SnippingTool% 截图工具
		echo.         截图工具是一个屏幕截图实用程序，用于截取打开的窗口、矩形区域、自由
		echo.         格式区域或整个屏幕的静态屏幕截图。
		echo.
	)
	echo.  [ 6] %C_SoundThemes% 声音主题
	echo.         各种 Windows 主题外壳声音。
	echo.
	echo.  [ 7] %C_SpeechRecognition% 语音识别
	echo.         语音识别使语音命令能够控制桌面用户界面、听写电子文档和电子邮件中的
	echo.         文本、导航网站、执行键盘快捷键以及操作鼠标光标。
	echo.
	echo.  [ 8] %C_Wallpapers% 墙纸
	echo.         各种 Windows 主题桌面外壳壁纸。
	echo.
	if "%ImageBuild%" geq "17763" if "%ImageBuild%" leq "22000" echo.  [ 9] %C_WindowsMediaPlayer% Windows Media Player
	if "%SelectedSourceOS%" equ "w11" if "%ImageBuild%" geq "22621" if "%ImageBuild%" leq "22631" echo.  [ 9] %C_WindowsMediaPlayer% 旧版 Windows Media Player
	echo.         Windows Media Player 是一个简单的实用工具，可让你播放音频和视频文件。
	echo.
	echo.  [10] %C_WindowsPhotoViewer% Windows 照片查看器
	echo.         Windows 照片查看器是一个简单的实用工具，可让你显示图像文件。
	echo.
	echo.  [11] %C_WindowsThemes% Windows 个性化主题
	echo.         各种 Windows 个性化主题。
	echo.
	echo.  [12] %C_WindowsTIFFIFilter% Windows TIFF IFilter（OCR）
	echo.         Windows TIFF IFilter 处理 TIFF 图像，然后将识别的文本提供给调用方以
	echo.         构建搜索索引。
	echo.
	echo.  [13] %C_WinSAT% Windows 系统评估工具（WinSAT）
	echo.         用于评估电脑的性能特征和功能的 Windows 性能基准工具。
	echo.         兼容性        ：Microsoft 游戏
	echo.
	echo.  [A]    所有多媒体组件
	echo.  [B]    回到上一步
	echo.  [N]    下一步
	echo.
	echo.===============================================================================
	echo.
	echo.  Tips：请输入你不需要的组件的序号，使前面的 + 变成 - 
	echo.        如果组件前为 * ，则该组件不能被精简。
	echo.
	set /p MenuChoice=请输入你的选项后按回车：

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
:: 移除 Windows 10 v1809/v1903/v1909/v2004/v20H2/v21H1/v21H2/v22H2、Windows 11 v21H2/v22H2 客户端网络菜单
if "%SelectedSourceOS%" neq "w7" if "%SelectedSourceOS%" neq "w81" if "%ImageBuild%" geq "17763" if "%ImageBuild%" leq "22631" (
	cls
	echo.===============================================================================
	echo.                                 网络组件
	echo.===============================================================================
	echo.
	echo.  [1] %C_OfflineFiles% 脱机文件
	echo.        脱机文件是同步中心的一项功能，它使网络文件可供用户使用，即使不可用也
	echo.        是如此。如果使用便携式计算机连接到服务器工作区网络的网络连接，这将非
	echo.        常有用。
	echo.        兼容性        ：应用程序防护 / 容器
	echo.
	echo.  [2] %C_OpenSSH% OpenSSH
	echo.        用于使用安全外壳（SSH）协议的远程登录的开源连接工具。
	echo.
	echo.  [3] %C_RemoteDesktopClient% 远程桌面客户端
	echo.        Microsoft 远程桌面客户端允许你从 Windows Server 和远程电脑连接到远程
	echo.        桌面服务，以使用和控制管理员提供给你的桌面和应用。
	echo.        兼容性        ：推荐
	echo.
	echo.  [4] %C_RemoteDifferentialCompression% 远程差分压缩（RDC）
	echo.        允许使用压缩技术将数据与远程源同步，以最大程度地减少通过网络发送的数
	echo.        据量。
	echo.
	echo.  [5] %C_SimpleTCPIPServices% 简单 TCP/IP 服务
	echo.        简单 TCP/IP 服务支持以下 TCP/IP 服务：Character Generator、Daytime、
	echo.        Discard、Echo 和 Quote of the Day。
	echo.
	echo.  [6] %C_TelnetClient% Telnet 客户端
	echo.        Telnet 客户端使 TCP/IP 用户能够使用 Telnet 服务器应用程序登录并使用远
	echo.        程系统上的应用程序。
	echo.
	echo.  [7] %C_TFTPClient% TFTP 客户端
	echo.        简单文件传输协议（TFTP）是一个简单的锁步文件传输协议，它允许客户端从
	echo.        远程主机获取文件或将文件放到远程主机上。
	echo.
	echo.  [8] %C_WalletService% 电子钱包服务
	echo.        钱包应用所需的后端，Microsoft Windows 支付系统。
	echo.
	echo.  [9] %C_WindowsMail% Windows 邮件
	echo.        Windows 邮件是一个电子邮件客户端。
	echo.
	echo.  [A]   所有网络组件
	echo.  [B]   回到上一步
	echo.  [N]   下一步
	echo.
	echo.===============================================================================
	echo.
	echo.  Tips：请输入你不需要的组件的序号，使前面的 + 变成 - 
	echo.        如果组件前为 * ，则该组件不能被精简。
	echo.
	set /p MenuChoice=请输入你的选项后按回车：

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
:: 移除 Windows 10 v1809/v1903/v1909/v2004/v20H2/v21H1/v21H2/v22H2、Windows 11 v21H2/v22H2 客户端隐私菜单
if "%SelectedSourceOS%" neq "w7" if "%SelectedSourceOS%" neq "w81" if "%ImageBuild%" geq "17763" if "%ImageBuild%" leq "22631" (
	cls
	echo.===============================================================================
	echo.                                 隐私组件
	echo.===============================================================================
	echo.
	echo.  [ 1] %C_AssignedAccess% 分配的访问权限
	echo.         管理员可以使用分配的访问权限来限制现有用户帐户仅使用你选择的一个已安
	echo.         装的 Windows。这对于设置单一功能设备（例如餐厅菜单或在贸易展览会上显
	echo.         示）非常有用。
	echo.
	echo.  [ 2] %C_CEIP% 客户体验改善计划（SQM）
	echo.         Windows 客户体验改善计划（SQM）收集有关客户如何使用有关他们遇到的某
	echo.         些问题的计划 Microsoft 的信息。Microsoft 使用此信息来改进客户最常使
	echo.         用的产品和功能，并帮助解决问题。
	echo.
	echo.  [ 3] %C_FaceRecognition% 人脸识别（Windows Hello 人脸）
	echo.         Windows Hello 人脸是一种登录到设备、应用、联机服务和网络的新方法。
	echo.         它更安全，因为它使用“生物识别身份验证”使用你的面部登录。
	echo.
	echo.  [ 4] %C_KernelDebugging% 内核调试
	echo.         内核调试器是用于简化内核开发人员调试和内核开发的调试器。
	echo.         依赖于        ：Windows 错误报告
	echo.         兼容性        ：应用程序防护 / 容器
	echo.
	echo.  [ 5] %C_LocationService% 定位服务
	echo.         此服务监视系统的当前位置并管理地理围栏（具有关联事件的地理位置）。
	echo.
	echo.  [ 6] %C_PicturePassword% 图片密码
	echo.         使用喜爱的照片登录到 Windows。图片密码是一种登录 Windows 的方法，涉
	echo.         及使用你选择的图片和在该图片上绘制的手势，而不是密码。
	echo.
	echo.  [ 7] %C_PinEnrollment% Pin 登录支持
	echo.         Microsoft Windows Hello 登录个人标识号（PIN）是你自己选择的一组数字
	echo.         或字母和数字的组合。使用 PIN 是登录到 Windows 设备的一种快速、安全的
	echo.         方法。你的 PIN 码安全地存储在你的设备上。
	echo.         兼容性        ：生物识别
	echo.
	echo.  [ 8] %C_UnifiedTelemetryClient% 统一遥测客户端
	echo.         遥测数据收集并向 Microsoft 报告，以改进 Windows。
	echo.
	echo.  [ 9] %C_WiFiNetworkManager% WiFi 网络管理器（WiFi 感知）
	echo.         提供自动与你的 Outlook、Skype 或 Facebook 联系人共享 Wi-Fi 密码的功
	echo.         能，从而实现朋友之间的无缝 Wi-Fi 网络使用。
	echo.
	echo.  [10] %C_WindowsErrorReporting% Windows 错误报告
	echo.         用于捕获故障转储并选择性地将其报告给 Microsoft 的基础工具。
	if "%ImageBuild%" geq "18362" if "%ImageBuild%" leq "18363" echo.         兼容性        ：全新安装体验（OOBE）
	echo.
	echo.  [11] %C_WindowsInsiderHub% Windows 预览体验计划
	echo.         Windows 预览体验计划是一个由数百万 Windows 忠实粉丝组成的社区，他们
	echo.         可以预览 Windows 功能。在预览 Windows 时，预览体验成员可以提供反馈并
	echo.         与 Microsoft 工程师直接互动，以帮助塑造 Windows 的未来。
	echo.
	echo.  [A]   所有隐私组件
	echo.  [B]   回到上一步
	echo.  [N]   下一步
	echo.
	echo.===============================================================================
	echo.
	echo.  Tips：请输入你不需要的组件的序号，使前面的 + 变成 - 
	echo.        如果组件前为 * ，则该组件不能被精简。
	echo.
	set /p MenuChoice=请输入你的选项后按回车：

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
:: 移除 Windows 10 v1809/v1903/v1909/v2004/v20H2/v21H1/v21H2/v22H2、Windows 11 v21H2/v22H2 客户端远程处理菜单
if "%SelectedSourceOS%" neq "w7" if "%SelectedSourceOS%" neq "w81" if "%ImageBuild%" geq "17763" if "%ImageBuild%" leq "22631" (
	cls
	echo.===============================================================================
	echo.                               远程处理组件
	echo.===============================================================================
	echo.
	if "%ImageBuild%" geq "17763" if "%ImageBuild%" leq "22000" (
		echo.  [1] %C_HomeGroup% 家庭组
		echo.        家庭组是家庭网络上可以共享文件和打印机的一组电脑。
		echo.
	)
	echo.  [2] %C_MultiPointConnector% MultiPoint Connector
	echo.        使计算机能够由 MultiPoint 管理器和仪表板应用监视和管理。
	echo.
	echo.  [3] %C_OneDrive% OneDrive 桌面客户端
	echo.        OneDrive 是一种云存储、文件托管服务，允许用户同步文件，稍后从 Web 浏览
	echo.        器或移动设备访问它们。
	echo.
	echo.  [4] %C_RemoteAssistance% 远程协助
	echo.        为你信任的人提供便捷的方式。例如朋友或技术支持人员连接到你的计算机并引
	echo.        导你完成解决方案。
	echo.
	echo.  [5] %C_RemoteDesktopServer% 远程桌面服务器
	echo.        远程桌面服务（RDS）是 Microsoft Windows Server 功能的总称，允许用户远
	echo.        程访问图形桌面和 Windows 应用程序。
	echo.        兼容性        ：应用程序防护 / 容器、Hyper-V
	echo.
	echo.  [6] %C_RemoteRegistry% 远程注册表
	echo.        使远程用户能够修改此计算机上的注册表设置。
	echo.
	echo.  [7] %C_WorkFoldersClient% 工作文件夹客户端
	echo.        允许用户将数据从位于公司数据中心的用户文件夹同步到其设备。
	echo.        包括 Active Directory 联合身份验证服务（ADFS）。
	echo.
	echo.  [A]   所有远程处理组件
	echo.  [B]   回到上一步
	echo.  [N]   下一步
	echo.
	echo.===============================================================================
	echo.
	echo.  Tips：请输入你不需要的组件的序号，使前面的 + 变成 - 
	echo.        如果组件前为 * ，则该组件不能被精简。
	echo.
	set /p MenuChoice=请输入你的选项后按回车：

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
:: 移除 Windows 10 v1809/v1903/v1909/v2004/v20H2/v21H1/v21H2/v22H2、Windows 11 v21H2/v22H2 客户端系统菜单
if "%SelectedSourceOS%" neq "w7" if "%SelectedSourceOS%" neq "w81" if "%ImageBuild%" geq "17763" if "%ImageBuild%" leq "22631" (
	cls
	echo.===============================================================================
	echo.                                系统组件
	echo.===============================================================================
	echo.
	echo.  [ 1] %C_AccessibilityTools% 辅助工具（轻松访问）
	echo.         辅助功能向导和工具可用于配置你的系统，以满足你的视觉、听力和移动需
	echo.         求。包括基本的辅助功能，如筛选键。
	echo.
	if "%ImageFlag%" equ "EnterpriseS" (
		echo.  [ 2] %C_Calculator% 旧版计算器
		echo.         Windows Win32 计算器。
		echo.
	)
	if "%ImageFlag%" equ "EnterpriseSN" (
		echo.  [ 2] %C_Calculator% 旧版计算器
		echo.         Windows Win32 计算器。
		echo.
	)
	echo.  [ 3] %C_DeviceLockdown% 设备锁定（嵌入式体验）
	echo.         包括自定义登录、键盘筛选器、shell 启动器、无品牌启动和统一写入筛选器。
	echo.
	echo.  [ 4] %C_EaseOfAccessCursors% 轻松访问光标
	echo.         鼠标指针（辅助功能工具）。
	echo.         依赖于        ：辅助工具（轻松访问）
	echo.
	echo.  [ 5] %C_EaseOfAccessThemes% 轻松访问主题
	echo.         包含轻松访问主题、高对比度变化。
	echo.         依赖于        ：辅助工具（轻松访问）
	echo.
	echo.  [ 6] %C_EasyTransfer% 轻松传送
	echo.         帮助你将文件和设置移动到新电脑。
	echo.         兼容性        ：Windows 升级
	echo.
	echo.  [ 7] %C_FileHistory% 文件历史记录
	echo.         自动备份库中包含的文件的修订版本。
	echo.
	if "%SelectedSourceOS%" equ "w11" if "%ImageBuild%" geq "22621" if "%ImageBuild%" leq "22631" (
		echo.  [ 8] %C_LiveCaptions% 实时字幕
		echo.         实时字幕辅助功能扩展。
		echo.         依赖于        ：辅助工具（轻松访问）
		echo.
	)
	echo.  [ 9] %C_Magnifier% 放大镜
	echo.         Microsoft 放大镜是一种显示实用程序，它通过创建一个单独的窗口来显示屏幕
	echo.         的放大部分，从而使计算机屏幕更具可读性。
	echo.         依赖于        ：辅助工具（轻松访问）
	echo.
	echo.  [10] %C_ManualSetup% 手动安装程序（Windows 就地升级）
	echo.         就地升级将安装 Windows 10/11，而无需事先删除客户端计算机上的旧版本操作
	echo.         系统。该过程会自动维护现有设置、程序和数据。
	echo.         兼容性        ：Windows 升级
	echo.
	echo.  [11] %C_Narrator% 讲述人
	echo.         Windows 讲述人是一种文本到语音转换实用工具，用于读取屏幕上显示的内容、
	echo.         活动窗口的内容、菜单选项或已键入的文本。
	echo.         依赖于        ：辅助工具（轻松访问）、语音识别
	echo.
	if "%SelectedSourceOS%" equ "w10" echo.  [12] %C_Notepad% 记事本
	if "%SelectedSourceOS%" equ "w11" echo.  [12] %C_Notepad% 旧版记事本
	echo.         Windows 记事本是 Windows 的简单文本编辑器，它可创建和编辑纯文本文档。
	echo.
	echo.  [13] %C_OnScreenKeyboard% 屏幕键盘
	echo.         屏幕键盘在计算机屏幕上显示虚拟键盘，允许用户使用指针设备或操纵杆键入
	echo.         数据。
	echo.         依赖于        ：辅助工具（轻松访问）
	echo.
	if "%SelectedSourceOS%" equ "w10" (
		echo.  [14] %C_Paint% 画图
		echo.         画图是一个简单的光栅图形和编辑工具。
		echo.
	)
	if "%SelectedSourceOS%" equ "w11" if "%ImageFlag%" equ "EnterpriseS" (
		echo.  [14] %C_Paint% 旧版画图
		echo.         画图是一个简单的光栅图形和编辑工具。
		echo.
	)
	if "%SelectedSourceOS%" equ "w11" if "%ImageFlag%" equ "EnterpriseSN" (
		echo.  [14] %C_Paint% 旧版画图
		echo.         画图是一个简单的光栅图形和编辑工具。
		echo.
	)
	echo.  [15] %C_ProjFS% Projected File System（ProjFS）
	echo.         允许应用程序创建虚拟文件系统，这些文件系统看起来与本地文件夹无关，但
	echo.         它们的全部内容由程序实时生成。
	echo.
	echo.  [16] %C_SecurityCenter% 安全中心
	echo.         安全中心是监视计算机安全和维护状态的工具。
	echo.         依赖于        ：Windows Defender
	echo.         兼容性        ：应用程序防护 / 容器
	echo.
	echo.  [17] %C_StepsRecorder% 步骤记录器
	echo.         步骤记录器是一种故障排除和辅助工具，用于记录用户在计算机上执行的操作。
	echo.         一旦记录下来，这些信息就可以与个人或团体协助进行故障排除的任何内容有
	echo.         关。
	echo.
	echo.  [18] %C_StorageSpaces% 存储空间
	echo.         允许你获取不同大小和接口的多个磁盘并将它们组合在一起，以便操作系统将它
	echo.         们视为一个大磁盘。
	echo.
	echo.  [19] %C_SystemRestore% 系统还原
	echo.         此选项将电脑带回较早的时间点，称为系统还原点。
	echo.
	if "%SelectedSourceOS%" equ "w11" if "%ImageBuild%" geq "22621" if "%ImageBuild%" leq "22631" (
		echo.  [20] %C_VoiceAccess% 语音访问
		echo.         语音访问扩展。
		echo.         依赖于        ：语音识别
		echo.
	)
	echo.  [21] %C_WindowsBackup% Windows 备份
	echo.         它可以创建文件夹或系统映像备份，以便在需要时用于恢复。
	echo.
	echo.  [22] %C_WindowsFirewall% Windows 防火墙
	echo.         Windows 防火墙 UI 及其功能。
	echo.         兼容性        ：应用程序防护 / 容器，推荐
	echo.
	echo.  [23] %C_WindowsSubsystemForLinux% 适用于 Linux 的 Windows 子系统（WSL）
	echo.         提供用于在 Windows 上运行本机用户模式 Linux shell 和工具的服务和环境。
	echo.
	echo.  [24] %C_WindowsToGo% Windows To Go
	echo.         在 USB 大容量存储设备（如 USB 闪存驱动器和外部硬盘驱动器）上准备便携式 
	echo.         Windows，并具有完全可管理的企业 Windows 环境。
	echo.
	echo.  [25] %C_WindowsUpdate% Windows 更新
	echo.         使计算机能够从 Microsoft或 WSUS 服务器获取 Windows 更新、联机添加新语
	echo.         言以及安装 WUSA MSU 更新程序包。
	echo.         兼容性        ：Windows 更新
	echo.
	echo.  [26] %C_Wordpad% 写字板
	echo.         Microsoft 写字板是一个富文本编辑器，具有一些基本的文字处理功能。
	echo.
	echo.  [A]    所有系统组件
	echo.  [B]   回到上一步
	echo.  [N]   下一步
	echo.
	echo.===============================================================================
	echo.
	echo.  Tips：请输入你不需要的组件的序号，使前面的 + 变成 - 
	echo.        如果组件前为 * ，则该组件不能被精简。
	echo.
	set /p MenuChoice=请输入你的选项后按回车：

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
:: 移除 Windows 10 v1809/v1903/v1909/v2004/v20H2/v21H1/v21H2/v22H2、Windows 11 v21H2/v22H2 客户端版本系统应用菜单
if "%SelectedSourceOS%" neq "w7" if "%SelectedSourceOS%" neq "w81" if "%ImageBuild%" geq "17763" if "%ImageBuild%" leq "22631" (
	cls
	echo.===============================================================================
	echo.                                  系统应用
	echo.===============================================================================
	echo.
	echo.  [ 1] %C_AddSuggestedFoldersToLibraryDialog% “添加文件夹建议”对话框（Microsoft.Windows.AddSuggestedFoldersToLibraryDialog）
	echo.         “添加文件夹建议”对话框是一个系统应用，用于显示一个对话框，提示你将建
	echo.         议的文件夹添加到库中，以便应用可以看到它们。
	echo.
	echo.  [ 2] %C_AppResolverUX% App Resolver（Microsoft.Windows.AppResolverUX）
	echo.         App Resolver 是用于解析应用快捷方式的系统应用。此应用负责在单击快捷方
	echo.         式图标时查找要启动的正确应用。
	echo.
	if "%ImageFlag%" neq "Core" if "%ImageFlag%" neq "CoreN" if "%ImageFlag%" neq "CoreSingleLanguage" (
		echo.  [ 3] %C_AssignedAccessLockApp% “指定访问锁定”应用（Microsoft.Windows.AssignedAccessLockApp）
		echo.         指定访问锁定应用是用于将 Windows 设备锁定到单个应用中的系统应用，此应
		echo.         用在分配的访问权限用户登录时启动。此应用用于创建和管理分配的访问权限会
		echo.         话，这允许你锁定设备，以便只能运行单个应用。
		echo.         依赖于        ：分配的访问权限
		echo.
	)
	echo.  [ 4] %C_AsyncTextService% Asynchronous Text 服务（Microsoft.AsyncTextService）
	echo.         Asynchronous Text 服务是一个系统应用，它提供内置应用（如联系人）之间的
	echo.         相互通信或为桌面贴纸提供扩展。
	echo.
	if "%ImageBuild%" geq "18362" if "%ImageBuild%" leq "22631" (
		echo.  [ 5] %C_CallingShellApp% Call（Microsoft.Windows.CallingShellApp）
		echo.         Call Progress 应用是一个系统应用，它为拨打和接听电话提供了新的体验。
		echo.         Calling Shell 应用是旧电话应用的替代品，包括 Wi-Fi 呼叫、VoIP 呼叫以
		echo.         及与 Microsoft Teams 集成等功能。
		echo.
	)
	echo.  [ 6] %C_OOBENetworkCaptivePortal% Captive Portal Flow（Microsoft.Windows.OOBENetworkCaptivePortal）
	echo.         Captive Portal Flow 是一个系统应用，用于在 Windows 安装程序的开箱即
	echo.         用体验（OOBE）阶段处理 Captive Portal 身份验证。Captive Portal 是某
	echo.         些 Wi-Fi 网络显示的网页，要求用户接受服务条款或输入凭据，然后才能访
	echo.         问 internet。
	echo.         依赖于        ：全新安装体验（OOBE）
	echo.
	echo.  [ 7] %C_CapturePicker% Capture Picker（Microsoft.Windows.CapturePicker）
	echo.         捕获选择器是一个系统应用，允许你选择屏幕上的项目以捕获设备上的屏幕截
	echo.         图和屏幕录像。
	echo.
	if "%ImageBuild%" geq "17763" if "%ImageBuild%" leq "18363" if "%ImageFlag%" neq "EnterpriseS" if "%ImageFlag%" neq "EnterpriseSN" (
		echo.  [ 8] %C_PPIProjection% 连接（Microsoft.PPIProjection）
		echo.         连接是一个系统应用，允许你将 Windows 10 设备无线投影到另一台设备，例
		echo.         如电视或投影仪。它还用于启用“设置”应用程序中的“项目”菜单。
		echo.
	)
	echo.  [ 9] %C_ContentDeliveryManager% Content Delivery Manager（Microsoft.Windows.ContentDeliveryManager）
	echo.         Content Delivery Manager 是一个系统应用，用于将内容（如壁纸、主题、应
	echo.         用和赞助应用（消费者体验））传送到 Windows 设备。此应用负责下载和安装
	echo.         内容，并使其保持最新状态。删除此组件会禁用推广的应用（如 Candy Crush、
	echo.         Facebook 等）、建议和你的手机设置。
	echo.
	if "%ImageBuild%" geq "17763" if "%ImageBuild%" leq "18363" (
		echo.  [10] %C_Cortana% Cortana（Microsoft.Windows.Cortana）
		echo.         Cortana 是 Windows 10 设备上的个人助理，它包含 Cortana UI，这是你在与 
		echo.         Cortana 交互时看到的用户界面。它还包含 Cortana 后端，这是为 Cortana 
		echo.         功能提供支持的软件。Windows 10“开始”菜单上的搜索 UI，任务栏和设置搜索
		echo.         功能需要 Cortana。
		echo.         兼容性        ：Shell Search
		echo.
	)
	echo.  [11] %C_CredDialogHost% Credential Dialog 主机（Microsoft.CredDialogHost）
	echo.         凭据对话框是系统应用，它为 Windows Hello 提供身份验证（登录）外壳支持。
	echo.
	echo.  [12] %C_Win32WebViewHost% 桌面应用 Web 查看器（Microsoft.Win32WebViewHost）
	echo.         桌面应用 Web 查看器是系统应用，用于在 Windows 设备中托管 Web 内容。此
	echo.         应用允许你在各种应用中查看网页，例如文件资源管理器、设置应用和“开始”菜单。
	echo.
	echo.  [13] %C_AccountsControl% 电子邮件和帐户（Microsoft.AccountsControl）
	echo.         电子邮件和帐户是系统应用，用于添加、管理或删除用于登录 Microsoft 应用的 
	echo.         Microsoft 帐户。
	echo.         兼容性        ：Microsoft Store
	echo.
	echo.  [14] %C_ECApp% 目视控制（Microsoft.ECApp）
	echo.         目视控制是一个系统应用，用于管理 Windows 设备中的目视控制设备设置。
	echo.         依赖于        ：Windows 混合现实
	echo.
	echo.  [15] %C_FileExplorer% 旧版 文件资源管理器（Microsoft.Windows.FileExplorer）
	echo.         文件资源管理器是系统应用，它是一个现代文件管理应用，允许你查看、组
	echo.         织和访问计算机上的文件。
	echo.
	echo.  [16] %C_FilePicker% 文件选取器（Microsoft.Windows.FilePicker）
	echo.         文件选取器是系统应用，它是一个单一的统一界面，允许用户从文件系统或
	echo.         其他应用中选择文件和文件夹。使用文件选取器，你的应用可以访问、浏览
	echo.         和保存用户系统上的文件和文件夹。
	echo.
	echo.  [17] %C_MapControl% 地图控件
	echo.         地图控件是地图应用运行所需的核心服务。
	echo.
	echo.  [18] %C_Edge% 旧版 Microsoft Edge（Microsoft.MicrosoftEdge）
	echo.         Microsoft Edge 是 Windows 设备中存在的默认 Web 浏览器。
	echo.
	echo.  [19] %C_EdgeDevToolsClient% Microsoft Edge DevTools（Microsoft.MicrosoftEdgeDevToolsClient）
	echo.         Microsoft Edge DevTools是 Edge 浏览器的扩展，包含面向 Web 开发者的 Dev 工具。
	echo.         依赖于        ：旧版 Microsoft Edge
	echo.
	echo.  [20] %C_ParentalControls% Microsoft 家庭功能（Microsoft.Windows.ParentalControls）
	echo.         Microsoft 家庭功能是系统应用，用于管理 Windows 设备上的家长控制。它
	echo.         允许你限制对网站、应用和游戏的访问，以及设置屏幕时间限制。
	echo.
	echo.  [21] %C_NarratorQuickStart% 讲述人（Microsoft.Windows.NarratorQuickStart）
	echo.         讲述人主页是一款现代讲述人应用，可大声朗读屏幕上的文本，使盲人或视力
	echo.         低下的人更容易使用他们的计算机。
	echo.         依赖于        ：讲述人
	echo.
	echo.  [22] %C_OOBENetworkConnectionFlow% Network Connection Flow（Microsoft.Windows.OOBENetworkConnectionFlow）
	echo.         Network Connection Flow 是系统应用，可帮助用户在 Windows 安装程序的
	echo.         全新体验（OOBE）阶段连接到网络。
	echo.         依赖于        ：全新安装体验（OOBE）
	echo.
	if "%ImageBuild%" geq "19041" if "%ImageBuild%" leq "22631" (
		echo.  [23] %C_NcsiUwpApp% 网络连接状态指示器（NCSI）（NcsiUwpApp）
		echo.         网络连接状态指示器（NCSI）是一个系统应用，负责监视网络连接的状态并在
		echo.         任务栏中显示网络图标。它还会执行定期检查以验证你的网络连接是否正常工
		echo.         作。
		echo.
	)
	echo.  [24] %C_CloudExperienceHost% 全新安装体验（OOBE）（Microsoft.Windows.CloudExperienceHost）
	echo.         全新体验（OOBE）是一个系统应用，用于控制 Windows 安装程序的最后阶段，
	echo.         提示用户选项和安装程序完成。它负责为 Microsoft 帐户登录过程提供用户界
	echo.         面，以及管理 Windows 的基于云的功能。
	echo.         它也在 sysprep 通用化之后调用。
	if "%ImageBuild%" geq "17763" if "%ImageBuild%" leq "18363" (
		echo.         Windows 10 任务栏上的搜索 UI 和设置搜索功能需要。
		echo.         兼容性        ：Microsoft Store、全新安装体验（OOBE）、推荐、Shell Search
	)
	if "%ImageBuild%" geq "19041" if "%ImageBuild%" leq "22631" echo.         兼容性        ：Microsoft Store、全新安装体验（OOBE）、推荐
	echo.         警告          ：仅当使用完全无人参与的设置且在安装过程中未连接到 
	echo.                         Internet 时，或启用 SkipMACHINE 无人值守选项才删除。
	echo.
	echo.  [25] %C_PinningConfirmationDialog% 固定确认对话框（Microsoft.Windows.PinningConfirmationDialog）
	echo.         固定确认对话框是系统应用，用于在尝试将应用固定到“开始”屏幕或任务栏时显
	echo.         示确认对话框。此对话框要求你确认是否要固定应用，还允许你选择固定应用的
	echo.         位置。
	echo.
	if "%ImageBuild%" geq "17763" if "%ImageBuild%" leq "22000" (
		echo.  [26] %C_QuickAssist% 快速助手
		echo.         快速助手是一种内置的现代远程协助工具，可让你与其他人共享屏幕，以便他们
		echo.         帮助你解决问题或提供技术支持。
		echo.
	)
	echo.  [27] %C_RetailDemoContent% 零售演示内容
	echo.         零售演示内容是 Windows 设备中包含的一组文件，用于创建零售演示体验。
	echo.         适用于零售商店宣传和展示 Windows 设备。此内容包括可用于向潜在客户
	echo.         展示 Windows 设备功能的视频、图像和应用等内容。
	echo.
	echo.
	echo.  [28] %C_XGpuEjectDialog% 安全移除硬件（Microsoft.Windows.XGpuEjectDialog）
	echo.         安全删除设备是系统应用，用于在需要从计算机弹出外部图形卡（eGPU）时显示对
	echo.         话框。
	echo.
	echo.  [29] %C_SettingSync% 设置同步
	echo.         设置同步是一项功能，可让你在多个设备之间同步设置。这意味着，如果你在其中
	echo.         一台设备上更改了设置，则更改将反映在登录到同一 Microsoft 帐户的所有其他设
	echo.         备上。
	echo.
	echo.  [30] %C_ShellExperienceHost% Shell 体验主机（ShellExperienceHost）
	echo.         Windows Shell 体验是 Windows 系统进程，负责在 Windows Shell（Windows 资
	echo.         源管理器）中提供通用应用集成，尤其是任务栏。它负责在窗口界面中呈现通用
	echo.         应用，并为 Windows 10/11 提供其特有的 GUI 功能，例如“开始”按钮和“开始”
	echo.         菜单、操作中心以及时钟、网络连接和电池图标以及其他任务栏元素的浮出控
	echo.         件。
	if "%ImageBuild%" equ "17763" (
		echo.         Windows 10 任务栏上的搜索 UI 和设置搜索功能需要。
		echo.         兼容性        ：推荐、Shell Search
	)
	if "%ImageBuild%" equ "22000" echo.         依赖于        ：Microsoft Visual C++ 2015 UWP Runtime
	if "%ImageBuild%" geq "18362" if "%ImageBuild%" leq "22631" echo.         兼容性        ：推荐
	if "%ImageBuild%" equ "17763" (
		echo.         警告          ：仅当使用其他“开始”菜单程序（如 Open Shell、Start 10/11、
		echo.                         StartIsBackAll）时删除。
	)
	echo.
	if "%ImageBuild%" geq "17763" if "%ImageBuild%" leq "18363" (
		echo.  [31] %C_InputApp% 外壳输入应用程序（InputApp）
		echo.         输入应用是系统应用，用于为备用用户输入文本输入处理器（TIP）和语言栏提供
		echo.         支持。在应用程序（笔和墨迹、语音等）中启用高级用户输入服务
		echo.         兼容性        ：Microsoft Office、推荐、触摸屏设备
		echo.
	)
	if "%ImageBuild%" geq "19041" if "%ImageBuild%" leq "22631" (
		echo.  [32] %C_UndockedDevKit% Shell Services ^(MicrosoftWindows.UndockedDevKit^)
		echo.         Undocked Dev Kit（Shell Services）是系统应用，用于开发和测试旨在在可拆卸设
		echo.         备（如平板电脑和笔记本电脑）上运行的 Windows 应用。设置 -^> 系统 -^> 系统
		echo.         信息窗口需要它。Windows 10/11 资源管理器、任务栏和设置上的搜索 UI 需要。
		echo.         兼容性        ：全新安装体验（OOBE）、推荐、Shell Search
		echo.
	)
	echo.  [33] %C_SkypeORTC% Skype ORTC
	echo.         Skype ORTC 是一组 API，允许开发人员向其应用程序添加实时通信功能。它基于开放
	echo.         实时通信（ORTC）标准，此标准是实时通信的免版税开源规范。
	echo.
	echo.
	echo.  [34] %C_SmartScreen% SmartScreen（Microsoft.Windows.AppRep.ChxApp）
	echo.         Windows Defender SmartScreen 提供网络钓鱼和恶意软件筛选器，旨在通过针对包含
	echo.         已知威胁的网站黑名单扫描用户访问的 URL 来帮助防止攻击。
	echo.
	if "%ImageBuild%" geq "18362" if "%ImageBuild%" leq "22631" (
		echo.  [35] %C_StartMenuExperienceHost% “开始”菜单（Microsoft.Windows.StartMenuExperienceHost）
		echo.         “开始”菜单体验主机是一个系统应用，负责管理“开始”菜单，包括动态磁贴、搜索
		echo.         栏和电源按钮。
		if "%ImageBuild%" geq "18362" if "%ImageBuild%" leq "22000" echo.         依赖于        ：Shell Experience Host
		if "%ImageBuild%" equ "22000" echo.         Depends on    : Microsoft Visual C++ 2015 UWP Runtime
		echo.         兼容性        ：推荐, Shell Search
		echo.         警告          ：仅当使用其他开始菜单程序（如 Open Shell、Start 10/11 和 
		echo.                         StartIsBackAll）时才移除。
		echo.
	)
	if "%ImageFlag%" neq "EnterpriseS" if "%ImageFlag%" neq "EnterpriseSN" (
		echo.  [36] %C_SecureAssessmentBrowser% 参加测试（Microsoft.Windows.SecureAssessmentBrowser）
		echo.         参加测试是一个基于 Web 的应用，允许用户对各种主题进行评估，例如安全意识、
		echo.         合规性和 IT 熟练程度。
		echo.
	)
	echo.  [37] %C_WebcamExperience% Webcam 体验
	echo.         Webcam 体验是媒体功能包的一个组件，可为 Windows 设备上的网络摄像机提供
	echo.         用户体验。它包括相机应用，可让你拍摄照片和视频，以及相机设置，允许你调
	echo.         整网络摄像头的设置。
	echo.
	if "%ImageBuild%" geq "19041" if "%ImageBuild%" leq "22631" (
		echo.  [38] %C_WebView2Runtime% WebView2 Runtime
		echo.         WebView2 Runtime 是一个可再发行的运行时，用作 WebView2 应用的基础（或
		echo.         支持）Web 平台。它是 Microsoft Edge Chromium web 浏览器的精简版本，针
		echo.         对性能和安全性进行了优化。WebView2 运行时由各种应用使用，包括 Microsoft 
		echo.         Office、Microsoft Power BI 和 Visual Studio。它允许开发人员将 Web 内容（如 
		echo.         HTML、CSS 和 JavaScript）嵌入到其本机应用中。这使得创建具有本机应用外观
		echo.         的混合应用成为可能，但也可以访问 Web。
		echo.         兼容性        ：推荐
		echo.
	)
	echo.  [39] %C_CBSPreview% Windows Barcode Preview（Windows.CBSPreview）
	echo.         Windows Barcode Preview 应用是一个内置应用，可用于预览使用设备相机扫描
	echo.         的条形码。
	echo.
	echo.  [40] %C_LockApp% Windows 默认锁屏（Microsoft.LockApp）
	echo.         Windows 默认锁屏界面是首次打开计算机或将其从睡眠状态唤醒时看到的屏幕。
	echo.         锁定计算机时也可以显示它。
	echo.
	if "%ImageBuild%" geq "17763" if "%ImageBuild%" leq "19045" echo.  [43] %C_WindowsDefender% Windows Defender（Microsoft.Windows.SecHealthUI）
	if "%ImageBuild%" geq "22000" if "%ImageBuild%" leq "22631" echo.  [43] %C_WindowsDefender% Windows Defender（Microsoft.SecHealthUI）
	echo.         Windows Defender 是一个内置的防病毒程序，旨在保护你的计算机免受恶意软
	echo.         件（包括病毒、间谍软件和勒索软件）的侵害。它还包括 Windows 安全中心应
	echo.         用，这是一个用于提供安全运行状况仪表板的系统应用。安全运行状况仪表板
	echo.         是一个中心位置，您可以在其中查看计算机的安全状态，包括有关防病毒软件、
	echo.         Windows Defender 和其他安全设置的信息。
	if "%ImageBuild%" geq "22000" if "%ImageBuild%" leq "22631" echo.         依赖于        ：Microsoft UI Xaml 2.4、Microsoft Visual C++ 2015 UWP Runtime
	echo.
	if "%ImageBuild%" geq "19041" if "%ImageBuild%" leq "22631" (
		if "%ImageBuild%" geq "19041" if "%ImageBuild%" leq "22000" echo.  [42] %C_ClientCBS% Windows 用户体验（MicrosoftWindows.Client.CBS）
		if "%ImageBuild%" geq "22621" if "%ImageBuild%" leq "22631" echo.  [42] %C_ClientCBS% Windows 桌面用户体验（MicrosoftWindows.Client.CBS）
		echo.         Windows 用户体验是一个系统进程，负责管理 Windows 应用和功能的安装和服务。
		echo.         它包括输入应用程序，屏幕剪辑和以 Windows 11 为中心的开始菜单功能。
		if "%ImageBuild%" equ "22000" echo.         依赖于        ：Microsoft Visual C++ 2015 UWP Runtime
		echo.         兼容性        ：Shell Search
		echo.
	)
	echo.  [43] %C_BioEnrollment% Windows Hello 安装程序（Microsoft.BioEnrollment）
	echo.         Windows Hello 安装程序是一个系统应用，用于注册和管理生物识别数据（如指
	echo.         纹和面部扫描），以便与 Windows Hello 配合使用。此应用负责创建和存储指纹
	echo.         或面部识别模板，以及在你登录计算机或设备时对你进行身份验证。
	echo.
	echo.         兼容性        ：生物识别
	echo.
	echo.  [44] %C_WindowsMixedReality% Windows 混合现实（WMR）
	echo.         Windows 混合现实 （WMR） 是一个平台，通过兼容的头戴式显示器提供增强现实
	echo.         和虚拟现实体验。它是虚拟现实（VR）和增强现实（AR）的结合，就像 Microsoft 
	echo.         HoloLens 一样。
	echo.
	echo.  [45] %C_PrintDialog% Windows 打印（Windows.PrintDialog）
	echo.         “打印”对话框是一个预配置的对话框，允许用户选择打印机、选择要打印的页面以
	echo.         及确定其他与打印相关的设置。它是打印机和打印相关设置的简单解决方案，而不
	echo.         是配置你自己的对话框。
	echo.         兼容性        ：打印
	echo.
	echo.  [46] %C_WindowsReaderPDF% Windows 阅读器（PDF）
	echo.         Windows PDF 阅读器是一个基于 Microsoft Edge 的简单易用的 PDF 文件查看器。
	echo.         依赖于        ：Microsoft Edge
	echo.
	if "%ImageBuild%" geq "19041" if "%ImageBuild%" leq "22000" (
		echo.  [47] %C_SearchApp% Windows Search（Microsoft.Windows.Search）
		echo.         搜索是系统应用，用于为 Windows 设备中的搜索功能提供支持。它负责索引你
		echo.         的文件、文件夹和应用，以便你可以快速找到所需的内容。Windows 10/11 资
		echo.         源管理器、任务栏和设置搜索功能上的搜索 UI 需要。
		if "%ImageBuild%" equ "22000" echo.         Depends on    : Microsoft Visual C++ 2015 UWP Runtime
		echo.         兼容性        ：推荐, Shell Search
		echo.
	)
	echo.  [48] %C_PeopleExperienceHost% Windows Shell Experience（Microsoft.Windows.PeopleExperienceHost）
	echo.         Windows 命令行管理程序体验是用于管理“人脉”应用的系统应用。它还为 
	echo.         Windows 中的其他功能（如“开始”菜单中的“人脉栏”和“人物磁贴”）提供底层基础
	echo.         结构。
	echo.
	echo.  [49] %C_AADBrokerPlugin% 工作或学校帐户（Microsoft.AAD.BrokerPlugin）
	echo.         工作或学校帐户是一个 Windows 系统应用，是 Azure Active Directory（AAD）
	echo.         WAM 插件的一部分。AAD WAM 插件负责处理启用 AAD 的应用程序的身份验证请求。
	echo.         当你进入启用了 AAD 的应用程序时，AAD WAM 插件将与 Azure Active Directory 
	echo.         通信，以验证凭据并获取访问令牌。它是 Windows 应用商店登录和/或应用安装所
	echo.         必需的（无需登录即可安装免费应用），并且取决于 Azure Active Directory
	echo.         兼容性        ：Microsoft Store
	echo.
	echo.  [50] %C_XboxGameCallableUI% Xbox Game Callable 用户界面（Microsoft.XboxGameCallableUI）
	echo.         Xbox Game Callable 用户界面是一个系统应用，用于为 Xbox 游戏提供通用 UI，
	echo.         以便与 Windows 上的其他应用和服务进行交互。它是 Xbox Play Anywhere 计划
	echo.         的核心组件，此程序允许在 Windows 和 Xbox 控制台上游玩 Xbox 游戏。
	echo.
	echo.  [A]    所有多媒体组件
	echo.  [B]    回到上一步
	echo.  [N]    选择完毕，开始精简
	echo.
	echo.===============================================================================
	echo.
	echo.  Tips：请输入你不需要的组件的序号，使前面的 + 变成 - 
	echo.        如果组件前为 * ，则该组件不能被精简。
	echo.
	set /p MenuChoice=请输入你的选项 ：

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

:: 移除 Windows 组件模组
:RemoveWindowsComponents

setlocal

set Components=

cls
echo.===============================================================================
echo.                               开始精简系统
echo.===============================================================================
echo.

:: 获取安装映像索引的体系结构
for /f "tokens=2 delims=: " %%a in ('%DISM% /Get-ImageInfo /ImageFile:"%InstallWim%" /Index:%ImageIndexNo% ^| findstr /i Architecture') do (set ImageArchitecture=%%a)


:: 设置组件状态标识
for %%i in (C_AdobeFlashForWindows,C_EdgeChromium,C_EdgeWebView,C_InternetExplorer,C_FirstLogonAnimation,C_GameExplorer,C_LockScreenBackground,C_ScreenSavers,C_SnippingTool,C_SoundThemes,C_SpeechRecognition,C_Wallpapers,C_WindowsMediaPlayer,C_WindowsPhotoViewer,C_WindowsThemes,C_WindowsTIFFIFilter,C_WinSAT,C_OfflineFiles,C_OpenSSH,C_RemoteDesktopClient,C_RemoteDifferentialCompression,C_SimpleTCPIPServices,C_TelnetClient,C_TFTPClient,C_WalletService,C_WindowsMail,C_AssignedAccess,C_CEIP,C_FaceRecognition,C_KernelDebugging,C_LocationService,C_PicturePassword,C_PinEnrollment,C_UnifiedTelemetryClient,C_WiFiNetworkManager,C_WindowsErrorReporting,C_WindowsInsiderHub,C_HomeGroup,C_MultiPointConnector,C_OneDrive,C_RemoteAssistance,C_RemoteDesktopServer,C_RemoteRegistry,C_WorkFoldersClient,C_AccessibilityTools,C_Calculator,C_DeviceLockdown,C_EaseOfAccessCursors,C_EaseOfAccessThemes,C_EasyTransfer,C_FileHistory,C_LiveCaptions,C_Magnifier,C_ManualSetup,C_Narrator,C_Notepad,C_OnScreenKeyboard,C_Paint,C_ProjFS,C_SecurityCenter,C_StepsRecorder,C_StorageSpaces,C_SystemRestore,C_VoiceAccess,C_WindowsBackup,C_WindowsFirewall,C_WindowsSubsystemForLinux,C_WindowsToGo,C_WindowsUpdate,C_Wordpad,C_AADBrokerPlugin,C_AccountsControl,C_AddSuggestedFoldersToLibraryDialog,C_AppResolverUX,C_AssignedAccessLockApp,C_AsyncTextService,C_BioEnrollment,C_CallingShellApp,C_CapturePicker,C_CBSPreview,C_ClientCBS,C_CloudExperienceHost,C_ContentDeliveryManager,C_Cortana,C_CredDialogHost,C_ECApp,C_Edge,C_EdgeDevToolsClient,C_FileExplorer,C_FilePicker,C_InputApp,C_LockApp,C_MapControl,C_NarratorQuickStart,C_NcsiUwpApp,C_OOBENetworkCaptivePortal,C_OOBENetworkConnectionFlow,C_ParentalControls,C_PeopleExperienceHost,C_PinningConfirmationDialog,C_PrintDialog,C_PPIProjection,C_QuickAssist,C_RetailDemoContent,C_SearchApp,C_SecureAssessmentBrowser,C_SettingSync,C_ShellExperienceHost,C_SkypeORTC,C_SmartScreen,C_StartMenuExperienceHost,C_UndockedDevKit,C_WebcamExperience,C_WebView2Runtime,C_Win32WebViewHost,C_WindowsDefender,C_WindowsMixedReality,C_WindowsReaderPDF,C_WindowsStoreCore,C_XboxCore,C_XboxGameCallableUI,C_XGpuEjectDialog,C_3DViewer,C_AdvertisingXaml,C_Alarms,C_BingNews,C_BingWeather,C_CalculatorApp,C_Camera,C_ClientWebExperience,C_Clipchamp,C_CommunicationsApps,C_DesktopAppInstaller,C_Family,C_FeedbackHub,C_GamingApp,C_GetHelp,C_Getstarted,C_HEIFImageExtension,C_HEVCVideoExtension,C_Maps,C_Messaging,C_MixedRealityPortal,C_NETNativeFramework16,C_NETNativeFramework17,C_NETNativeFramework22,C_NETNativeRuntime16,C_NETNativeRuntime17,C_NETNativeRuntime22) do (
	if "%%i" neq "C_ManualSetup" if "!%%i!" equ "-" (
		for /f "tokens=2 delims=_" %%j in ("%%i") do (
			set "Components=!Components!%%j;"
		)
	)
)

if "%Components%" equ ""  (
	echo.未选择要精简的组件...
	goto :Stop
)

echo.-------------------------------------------------------------------------------
echo.####正在开始移除 Windows 组件##################################################
echo.-------------------------------------------------------------------------------
echo.
echo.    映像文件名称             ：Install.wim
echo.    映像索引                 ：%ImageIndexNo%
echo.    映像体系结构             ：%ImageArchitecture%
echo.    映像版本                 ：%ImageVersion%.%ImageServicePackBuild%.%ImageServicePackLevel%
echo.
echo.-------------------------------------------------------------------------------
echo.####正在移除 Windows 组件######################################################
echo.-------------------------------------------------------------------------------

if "%Components%" neq "" (
	echo.
	echo.===========================[Install.wim，索引 ：%ImageIndexNo%]============================
	echo.
	:: 移除 Windows 组件
	if "%C_ManualSetup%" equ "-" (
		"%Bin%\ToolKitHelper.exe" "%InstallMount%\%ImageIndexNo%" "%Components%ManualSetup;"
	) else (
		"%Bin%\ToolKitHelper.exe" "%InstallMount%\%ImageIndexNo%" "%Components%"
	)
	echo.
)

echo.-------------------------------------------------------------------------------
echo.####系统精简完成################################################################
echo.-------------------------------------------------------------------------------
echo.
echo.MSMG遇到精简错误就会直接终止任务，下面的组件将不会被精简。
echo.
echo.如果你没有遇到错误，所有组件全部精简，请输入1继续；
echo.
echo.如果你遇到错误，请记住报错前最后一个组件，输入2回到选择界面，取消选择报错组件。
echo.
choice /C:12 /N /M "请输入你的选项 ："
if errorlevel 2 goto :RemoveInternetMenu
if errorlevel 1 echo.

:Stop
echo.
echo.-------------------------------------------------------------------------------
echo.####正在运行 DISM++ 以精简APPX#################################################
echo.-------------------------------------------------------------------------------
echo.
echo.输入1打开Dism++用于优化系统精简APPX，输入2跳过此步进入下一个环节。
echo.
choice /C:12 /N /M "请输入你的选项 ："
if errorlevel 2 goto :skipdism
if errorlevel 1 %Bin%\DISM++\dism++%HostArchitecture%.exe
:skipdism
echo.===============================================================================
echo.

set Components=

endlocal

:: 重置组件状态标识
for %%i in (C_AdobeFlashForWindows,C_EdgeChromium,C_EdgeWebView,C_InternetExplorer,C_FirstLogonAnimation,C_GameExplorer,C_LockScreenBackground,C_ScreenSavers,C_SnippingTool,C_SoundThemes,C_SpeechRecognition,C_Wallpapers,C_WindowsMediaPlayer,C_WindowsPhotoViewer,C_WindowsThemes,C_WindowsTIFFIFilter,C_WinSAT,C_OfflineFiles,C_OpenSSH,C_RemoteDesktopClient,C_RemoteDifferentialCompression,C_SimpleTCPIPServices,C_TelnetClient,C_TFTPClient,C_WalletService,C_WindowsMail,C_AssignedAccess,C_CEIP,C_FaceRecognition,C_KernelDebugging,C_LocationService,C_PicturePassword,C_PinEnrollment,C_UnifiedTelemetryClient,C_WiFiNetworkManager,C_WindowsErrorReporting,C_WindowsInsiderHub,C_HomeGroup,C_MultiPointConnector,C_OneDrive,C_RemoteAssistance,C_RemoteDesktopServer,C_RemoteRegistry,C_WorkFoldersClient,C_AccessibilityTools,C_Calculator,C_DeviceLockdown,C_EaseOfAccessCursors,C_EaseOfAccessThemes,C_EasyTransfer,C_FileHistory,C_LiveCaptions,C_Magnifier,C_ManualSetup,C_Narrator,C_Notepad,C_OnScreenKeyboard,C_Paint,C_ProjFS,C_SecurityCenter,C_StepsRecorder,C_StorageSpaces,C_SystemRestore,C_VoiceAccess,C_WindowsBackup,C_WindowsFirewall,C_WindowsSubsystemForLinux,C_WindowsToGo,C_WindowsUpdate,C_Wordpad,C_AADBrokerPlugin,C_AccountsControl,C_AddSuggestedFoldersToLibraryDialog,C_AppResolverUX,C_AssignedAccessLockApp,C_AsyncTextService,C_BioEnrollment,C_CallingShellApp,C_CapturePicker,C_CBSPreview,C_ClientCBS,C_CloudExperienceHost,C_ContentDeliveryManager,C_Cortana,C_CredDialogHost,C_ECApp,C_Edge,C_EdgeDevToolsClient,C_FileExplorer,C_FilePicker,C_InputApp,C_LockApp,C_MapControl,C_NarratorQuickStart,C_NcsiUwpApp,C_OOBENetworkCaptivePortal,C_OOBENetworkConnectionFlow,C_ParentalControls,C_PeopleExperienceHost,C_PinningConfirmationDialog,C_PrintDialog,C_PPIProjection,C_QuickAssist,C_RetailDemoContent,C_SearchApp,C_SecureAssessmentBrowser,C_SettingSync,C_ShellExperienceHost,C_SkypeORTC,C_SmartScreen,C_StartMenuExperienceHost,C_UndockedDevKit,C_WebcamExperience,C_WebView2Runtime,C_Win32WebViewHost,C_WindowsDefender,C_WindowsMixedReality,C_WindowsReaderPDF,C_WindowsStoreCore,C_XboxCore,C_XboxGameCallableUI,C_XGpuEjectDialog,C_3DViewer,C_AdvertisingXaml,C_Alarms,C_BingNews,C_BingWeather,C_CalculatorApp,C_Camera,C_ClientWebExperience,C_Clipchamp,C_CommunicationsApps,C_DesktopAppInstaller,C_Family,C_FeedbackHub,C_GamingApp,C_GetHelp,C_Getstarted,C_HEIFImageExtension,C_HEVCVideoExtension,C_Maps,C_Messaging,C_MixedRealityPortal,C_NETNativeFramework16,C_NETNativeFramework17,C_NETNativeFramework22,C_NETNativeRuntime16,C_NETNativeRuntime17,C_NETNativeRuntime22) do (
	set "%%i=+"
)

:: 重置组件兼容性状态标识
for %%i in (CC_AdobeInstallers,CC_ApplicationGuardContainers,CC_Biometric,CC_Hyper-V,CC_MicrosoftGames,CC_MicrosoftOfice,CC_MicrosoftStore,CC_ModernAppSupport,CC_OOBE,CC_Printing,CC_Recommended,CC_ShellSearch,CC_TouchScreenDevices,CC_VisualStudio,CC_WindowsUpdate,CC_WindowsUpgrade,CC_XboxApp) do (
	set "%%i=+"
)

for %%i in (C_AADBrokerPlugin,C_AccountsControl,C_BioEnrollment,C_ClientCBS,C_CloudExperienceHost,C_Cortana,C_DesktopAppInstaller,C_EasyTransfer,C_EdgeChromium,C_EdgeWebView,C_GameExplorer,C_GamingApp,C_InputApp,C_InternetExplorer,C_KernelDebugging,C_ManualSetup,C_NETNativeFramework16,C_NETNativeFramework17,C_NETNativeFramework22,C_NETNativeRuntime16,C_NETNativeRuntime17,C_NETNativeRuntime22,C_OfflineFiles,C_PinEnrollment,C_PrintDialog,C_RemoteDesktopClient,C_RemoteDesktopServer,C_SearchApp,C_SecurityCenter,C_ShellExperienceHost,C_StartMenuExperienceHost,C_UIXaml20,C_UIXaml24,C_UIXaml27,C_UndockedDevKit,C_VCLibs140UWP,C_VCLibs140UWPDesktop,C_WindowsErrorReporting,C_WindowsFirewall,C_WindowsStore,C_WindowsStoreCore,C_WindowsUpdate,C_WinSAT,C_XboxIdentityProvider,C_XboxCore,C_XboxApp) do (
	if "%%i" equ "C_WindowsErrorReporting" if "%ImageBuild%" geq "18362" if "%ImageBuild%" leq "18363" set "%%i=*"
	if "%%i" equ "C_ClientCBS" if "%ImageBuild%" geq "19041" if "%ImageBuild%" leq "22631" set "%%i=*"
	if "%%i" neq "C_ClientCBS" if "%%i" neq "C_WindowsErrorReporting" set "%%i=*"
)

goto :ApplyTweaksMenu

:: 应用调整菜单
:ApplyTweaksMenu

setlocal
set Tweak=

echo.正在安装映像注册表……
call :MountImageRegistry "%InstallMount%\%ImageIndexNo%"
cls
echo.===============================================================================
echo.                                  系统优化
echo.===============================================================================
echo.

if "%SelectedSourceOS%" equ "w10" (
	echo.  [ 1]   禁止通过 Windows 更新自动更新驱动
	echo.  [ 2]   禁用自动下载并安装第三方应用
	echo.  [ 3]   禁用自动执行 Windows 升级
	echo.  [ 4]   禁用 Cortana 应用
	echo.  [ 5]   禁用下载文件夹自动按日期分组布局
	echo.  [ 6]   禁用 Microsoft 用于 Windows 更新保留的存储空间
	echo.  [ 7]   禁用 Windows Defender
	echo.  [ 8]   禁用 Windows 防火墙
	echo.  [ 9]   禁用 Windows SmartScreen
	echo.  [10]   禁用 Windows 更新
	echo.  [11]   使用完整 ResetBase 启用 DISM 映像清理
	echo.  [12]   启用 Fraunhofer MP3 Professional Codec
	echo.  [13]   启用 Windows 照片查看器
	echo.  [14]   强制让 .NET 程序使用最新的 .NET Framework
	echo.  [15]   隐藏任务栏 Cortana 图标
	echo.  [16]   隐藏任务栏立即开会图标
	echo.  [17]   隐藏任务栏资讯和兴趣
	echo   [18]   隐藏任务栏搜索栏
	echo.  [19]   隐藏任务栏任务视图图标
	echo.
	echo.  [A]    所有调整
	echo.  [X]    下一步
	echo.
	echo.===============================================================================
	echo.
	echo.  Tips：此界面不支持批量选择
	echo.
	set /p MenuChoice=请输入你的选项 ：

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
	echo.  [ 1]   禁止通过 Windows 更新自动更新驱动
	echo.  [ 2]   禁用自动下载并安装第三方应用
	echo.  [ 3]   禁用自动下载并安装 Microsoft Teams 应用
	echo.  [ 4]   禁用自动执行 Windows 升级
	echo.  [ 5]   禁用 Cortana 应用
	echo.  [ 6]   禁用下载文件夹自动按日期分组布局
	echo.  [ 7]   禁用 Microsoft 用于 Windows 更新保留的存储空间
	echo.  [ 8]   禁用 Windows 11 安装程序硬件检查
	echo.  [ 9]   禁用 Windows Defender
	echo.  [10]   禁用 Windows 防火墙
	echo.  [11]   禁用 Windows SmartScreen
	echo.  [12]   禁用 Windows 更新
	echo.  [13]   使用完整 ResetBase 启用 DISM 映像清理
	echo.  [14]   启用 Fraunhofer MP3 Professional Codec
	echo.  [15]   启用 Windows 经典上下文菜单
	echo.  [16]   启用 Windows 本地帐户
	echo.  [17]   启用 Windows 照片查看器
	echo.  [18]   强制让 .NET 程序使用最新的 .NET Framework
	echo.  [19]   隐藏任务栏聊天图标
	echo.  [20]   隐藏任务栏 Cortana 图标
	echo.  [21]   隐藏任务栏立即开会图标
	echo.  [22]   隐藏任务栏资讯和兴趣
	echo   [23]   隐藏任务栏搜索栏
	echo.  [24]   隐藏任务栏任务视图图标
	echo.  [25]   隐藏任务栏小组件图标
	echo.  [26]   设置任务栏对齐方式为左对齐
	echo.  [27]   禁用遥测
	echo.
	echo.  [A]    所有调整
	echo.  [X]    下一步
	echo.
	echo.===============================================================================
	echo.
	echo.  Tips：此界面不支持批量选择
	echo.
	set /p MenuChoice=请输入你的选项 ：

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
echo.                                 系统优化
echo.===============================================================================
echo.
:: 获取更新后的映像信息
if "%ImageBuild%" geq "18362" if "%ImageBuild%" leq "19045" (
	:: 获取已更新的映像索引信息模组
	for /f "tokens=3 delims= " %%x in ('reg query "HKLM\TK_SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v "CurrentBuild" ^| find "REG_SZ"') do (set /a ImageBuild=%%x)
	set "ImageVersion=10.0.%ImageBuild%"
	for /f "tokens=3 delims= " %%y in ('reg query "HKLM\TK_SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v "UBR" ^| find "REG_DWORD"') do (set /a ImageServicePackBuild=%%y)
)

:: 获取安装映像索引的体系结构
for /f "tokens=2 delims=: " %%a in ('%DISM% /Get-ImageInfo /ImageFile:"%InstallWim%" /Index:%ImageIndexNo% ^| findstr /i Architecture') do (set ImageArchitecture=%%a)


echo.-------------------------------------------------------------------------------
echo.####正在开始应用调整###########################################################
echo.-------------------------------------------------------------------------------
echo.
echo.    映像文件名称             ：Install.wim
echo.    映像索引                 ：%ImageIndexNo%
echo.    映像体系结构             ：%ImageArchitecture%
echo.    映像版本                 ：%ImageVersion%.%ImageServicePackBuild%.%ImageServicePackLevel%
echo.
echo.-------------------------------------------------------------------------------
if "%Tweak%" equ "AllTweaks" echo.####正在应用所有调整###########################################################
if "%Tweak%" equ "Disable3RDPartyApps" echo.####正在应用禁用自动下载并安装第三方应用调整###################################
if "%Tweak%" equ "DisableCortanaApp" echo.####正在应用禁用 Cortana 应用调整##############################################
if "%Tweak%" equ "DisableDownloadsLayout" echo.####正在应用禁用下载文件夹自动按日期分组布局调整###############################
if "%Tweak%" equ "DisableDriversUpdates" echo.####正在应用禁止通过 Windows 更新自动更新驱动调整##############################
if "%Tweak%" equ "DisableReservedStorage" echo.####正在应用禁用 Microsoft 用于进行 Windows 更新保留的存储空间#################
if "%Tweak%" equ "DisableTeamsApp" echo.####正在应用禁用自动下载并安装 Teams 应用调整##################################
if "%Tweak%" equ "DisableW11InstHardwareCheck" echo.####正在应用禁用 Windows 11 安装程序硬件检查###################################
if "%Tweak%" equ "DisableWindowsDefender" echo.####正在应用禁用 Windows Defender 调整#########################################
if "%Tweak%" equ "DisableWindowsFirewall" echo.####正在应用禁用 Windows 防火墙调整############################################
if "%Tweak%" equ "DisableWindowsSmartScreen" echo.####正在应用禁用 Windows SmartScreen 调整######################################
if "%Tweak%" equ "DisableWindowsUpdate" echo.####正在应用禁用 Windows 更新调整##############################################
if "%Tweak%" equ "DisableWindowsUpgrade" echo.####正在应用禁用自动升级 Windows 操作系统调整##################################
if "%Tweak%" equ "EnableClassicContextMenu" echo.####正在应用启用 Windows 经典上下文菜单########################################
if "%Tweak%" equ "EnableFMP3ProCodec" echo.####正在应用启用 Fraunhofer MP3 Professional Codec 调整########################
if "%Tweak%" equ "EnableFullResetBase" echo.####正在应用使用完整 ResetBase 启用 DISM 映像清理调整##########################
if "%Tweak%" equ "EnableLocalAccount" echo.####正在应用启用 Windows 本地帐户调整##########################################
if "%Tweak%" equ "EnablePhotoViewer" echo.####正在应用启用 Windows 照片查看器调整########################################
if "%Tweak%" equ "ForceLatestNetFramework" echo.####正在应用强制 .NET 程序使用最新的 .NET Framework 调整#######################
if "%Tweak%" equ "HideChatIcon" echo.####正在应用隐藏任务栏聊天图标调整#############################################
if "%Tweak%" equ "HideCortanaIcon" echo.####正在应用隐藏任务栏 Cortana 图标调整########################################
if "%Tweak%" equ "HideMeetNowIcon" echo.####正在应用隐藏任务栏立即开会图标调整#########################################
if "%Tweak%" equ "HideNewsAndInterests" echo.####正在应用隐藏任务栏资讯和兴趣调整###########################################
if "%Tweak%" equ "HideSearchBar" echo.####正在应用隐藏任务栏上的搜索栏调整###########################################
if "%Tweak%" equ "HideTaskViewIcon" echo.####正在应用隐藏任务栏任务视图图标调整#########################################
if "%Tweak%" equ "HideWidgetsIcon" echo.####正在应用隐藏任务栏小组件图标调整###########################################
if "%Tweak%" equ "SetTaskbarAlignLeft" echo.####正在应用设置任务栏对齐方式为左对齐调整#####################################
if "%Tweak%" equ "Disableyc" echo.####正在应用禁用遥测###########################################################
echo.-------------------------------------------------------------------------------

echo.
echo.==========================[Install.wim，索引 ：%ImageIndexNo%]============================
echo.
echo.正在将注册表设置合并到映像注册表……

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
echo.####应用调整已完成#############################################################
echo.-------------------------------------------------------------------------------

:Stop
echo.
echo.===============================================================================
echo.
pause>nul|set /p=请按任意键继续执行……

set Tweaks=

endlocal

:: 返回到应用调整菜单
goto :ApplyTweaksMenu

:: 保存修改
:ApplyMenu

echo.正在卸载映像注册表……
call :UnMountImageRegistry
cls
echo.===============================================================================
echo.                                 保存修改
echo.===============================================================================
echo.
echo.  [1]   应用并保存到源映像文件
echo.
echo.  [2]   丢弃更改并卸载源映像文件
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

choice /C:12 /N /M "请输入你的选项 ："
if errorlevel 2 goto :DiscardSource
if errorlevel 1 goto :SaveSource

:: 保存映像
:SaveSource

setlocal

set "TrimEditions=No"

cls
echo.===============================================================================
echo.                           应用并保存更改到源映像
echo.===============================================================================
echo.
:: 清理映像
echo.-------------------------------------------------------------------------------
echo.####正在开始使用组件清理和 ResetBase 清理源映像################################
echo.-------------------------------------------------------------------------------
echo.
:: 使用 ResetBase 选项执行对 [Install.wim] 的映像组件清理
echo.-------------------------------------------------------------------------------
echo.正在执行对 [Install.wim，索引 ：%ImageIndexNo%] 的映像组件清理……
echo.-------------------------------------------------------------------------------
if exist "%InstallMount%\%ImageIndexNo%\Windows\WinSxS\pending.xml" (
	echo.
	echo.当 Pending.xml 存在时无法执行映像组件清理……
	echo.
) else (
	%DISM% /Image:"%InstallMount%\%ImageIndexNo%" /Cleanup-Image /StartComponentCleanup /ResetBase
)

echo.-------------------------------------------------------------------------------
echo.####使用组件清理和 ResetBase 清理源映像已完成##################################
echo.-------------------------------------------------------------------------------
echo.
echo.-------------------------------------------------------------------------------
echo.####正在清理映像文件夹########################################################
echo.-------------------------------------------------------------------------------
echo.
echo.正在清理映像 Windows 临时和日志文件或文件夹。
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
::清理语言
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
echo.####正在清理映像文件夹已完成###################################################
echo.-------------------------------------------------------------------------------
echo.

::精简SXS
echo.-------------------------------------------------------------------------------
echo.####正在清理WinSXS文件夹######################################################
echo.-------------------------------------------------------------------------------
echo.
echo.  [1]   轻量精简
echo.  [2]   深度精简
echo.
echo.  轻度精简可以保证系统稳定；深度精简可能会导致系统问题，请虚拟机测试后再安装。
echo.  不知道如何选择的，请选择1。
echo.
choice /C:12 /N /M "请输入你的选项 ："
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
echo.####正在开始应用并保存更改到源映像#############################################
echo.-------------------------------------------------------------------------------
echo.
if %ImageCount% neq 1 (
	choice /C:NY /N /M "你想要去除未选择的映像版本吗 ？ [是‘Y’/否‘N’] ："
	if errorlevel 2 set "TrimEditions=Yes"
	echo.
)

:: 保存并卸载源安装和恢复映像
echo.-------------------------------------------------------------------------------
echo.正在应用更改并卸载 [Install.wim，索引 ：%ImageIndexNo%] 映像……
echo.-------------------------------------------------------------------------------
%DISM% /Unmount-Image /MountDir:"%InstallMount%\%ImageIndexNo%" /Commit
echo.
if exist "%InstallMount%\%ImageIndexNo%" rd /q /s "%InstallMount%\%ImageIndexNo%" >nul

:: 使用最大压缩重建源安装映像。
echo.-------------------------------------------------------------------------------
echo.正在使用最大压缩优化源 [Install.wim] 映像……
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
echo.####应用并保存更改到源映像已完成###############################################
echo.-------------------------------------------------------------------------------
echo.

:Stop
echo.===============================================================================
echo.
pause>nul|set /p=请按任意键继续执行……

set TrimEditions=

endlocal

set SelectedSourceOS=

goto :Quit

:: 丢弃更改并卸载
:DiscardSource

cls
echo.===============================================================================
echo.                            丢弃更改并卸载源映像
echo.===============================================================================
echo.
echo.-------------------------------------------------------------------------------
echo.####正在开始丢弃更改并卸载源映像###############################################
echo.-------------------------------------------------------------------------------
echo.
echo.-------------------------------------------------------------------------------
echo.正在卸载 [Install.wim，索引 ：%ImageIndexNo%] 映像……
echo.-------------------------------------------------------------------------------
%DISM% /Unmount-Image /MountDir:"%InstallMount%\%ImageIndexNo%" /"Discard"
echo.
if exist "%InstallMount%\%ImageIndexNo%" rd /q /s "%InstallMount%\%ImageIndexNo%" >nul
echo.-------------------------------------------------------------------------------
echo.####丢弃更改并卸载源映像已完成#################################################
echo.-------------------------------------------------------------------------------
echo.

set SelectedSourceOS=

:Stop
echo.===============================================================================
echo.
pause>nul|set /p=请按任意键继续执行……

goto :Quit

:: 退出
:Quit

cls
echo.===============================================================================
echo. 	                                退出
echo.===============================================================================
echo.
echo.正在执行后期清理操作，请稍候...
echo.
call :CleanUp
echo.
echo.
echo.正在退出...
echo.
echo.===============================================================================
echo.
pause>nul|set /p=按任意键退出...

:: 恢复 DOS 窗口大小
reg delete "HKCU\Console\%%SystemRoot%%_system32_cmd.exe" /f >nul

reg add "HKU\.DEFAULT\Console" /v "FaceName" /t REG_SZ /d "Consolas" /f
reg add "HKU\.DEFAULT\Console" /v "FontFamily" /t REG_DWORD /d "0x36" /f
reg add "HKU\.DEFAULT\Console" /v "FontSize" /t REG_DWORD /d "0x100000" /f
reg add "HKU\.DEFAULT\Console" /v "FontWeight" /t REG_DWORD /d "0x190" /f
reg add "HKU\.DEFAULT\Console" /v "ScreenBufferSize" /t REG_DWORD /d "0x12c0050" /f

endlocal
exit



:: ############################################################################################
:: 子函数
:: ############################################################################################

::-------------------------------------------------------------------------------------------
:: 安装映像注册表模组
:: 输入参数 [ %~1 ：映像安装路径 ]
::-------------------------------------------------------------------------------------------
:MountImageRegistry

:: 安装映像注册表用于脱机编辑
reg load HKLM\TK_COMPONENTS "%~1\Windows\System32\config\COMPONENTS" >nul
reg load HKLM\TK_DEFAULT "%~1\Windows\System32\config\default" >nul
reg load HKLM\TK_NTUSER "%~1\Users\Default\ntuser.dat" >nul
reg load HKLM\TK_SOFTWARE "%~1\Windows\System32\config\SOFTWARE" >nul
reg load HKLM\TK_SYSTEM "%~1\Windows\System32\config\SYSTEM" >nul

goto :eof
::-------------------------------------------------------------------------------------------

::-------------------------------------------------------------------------------------------
:: 卸载映像注册表模组
:: 输入参数 [ None ]
::-------------------------------------------------------------------------------------------
:UnMountImageRegistry

:: 卸载映像注册表
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
:: 清理 MSMG 工具箱的临时文件和文件夹
::-------------------------------------------------------------------------------------------
:CleanUp

echo.正在开始清理……
echo.
echo.正在清理映像注册表安装点……
call :UnMountImageRegistry

echo.
echo.正在清理映像安装点……
for /l %%i in (1, 1, 100) do (
	if exist "%InstallMount%\%%i\Windows" Dism.exe /English /Unmount-Wim /MountDir:"%InstallMount%\%%i" /Discard >nul
)

:: 清理映像安装点文件夹
if exist "%InstallMount%" rd /q /s "%InstallMount%" >nul
if not exist "%InstallMount%" md "%InstallMount%" >nul
echo.

:: 清理日志文件夹
echo.正在清理日志文件……
if exist "%Logs%" rd /q /s "%Logs%" >nul
if not exist "%Logs%" md "%Logs%" >nul
echo.

:: 清理临时文件、文件夹
echo.正在清理临时文件……
if exist "%Temp%" rd /q /s "%Temp%" >nul
if not exist "%Temp%" md "%Temp%" >nul

echo.
echo.已完成清理……
echo.

goto :eof
::-------------------------------------------------------------------------------------------

