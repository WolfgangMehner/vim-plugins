#-----------------------------------------------------------------------
#  set Bash prompts 
#  PS4 shows the function name when execution is inside a function and
#  the xtrace option is set.
#-----------------------------------------------------------------------
export PS2='continue> '
export PS3='choose: '
export PS4='|${BASH_SOURCE} ${LINENO}${FUNCNAME[0]:+ ${FUNCNAME[0]}()}|  '

