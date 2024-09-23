uses
  strings,
  lcommon, lcmdline, ltexts, lasmscp;

procedure parseFile(const path: string);
var
  assemblyParser: PAssemblyParser;
begin
  assemblyParser := new (PAssemblyParser, init);
  with assemblyParser^ do
  begin
    setSourceFile(path);
    parse;
    release;
  end;
end;

const
  C_BUILD_DATE = '2024-09-21';
  C_BUILD_TIME = '17:24';

begin
  commandLine.sourceFilename := '\examples\abc.asm';

  msg(EMsgStrong, C_STR_BANNER, C_STR_LSYSTEM_VERSION + #0 + C_STR_LSYSTEM_CODENAME);
  msg(EMsgStrong, C_STR_BUILD_TS, C_BUILD_DATE + #0 + C_BUILD_TIME);
  if commandLine.sourceFilename = '' then 
  begin
    msg(EMsgFatal, C_STR_NO_SOURCE_FILE, '');
    halt(1);
  end;
  parseFile(commandLine.sourceFilename);
end.