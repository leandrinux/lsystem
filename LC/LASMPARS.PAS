{
  Assembly source code parser unit
}
unit
  lasmpars;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc, ustream, ufstream, ulist, ustring,
    lcommon, lparser, lasmtknz, lasmlang, lsymbols;

  const 
    C_ASM_PARSER_TYPE = 'asm';

  type
    PAssemblyParser = ^TAssemblyParser;
    TAssemblyParser = object (TParser)
    public
      constructor init;
      destructor done; virtual;
      procedure run; virtual;
      procedure receiveMessage(message: PObjectMessage); virtual;
    private
      procedure onFoundKnownSymbol(symbol: PSymbol);
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
    language^.setDelegate(@self);
    writeln('Parsing... ');
    if language^.parseProgram <> EParseSuccessful then 
    begin
      writeln('failed');
      exit;
    end;

    language^.release;
    tokenizer^.release;
  end;

  procedure TAssemblyParser.receiveMessage(message: PObjectMessage);
  begin
    if message^.opcode = C_MSG_FOUND_KNOWN_SYMBOL then 
      onFoundKnownSymbol(PSymbol(message^.payload));
  end;

  { TAssemblyParser private }

  procedure TAssemblyParser.onFoundKnownSymbol(symbol: PSymbol);
  begin
    getSymbols^.addSymbol(symbol);
  end;

  { Other }

end.
