class-pool .
*"* class pool for class YCL_YPYM_CREATE_PAY_CUST_DATA

*"* local type definitions
include YCL_YPYM_CREATE_PAY_CUST_DATA=ccdef.

*"* class YCL_YPYM_CREATE_PAY_CUST_DATA definition
*"* public declarations
  include YCL_YPYM_CREATE_PAY_CUST_DATA=cu.
*"* protected declarations
  include YCL_YPYM_CREATE_PAY_CUST_DATA=co.
*"* private declarations
  include YCL_YPYM_CREATE_PAY_CUST_DATA=ci.
endclass. "YCL_YPYM_CREATE_PAY_CUST_DATA definition

*"* macro definitions
include YCL_YPYM_CREATE_PAY_CUST_DATA=ccmac.
*"* local class implementation
include YCL_YPYM_CREATE_PAY_CUST_DATA=ccimp.

*"* test class
include YCL_YPYM_CREATE_PAY_CUST_DATA=ccau.

class YCL_YPYM_CREATE_PAY_CUST_DATA implementation.
*"* method's implementations
  include methods.
endclass. "YCL_YPYM_CREATE_PAY_CUST_DATA implementation
