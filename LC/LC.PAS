uses
  lcommon, ltexts, lcmdline, lbuilder;

const 
  C_BUILD_DATE = '2024-11-18';
  C_BUILD_TIME = '15:36';

procedure build;
var
  builder: PBuilder;  
begin
  builder := new(PBuilder, init);
  with cmdline do
  begin
    if srcType = 'il' then
      builder^.setInputLanguage(ELanguageIL)
    else if srcType = 'asm' then
      builder^.setInputLanguage(ELanguageAssembly)
    else begin
      msg(EMsgFatal, 'Unsupported input language ""', srcType);
      exit;
    end;

    if dstType = 'bin' then
      builder^.setOutputLanguage(ELanguageBinary)
    else begin
      msg(EMsgFatal, 'Unsupported output language ""', dstType);
      exit;
    end;

    builder^.setVerbose(verbose);

    msg(EMsgGood, 'Building %0', srcPath);    
    builder^.runWithPath(srcPath);
  end;
  builder^.release;
end;

begin
  msg(EMsgStrong, C_STR_BANNER, C_STR_LSYSTEM_VERSION + #0 + C_STR_LSYSTEM_CODENAME);
  msg(EMsgStrong, C_STR_BUILD_TS, C_BUILD_DATE + #0 + C_BUILD_TIME);
  build;
end.