{
  Assembly source code parser unit
}
unit
  lasmpars;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc, ustream, ufstream, ulist, ustring,
    lcommon, lparser, lasmtknz, lasmlang;
    {lliteral, lcbase, ltokenzr, llang, lbingen, lbindata;}

  const 
    C_ASM_PARSER_TYPE = 'asm';

  type
    PAssemblyParser = ^TAssemblyParser;
    TAssemblyParser = object (TParser)
    public
      constructor init;
      destructor done; virtual;
      procedure run; virtual;
    private
    end;

implementation

  { TAssemblyParser public }

  constructor TAssemblyParser.init;
  begin
    inherited init;
  end;

  destructor TAssemblyParser.done;
  begin
    inherited done;
  end;

  procedure TAssemblyParser.run;
  var
    tokenizer: PTokenizer;
    tokens: PList;
    language: PLanguage;
  begin
    write('Tokenizing... ');
    tokenizer := new(PTokenizer, init);
    tokenizer^.tokenize(getSource);
    tokens := tokenizer^.getTokens;
    writeln('got ', tokens^.getCount ,' tokens.');

    language := new (PLanguage, initWithTokens(tokens));
    language^.setDelegate(self.getDelegate);
    write('Parsing... ');
    if language^.parseProgram <> EParseSuccessful then 
    begin
      writeln('failed');
      exit;
    end;
    
    language^.release;
    tokenizer^.release;
  end;

  { TAssemblyParser private }


  { Other }

end.
