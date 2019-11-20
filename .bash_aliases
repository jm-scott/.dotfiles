# vcXsrv display variable
export DISPLAY=localhost:0.0

# [Bash]
alias c="clear"

# [git]
alias gs="git status"
# [Windows]
alias exp="explorer.exe"

# [Python]
alias python="python3"
alias pip="pip3"

# [ls]
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    
	
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi
