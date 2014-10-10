# Set the default prompt command. Make sure that every terminal escape
# string has a newline before and after, so that fish will know how
# long it is.

function fish_prompt --description "Write out the prompt"

	# Just calculate these once, to save a few cycles when displaying the prompt
	if not set -q __fish_prompt_hostname
		set -g __fish_prompt_hostname (hostname|cut -d . -f 1)
	end
	if not set -q __cmdline_color
		set -g __cmdline_color (set_color -o green)
	end

	if not set -q __fish_prompt_normal
		set -g __fish_prompt_normal (set_color normal)
	end

	switch $USER

		case root

		if not set -q __fish_prompt_cwd
			if set -q fish_color_cwd_root
				set -g __fish_prompt_cwd (set_color $fish_color_cwd_root)
			else
				set -g __fish_prompt_cwd (set_color $fish_color_cwd)
			end
		if not set -q __cmdline_suffix
			set -g __fish_prompt_cmdline_suffix '#'
		end

		end

		case '*'

		if not set -q __fish_prompt_cwd
			set -g __fish_prompt_cwd (set_color -o blue)
		end
		if not set -q __cmdline_suffix
			set -g __cmdline_suffix '$'
		end

	end

	echo -n -s "$__cmdline_color$USER$__fish_prompt_cwd@$__cmdline_color$__fish_prompt_hostname" ' ' "$__fish_prompt_cwd" (prompt_pwd) "$__fish_prompt_normal$__cmdline_suffix "

end

