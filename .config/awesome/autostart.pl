#!/usr/bin/perl

my %programmes = (
	'volumeicon' => 'volumeicon &',
	'thunar' => 'thunar --daemon &',
	'compton'	=>	'compton -bf -o 0.85 -m 0.85 -D9 -O 0.05 -I 0.05 &',
	'wicd-client' => 'wicd-client -t&',
	'fcitx' => 'fcitx -d &',
	'launchy' => 'launchy &',
	'xfdesktop' => 'xfdesktop &',
	'autossh' => 'autossh -M 20000 -D 9050 -CnN antigfw\@vps &',
	'goldendict' => 'goldendict &',
	'EvernoteTray' => 'wine  "/home/hacksign/.wine/drive_c/Program Files/Evernote/Evernote/EvernoteTray.exe"&',
);
foreach my $key(keys %programmes){
	system($programmes{$key}) if `pgrep $key|wc -l` == 0;
}
