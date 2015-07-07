#!/usr/bin/perl

my %programmes = (
	#'syndaemon' => 'syndaemon -t -k -i 2 -d &',
	'xfdesktop' => 'xfdesktop --disable-wm-check &',
	'compton'	=>	'compton -bf -o 0.85 -m 0.85 -D9 -O 0.05 -I 0.05 &',
	'volumeicon' => 'volumeicon &',
	'thunar' => 'thunar --daemon &',
	'nm-applet' => 'nm-applet&',
	'fcitx' => 'fcitx-autostart &',
	'launchy' => 'launchy &',
	'goldendict' => 'goldendict &',
	'thunderbird' => 'thunderbird &',
	'myentunnel.exe' => 'wine "/home/hacksign/Software/Program Files (x86)/MyEnTunnel/myentunnel.exe" &',
	'EvernoteTray' => 'wine  "/home/hacksign/Software/Program Files (x86)/Evernote/Evernote/EvernoteTray.exe"&',
);
foreach my $key(keys %programmes){
	system($programmes{$key}) if `pgrep $key|wc -l` == 0;
}
