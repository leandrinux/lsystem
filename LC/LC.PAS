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
  builder^.setSource(cmdline.srcPath, cmdline.srcType);
  builder^.setTarget(cmdline.dstPath, cmdline.dstType);
  builder^.run;
  builder^.release;
end;

begin
  msg(EMsgStrong, C_STR_BANNER, C_STR_LSYSTEM_VERSION + #0 + C_STR_LSYSTEM_CODENAME);
  msg(EMsgStrong, C_STR_BUILD_TS, C_BUILD_DATE + #0 + C_BUILD_TIME);
  build;
end.