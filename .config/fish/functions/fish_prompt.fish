function fish_prompt --description 'Write out the prompt'
    set -l last_status $status

    # User
    set_color green
    echo -n (whoami)

    set_color normal
    echo -n '@'

    # Host
    set_color yellow
    echo -n (hostname -s)

    set_color purple
    printf ' [%s] ' (date "+%H:%M:%S") 
    set_color red
    echo -n ': '

    # PWD
    set_color $fish_color_cwd
    echo -n (prompt_pwd)

    __terlar_git_prompt
    echo

    if not test $last_status -eq 0
    set_color $fish_color_error
    end

    set_color green
    echo -n '>> '
    set_color normal

    # for terminator's title of tab bar
    echo -ne "\e]2;"(whoami)"@"(hostname -s)":"(prompt_pwd)"\a"
end
