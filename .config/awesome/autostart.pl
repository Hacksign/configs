#!/usr/bin/perl

my %programmes = (
	'syndaemon' => 'syndaemon -t -k -i 2 -d &',
	'xfdesktop' => 'xfdesktop --disable-wm-check &',
	'compton'	=>	'compton -cfCG -o 0.85 -m 0.85 -D9 -O 0.05 -I 0.05 -l -17 -t -17 --shadow-exclude \'_NET_WM_STATE@[0]:a = "_NET_WM_STATE_MAXIMIZED_VERT"\' &',
	'volumeicon' => 'volumeicon &',
	'thunar' => 'thunar --daemon &',
	'nm-applet' => 'nm-applet&',
	'fcitx' => 'fcitx-autostart &',
	#'synapse' => 'synapse -s &',
	'goldendict' => 'goldendict &',
	'thunderbird' => 'thunderbird &',
	'myentunnel.exe' => 'wine "/home/hacksign/Software/Program Files (x86)/MyEnTunnel/myentunnel.exe" &',
	'EvernoteTray' => 'wine  "/home/hacksign/Software/Program Files (x86)/Evernote/Evernote/EvernoteTray.exe"&',
	'indicator-keylock' => 'indicator-keylock &',
	'caffeine' => 'caffeine &',
);
foreach my $key(keys %programmes){
	if(lc($key) eq 'launchy'){
		system('pkill -i -9 '.$key) if `pgrep $key|wc -l` == 1;
	}
	system($programmes{$key}) if `pgrep $key|wc -l` == 0;
}
