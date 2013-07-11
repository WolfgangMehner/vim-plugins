#===  FUNCTION  ================================================================
#         NAME:  _trap_RETURN
#  DESCRIPTION:  Trap code for the pseudo-signal RETURN. Generates a message.
#                The RETURN trap is not inherited by functions.
#                Use 'set -o functrace'
#   PARAMETERS:  The current line number given by $LINENO .
#                variable(s) to be tracked
#===============================================================================
function _trap_RETURN ()
{
  echo -e "\nRETURN line ${1}: "
}    # ----------  end of functionn _trap_RETURN  ----------

trap '_trap_RETURN $LINENO' RETURN              # trap RETURN

#trap - RETURN                                   # reset the RETURN trap

