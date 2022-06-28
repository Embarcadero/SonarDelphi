// Test file to ensure that experimental units are ignored.
unit MyUnit experimental;

interface

type
  // This class name should trigger "ClassNameRule"
  XClass = class(TInterfacedObject)

  end;

implementation

end.
