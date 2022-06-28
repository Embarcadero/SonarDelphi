// Test file to ensure that a deprecated comment does not trigger "UnitNameRule"
unit MyUnit deprecated 'Should no longer be used!';

interface

type
  // This class name should trigger "ClassNameRule"
  TClass = class(TInterfacedObject)

  end;

implementation

end.
