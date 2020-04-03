unit DUnitX.Loggers.XML.SonarQube;

interface

{$I DUnitX.inc}

uses
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  DUnitX.TestFramework,
  DUnitX.Loggers.Null;

type
  TDUnitXXMLSonarQubeLogger = class(TDUnitXNullLogger)
  private
    FOutputStream : TStream;
    FOwnsStream   : boolean;
    FIndent       : integer;
    FFormatSettings : TFormatSettings;

    FSourceDirsFilename: String;
    FFileNames: TDictionary<String,String>;
  protected
    procedure Indent;
    procedure Outdent;
    procedure WriteXMLLine(const value : string);

    procedure OnTestingStarts(const threadId: TThreadID; testCount, testActiveCount: Cardinal); override;
    procedure OnTestingEnds(const RunResults: IRunResults); override;

    function FilenameByUnitName(const AUnitName: String): String;

    procedure CollectFilenamesForUnitnames;
    procedure FindDelphiUnits(const ASearchPath: String; ARecursive: Boolean = True);

    procedure WriteFixtureResult(const fixtureResult : IFixtureResult);
    procedure WriteTestResult(const testResult : ITestResult);

    function Format(const Format: string; const Args: array of const): String;
  public
    constructor Create(const ASourceDirsFilename: String; const AOutputStream : TStream; const AOwnsStream : boolean = false);
    destructor Destroy;override;
  end;

  TDUnitXXMLSonarQubeFileLogger = class(TDUnitXXMLSonarQubeLogger)
  public
    constructor Create(const ASourceDirsFilename: String; const AFilename: string = '');

    class function GetSourcesDirFromCommandLine: String;
  end;

implementation

uses
  JclDebug, System.IOUtils, DUnitX.CommandLine.Options;

function IsValidXMLChar(wc: WideChar): Boolean;
begin
  case Word(wc) of
    $0009, $000A, $000C, $000D,
      $0020..$D7FF,
      $E000..$FFFD, // Standard Unicode chars below $FFFF
      $D800..$DBFF, // High surrogate of Unicode character  = $10000 - $10FFFF
      $DC00..$DFFF: // Low surrogate of Unicode character  = $10000 - $10FFFF
      result := True;
  else
    result := False;
  end;
end;

function StripInvalidXML(const s: string): string;
var
  i, count: Integer;
begin
  {$IFNDEF NEXTGEN}
  count := Length(s);
  setLength(result, count);
  for i := 1 to Count do // Iterate
  begin
    if IsValidXMLChar(WideChar(s[i])) then
      result[i] := s[i]
    else
      result[i] := ' ';
  end; // for}
  {$ELSE}
  count := s.Length;
  SetLength(result, count);
  for i := 0 to count - 1 do // Iterate
  begin
    if IsValidXMLChar(s.Chars[i]) then
    begin
      result := result.Remove(i, 1);
      result := result.Insert(i, s.Chars[i]);
    end
    else
    begin
      result := result.Remove(i, 1);
      result := result.Insert(i, s.Chars[i]);
    end;
  end; // for}
  {$ENDIF}
