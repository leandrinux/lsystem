uses
  consts, utils, uclasses, types, locale,
  uobject, uexc, ustream, ufstream, ulist,
  ltokenzr;

procedure writeTokens(const sourceName: string; tokens: PList);
var
  fsTokenized: PFileStream;
  token: PToken;
begin
  write('Saving ', tokens^.getCount, ' tokens... ');
  fsTokenized := new (PFileStream, initWithPath('\examples\' + sourceName + '.tkn', EFileCreate));

  tokens^.moveToStart;
  token := PToken(tokens^.getObjectAtCursor);
  while token<>nil do
  begin
    fsTokenized^.writeln(token^.value);
    tokens^.moveForward;
    token := PToken(tokens^.getObjectAtCursor);
  end;
  fsTokenized^.release;
  writeln('done');
end;

function testfile(const sourceName: string): boolean;
var
  fsSource: PFileStream;
  tokenizer: PTokenizer;
begin
  fsSource := new (PFileStream, initWithPath('\examples\' + sourceName + '.asm', EFileReadOnly));
  tokenizer := new (PTokenizer, init);
  writeln('Tokenizing...');
  tokenizer^.tokenize(fsSource);
  writeTokens(sourceName, tokenizer^.getTokens);
  tokenizer^.release;
  fsSource^.release;
end;

begin
  testFile('full');
end.