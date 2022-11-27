# Run startx on login
if [[ -z "$DISPLAY" ]] && [[ $(tty) = /dev/tty1 ]]; then 
    startx
fi
