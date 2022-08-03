unit RecordHelperTest;

interface

type

  // This works
  TSomeClass = class(TObject)
    class var fSomeClassVar: ISomeInterface;
  end;

  // This doesn't
  TSomeRecordHelper = record helper for xzy
    class var fSomeClassVar: ISomeInterface;
  end;

implementation

end.