{
  Assembly source code parser unit
}
unit
  lasmpars;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc, ustream, ufstream, ulist, ustring,
    lcommon, lcbase, lparser, lasmtknz, lasmlang, lsymbols;

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
      procedure onNewSentence(sentence: PSentence);
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
    lcommon.msg(EMsgNormal, 'Tokenizing... ', #0);
    tokenizer := new(PTokenizer, init);
    tokenizer^.tokenize(getSource);
    tokens := tokenizer^.getTokens;

    language := new (PLanguage, initWithTokens(tokens));
    language^.setDelegate(@self);
    lcommon.msg(EMsgNormal, 'Parsing... ', #0);
    if language^.parseProgram <> EParseSuccessful then 
    begin
      lcommon.msg(EMsgFatal, 'Parsing failed.', #0);
      exit;
    end;

    language^.release;
    tokenizer^.release;
  end;

  procedure TAssemblyParser.receiveMessage(message: PObjectMessage);
  begin
    if message^.opcode = C_MSG_FOUND_KNOWN_SYMBOL then 
      onFoundKnownSymbol(PSymbol(message^.payload))
    else if message^.opcode = C_MSG_ADD_NEW_SENTENCE then 
      onNewSentence(PSentence(message^.payload));
  end;

  { TAssemblyParser private }

  procedure TAssemblyParser.onFoundKnownSymbol(symbol: PSymbol);
  begin
    getSymbols^.addSymbol(symbol);
  end;

  procedure TAssemblyParser.onNewSentence(sentence: PSentence);
  var
    symbol: PSymbol;
  begin
    if sentence^.labelName <> '' then
    begin
      symbol := new(PSymbol, init);
      symbol^.name := sentence^.labelName;
      symbol^.value := getWriter^.getCodeSize;
      getSymbols^.addSymbol(symbol);
      symbol^.release;
    end;
    getWriter^.onSentence(sentence^);
  end;

  { Other }

end.
