#!/bin/bash
#simple curses library to create windows on terminal
#
#author: Patrice Ferlet metal3d@copix.org
#license: new BSD
#
#create_buffer patch by Laurent Bachelier

create_buffer(){
  # Try to use SHM, then $TMPDIR, then /tmp
  if [ -d "/dev/shm" ]; then
    BUFFER_DIR="/dev/shm"
  elif [ -z $TMPDIR ]; then
    BUFFER_DIR=$TMPDIR
  else
    BUFFER_DIR="/tmp"
  fi

  [[ "$1" != "" ]] &&  buffername=$1 || buffername="bashsimplecurses"

  # Try to use mktemp before using the unsafe method
  if [ -x `which mktemp` ]; then
    #mktemp --tmpdir=${BUFFER_DIR} ${buffername}.XXXXXXXXXX
    mktemp ${BUFFER_DIR}/${buffername}.XXXXXXXXXX
  else
    echo "${BUFFER_DIR}/bashsimplecurses."$RANDOM
  fi
}

#Usefull variables
LASTCOLS=0
BUFFER=`create_buffer`
POSX=0
POSY=0
LASTWINPOS=0

# Color variables
__gray="\033[1;30m"
__light_grey="\033[0;37m"
__cyan="\033[0;36m"
__light_cyan="\033[1;36m"
__no_color="\033[0m"
__black="\033[0;30m"
__blue="\033[0;34m"
__green="\033[0;32m"
__red="\033[0;31m"
__purple="\033[0;35m"
__brown="\033[0;33m"
__yellow="\033[1;33m"
__light_blue="\033[1;34m"
__light_green="\033[1;32m"
__light_red="\033[1;31m"
__light_purple="\033[1;35m"
__white="\033[1;37m"

#call on SIGINT and SIGKILL
#it removes buffer before to stop
on_kill(){
    tput cup 0 0 >> $BUFFER
    # Erase in-buffer
    tput ed >> $BUFFER
    rm -rf $BUFFER
    exit 0
}
trap on_kill SIGINT SIGTERM


#initialize terminal
term_init(){
    POSX=0
    POSY=0
    tput clear >> $BUFFER
}


#change line
_nl(){
    POSY=$((POSY+1))
    tput cup $POSY $POSX >> $BUFFER
    #echo
}


move_up(){
    set_position $POSX 0
}

col_right(){
    left=$((LASTCOLS+POSX))
    set_position $left $LASTWINPOS
}

#put display coordinates
set_position(){
    POSX=$1
    POSY=$2
}

#initialize chars to use
_TL="\033(0l\033(B"
_TR="\033(0k\033(B"
_BL="\033(0m\033(B"
_BR="\033(0j\033(B"
_SEPL="\033(0t\033(B"
_SEPR="\033(0u\033(B"
_VLINE="\033(0x\033(B"
_HLINE="\033(0q\033(B"

init_chars(){
    if [[ -z "$ASCIIMODE" && $LANG =~ ".*\.UTF-8" ]] ; then ASCIIMODE=utf8; fi
    if [[ "$ASCIIMODE" != "" ]]; then
        if [[ "$ASCIIMODE" == "ascii" ]]; then
            _TL="+"
            _TR="+"
            _BL="+"
            _BR="+"
            _SEPL="+"
            _SEPR="+"
            _VLINE="|"
            _HLINE="-"
        fi
        if [[ "$ASCIIMODE" == "utf8" ]]; then
            _TL="\xE2\x94\x8C"
            _TR="\xE2\x94\x90"
            _BL="\xE2\x94\x94"
            _BR="\xE2\x94\x98"
            _SEPL="\xE2\x94\x9C"
            _SEPR="\xE2\x94\xA4"
            _VLINE="\xE2\x94\x82"
            _HLINE="\xE2\x94\x80"
        fi
    fi
}


