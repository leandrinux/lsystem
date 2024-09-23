uses
  consts, utils, uclasses, types, locale,
  uobject, uexc, ustream, ufstream,
  ltokenzr;

function testfile(const sourceName: string): boolean;
var
  fsSource, fsTokenized: PFileStream;
  tokenizer: PTokenizer;
  token: string;
begin
  fsSource := new (PFileStream, initWithPath('\examples\' + sourceName + '.asm', EFileReadOnly));
  fsTokenized := new (PFileStream, initWithPath('\examples\' + sourceName + '.tkn', EFileReadOnly));
  tokenizer := new (PTokenizer, init);

  token := tokenizer^.next(fsSource);
  while token <> '' do
  begin
    write(token, ' ');
    token := tokenizer^.next(fsSource);
  end;
  tokenizer^.release;
  fsSource^.release;
  fsTokenized^.release;
end;

begin
  testFile('abc');
end.