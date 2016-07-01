#!/usr/bin/perl

my %programmes = (
    'syndaemon' => 'syndaemon -t -k -i 2 -d &',
    'xfdesktop' => 'xfdesktop --disable-wm-check &',
    'compton'	=>	'compton -zcfCG -o 0.85 -m 0.85 -D9 -O 0.05 -I 0.05 -l -17 -t -17 --shadow-exclude \'_NET_WM_STATE@[0]:a = "_NET_WM_STATE_MAXIMIZED_VERT"\' && _NET_WM_OPAQUE_REGION@:c && argb &',
    'volumeicon' => 'volumeicon &',
    'thunar' => 'thunar --daemon &',
    'nm-applet' => 'nm-applet&',
    'fcitx' => 'fcitx-autostart &',
    'bcloud' => 'bcloud-gui &',
    #'synapse' => 'synapse -s &',
    'goldendict' => 'goldendict &',
    'thunderbird' => 'thunderbird &',
    'ss-qt5' => 'ss-qt5 &',
    'touchegg' => 'touchegg &',
    'EvernoteTray' => 'wine  "/home/hacksign/Software/Program Files (x86)/Evernote/Evernote/EvernoteTray.exe"&',
    'indicator-keylock' => 'indicator-keylock &',
    'caffeine' => 'caffeine &',
);
foreach my $key(keys %programmes){
    system($programmes{$key}) if `pgrep -f '$key'|wc -l` == 1;
}
