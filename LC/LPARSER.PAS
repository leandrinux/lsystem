{
  Assembly source code parser unit
}
unit
  lparser;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc, ustream, ufstream, ulist, ustring,
    lcommon, lliteral, lcbase, ltokenzr, llang;

  type
    PAssemblyParser = ^TAssemblyParser;
    TAssemblyParser = object (TObject)
    public
      constructor init;
      destructor done; virtual;
      procedure setSourceFile(const path: string);
      procedure parse;
    private
      _source: PStream;
    end;

implementation

  { TAssemblyParser public }

  constructor TAssemblyParser.init;
  begin
    inherited init;
    _source := nil;
  end;

  destructor TAssemblyParser.done;
  begin
    if (_source <> nil) then _source^.release;
    inherited done;
  end;

  procedure TAssemblyParser.setSourceFile(const path: string);
  var 
    fs: PFileStream;
  begin
    fs := new(PFileStream, initWithPath(path, EFileReadOnly));
    if (_source <> nil) then _source^.release;
    _source := fs;
  end;

  procedure TAssemblyParser.parse;
  var
    tokenizer: PTokenizer;
    tokens: PList;
    language: PLanguage;
  begin
    writeln('Tokenizing...');
    tokenizer := new(PTokenizer, init);
    tokenizer^.tokenize(_source);
    tokens := tokenizer^.getTokens;
    writeln('Got ', tokens^.getCount ,' tokens.');

    language := new (PLanguage, init);
    writeln('Parsing...');
    if language^.parseProgram(tokens) = EParseSuccessful then 
      writeln('parse success') 
    else 
      writeln('parse error');

    language^.release;
    tokenizer^.release;
  end;

  { TAssemblyParser private }


  { Other }

end.
