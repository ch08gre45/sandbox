#!/bin/bash

# Utility scripts library for working with terminal display

# Setup color variables
# Usage echo -e "Normal text ${__color}Text of chosen color${__no_color} Normal text"
setup_color() {
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
}

# Snippet taken from http://top-scripts.blogspot.ro/2011/01/blog-post.html
e='echo -en'                                     # shortened echo command variable
   ESC=$( $e "\033")                             # variable containing escaped value
 clear(){ $e "\033c";}                           # clear screen
 civis(){ $e "\033[?25l";}                       # hide cursor
 cnorm(){ $e "\033[?12l\033[?25h";}              # show cursor
  tput(){ $e "\033[${1};${2}H";}                 # terminal put (x and y position)
colput(){ $e "\033[${1}G";}                      # put text in the same line as the specified column
  mark(){ $e "\033[7m";}                         # select current line text
unmark(){ $e "\033[27m";}                        # normalize current line text
  draw(){ $e "\033%@";echo -en "\033(0";}        # switch to 'garbage' mode to be able to draw
 write(){ $e "\033(B";}                          # return to normal (reset)
  blue(){ $e "\033c\033[0;1m\033[37;44m\033[J";} # clear screen, set background to blue and font to white
