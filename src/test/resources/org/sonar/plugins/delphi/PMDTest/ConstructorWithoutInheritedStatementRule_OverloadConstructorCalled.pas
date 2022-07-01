unit MyUnit;

interface

type
  TClass = class(TInterfacedObject)
  private
    fMember: Boolean;
    fMember2: Integer;
  public
    constructor Create(pParam: Boolean); overload;
    constructor Create(pParam: Boolean; pParam2: Integer); overload;
  end;

implementation

{ TClass }

constructor TClass.Create(pParam: Boolean);
begin
  // This constructor must not trigger "ConstructorWithoutInheritedStatementRule"
  Create(pParam, 0);
end;

constructor TClass.Create(pParam: Boolean; pParam2: Integer);
begin
  inherited Create();
  fMember := pParam;
  fMember2 := pParam2;
end;

end.
