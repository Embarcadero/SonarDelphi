unit GrammarTest2020;

interface

uses
  System.SysUtils;

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
    procedure MyProc(AProcedure: TSortOrder<Integer>.TSortItem2<Integer>.TMyType);
  end;

  //Support generic class type in generic constraint
  TMyGenericClassExt<A, B: TSortOrder<Integer>> = class
  end;

  //Support multiple different constraints in generic class definition
  TMyGenericClassExt2<A, B: TSortOrder<Integer>; C: class; D, E: TMyClass> = class
  end;

  //Support for type in helper class
  TMyHelper = class helper for TMyClass
  type
    MyType = Integer;
  end;

//Support for (1 * 2) + 3
const
  A = ((1 * 2) + 3);
  A2 = ((1 * 2) + (3*4));
  A3 = (1 * 2) + 3;
  A4 = 1 * 2 + 3;

procedure MyProcedure;

const I: String = 'Warning';
const PI: ^Integer = @I;
const PF: Pointer = @MyProcedure;
const WarningStr: PChar = 'Warning!';
const MyString: String = 'Hello';

implementation

procedure MyProcedure;
type
  TBla = 0..5;
var
  a: Boolean;
  i: Integer;
  d: Double;
  c: String;
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
begin

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

end.
