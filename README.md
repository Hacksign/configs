##ArchLinux Install Guide
======
#1.原则
	只使用进入core/community/extra仓库的工具,除非这三个源中没有此套件再使用AUR源中的包
	尽量少的依赖关系
	尽量少的磁盘空间占用


#2.安装的包
	base
	base-devel
	xorg-server
	xorg-utils
	xorg-xinit	:	startx等命令
	xorg-xrandr	:	屏幕分辨率以及多屏管理支持,awesome要用到
	xorg-xprop	:	窗口属性查看器，下面的awesome窗口管理器要用到
	xf86-input-synaptics	:	触控板驱动模块,https://wiki.archlinux.org/index.php/Touchpad_Synaptics
	sudo
	awesome : 平铺式窗口管理器
		vicious
	terminator : 终端模拟器
	evince	:	PDF查看器
	ristretto : Image查看器
	thunar	:	文件管理器
		gksu
		gvfs
		xfce4-panel
		tumbler
		thunar-volman
		thunar-archive-plugin
		thunar-media-tags-plugin
	xfce4-screenshooter :	截图
	xcompmgr	:	简单的窗口透明特效管理
	volumeicon	:	音量调节
		alsa-utils
	wicd	:	网络管理
		wicd-gtk	:	网络链接管理器
	fcitx	:	中文输入法
		aspell	:	fcitix拼写预测支持
		fcitx-cloudpinyin	:	一定要先安装fcitx再装这个，不然可能找不到中文输入法，云输入法
		fcitx-configtool	:	图形界面配置支持
		fcitx-gtk2
		fcitx-gtk3
		fcitx-qt4
		配置请参考:https://wiki.archlinux.org/index.php/Fcitx_(简体中文)
		如果想中文状态下输入英文字符,修改/usr/share/fcitx/data/punc.mb.zh_CN的映射关系
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
	fish	:	类似bash的shell，提示和颜色更加全面
	checkgmail	:	gmail检查器，需要自己hack一下，使用上autossh创建的代理，需要perl的LWP::Protocol::socks包，然后/usr/bin/checkgmail脚本中所有的UserAgent实例都需要添加$ua->proxy([qw/http htts/] => "socks://host:port");支持.
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
	vim
	wine
		wine-mono
		wine_gecko
	AUR源	:	以下内容到/etc/pacman.conf最后
		[archlinuxfr]
		SigLevel = Never
		Server = http://repo.archlinux.fr/$arch
	xf86-input-evdev-trackpoint	:	小红点支持，此包必须从AUR源获取

#参考资料:
	一个可用套件的列表介绍:https://wiki.xfce.org/recommendedapps
