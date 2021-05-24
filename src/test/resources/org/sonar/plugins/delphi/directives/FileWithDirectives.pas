unit TestUnit;

{$include 	include1.inc}
{$i 		include2.inc}

{$define TEST}
{$undef TEST}

(* nasty
	{ comment 
		//test {$include error.inc}
	} 
*)

{$if I_FEEL_HAPPY}
	
{$else}

{$ifend}

{$ifdef TEST}

	{$ifndef UseMe}
	  {$ifdef EnableMemoryLeakReporting}
	
	  {$else}
	
	  {$endif}
	{$else}
	  {$if VERSION >= 18}
	  
	  {$ifend}
	  
	  {$if RTLVersion < 18}
	
	  {$ifend}
	{$endif}

{$endif}


interface

const 
  cLenght =
{$if CompilerVersion >= 22}
   500;	
{$else}
   250;
{$ifend}

implementation

begin
end.