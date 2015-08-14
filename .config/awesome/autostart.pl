#!/usr/bin/perl

my %programmes = (
	'syndaemon' => 'syndaemon -t -k -i 2 -d &',
	'xfdesktop' => 'xfdesktop --disable-wm-check &',
	'compton'	=>	'compton -f -o 0.85 -m 0.85 -D9 -O 0.05 -I 0.05 &',
	'volumeicon' => 'volumeicon &',
	'thunar' => 'thunar --daemon &',
	'nm-applet' => 'nm-applet&',
	'fcitx' => 'fcitx-autostart &',
	'launchy' => 'launchy &',
	#'synapse' => 'synapse -s &',
	'goldendict' => 'goldendict &',
	'thunderbird' => 'thunderbird &',
	'myentunnel.exe' => 'wine "/home/hacksign/Software/Program Files (x86)/MyEnTunnel/myentunnel.exe" &',
	'EvernoteTray' => 'wine  "/home/hacksign/Software/Program Files (x86)/Evernote/Evernote/EvernoteTray.exe"&',
	'caffeine' => 'caffeine &',
);
foreach my $key(keys %programmes){
	if(lc($key) eq 'launchy'){
		system('pkill -9 '.$key);
	}
	system($programmes{$key}) if `pgrep $key|wc -l` == 0;
}
