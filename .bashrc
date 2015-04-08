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
#for my locale characters
export LANG="en_US.UTF-8"
export LANGUAGE="zh_CN:zh"
export LC_CTYPE="zh_CN.UTF-8"
export LC_MESSAGES="zh_CN.UTF-8"
