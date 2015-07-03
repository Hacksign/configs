# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific aliases and functions
shopt -s autocd
alias ..="cd .."
alias ls="ls -F --color"
alias ll="ls -l"
alias la="ls -la"