#Append a windo on POSX,POSY
window(){
    LASTWINPOS=$POSY
    title=$1
    color=$2
    tput cup $POSY $POSX
    cols=$(tput cols)
    cols=$((cols))
    if [[ "$3" != "" ]]; then
        cols=$3
        if [ $(echo $3 | grep "%") ];then
            cols=$(tput cols)
            cols=$((cols))
            w=$(echo $3 | sed 's/%//')
            cols=$((w*cols/100))
        fi
    fi
    len=$(echo "$1" | echo $(($(wc -c)-1)))
    left=$(((cols/2) - (len/2) -1))

    #draw up line
    clean_line
    echo -ne $_TL
    for i in `seq 3 $cols`; do echo -ne $_HLINE; done
    echo -ne $_TR
    #next line, draw title
    _nl

    tput sc
    clean_line
    echo -ne $_VLINE
    tput cuf $left
    #set title color
    case $color in
        green)
            echo -n -e "\E[01;32m"
            ;;
        red)
            echo -n -e "\E[01;31m"
            ;;
        blue)
            echo -n -e "\E[01;34m"
            ;;
        light_grey)
            echo -n -e "\033[0;37m"
            ;;
        cyan)
            echo -n -e "\033[0;36m"
            ;;
        light_cyan)
            echo -n -e "\033[1;36m"
            ;;
        black)
            echo -n -e "\033[0;30m"
            ;;
        purple)
            echo -n -e "\033[0;35m"
            ;;
        brown)
            echo -n -e "\033[0;33m"
            ;;
        yellow)
            echo -n -e "\033[1;33m"
            ;;
        light_blue)
            echo -n -e "\033[1;34m"
            ;;
        light_green)
            echo -n -e "\033[1;32m"
            ;;
        light_red)
            echo -n -e "\033[1;31m"
            ;;
        light_purple)
            echo -n -e "\033[1;35m"
            ;;
        white)
            echo -n -e "\033[1;37m"
            ;;
        grey|*)
            echo -n -e "\E[01;37m"
            ;;
    esac


    echo $title
    tput rc
    tput cuf $((cols-1))
    echo -ne $_VLINE
    echo -n -e "\e[00m"
    _nl
    #then draw bottom line for title
    addsep

    LASTCOLS=$cols

}

#append a separator, new line
addsep (){
    clean_line
    echo -ne $_SEPL
    for i in `seq 3 $cols`; do echo -ne $_HLINE; done
    echo -ne $_SEPR
    _nl
}


#clean the current line
clean_line(){
    tput sc
    #tput el
    tput rc

}


#add text on current window
append_file(){
    [[ "$1" != "" ]] && align="left" || align=$1
    while read l;do
        l=`echo $l | sed 's/____SPACES____/ /g'`
        _append "$l" $align
    done < "$1"
}
append(){
    text=$(echo -e $1 | fold -w $((LASTCOLS-2)) -s)
    rbuffer=`create_buffer bashsimplecursesfilebuffer`
    echo  -e "$text" > $rbuffer
    while read a; do
        _append "$a" $2
    done < $rbuffer
    rm -f $rbuffer
}
_append(){
    clean_line
    tput sc
    echo -ne $_VLINE
    len=$(echo "$1" | wc -c )
    len=$((len-1))
    left=$((LASTCOLS/2 - len/2 -1))

    [[ "$2" == "left" ]] && left=0

    tput cuf $left
    echo -e "$1"
    tput rc
    tput cuf $((LASTCOLS-1))
    echo -ne $_VLINE
    _nl
}

#add separated values on current window
append_tabbed(){
    [[ $2 == "" ]] && echo "append_tabbed: Second argument needed" >&2 && exit 1
    [[ "$3" != "" ]] && delim=$3 || delim=":"
    clean_line
    tput sc
    echo -ne $_VLINE
    len=$(echo "$1" | wc -c )
    len=$((len-1))
    left=$((LASTCOLS/$2))
    for i in `seq 0 $(($2))`; do
        tput rc
        tput cuf $((left*i+1))
        echo "`echo $1 | cut -f$((i+1)) -d"$delim"`"
    done
    tput rc
    tput cuf $((LASTCOLS-1))
    echo -ne $_VLINE
    _nl
}

#append a command output
append_command(){
    buff=`create_buffer command`
    echo -e "`$1`" | sed 's/ /____SPACES____/g' > $buff 2>&1
    append_file $buff "left"
    rm -f $buff
}

#close the window display
endwin(){
    clean_line
    echo -ne $_BL
    for i in `seq 3 $LASTCOLS`; do echo -ne $_HLINE; done
    echo -ne $_BR
    _nl
}

#refresh display
refresh (){
    cat $BUFFER
    echo -n "" > $BUFFER
}



#main loop called
main_loop (){
    term_init
    init_chars
    [[ "$1" == "" ]] && time=1 || time=$1
    while [[ 1 ]];do
        tput cup 0 0 >> $BUFFER
        tput il $(tput lines) >>$BUFFER
        main >> $BUFFER
        tput cup $(tput lines) $(tput cols) >> $BUFFER
        refresh
        sleep $time
        POSX=0
        POSY=0
    done
}
