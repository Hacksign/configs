#!/usr/bin/perl

my %programmes = (
	'volumeicon' => 'volumeicon &',
	'xcompmgr' => 'xcompmgr -cCfF -r7 -o.65 -l-10 -t-8 -D1 &',
	'wicd-client' => 'wicd-gtk -t&',
	'fcitx' => 'fcitx -d &',
	'launchy' => 'launchy &',
	'autossh' => 'autossh -M 20000 -D 9050 -CnN antigfw\@vps &',
	'EvernoteTray' => 'wine  "/home/hacksign/.wine/drive_c/Program Files/Evernote/Evernote/EvernoteTray.exe"&',
);
foreach my $key(keys %programmes){
	system($programmes{$key}) if `pgrep $key|wc -l` == 0;
}
