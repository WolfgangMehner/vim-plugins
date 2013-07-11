#===  FUNCTION  ================================================================
#         NAME:  _trap_ERROR
#  DESCRIPTION:  Trap code for the pseudo-signal ERR (A command returning a
#                non-zero exit status).  Generates an error message.
#   PARAMETERS:  The current line number given by $LINENO .
#===============================================================================
function _trap_ERROR ()
{
  echo -e "\nERROR line ${1}: Command exited with status ${?}"
}    # ----------  end of function _trap_ERROR  ----------

trap '_trap_ERROR $LINENO' ERR                  # trap ERR

#trap - ERR                                      # reset the ERR trap

