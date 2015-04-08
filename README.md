##ArchLinux Install Guide
======
#1.原则
	只使用进入core/community/extra仓库的工具,除非这三个源中没有此套件再使用AUR源中的包
	尽量少的依赖关系
	尽量少的磁盘空间占用

#2.重要
	安装过程,chroot后,一定要安装的包,不要等重启后在安装,有可能连接不上网络或根本不能重启:
	grub
	net-tools

#3.安装的包
	base
	base-devel
	xorg-server
	xorg-utils
	xorg-xinit	:	startx等命令
	xorg-xrandr	:	屏幕分辨率以及多屏管理支持,awesome要用到
	xorg-xprop	:	窗口属性查看器，下面的awesome窗口管理器要用到
	xf86-input-synaptics	:	触控板驱动模块,https://wiki.archlinux.org/index.php/Touchpad_Synaptics
	sudo
	acpid	:	电源管理守护进程
		systemctl enable acpid
	awesome : 平铺式窗口管理器
		vicious
	terminator : 终端模拟器
		wiki:https://code.google.com/p/jessies/w/list
	evince	:	PDF查看器
	ristretto : Image查看器
	galculator : 计算器
	goldendict : 字典
		这个字典支持好多中格式的词库,词库可以网上搜索,或者使用本git中.goldendict目录下的文件.
        需要在 "编辑"/"字典"/"构词法" 中设置以下构词法为本git中.goldendict/morphology/才能提高英文单词识别率
	bcloud	: 百度云盘Linux客户端
		gnome-keyring 如果需要记住密码&自动登录的特性,需要安装这个包
	thunar	:	文件管理器
		gksu
		gvfs
		xfce4-panel
		tumbler
		thunar-volman
		thunar-archive-plugin
		thunar-media-tags-plugin
		如果遇到没有图标的情况,需要设置~/.gtkrc-2.0文件,加上gtk-icon-theme-name="XXX"即可
	xfdesktop : 与awesome配合使用,可以有一个windows风格的桌面
	thunderbird : 邮件客户端
		FireTray firefox的Add-on,可以最小化到托盘以及启动时最小化,支持linux
		Mark GMail Read 对Gmail文件夹中的邮件自动Mark read,不用每次从Inbox里面mark一边,然后再从gmail的文件夹中mark一边
		Super Date Format 格式化接受时间列的时间格式
		Thunderbird Conversations 按照会话模式显示邮件
	smplayer : mplayer的一个前端
		smplayer-themes 主题包
		smplayer-skins 皮肤
	xfce4-screenshooter :	截图
	xcompmgr	:	简单的窗口透明特效管理
		注意,不知道什么原因这个可能会导致Xorg持续占用很高的cpu,可以试一下compton,这个是xcompmgr的另外一个form版本,功能更强大.
		compton -cCGfF -o 0.38 -O 200 -I 200 -t 0 -l 0 -r 3 -D2 -m 0.88
	volumeicon	:	音量调节
		alsa-utils
        pulseaudio-alsa : 下面的pavucontrol需要安装这个才可以正常工作
		pavucontrol : 一套高级输入输出设备管理的GUI前端,在volumeicon设置中,将'external mixer'设置为它即可
	------------------------------------------------------------------------------------------------------------------------
	--以下两个套件选择一个,都是用来管理图形化网络配置的,nm支持VPN,wicd目前还不支持
	network-manager-applet :
		需要先安装networkmanager,然后systemctl enable NetworkManager
        然后是登录VPN需要的几个插件:
        networkmanager-openconnect
        networkmanager-openvpn
        networkmanager-pptp
        networkmanager-vpnc
	wicd	:	网络管理
		wicd-gtk	:	网络链接管理器,需要systemctl enable wicd
	------------------------------------------------------------------------------------------------------------------------
	system-config-printer : 打印机图形化前端,这个注意看pacman的推荐安装
		cups服务,并且systemctl enable org.cups.cupsd.service启用服务,不然这个前端不可用
		python-packagekit
		python-pysmbc
		等,根据需要安装
	fcitx	:	中文输入法
		aspell	:	fcitix拼写预测支持
		fcitx-cloudpinyin	:	一定要先安装fcitx再装这个，不然可能找不到中文输入法，云输入法
		fcitx-configtool	:	图形界面配置支持
		fcitx-gtk2
		fcitx-gtk3
		fcitx-qt4
		配置请参考:https://wiki.archlinux.org/index.php/Fcitx_(简体中文)
		如果想中文状态下输入英文字符,修改/usr/share/fcitx/data/punc.mb.zh_CN的映射关系
		/etc/profile需要设置的几个变量：
		export GTK_IM_MODULE=fcitx
		export QT_IM_MODULE=fcitx
		export XIM=fcitx
		export XIM_PROGRAM=fcitx
		export XMODIFIERS="@im=fcitx"
	virtualbox : 虚拟机
		host机器为安装virtualbo的机器,guest机器为虚拟出来的系统机器
		需要安装linux-headers包,否则vboxsf等内核模块不能正常加载
		记得安装virtualbox-guest-utils并systemctl enable vboxservice,具体请参考下面的链接
		https://wiki.archlinux.org/index.php/VirtualBox
	autossh	:	ssh socks5代理守护进程
	git	:	代码管理
	launchy	:	启动器
	adobe-source-han-sans-cn-fonts :	中文字体
	file-roller	:	归档管理器
		p7zip
		unrar
		unzip
	firefox
		flashplugin
		//下面这些是firefox的音频/视频解码包,有些地方,比如qq音乐需要用到一些特殊音频的解码,如aac
		gst-libav 1.4.4-1
		gst-plugins-base 1.4.4-1
		gst-plugins-base-libs 1.4.4-1
		gst-plugins-good 1.4.4-1
		gst-plugins-ugly 1.4.4-2
		gstreamer 1.4.4-1
		gstreamer0.10 0.10.36-4
		gstreamer0.10-bad 0.10.23-8
		gstreamer0.10-bad-plugins 0.10.23-8 (gstreamer0.10-plugins)
		gstreamer0.10-base 0.10.36-3
		gstreamer0.10-base-plugins 0.10.36-3 (gstreamer0.10-plugins)
		gstreamer0.10-ffmpeg 0.10.13-2 (gstreamer0.10-plugins)
		gstreamer0.10-good 0.10.31-6
		gstreamer0.10-good-plugins 0.10.31-6 (gstreamer0.10-plugins)
		gstreamer0.10-ugly 0.10.19-13
		gstreamer0.10-ugly-plugins 0.10.19-13 (gstreamer0.10-plugins)
	fish	:	类似bash的shell，提示和颜色更加全面
	qt4
	gtk2
	gtk3
		gtk-aurora-engine
		gtk-chtheme
		gtk-engine-murrine
		gtk-engines
		gtk-update-icon-cache
		clearlooks-phenix :	gtk2&gtk3主题，需要用git从https://github.com/jpfleury/clearlooks-phenix下载
	human-icon-theme
		然后拷贝此git源usr/share/icon/XcursorHuman到/usr/share/icon下，并
		ln -sv /usr/share/icon/Human/index.theme /usr/share/icon/default/index.theme
		随后修改/usr/share/icon/default/index.theme,再Name字段下添加下面一行
		Inherits=XcursorHuman
		更改鼠标主题
	ntfs-3g
	nvidia-340xx
	nvidia-340xx-libgl
	nvidia-340xx-utils
	vim or gvim
		vim-ctrlp : 快速打开目录下的文件
		vim-minibufexpl : 在顶部显示多个缓冲区标签
        vim-a : 在头文件和源文件快速切换
        vim-surround : 快速改面'"([{包围
        //下面两个在aur源
        vim-delimitmate : 自动补全'"([{
        vim-mark : 自动高亮cursor下的关键字(背景高亮)
	wine
		wine-mono
		wine_gecko
		然后用regedit /s wine_font.reg导入字体设置,并拷贝simsun.ttc字体到~/.wine/drive_c/windows/Fonts目录下
		更改~/.wine/drive_c/*.reg中的tahoma关联的字体为simsun.ttc,详见http://linux-wiki.cn/wiki/zh-hans/Wine的中文显示与字体设置
	AUR源	:	以下内容到/etc/pacman.conf最后
		[archlinuxfr]
		SigLevel = Never
		Server = http://repo.archlinux.fr/$arch
	xf86-input-evdev-trackpoint	:	小红点支持，此包必须从AUR源获取
		这个的配置文件对触控板区域设置偏小,需要根据自己的需求调整

#4.配置
	时间配置:
		主要是hwclock和timedatectl两个命令的配合使用,具体请用--help参数查看帮助.
		1.ln -sv /usr/share/zoneinfo/Asia/Shanghai /etc/localtime  设置好时区
		2.然后用timedatectl看一下localtime和utc time是否式正确的,如果不是正确的,则使用set-time 'YYYY-MM-DD HH:MM:SS'设置时间
		3.最后用hwclock --localtime --hctosys设置本地硬件时间为系统时间

#参考资料:
	一个可用套件的列表介绍:https://wiki.xfce.org/recommendedapps
