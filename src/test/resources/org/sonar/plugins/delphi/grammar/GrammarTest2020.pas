unit GrammarTest2020;

interface

uses
  System.SysUtils, Windows;

type
  //Support array and const <value>..<value>
  MyArray = array[0..2] of Integer;
  TConstNumbers = 0..5;

  //Support AnsiString(<value>)
  TAnsiStringWindows1252 = type AnsiString(1252);

  TMyRefToProc = reference to procedure(AValue: Integer);

  //Support &<reserved keyword>
  MyRecord = record
    &type: TConstNumbers;
    &implementation: Integer;
  end;

  TMyClass<T: class> = class(TObject)
  type
    TMyRefToProc = reference to procedure(AValue: T);
  end;

  //Support method definitions for multiple inner classes
  TSortOrder<T> = class
  strict private
    type
      TSortItem<T> = class
      strict private
        type
          TMyInner = class
            constructor Create;
          end;
      private
        Value: T;
        constructor Create(AValue: T);
        function GetValue: T;
      end;
      TRecordItem = record
        class operator LogicalAnd(const left, right: TRecordItem): TRecordItem;
      end;
    public
    type
      TSortItem2<T> = class
      type TMyType = TProc;
      strict private
        type
          TMyInner = class
            constructor Create;
          end;
      private
        Value: T;
        constructor Create(AValue: T);
        function GetValue: T;
      end;
  end;

  //Support for type definition inside a generic class
  TMyClass = class(TSortOrder<Integer>)
  private
    //Support [unsafe] and [weak] attributes
    [unsafe] procedure MyProc(AProcedure: TSortOrder<Integer>.TSortItem2<Integer>.TMyType);
    [weak] procedure MyProcWeak(AProcedure: TSortOrder<Integer>.TSortItem2<Integer>.TMyType);
  end;

  //Support generic class type in generic constraint
  TMyGenericClassExt<A; B: TSortOrder<Integer>> = class
  end;

  //Support multiple different constraints in generic class definition
  TMyGenericClassExt2<A, B: TSortOrder<Integer>; C: class; D, E: TMyClass> = class
  end;

  //Support for type in helper class
  TMyHelper = class helper for TMyClass
  type
    MyType = Integer;
  end;

  IMyInterface = interface(IInterface)
  ['{D2FF7704-5F26-496E-84D4-891FF1836DE7}']
    function MyFunction: Integer;
    procedure MyProcedure(AValue: Integer);
  end;

  IMyGenericInterface<T> = interface(IInterface)
    function MyFunctionGeneric: T;
  end;

  //Support method interface resolution
  TMethodResolution<T> = class(TInterfacedObject, IMyInterface, IMyGenericInterface<T>)
  private
    function IMyInterface.MyFunction = MyFunctionHere;
    procedure IMyInterface.MyProcedure = MyProcedureHere;
    function IMyGenericInterface<T>.MyFunctionGeneric = MyFunctionHereGeneric;

    procedure MyProcedureHere(AValue: Integer);
    function MyFunctionHere: Integer;
    function MyFunctionHereGeneric: T;
  end;

//Support for external '<dll>'
function ImageEnumerateCertificates(FileHandle: THandle; TypeFilter: WORD;
  out CertificateCount: DWORD; Indicies: PDWORD; IndexCount: Integer): BOOL; stdcall; external 'Imagehlp.dll';

//Support for (1 * 2) + 3
const
  A = ((1 * 2) + 3);
  A2 = ((1 * 2) + (3*4));
  A3 = (1 * 2) + 3;
  A4 = 1 * 2 + 3;

procedure MyProcedure;

//Support [result: unsafe] attribute
[result: unsafe] function MyFunction: IMyInterface;

const I: String = 'Warning';
const PI: ^Integer = @I;
const PF: Pointer = @MyProcedure;
const WarningStr: PChar = 'Warning!';

//Support control characters in a string (^M, #13 and combination)
resourcestring
  MY_RESOURCE = 'Hello'#13#10;
  MY_RESOURCE3 = ^M'Hello';
  MY_RESOURCE4 = 'Hello'^M#13#10'foo'#13^M;
  MY_RESOURCE5 = 'Hello'^M^M^M;
  MY_RESOURCE6 = 'Hello'^M^M^M'bar';

