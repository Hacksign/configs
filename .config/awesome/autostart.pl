#!/usr/bin/perl

my %programmes = (
	'xfdesktop' => 'xfdesktop &',
	'compton'	=>	'compton -bf -o 0.85 -m 0.85 -D9 -O 0.05 -I 0.05 &',
	'volumeicon' => 'volumeicon &',
	'thunar' => 'thunar --daemon &',
	'nm-applet' => 'nm-applet&',
	'fcitx' => 'fcitx -d &',
	'launchy' => 'launchy &',
	'goldendict' => 'goldendict &',
	'thunderbird' => 'thunderbird &',
	'myentunnel.exe' => 'wine "/home/hacksign/.wine/drive_c/Program Files/MyEnTunnel/myentunnel.exe" &',
	'EvernoteTray' => 'wine  "/home/hacksign/.wine/drive_c/Program Files/Evernote/Evernote/EvernoteTray.exe"&',
);
foreach my $key(keys %programmes){
	system($programmes{$key}) if `pgrep $key|wc -l` == 0;
}
