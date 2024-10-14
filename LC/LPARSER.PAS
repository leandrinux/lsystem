{
  Assembly source code parser unit
}
unit
  lparser;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc, ustream, ufstream, ulist, ustring,
    lcommon, lliteral, lcbase, ltokenzr, llang, lbingen, lbindata;

  type
    PAssemblyParser = ^TAssemblyParser;
    TAssemblyParser = object (TObject)
    public
      constructor init;
      destructor done; virtual;
      procedure setSourceFile(const path: string);
      procedure setTargetFile(const path: string);
      procedure parse;
    private
      _source: PStream;
      _target: PStream;
    end;

implementation

  { TAssemblyParser public }

  constructor TAssemblyParser.init;
  begin
    inherited init;
    _source := nil;
    _target := nil;
  end;

  destructor TAssemblyParser.done;
  begin
    if (_source <> nil) then _source^.release;
    if (_target <> nil) then _target^.release;
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

  procedure TAssemblyParser.setTargetFile(const path: string);
  var 
    fs: PFileStream;
  begin
    fs := new(PFileStream, initWithPath(path, EFileCreate));
    if (_target <> nil) then _target^.release;
    _target := fs;
  end;

  procedure TAssemblyParser.parse;
  var
    tokenizer: PTokenizer;
    tokens: PList;
    language: PLanguage;
    binaryData: PBinaryData;
    binaryGenerator: PBinaryGenerator;
  begin
    writeln('Tokenizing...');
    tokenizer := new(PTokenizer, init);
    tokenizer^.tokenize(_source);
    tokens := tokenizer^.getTokens;
    writeln('Got ', tokens^.getCount ,' tokens.');

    binaryData := new (PBinaryData, init);
    language := new (PLanguage, initWithTokens(tokens, binaryData));
    writeln('Parsing...');
    if language^.parseProgram <> EParseSuccessful then 
    begin
      writeln('parse error');
      exit;
    end;

    writeln('Building binary...');
    binaryGenerator := new (PBinaryGenerator, initWithBinaryData(binaryData));
    binaryGenerator^.make(_target);
    binaryGenerator^.release;

    binaryData^.release;
    language^.release;
    tokenizer^.release;
  end;

  { TAssemblyParser private }


  { Other }

end.