//Support namespace.Value
procedure PublicProcedure(ABool: Boolean=System.False);

implementation

uses
  System.Rtti, System.TypInfo;

function MyFunction: IMyInterface;
begin

end;

procedure MyProcedure;
type
  TBla = 0..5;
var
  a: Boolean;
  i: Integer;
  d: Double;
  c: String;
{ //TODO: fix that these keywords can be used as variable
  absolute, abstract, add, ansistring, assembler, assembly: integer;
  at , automated , break , cdecl , contains: integer;
  continue , default , deprecated , dispid: integer;
  dq , dw , dynamic , exit , experimental , export , external: integer;
  far , final , forward , helper: integer;
  implements , index: integer;
  local , message , name , near , nodefault: integer;
  on , operator , out , overload , override , package , pascal , platform: integer;
  pointer , private , protected , public , published: integer;
  read , readonly , reference , register , reintroduce , remove , requires: integer;
  resident , safecall , sealed , static , stdcall , stored: integer;
}
  strict , unsafe: integer;
  varargs , variant , virtual , write , writeonly , false , true: integer;
begin
  //Support realnumbers
  d := 1.0e-10 + 2;
  a := 3 >= 4;

  //Support for .ToUpper after string
  c := 'Hello world'.ToUpper();
  i := Pos('EoCustomLinkResponseDateTime'.ToUpper, c.ToUpper);
  try

  except
    on E: Exception do i := i + 1;
  end;
end;

{ TSortOrder<T>.TSortItem<T>.TMyInner }

constructor TSortOrder<T>.TSortItem<T>.TMyInner.Create;
var
  A: TMyGenericClassExt<TObject, TSortOrder<Integer>>;
begin
  //Support 'with' multiple arguments
  with A as TMyGenericClassExt<TObject, TSortOrder<Integer>> do begin

  end;
end;

{ TSortOrder<T>.TSortItem<T> }

constructor TSortOrder<T>.TSortItem<T>.Create(AValue: T);
begin

end;

function TSortOrder<T>.TSortItem<T>.GetValue: T;
begin

end;

{ TSortOrder<T>.TRecordItem }

class operator TSortOrder<T>.TRecordItem.LogicalAnd(const left,
  right: TRecordItem): TRecordItem;
begin

end;

{ TSortOrder<T>.TSortItem2<T>.TMyInner }

constructor TSortOrder<T>.TSortItem2<T>.TMyInner.Create;
begin

end;

{ TSortOrder<T>.TSortItem2<T> }

constructor TSortOrder<T>.TSortItem2<T>.Create(AValue: T);
begin

end;

function TSortOrder<T>.TSortItem2<T>.GetValue: T;
begin

end;

{ TMyClass }

procedure TMyClass.MyProc(
  AProcedure: TSortOrder<Integer>.TSortItem2<Integer>.TMyType);
begin

end;

procedure TMyClass.MyProcWeak(
  AProcedure: TSortOrder<Integer>.TSortItem2<Integer>.TMyType);
begin

end;

{ TMethodResolution<T> }

function TMethodResolution<T>.MyFunctionHere: Integer;
var
  bool: Boolean;
begin
//Support namespace.Value
  WriteLn('MyBoolean: ' + bool.ToString(True, TUseBoolStrs.True));
end;

function TMethodResolution<T>.MyFunctionHereGeneric: T;
var
  localPropInfo: PPropInfo;
  localPropTypeName: String;
  localPropTypeKind: TTypeKind;
begin
//Support double pointer (^^) reference
  localPropTypeName := String(localPropInfo^.PropType^^.Name);
  localPropTypeKind := localPropInfo^.PropType^^.Kind;
end;

procedure TMethodResolution<T>.MyProcedureHere(AValue: Integer);
begin

end;

procedure PublicProcedure(ABool: Boolean=System.False);
begin

end;

// Inline variable declaration with and without type

procedure Test();
begin
  var i := GetTickCount64();
end;

procedure Test2();
begin
  var s: string;
  var t: UInt64 := GetTickCount64();
  for var i := 0 to ControlCount - 1 do
	  Inc(t);
  for var i := 0 downto ControlCount - 1 do
	  Inc(t);
end;

end.
