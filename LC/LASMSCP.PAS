{
  Assembly source code parser unit
}
unit
  lasmscp;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc, ustream, ufstream,
    ltokenzr;

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
  begin
    tokenizer := new (PTokenizer, init);
    tokenizer^.next(_source);
    tokenizer^.release;
  end;

  { TAssemblyParser private }

  { Other }

end.