end;
function EscapeForXML(const value: string; const isAttribute: boolean = True; const isCDATASection : Boolean = False): string;
begin
  result := StripInvalidXML(value);
  {$IFNDEF NEXTGEN}
  if isCDATASection  then
  begin
    Result := StringReplace(Result, ']]>', ']>',[rfReplaceAll]);
    exit;
  end;

  //note we are avoiding replacing &amp; with &amp;amp; !!
  Result := StringReplace(result, '&amp;', '[[-xy-amp--]]',[rfReplaceAll]);
  Result := StringReplace(result, '&', '&amp;',[rfReplaceAll]);
  Result := StringReplace(result, '[[-xy-amp--]]', '&amp;amp;',[rfReplaceAll]);
  Result := StringReplace(result, '<', '&lt;',[rfReplaceAll]);
  Result := StringReplace(result, '>', '&gt;',[rfReplaceAll]);

  if isAttribute then
  begin
    Result := StringReplace(result, '''', '&#39;',[rfReplaceAll]);
    Result := StringReplace(result, '"', '&quot;',[rfReplaceAll]);
  end;
  {$ELSE}
  if isCDATASection  then
  begin
    Result := Result.Replace(']]>', ']>', [rfReplaceAll]);
    exit;
  end;

  //note we are avoiding replacing &amp; with &amp;amp; !!
  Result := Result.Replace('&amp;', '[[-xy-amp--]]',[rfReplaceAll]);
  Result := Result.Replace('&', '&amp;',[rfReplaceAll]);
  Result := Result.Replace('[[-xy-amp--]]', '&amp;amp;',[rfReplaceAll]);
  Result := Result.Replace('<', '&lt;',[rfReplaceAll]);
  Result := Result.Replace('>', '&gt;',[rfReplaceAll]);

  if isAttribute then
  begin
    Result := Result.Replace('''', '&#39;',[rfReplaceAll]);
    Result := Result.Replace('"', '&quot;',[rfReplaceAll]);
  end;
  {$ENDIF}
end;

{ TDUnitXXMLSonarQubeFileLogger }

constructor TDUnitXXMLSonarQubeFileLogger.Create(const ASourceDirsFilename: String;
  const AFilename: string);
var
  sXmlFilename  : string;
  fileStream    : TFileStream;
  lXmlDirectory: string;
const
  DEFAULT_SQUNIT_FILE_NAME = 'TEST-dunitx-sqresults.xml';
begin
  sXmlFilename := AFilename;

  if sXmlFilename = '' then
    sXmlFilename := ExtractFilePath(ParamStr(0)) + DEFAULT_SQUNIT_FILE_NAME;

  lXmlDirectory := ExtractFilePath(sXmlFilename);
  ForceDirectories(lXmlDirectory);

  fileStream := TFileStream.Create(sXmlFilename, fmCreate);

  //base class will destroy the stream;
  inherited Create(ASourceDirsFilename, fileStream,true);
end;

class function TDUnitXXMLSonarQubeFileLogger.GetSourcesDirFromCommandLine: String;
const
  SOURCES_PARAM = '-sources:';
var
  i: Integer;
  LParam: String;
begin
  Result := '';

  if ParamCount > 0 then
  begin
    for i := 1 to ParamCount do begin
      LParam := ParamStr(i);
      if LParam.StartsWith(SOURCES_PARAM) then
        Result := LParam.Substring(Length(SOURCES_PARAM));
    end;
  end;

end;

{ TDUnitXXMLSonarQubeLogger }

procedure TDUnitXXMLSonarQubeLogger.CollectFilenamesForUnitnames;
var
  LSourcesList: TStringList;
  LSourceDir: String;
begin
  //Search all source directories and create a list of unitname > full filename
  FFileNames.Clear;

  LSourcesList := TStringList.Create;
  try
    try
      LSourcesList.LoadFromFile(FSourceDirsFilename);
    except
      on E: Exception do
        System.WriteLn('Error loading sources file, results cannot be imported in SonarQube. (' + E.Message + ')');
    end;

    for LSourceDir in LSourcesList do begin
      FindDelphiUnits(LSourceDir, False);
    end;
  finally
    FreeAndNil(LSourcesList);
  end;
end;

constructor TDUnitXXMLSonarQubeLogger.Create(const ASourceDirsFilename: String;
  const AOutputStream: TStream; const AOwnsStream: boolean);
var
  preamble: TBytes;
  {$IFNDEF DELPHI_XE_UP}
  oldThousandSeparator: Char;
  oldDecimalSeparator: Char;
  {$ENDIF}
begin
  inherited Create;
  {$IFDEF DELPHI_XE_UP }
  FFormatSettings := TFormatSettings.Create;
  FFormatSettings.ThousandSeparator := ',';
  FFormatSettings.DecimalSeparator := '.';
  {$ELSE}
  oldThousandSeparator        := {$IFDEF USE_NS}System.{$ENDIF}SysUtils.ThousandSeparator;
  oldDecimalSeparator         := {$IFDEF USE_NS}System.{$ENDIF}DecimalSeparator;
  try
    SysUtils.ThousandSeparator := ',';
    SysUtils.DecimalSeparator := '.';
  {$ENDIF}
  FOutputStream := AOutputStream;
  FOwnsStream   := AOwnsStream;

  Preamble := TEncoding.UTF8.GetPreamble;
  FOutputStream.WriteBuffer(preamble[0], Length(preamble));
  {$IFNDEF DELPHI_XE_UP}
  finally
    {$IFDEF USE_NS}System.{$ENDIF}SysUtils.ThousandSeparator := oldThousandSeparator;
    {$IFDEF USE_NS}System.{$ENDIF}SysUtils.DecimalSeparator  := oldDecimalSeparator;
  end;
  {$ENDIF}
  FSourceDirsFilename := ASourceDirsFilename;
  FFileNames := TDictionary<String, String>.Create;
end;

destructor TDUnitXXMLSonarQubeLogger.Destroy;
begin
  if FOwnsStream then
    FOutputStream.Free;
  if Assigned(FFileNames) then
    FFileNames.Free;
  inherited;
end;

function TDUnitXXMLSonarQubeLogger.FilenameByUnitName(
  const AUnitName: String): String;
begin
  if not FFileNames.ContainsKey(AUnitName) then
    Result := 'FILE NOT FOUND'
  else
    Result := FFileNames.Items[AUnitName];
end;

procedure TDUnitXXMLSonarQubeLogger.FindDelphiUnits(const ASearchPath: String;
  ARecursive: Boolean = True);
var
  searchResult: TSearchRec;
begin
  if FindFirst(ASearchPath+'\*', faAnyFile, searchResult)=0 then begin
    try
      repeat
        if (searchResult.Attr and faDirectory)=0 then begin
          if TPath.GetExtension(searchResult.Name) = '.pas' then
            FFileNames.Add(TPath.GetFileNameWithoutExtension(searchResult.Name), IncludeTrailingBackSlash(ASearchPath)+searchResult.Name);
        end else if (searchResult.Name<>'.') and (searchResult.Name<>'..') then begin
          if ARecursive then
            FindDelphiUnits(IncludeTrailingBackSlash(ASearchPath)+searchResult.Name);
        end;
      until FindNext(searchResult)<>0
    finally
      FindClose(searchResult);
    end;
  end;
end;

function TDUnitXXMLSonarQubeLogger.Format(const Format: string;
  const Args: array of const): String;
begin
  Result := {$IFDEF USE_NS}System.{$ENDIF}SysUtils.Format(Format, Args, FFormatSettings);
end;

procedure TDUnitXXMLSonarQubeLogger.Indent;
begin
  Inc(FIndent,2);
end;

procedure TDUnitXXMLSonarQubeLogger.OnTestingEnds(
  const RunResults: IRunResults);
var
  fixtureRes  : IFixtureResult;
begin
  inherited;

{ first things first, rollup the namespaces.
  So, where parent fixtures have no tests, or only one child fixture, combine into a single fixture.
  }
  for fixtureRes in RunResults.FixtureResults do
    fixtureRes.Reduce;

  WriteXMLLine('<testExecutions version="1">');
  Indent;

  for fixtureRes in RunResults.FixtureResults do
    WriteFixtureResult(fixtureRes);

  Outdent;
  WriteXMLLine('</testExecutions>');
end;

procedure TDUnitXXMLSonarQubeLogger.OnTestingStarts(const threadId: TThreadID;
  testCount, testActiveCount: Cardinal);
begin
  inherited;

  CollectFilenamesForUnitnames;
end;

procedure TDUnitXXMLSonarQubeLogger.Outdent;
begin
  Dec(FIndent,2);
end;

procedure TDUnitXXMLSonarQubeLogger.WriteFixtureResult(
  const fixtureResult: IFixtureResult);
var
  testResult : ITestResult;
  child: IFixtureResult;
  LPath: String;
begin
  if (not fixtureResult.Fixture.TestClass.ClassNameIs('TObject'))  then
  begin
    if fixtureResult.TestResults.Count = 0 then
      Exit;

    LPath := FilenameByUnitName(fixtureResult.Fixture.UnitName);
    WriteXMLLine('<file path="' + LPath + '">');
    Indent;

    for testResult in fixtureResult.TestResults do
      WriteTestResult(testResult);

    Outdent;
    WriteXMLLine('</file>');
  end;

  for child in fixtureResult.Children do
    WriteFixtureResult(child);
end;

procedure TDUnitXXMLSonarQubeLogger.WriteTestResult(
  const testResult: ITestResult);
begin
  WriteXMLLine('<testCase name="' + EscapeForXML(testResult.Test.Name) + '" duration="' + testResult.Duration.Milliseconds.ToString + '">');

  Indent;
  case testResult.ResultType of
    TTestResultType.MemoryLeak,
    TTestResultType.Error:
      WriteXMLLine('<error message="' + EscapeForXML(testResult.Message) + '">' + EscapeForXML(testResult.StackTrace, False) + '</error>');
    TTestResultType.Failure:
      WriteXMLLine('<failure message="' + EscapeForXML(testResult.Message) + '">' + EscapeForXML(testResult.StackTrace, False) + '</failure>');
    TTestResultType.Ignored:
      WriteXMLLine('<skipped message="' + EscapeForXML(testResult.Message) + '"/>');
  end;
  Outdent;
  WriteXMLLine('</testCase>');
end;

procedure TDUnitXXMLSonarQubeLogger.WriteXMLLine(const value: string);
var
  bytes : TBytes;
  s : string;
begin
  s := StringOfChar(' ',FIndent) + value + #13#10;
  bytes := TEncoding.UTF8.GetBytes(s);
  FOutputStream.Write(bytes[0],Length(bytes));
end;

end.
