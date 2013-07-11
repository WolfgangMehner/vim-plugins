#===  FUNCTION  ================================================================
#         NAME:  _trap_EXIT
#  DESCRIPTION:  Trap code for the pseudo-signal EXIT. Generates an message.
#   PARAMETERS:  The current line number given by $LINENO .
#===============================================================================
function _trap_EXIT ()
{
  echo -e "\nEXIT line ${1}: Script exited with status ${?}"
}    # ----------  end of function ----------

trap '_trap_EXIT $LINENO' EXIT                  # trap EXIT

#trap - EXIT                                     # reset the EXIT trap

