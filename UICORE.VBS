//#################################################
//注意：这是PECMD源码，不是VBS脚本！！！
//PECMD主程序下载：pecmd.net
//#################################################
//直接当PECMD用
SET &ag=%*
%&ag%
EXIT FILE

//#################################################
//导入文件
//#################################################
_SUB importfile
//打开文件
BROW 源文件,%CurDir%\DVD,请打开一个WIM/ESD镜像,WIM镜像|*.wim|ESD镜像|*.esd|,0x02082000
IFEX %源文件%,! 
{
	WRIT -,+0,您还未选择源镜像文件，请重新选择！
	EXIT FILE
}
//获取扩展名
FEXT 扩展名=%源文件%
//获取目录名
FDIR 目录=%源文件%
IFEX |%目录%=%CurDir%\DVD\sources,
{
	//获取文件名
	FNAM 文件名=%源文件%
	IFEX |%文件名%=install,! FILE %源文件%>>%目录%\install.%扩展名%
}!
{
	//复制到目标目录
	FILE %源文件%=>%CurDir%\DVD\sources\install.%扩展名%
}
WRIT -,+0,文件已导入...
_END

//#################################################
//精简WinSXS--轻量精简
//#################################################
_SUB winsxs1
//读取配置文件
ENVI 配置=%CurDir%\Bin\sxs\sxs1.txt
ENVI 目录=%~1\Windows\WinSXS
//检测配置文件是否存在
IFEX %配置%,! 
{
	WRIT -,+0,配置文件丢失！WinSXS没有精简。
	EXIT FILE
}
//while循环读取配置
ENVI readline=1
READ %配置%,%readline%,sxsfolder
LOOP $%sxsfolder%!=The_End,
{
	//通配符删除文件
	IFEX %目录%\%sxsfolder%,FILE %目录%\%sxsfolder%_*
	CALC readline=%readline% + 1
	READ %配置%,%readline%,sxsfolder
}
WRIT -,+0,WinSXS精简完成...
_END

//#################################################
//精简WinSXS--深度精简
//#################################################
_SUB winsxs2
//读取配置文件
ENVI 配置=%CurDir%\Bin\sxs\sxs2.txt
ENVI 目录=%~1\Windows
//将SXS重命名为SXSBak
FILE %目录%\WinSXS>>%目录%\WinSXSBak
MDIR %目录%\WinSXS
//检测配置文件是否存在
IFEX %配置%,! 
{
	WRIT -,+0,配置文件丢失！WinSXS没有精简。
	EXIT FILE
}
//while循环读取配置
ENVI readline=1
READ %配置%,%readline%,sxsfolder
LOOP $%sxsfolder%!=The_End,
{
	//通配符移动文件
	IFEX %目录%\WinSXSBak\%sxsfolder%,
	{
		FILE %目录%\WinSXSBak\%sxsfolder%_*->%目录%\WinSXS\
	}!
	{
		WRIT -,+0,出现错误：%sxsfolder%
	}
	CALC readline=%readline% + 1
	READ %配置%,%readline%,sxsfolder
}
WRIT -,+0,WinSXS精简完成...
_END

//#################################################
//导出--去除其它版本
//#################################################
_SUB exportonly
//打开文件
BROW 目标,&%Desktop%\install.wim,请保存最终的WIM/ESD镜像,WIM镜像|*.wim|ESD镜像|*.esd|,0x02090002
//获取后缀
RSTR 后缀=3,%目标%
//判断后缀使用不同的导出方法
IFEX |%后缀%=wim,
{
	EXEC =%CurDir%\Bin\wimlib-imagex.exe export %CurDir%\DVD\sources\install.wim %1 "%目标%" --compress=LZX
}
IFEX |%后缀%=esd,
{
	EXEC =%2 /Export-Image /compress:recovery /CheckIntegrity /SourceImageFile:%CurDir%\DVD\sources\install.wim /SourceIndex:%1 /DestinationImageFile:"%目标%"
}
_END
