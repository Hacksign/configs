function rm --description "alias rm='mv $argv ~/.local/share/Trash/files'"
	set flist (echo $argv|sed 's/-\w* //g'|sed 's/ -\w*//g')
	mv -f "$flist" ~/.local/share/Trash/files
end
