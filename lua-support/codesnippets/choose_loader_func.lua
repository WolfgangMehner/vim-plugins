local func = assert ( package.loadlib ( 'LIB_PATH/lib.so', 'luaopen_MODULE_SUBMODULE' ) )
package.preload [ 'MODULE_NAME' ] = func
local module = require ( 'MODULE_NAME' )
