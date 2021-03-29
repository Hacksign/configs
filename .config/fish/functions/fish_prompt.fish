function fish_prompt --description 'Write out the prompt'
    set -l last_status $status

    # User
    set_color green
    echo -n (whoami)

    set_color normal
    echo -n '@'

    # Host
    set_color yellow
    echo -n (hostname)

    set_color cyan
    printf ' [%s] ' (date "+%H:%M:%S") 
    set_color brblue
    echo -n ': '

    # PWD
    set_color brwhite
    echo -n (prompt_pwd)

    set_color normal

    __terlar_git_prompt
    echo ''

    if not test $last_status -eq 0
			if not set -q $fish_color_error
				set_color $fish_color_error
				echo -n '>> '
			else
				set_color brred
				echo -n '>> '
			end
			else
				set_color green
				echo -n '>> '
    end

    set_color normal

    # for terminator's title of tab bar
    echo -ne "\e]2;"(whoami)"@"(hostname)":"(prompt_pwd)"\a"
end
