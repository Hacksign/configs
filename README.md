##ArchLinux Install Guide   
======   
#1.原则   
    只使用进入core/community/extra仓库的工具,除非这三个源中没有此套件再使用AUR源中的包   
    尽量少的依赖关系   
    尽量少的磁盘空间占用   
   
#2.重要   
    安装过程,chroot后,一定要安装的包,不要等重启后在安装,有可能连接不上网络或根本不能重启:   
    grub 或者用systemd自带的bootctl新增一个bootmgr,参考下面的链接:   
    https://wiki.archlinux.org/index.php/Beginners'_guide#For_UEFI_motherboards   
   
#3.安装的包   
    yaourt :   
        在/etc/pacman.conf中新增如下配置:   
            [archlinuxcn]   
            SigLevel = Optional TrustAll   
            Server   = http://repo.archlinuxcn.org/$arch   
            [archlinuxfr]   
            SigLevel = Never   
            Server = http://repo.archlinux.fr/$arch   
        然后执行命令,pacman -Sy && pacman -S yaourt   
    base   
    base-devel   
    xorg-server   
    xorg-utils   
    xorg-xinit	:	startx等命令   
    xorg-xrandr	:	屏幕分辨率以及多屏管理支持,awesome要用到   
        复制./etc/udev/rules.d/98-screen-detect.rules到/etc/udev/rules.d/目录下   
        复制./usr/lib/udev/notify-awesome到/usr/lib/udev目录下    
        经过上述步骤， 结合本目录下的.config/awesome配置，可以实现显示器自动监视、扩展的功能    
    xrdp :
        首先要参考ArchWiki：
            https://wiki.archlinux.org/title/xrdp
            注意一定要安装xorgxrdp,不然会启动不了Xorg的backend
        然后如果有自定义的文件在/etc/X11/xorg.conf.d/目录下，要注意是否使用了modesetting的Driver，如果有使用（例如nvidia的Driver），则需要修改/etc/xrdp/sesman.ini的启动参数：
            param=-configdir
            param=/etc/X11/xrdp
            param=-config
            param=xorg.conf
        最后， 如果thunar等无法链接smb等，大概率是dbus的问题， 需要安装AUR中的: dbus-x11
    avaloniailspy:
        .NET 反汇编工具的Linux版本
    plank:
        类似OS/X的Dock工具
    alltray 或者 kdocker:   
        将任意程序最小化到系统tray的工具。   
        推荐kdocker，功能性上逼alltray好一点。   
    syncthing-gtk:
        同步工具
    fusuma :   
        可以协助实现触控板手势的一个东西, ruby写的,使用如下命令安装
            gem intsall fusuma
        然后到~/.config/awesome/autostart/init.lua中激活这个选项.
        最后定义配置文件:
            ln -svf 本工程路径/.config/fusuma ~/.config/
        注意， 需要将当前用户加入到input组中：
        gpasswd -a $USER input
    libinput-gestures :
        另外一个手势任务的东西， 参考这篇文章：
        https://segmentfault.com/a/1190000011327776
        注意， 需要将当前用户加入到input组中：
        gpasswd -a $USER input
	同时需要安装 xdotool 和 wmctrl 两个软件
	安装驱动： xf86-input-libinput
	同时将此目录下的文件拷贝到系统目录 ./etc/X11/xorg.conf.d/30-magic-trackpad2.conf
    remmina:   
       一个GTK的前端，可以管理SSH、RDP（需要装插件，注意可选提示）、VNC等多种协议的链接   
       这个需要配合 rxvt-unicode 这个中断模拟器来使用，而这个中断模拟器，需要本源中.Xresources文件在$HOME下    
    shadowsocks-qt5-git :
       client side for shadowsocks
    zssh:    
       需要配合lrzsz包使用, 用于用rz和sz传输文件.    
    xorg-xprop	:
    sudo   
    acpid	:	电源管理守护进程   
    systemctl enable acpid   
    slim :   
        最好使用https://github.com/Hacksign/slim-1.3.6.git 的slim,这个版本修复了slim在多显示器环境下显示错位的问题.   
    lightdm-gtk-greeter :   
        依赖于lightdm,登录管理器.   
        *注意*如果之前使用过slim,要先systemctl disable slim,不然会出现File Exists的错误.   
        *注意*配置/etc/lighdm下的lightdm.conf和light-gtk-greeter.conf文件以适应当前系统.   
        *注意*如果需要gnome-keyring的支持,需要在/etc/pam.d/lightm-greeter中进行如下设置:   
        ```
        -auth       optional    pam_gnome_keyring.so
        -password   optional    pam_gnome_keyring.so
        -session  optional    pam_gnome_keyring.so auto_start
        ```
        并禁止掉其他所有文件中的如上行.   
        具体配置参考wiki:https://wiki.archlinux.org/index.php/LightDM   
        此外，如果想起用高对比度设置的主题， 需要在/etc/lightdm/lightdm-gtk-greeter.conf中设置如下选项    
            a11y-states = +contrast    
    awesome : 平铺式窗口管理器   
	aur/lua-luafilesystem, need install by yaourt	
    vicious   
    terminator : 终端模拟器   
    dia : 画流程图的工具   
    wiki:https://code.google.com/p/jessies/w/list   
    evince	:	PDF查看器   
    qpdfview : pdf查看器   
    blueman	:	蓝牙管理器   
        pacman -S pulseaudio-bluetooth, 不然会出现protocol not supported的问题   
        需要先system enable bluetooth   
        如果想要自启动, 启动blueman-applet即可   
    atom : 文本编辑器
    nomacs : 图片查看器，这个界面做的不错，推荐
    ristretto : Image查看器   
    galculator : 计算器   
    goldendict : 字典   
        这个字典支持好多中格式的词库,词库可以网上搜索,或者使用本git中.goldendict目录下的文件.   
        需要在 "编辑"/"字典"/"构词法" 中设置以下构词法为本git中.goldendict/morphology/才能提高英文单词识别率   
    gksu   
    gvfs   
        gvfs-nfs:  nfs支持
        gvfs-smb:  smb支持
        gnome-keyring 如果需要记住密码&自动登录的特性,需要安装这个包   
    xfce4-panel   
    xfce4-notifyd :
        一个用来显示通知的服务， 可以更美观的显示屏幕角落弹出框类型的通知。
    ultra-flat-icon   
        拷贝本源中的ultra-flat-icon到/usr/share/icon目录下,注意这个icon带鼠标主题.   
        然后拷贝本源中的.Xresources到家目录下,即可使用48px大小的鼠标主题.   
	ln -svf /usr/share/icon/ultra-flat-icon /usr/share/icons/default
    qt5ct 与 qt5-styleplugins
	安装这个文件，然后拷贝 etc/profile.d/qt.sh 到/etc/profile.d目录
        重启后在 at5ct 中设置使用gtk2主题
    tumbler   
    thunar	:	文件管理器   
        tumbler: 让thunar显示图片等文件的预览图， 如果需要其他文件的预览， 注意可选依赖。
    thunar-volman   
    thunar-archive-plugin   
    thunar-media-tags-plugin   
        如果遇到没有图标的情况,需要设置~/.gtkrc-2.0文件,加上gtk-icon-theme-name="XXX"即可   
        注意系统是否安装了处理icon主题文件的库,例如本repo中usr/share/icon/ultra-flat-icon使用了svg格式的图片文件,那么请确保系统安装了librsvg   
        xfdesktop : 与awesome配合使用,可以有一个windows风格的桌面   
        可以使用--disable-wm-check强制xfdesktop不检查窗口管理器   
    n1 : 邮件客户端    
        node写的邮件客户端, 界面上面要比thunderbird更加漂亮.   
        zenity 为n1客户端的新邮件提醒插件   
    thunderbird : 邮件客户端   
        FireTray firefox的Add-on,可以最小化到托盘以及启动时最小化,支持linux,注意:thunderbird 38.0.1和firetray 5.6.1-signed有冲突导致不能运行,建议到Firetray的下载页面下载0.4.8版本,然后禁止掉此插件的自动升级功能.   
        Mark GMail Read 对Gmail文件夹中的邮件自动Mark read,不用每次从Inbox里面mark一边,然后再从gmail的文件夹中mark一边   
        Super Date Format 格式化接受时间列的时间格式   
        Thunderbird Conversations 按照会话模式显示邮件   
    smplayer : mplayer的一个前端   
    smplayer-themes 主题包   
    smplayer-skins 皮肤   
    deepin-voice-recorder : 深度录音工具
    deepin-screen-recorder : 深度录屏工具、截图工具
	如果想要支持剪贴板复制，需要安装剪切板管理器： gpaste, 然后使用gpaste-client preferences打开图像支持， 最后设置 gpaste-client start 自动启动即可。
    xcompmgr	:	简单的窗口透明特效管理   
        注意,不知道什么原因这个可能会导致Xorg持续占用很高的cpu,可以试一下picom,这个是xcompmgr的另外一个form版本,功能更强大.   
    picom -cCGfF -o 0.38 -O 200 -I 200 -t 0 -l 0 -r 3 -D2 -m 0.88   
    bcloud :   
        百度云盘的GUI前端,记得在首选项里面打开同步文件夹的功能.    
    pulseaudio-alsa : 下面的pavucontrol需要安装这个才可以正常工作   
        pavucontrol : 一套高级输入输出设备管理的GUI前端,在volumeicon设置中,将'external mixer'设置为它即可
        volumeicon	:	音量调节   
        alsa-utils   

