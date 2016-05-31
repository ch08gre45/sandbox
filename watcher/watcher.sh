#!/bin/bash

. `dirname $0`/simple_curses_mod.sh

main(){
  window "Hosts" "cyan" "33%"
    append "Host related information" "left"
    append "Status - Last check time - Message" "left"
  endwin

	window "Host1" "cyan" "33%"
    while read chk_id chk_state last_check msg
    do
      if [ $chk_state -eq 0 ]; then
        append "[ ${__light_green}OK${__no_color} ] - ${last_check} - ${msg}" "left"
      else
        append "[${__light_red}FAIL${__no_color}] - ${last_check} - ${msg}" "left"
      fi
    done < /home/ch08gre45/scripts/test/server1.checks
	endwin

  window "Host2" "cyan" "33%"
    while read chk_id chk_state last_check msg
    do
      if [ $chk_state -eq 0 ]; then
        append "[ ${__light_green}OK${__no_color} ] - ${last_check} - ${msg}" "left"
      else
        append "[${__light_red}FAIL${__no_color}] - ${last_check} - ${msg}" "left"
      fi
    done < /home/ch08gre45/scripts/test/server2.checks
	endwin

  window "Host3" "cyan" "33%"
    while read chk_id chk_state last_check msg
    do
      if [ $chk_state -eq 0 ]; then
        append "[ ${__light_green}OK${__no_color} ] - ${last_check} - ${msg}" "left"
      else
        append "[${__light_red}FAIL${__no_color}] - ${last_check} - ${msg}" "left"
      fi
    done < /home/ch08gre45/scripts/test/server3.checks
  endwin

	col_right
	move_up

	window "Application" "cyan" "33%"
		append "Application related information"
	endwin

	window "App tab 1" "cyan" "33%"
		append "${__light_purple}We can had some text${__no_color}, log..."
	endwin

	window "App tab 2" "cyan" "33%"
		append "Example using command"
		append "`date`"
		append "I only ask for date"
	endwin

	col_right
	move_up

	window "Whatever" "cyan" "34%"
		append "We can add some little windows... rememeber that very long lines are wrapped to fit window !" "left"
	endwin

	window "Tabbed values" "red" "34%"
		append_tabbed "colomn1:column2:column3" 3
		append_tabbed "val 1:val 2:val 3" 3
		append_tabbed "val 4:val 5:val 6" 3
	endwin

	window "Little" "green" "12%"
		append "this is a simple\nlittle window"
	endwin

	col_right

	window "Other window" "blue" "22%"
		append "And this is\nanother little window"
	endwin


}
main_loop
