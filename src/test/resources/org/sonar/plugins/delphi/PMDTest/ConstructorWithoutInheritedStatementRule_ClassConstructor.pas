unit MyUnit;

interface

type
  TClass = class(TInterfacedObject)
  private
    class var fMember: Boolean;
    class constructor Create();
  end;

  TClass2 = class(TClass)
  private
    class var fMember2: Integer;
    class constructor Create();
  end;

implementation

{ TClass }

class constructor TClass.Create;
begin
  fMember := True;
end;

{ TClass2 }

class constructor TClass2.Create;
begin
  fMember2 := 42;
end;

end.