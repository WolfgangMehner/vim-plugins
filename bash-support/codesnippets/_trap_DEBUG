#===  FUNCTION  ================================================================
#         NAME:  _trap_DEBUG
#  DESCRIPTION:  Trap code for the pseudo-signal DEBUG. Generate a message.
#                The DEBUG trap is not inherited by functions.
#                Use 'set -o functrace'
#   PARAMETERS:  1) identification (e.g. line number $LINENO)
#                2) variable name(s) to be tracked
#===============================================================================
function _trap_DEBUG ()
{
	declare identification=$1;
	while [ ${#} -gt 1 ]; do
		shift
		echo -e "DEBUG [$identification] ${1} = '${!1}'"
	done
}    # ----------  end of function _trap_DEBUG  ----------

trap '_trap_DEBUG $LINENO <-variable names->' DEBUG        # trap DEBUG

#trap - DEBUG                                    # reset the DEBUG trap

