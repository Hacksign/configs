# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

export PS1="\[\e[1;32m\][\[\e[1;34m\]\u\[\e[0;1m\]@\h \[\e[1;33m\]\W\[\e[1;32m\]]\[\e[1;31m\]\\$ \[\e[0m\]"
export LANG="zh_CN.UTF-8"

# User specific aliases and functions
alias ..="cd .."
alias ls="ls -F --color"
alias ll="ls -l --time-style='long-iso'"
alias la="ls -la"
