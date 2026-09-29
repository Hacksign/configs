function fish_prompt --description 'Write out the prompt'
    set -l last_status $status

    set_color white
    echo -n '┏━ '

    # User
    set_color --bold green
    echo -n (whoami)

    set_color --bold normal
    echo -n '@'

    # Host
    set_color --bold yellow
    echo -n (uname -n)

    set_color --bold cyan
    printf ' %s ' (date "+%H:%M:%S") 

    # PWD
    set_color --bold brwhite
    echo -n (prompt_pwd)

    set_color --bold normal

    __terlar_git_prompt
    echo ''

    set_color --bold white
    echo -n '┗━ '

    if not test $last_status -eq 0
			if not set -q $fish_color_error
				set_color --bold $fish_color_error
				echo -n '>> '
			else
				set_color --bold brred
				echo -n '>> '
			end
			else
				set_color --bold green
				echo -n '>> '
    end

    set_color --bold normal

    # for terminator's title of tab bar
    echo -ne "\e]2;"(whoami)"@"(uname -n)":"(prompt_pwd)"\a"
end
