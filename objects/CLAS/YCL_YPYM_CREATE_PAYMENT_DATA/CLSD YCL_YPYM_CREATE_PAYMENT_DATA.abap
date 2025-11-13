class-pool .
*"* class pool for class YCL_YPYM_CREATE_PAYMENT_DATA

*"* local type definitions
include YCL_YPYM_CREATE_PAYMENT_DATA==ccdef.

*"* class YCL_YPYM_CREATE_PAYMENT_DATA definition
*"* public declarations
  include YCL_YPYM_CREATE_PAYMENT_DATA==cu.
*"* protected declarations
  include YCL_YPYM_CREATE_PAYMENT_DATA==co.
*"* private declarations
  include YCL_YPYM_CREATE_PAYMENT_DATA==ci.
endclass. "YCL_YPYM_CREATE_PAYMENT_DATA definition

*"* macro definitions
include YCL_YPYM_CREATE_PAYMENT_DATA==ccmac.
*"* local class implementation
include YCL_YPYM_CREATE_PAYMENT_DATA==ccimp.

*"* test class
include YCL_YPYM_CREATE_PAYMENT_DATA==ccau.

class YCL_YPYM_CREATE_PAYMENT_DATA implementation.
*"* method's implementations
  include methods.
endclass. "YCL_YPYM_CREATE_PAYMENT_DATA implementation
