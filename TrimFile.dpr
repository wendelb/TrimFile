program TrimFile;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Classes;

type
  TParams = record
    ReadStdIn: Boolean;
    WriteStdOut: Boolean;
    FileName: String;
    TrimRight: Boolean;
    TrimLeft: Boolean;
  end;

  EInvalidParams = class(Exception);

const
  CMDLineSwitches: array[0..1] of Char = ('/', '-');

function CompareParam(const CMDLine, Test: String): boolean;
var
  i: Integer;
begin
  Result := false;
  for i := Low(CmdLineSwitches) to High(CmdLineSwitches) do
    Result := Result or SameText(CMDLine, CmdLineSwitches[i] + Test);
end;

function ParseParams(): TParams;
var
  i: Integer;
  param: String;
begin
  for i := 1 to ParamCount do
  begin
    param := ParamStr(i);

    if CompareParam(param, 'stdout') then
    begin
      Result.WriteStdOut := true;
      Continue;
    end;

    if CompareParam(param, 'stdin') then
    begin
      Result.ReadStdIn := true;
      Continue;
    end;

    if CompareParam(param, 'trimright') then
    begin
      Result.TrimRight := true;
      Continue;
    end;

    if CompareParam(param, 'trimleft') then
    begin
      Result.TrimLeft := true;
      Continue;
    end;

    if CompareParam(param, 'trimboth') then
    begin
      Result.TrimLeft := true;
      Result.TrimRight := true;
      Continue;
    end;

    // No param so it must be the filename!
    Result.FileName := param;
  end;

  if (((not Result.ReadStdIn) or (not Result.WriteStdOut)) and (Result.FileName = '')) then
    raise EInvalidParams.Create('No file specified');

  if ((not Result.TrimRight) and (not Result.TrimLeft)) then
    raise EInvalidParams.Create('No action will be taken');
end;


procedure PrintUsage();
begin
  WriteLn(ErrOutput, '');
  WriteLn(ErrOutput, 'TrimFile - A tool to trim each line of a file');
  WriteLn(ErrOutput, 'Usage: TrimFile.exe [OPTION] [input-file]');
  WriteLn(ErrOutput, '');
  WriteLn(ErrOutput, '  -stdout      Print the result to StdOutput instead of saving it to the file');
  WriteLn(ErrOutput, '  -stdin       Read from StdInput instead from file');
  WriteLn(ErrOutput, '  -trimleft    Removes all leading whitespace');
  WriteLn(ErrOutput, '  -trimright   Removes all trailing whitespace');
  WriteLn(ErrOutput, '  -trimboth    Short for -trimleft -trimright');
  WriteLn(ErrOutput, '');
  WriteLn(ErrOutput, 'As long as one of -stdout or -stdin is missing, a filename has to be given.');
  WriteLn(ErrOutput, '');
  WriteLn(ErrOutput, 'TrimFile homepage: https://github.com/wendelb/TrimFile');
  WriteLn(ErrOutput, 'Please report any issues you encounter at the issue tracker.');
  WriteLn(ErrOutput, '(c) by Bernhard Wendel, 2014');
  WriteLn(ErrOutput, '');
end;

function ReadFile(var fp: TextFile): TStringList;
var
  line: String;
begin
  Result := TStringList.Create;
  while not EOF(fp) do
  begin
    Readln(fp, line);
    Result.Add(line);
  end;
end;

procedure TrimList(const List: TStringList; const ATrimRight, ATrimLeft: Boolean);
var
  i: Integer;
  line: String;
begin
  for i := 0 to List.Count - 1 do
  begin
    Line := List[i];
    if ATrimRight then
      Line := TrimRight(Line);

    if ATrimLeft then
      Line := TrimLeft(Line);

    List[i] := Line;
  end;
end;

procedure EchoList(const List: TStringList);
var
  line: String;
begin
  for line in List do
  begin
    WriteLn(Output, line);
  end;
end;

var
  Params: TParams;
  fp: TextFile;
  FileContent: TStringList;
begin
  try
    Params := ParseParams;

    if Params.ReadStdIn then
    begin
      FileContent := ReadFile(Input);
    end
    else
    begin
      if FileExists(Params.FileName) then
      begin
        AssignFile(fp, Params.FileName);
        Reset(fp);
        FileContent := ReadFile(fp);
        CloseFile(fp);
      end
      else
        raise EFileNotFoundException.Create('The given filename was not found');
    end;

    TrimList(FileContent, Params.TrimRight, Params.TrimLeft);

    if Params.WriteStdOut then
    begin
      EchoList(FileContent);
    end
    else
      FileContent.SaveToFile(Params.FileName);

  except
    on E: Exception do
    begin
      Writeln(ErrOutput, 'Exception: ', E.ClassName, ': ', E.Message);
      PrintUsage;
    end;
  end;
end.
