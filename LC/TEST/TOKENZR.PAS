uses
  consts, utils, uclasses, types, locale,
  uobject, uexc, ustream, ufstream,
  ltokenzr;

function testfile(const sourceName: string): boolean;
var
  fsSource, fsTokenized: PFileStream;
  tokenizer: PTokenizer;
  token: TToken;
  success: boolean;
begin
  fsSource := new (PFileStream, initWithPath('\examples\' + sourceName + '.asm', EFileReadOnly));
  fsTokenized := new (PFileStream, initWithPath('\examples\' + sourceName + '.tkn', EFileReadOnly));
  tokenizer := new (PTokenizer, init);

  success := tokenizer^.next(fsSource, token);
  while success do
  begin
    write('(', token.position, ', "', token.value, '") ');
    success := tokenizer^.next(fsSource, token);
  end;
  tokenizer^.release;
  fsSource^.release;
  fsTokenized^.release;
end;

begin
  testFile('write');
end.