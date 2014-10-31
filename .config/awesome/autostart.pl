#!/usr/bin/perl

my %programmes = (
	'volumeicon' => 'volumeicon &',
	'xcompmgr' => 'xcompmgr -s -n -Cc -fF -l-10 -O-10 -D1 -t-3 -l-4 -r4&',
	'wicd-client' => 'wicd-gtk -t&',
	'fcitx' => 'fcitx -d &',
	'launchy' => 'launchy &',
	'EvernoteTray' => 'wine  "/home/hacksign/.wine/drive_c/Program Files/Evernote/Evernote/EvernoteTray.exe"&',
	'FSCapture' => 'wine "/home/hacksign/Software/CaptureScreen/FSCapture.exe -Silent"&',
	'udiskie' => 'udiskie&',
	'autossh' => 'autossh -M 20000 -D 9050 -CnN antigfw\@www.hacksign.cn -f&'
);
foreach my $key(keys %programmes){
	system($programmes{$key}) if `pgrep $key|wc -l` == 0;
}
