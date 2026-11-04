// Macro types.
@s NcParam char *name, *kind; variadic:bool
@s NcParams v:*NcParam; n,cap:usize
@s NcMacro params:NcParams; body:NcTokens; program:bool
@s NcBindings values,fresh:NcMap; variadic:*char
