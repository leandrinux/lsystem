uses
  consts, utils, uclasses, types, locale,
  uobject, uexc, ustream, ufstream, ulist,
  lparser;

function testfile(const sourceName: string): boolean;
var
  parser: PAssemblyParser;
begin
  parser := new (PAssemblyParser, init);
  parser^.setSourceFile('\examples\' + sourceName + '.asm');
  parser^.parse;
  parser^.release;
end;

begin
  testFile('hellow');
end.