------------------------------------------------------------------------------------------------------------------------
    以下两个套件选择一个,都是用来管理图形化网络配置的,nm支持VPN,wicd目前还不支持   
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
    fcitx5	:	中文输入法   
        pacman -S fcitx5-im,选择全部安装   
        将本工程下的etc/profile.d/fcitx.sh拷贝到/etc/profile.d/目录下, 并重启系统   
        将本工程下的.config/fcitx/rime/default.custom.yaml链接到~/.local/share/fcitx5/rime/
    virtualbox : 虚拟机   
        host机器为安装virtualbo的机器,guest机器为虚拟出来的系统机器   
        需要安装linux-headers包,否则vboxsf等内核模块不能正常加载   
        记得安装virtualbox-guest-utils并systemctl enable vboxservice,具体请参考下面的链接   
            https://wiki.archlinux.org/index.php/VirtualBox   
        virtualbox-ext-oracle, 这个包对virtualbox提供了USB3.0等功能的支持.   
        最后将需要使用virtualbox虚拟机的用户加到vboxusers组中   
    autossh	:	ssh socks5代理守护进程   
    git	:	代码管理   
    gmrun	:	启动器   
    wqy-bitmapfont/wqy-microhei/wqy-zenhei:
      上面这三个字体需要安装, 经长期使用, 这几个字体对系统支持较好. 需要用lxappearance设置系统字体为微米黑
    adobe-source-han-sans-cn-fonts :	中文字体   
    ttf-hack :  英文字体,适合用作变成字体   
    本工程的usr/share/fonts/wqy-unibit-bdf-1.1.0-1.tar.bz2 : 将此文件解压到/usr/share/fonts/wenquanyi/unibit目录下
    ttf-symbola字体:   
        有一些特殊的符号,需要这个字体, 不然可能会出现一个框中有4个数字这种情况的字体.   
    terminus-font:
      控制台的一些字体, 需要配合本目录下面的etc/vconsole.conf文件使用
    file-roller	:	归档管理器   
    p7zip   
    unrar   
    unzip 或 unzip-iconv   
        unzip-iconv为加了-O参数的修改版本， 可以解决中文乱码的问题。    
        同时还需要将此目录下的文件放到对应的系统目录， 以解决file-roller归档管理器中查看文件的乱码问题    
          `etc/profile.d/unzip.sh`     
    firefox   
        //如果对隐私保护要求比较高,需要在首选项的'隐私'中,将'历史'设置为'使用自定义选项',将'允许第三方cookie'设置为'总不',这样一个网站只能要求自己的cookie而无权利要求其他域下的cookie.
        //如果要FF适应高分屏,请调整about:config中的layout.css.devPixelsPerPx的值为1.5(具体合适的数值请自己尝试)即可使字体大小的设置生效.   
        //目前firefox有个bug,在高分屏,高dpi,多显示器环境下下,layout.css.devPixelsPerPx的值小于2.0会导致菜单出现在错误的显示器上.如果出现这个问题请调整这个属性的值   
        //如果觉得进行上述调整后,FF的图标也跟着模糊了,请安装图标主题 GNOME Firefox theme   
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
        gstreamer0.10-ugly 0.10.    -13   
        gstreamer0.10-ugly-plugins 0.10.    -13 (gstreamer0.10-plugins)   
    caffeine-ng : 自动禁用屏保的工具.   
    fish	:	类似bash的shell，提示和颜色更加全面   
    qt4   
    gtk2   
    gtk3   
    gtk-engine-aurora
    lxappearance:   
        可以同时更换gtk2/gtk3主题/字体/鼠标指针等,GUI配置工具.
    arandr :
        一个可以设置显示器/扩展显示器的东西
    fsearch-git :
        linux下的everything
    gtk-engine-murrine   
    gtk-engines   
    gtk-update-icon-cache   
    ntfs-3g   
    nvidia-340xx   
    nvidia-340xx-libgl   
    nvidia-340xx-utils   
    indicator-keylock :   
        需要先安装依赖： pacman -S intltool
        指示大写键状态的,对于没有大写键状态提示的笔记本有用,可选依赖:   
            notification-daemon   
        注意可能依赖intltool,提示找不到intltoolize需要安装这个依赖.   
    gvim or vim   
        ctags & cscope : 编程语言的快速搜索支持   
        安装vundle-git   
        将本源中etc/vimrc拷贝到/etc下, 然后命令行执行:vim +PluginInstall   
    wine   
    wine-mono   
    wine_gecko   
        然后用regedit /s wine_font.reg导入字体设置,并拷贝simsun.ttc字体到~/.wine/drive_c/windows/Fonts目录下   
        更改~/.wine/drive_c/*.reg中的tahoma关联的字体为simsun.ttc,详见http://linux-wiki.cn/wiki/zh-hans/Wine的中文显示与字体设置   
        如果使用的是64位的系统,需要激活pacman的multilib源,然后安装源中的lib32-ncursses库   
    xf86-input-evdev-trackpoint	:	小红点支持，此包必须从AUR源获取   
        这个的配置文件对触控板区域设置偏小,需要根据自己的需求调整   
    TM2013Preview :   
        据说这个版本最稳定,没有尝试过其他的版本.
        需要在winecfg中创建一个TM.exe的选项,然后将msvcp60,riched20,riched32设置成原装,不然可能无法输入东西.   
    wps-office :   
        需要激活archlinuxcn源，然后安装此包，以及此包的字体需求ttf-wps-fonts

   
#4.配置   
    时间配置:   
        主要是hwclock和timedatectl两个命令的配合使用,具体请用--help参数查看帮助.   
            1.ln -sv /usr/share/zoneinfo/Asia/Shanghai /etc/localtime  设置好时区   
            2.然后用timedatectl看一下localtime和utc time是否是正确的,如果不是正确的,则使用set-time 'YYYY-MM-DD HH:MM:SS'设置时间   
            3.最后用hwclock --localtime --hctosys设置本地硬件时间为系统时间   
        进入windows后与linux时间不一致问题:windows认为BIOS中的时间为LocalTime,可用如下方法设置Windows对待时间为UTC,打开CMD,输入Reg add HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation /v RealTimeIsUniversal /t REG_DWORD /d 1   
    指纹识别配置:   
        此章节配置和具体机器有关,此配置适合x1 Carbon (1/2/3) & T420,其他机型没有验证过.   
        主要参考此wiki:https://wiki.archlinux.org/index.php/Fprint   
        此外,需要修改的是/etc/pam.d/下的lightdm(如果使用lightdm做登录管理器的话)/su/sudo,在行首加上:   
            auth      sufficient pam_fprintd.so   
        然后再需要指纹识别的用户权限下,运行命令fprintd-enroll   
        指纹数据库存放的目录为/var/lib/fprint   
    高分屏配置:   
        如果控件太小,例如下拉条宽度太小,需要修改/usr/share/themes目录下对应的主题控件的大小.   
    彩色命令行:   
        export PS1="\[\e[1;32m\][\[\e[1;34m\]\u\[\e[0;1m\]@\h \[\e[1;33m\]\W\[\e[1;32m\]]\[\e[1;31m\]\\$ \[\e[0m\]"   
    本人的笔记本在关机的时候,耳机会听到'次拉'一声的噪音,查资料得知需要在/etc/modprobe.d/sound.conf下加入如下行即可:   
        options snd-hda-intel model=,generic   
    在/etc/ssh/ssh_config去掉如下行的注释,防止在登录的时候出现卡在某些验证的问题:   
       MACs hmac-md5,hmac-sha1,umac-64@openssh.com,hmac-ripemd160    
   
#参考资料:   
    一个可用套件的列表介绍:https://wiki.xfce.org/recommendedapps   
