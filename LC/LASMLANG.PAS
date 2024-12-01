{
  Language parser helper unit
}
unit 
  lasmlang;

interface
  
  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc, ulist,
    lcommon, lliteral, lcbase, lsymbols, lasmtknz;

  const
    C_MSG_FOUND_KNOWN_SYMBOL = $BA;
    C_MSG_ADD_NEW_SENTENCE   = $BB;

  type
    EParseResult = (
      EParseSuccessful,
      EParseUnsuccessful,
      EParseFatalError
    );

    PLanguage = ^TLanguage;
    TLanguage = object (TObject)
    public
      constructor initWithTokens(tokens: PList);
      destructor done; virtual;
      function parseProgram: EParseResult;  
    private
      _tokens: PList;
      procedure next;
      function token: string;
      function lookAhead: string;
      function parseSentence: EParseResult;
      function parseCodeBlock: EParseResult;
      function parseDefinitionItem: EParseResult;
      function parseDefinitionDeclaration: EParseResult;
      function parseVariableItem: EParseResult;
      function parseVariableDeclaration: EParseResult;
      function parseDeclaration: EParseResult;
      function parseDataBlock: EParseResult;
      procedure didParseSentence(var sentence: TSentence);
  end;

implementation

  const
    C_KEYWORD_DATA_SECTION = '.data';
    C_KEYWORD_CODE_SECTION = '.code';
    C_KEYWORD_DEFINITION_DECLARATION = 'let';
    C_KEYWORD_VARIABLE_DECLARATION = 'var';

  { TLanguage public }

  constructor TLanguage.initWithTokens(tokens: PList);
  begin
    inherited init;
    _tokens := tokens;
    _tokens^.retain;
    _tokens^.moveToStart;
  end;

  destructor TLanguage.done;
  begin
    _tokens^.release;
    inherited done;
  end;

  function TLanguage.parseProgram: EParseResult;  
  var 
    result: EParseResult;
  begin    
    if token = C_KEYWORD_DATA_SECTION then
    begin
      next;
      result := parseDataBlock;
    end else
      result := EParseSuccessful;

    if result = EParseFatalError then
    begin
      msg(EMsgFatal, 'Data block contains errors', #0);
      exit;
    end;

    if token = C_KEYWORD_CODE_SECTION then
    begin
      next;
      result := parseCodeBlock;
      if result = EParseUnsuccessful then
        msg(EMsgFatal, 'Code section contains errors', #0);
    end else begin
      msg(EMsgFatal, 'Expected .code header, got "%0" instead.', token);
      result := EParseFatalError;
    end;

    parseProgram := result;
  end;

  { TLanguage private }

  procedure TLanguage.next;
  begin
    _tokens^.moveForward;
  end;

  function TLanguage.token: string;
  var 
    t: PToken;
  begin
    t := PToken(_tokens^.getObjectAtCursor);
    if t<>nil then 
    begin
      token := t^.value;
    end else token := '';
  end;
  
  function TLanguage.lookAhead: string;
  var t: PToken;
  begin
    t := PToken(_tokens^.getObjectAfterCursor);
    if t<>nil then lookAhead := t^.value else lookAhead := '';
  end;

  function TLanguage.parseSentence: EParseResult;
  var
    success: boolean;
    sentence: TSentence;
  begin
    parseSentence := EParseUnsuccessful;
    fillchar(sentence, sizeof(TSentence), 0);

    if token = '' then exit;
    
    { check for label at beginning of sentence }
    if lookAhead = ':' then
    begin
      sentence.labelName := token;
      next; { skips label name } 
      next; { skips colon } 
    end;

    { check for the opname to be correct } 
    sentence.opname := token; 
    with sentence do success := getOpcodeInfoByName(opname, opcode, argCount);
    if not success then
    begin
      msg(EMsgFatal, 'Found invalid operation "%0"', sentence.opname);
      parseSentence := EParseFatalError;
      exit;
    end;
    next;

    { if no arguments then we're done }
    if sentence.argCount = 0 then
    begin
      parseSentence := EParseSuccessful;
      didParseSentence(sentence);
      exit;
    end;

    { check first argument }
    sentence.args[0].value := token;
    sentence.args[0].argType := getParameterType(token);
    if sentence.args[0].argType = EParameterTypeUnknown then 
    begin
      msg(EMsgFatal, 'Expected first operation argument', #0);
      parseSentence := EParseFatalError;
      exit;
    end;  

    if sentence.argCount = 1 then
    begin
      parseSentence := EParseSuccessful;
      didParseSentence(sentence);
      next;
      exit;
    end;

    next;
    if token <> ',' then
    begin
      msg(EMsgFatal, 'Expected comma, got "%0" instead.', #0);
      parseSentence := EParseFatalError;
      exit;
    end;

    next;
    sentence.args[1].value := token;
    sentence.args[1].argType := getParameterType(token);
    if sentence.args[1].argType = EParameterTypeUnknown then 
    begin
      msg(EMsgFatal, 'Expected second operation argument', #0);
      parseSentence := EParseFatalError;
      exit;
    end;
    next;
    parseSentence := EParseSuccessful;
    didParseSentence(sentence);
  end;

  function TLanguage.parseCodeBlock: EParseResult;
  var
    count: longint;
  begin
    parseCodeBlock := EParseUnsuccessful;
    count := 0;
    while parseSentence = EParseSuccessful do inc(count);
    if parseSentence = EParseFatalError then
    begin
      msg(EMsgFatal, 'Code section contains errors', #0);
      parseCodeBlock := EParseFatalError;
    end else 
    if count > 0 then 
      parseCodeBlock := EParseSuccessful 
    else 
      parseCodeBlock := EParseUnsuccessful;
  end;

  function TLanguage.parseDefinitionItem: EParseResult;
  var
    isValidNumber: boolean;
    identifier: TIdentifier;
    value: TUInt32;
    symbol: PSymbol;
  begin
    identifier := token;
    if not isValidIdentifier(identifier) then 
    begin
      msg(EMsgFatal, 'Expected valid identifier, got "%0"', token);
      parseDefinitionItem := EParseFatalError;
      exit;
    end;
    next;
    if token <> '=' then
    begin
      msg(EMsgFatal, 'Expected = after definition identifier, got "%0"', token);
      parseDefinitionItem := EParseFatalError;
      exit;
    end;
    next;
    isValidNumber := any2int(token, value);
    if not isValidNumber then
    begin
      msg(EMsgFatal, 'Expected a numeric literal, got "%0"', token);
      parseDefinitionItem := EParseFatalError;
      exit;
    end;
    next;

    { we found a symbol, we notify the parser }
    symbol := new(PSymbol, init);
    symbol^.name := identifier;
    symbol^.value := value;
    sendMessageWithData(
      C_MSG_FOUND_KNOWN_SYMBOL,
      getDelegate,
      symbol,
      0
    );
    symbol^.release;

    parseDefinitionItem := EParseSuccessful;
  end;

  function TLanguage.parseDefinitionDeclaration: EParseResult;
  begin
    if token <> C_KEYWORD_DEFINITION_DECLARATION then 
    begin
      parseDefinitionDeclaration := EParseUnsuccessful;
      exit;
    end;
    repeat
      next;
      if parseDefinitionItem = EParseFatalError then
      begin
        msg(EMsgFatal, 'Definition declaration contains errors', #0);
        parseDefinitionDeclaration := EParseFatalError;
        exit;
      end;      
    until token <> ',';
    parseDefinitionDeclaration := EParseSuccessful;
  end;

  function TLanguage.parseVariableItem: EParseResult;
  begin
    if not isValidIdentifier(token) then 
    begin
      msg(EMsgFatal, 'Expected a valid identifier, got "%0"', token);
      parseVariableItem := EParseFatalError;
      exit;
    end;
    next;
    if token <> ':' then
    begin
      msg(EMsgFatal, 'Expected : after variable identifier, got "%0"', token);
      parseVariableItem := EParseFatalError;
      exit;
    end;
    next;
    if not isValidVariableType(token) then 
    begin
      msg(EMsgFatal, 'Expected a valid variable type, got "%0"', token);
      parseVariableItem := EParseFatalError;
      exit;
    end;
    next;

    if token = '=' then
    begin
      next;
      if not isValidLiteral(token) then
      begin
        msg(EMsgFatal, 'Expected a literal, got "%0"', token);
        exit;
      end else begin
        next;
      end;
    end;
    parseVariableItem := EParseSuccessful;
  end;

  function TLanguage.parseVariableDeclaration: EParseResult;
  begin
    if token <> C_KEYWORD_VARIABLE_DECLARATION then 
    begin
    parseVariableDeclaration := EParseUnsuccessful;
    exit;
    end;
    repeat
      next;
      if parseVariableItem = EParseFatalError then
      begin
        msg(EMsgFatal, 'Variable declaration contains errors', #0);
        parseVariableDeclaration := EParseFatalError;
        exit;
      end;      
    until token <> ',';
    parseVariableDeclaration := EParseSuccessful;
  end;

  function TLanguage.parseDeclaration: EParseResult;
  var
    result: EParseResult;
    count: byte;
  begin
    count := 0;
    repeat
      result := parseDefinitionDeclaration;
      if result = EParseFatalError then
      begin
        msg(EMsgFatal, 'Data section contains errors', #0);
        exit;
      end;
      if result = EParseUnsuccessful then
      begin
        result := parseVariableDeclaration;
        if result = EParseFatalError then
        begin
          msg(EMsgFatal, 'Data section contains errors', #0);
          exit;
        end;          
      end;
      if result = EParseSuccessful then inc(count);
    until result = EParseUnsuccessful;
    if count>0 then
      parseDeclaration := EParseSuccessful
    else  
      parseDeclaration := EParseUnsuccessful;
  end;

  function TLanguage.parseDataBlock: EParseResult;
  begin
    while parseDeclaration = EParseSuccessful do;
    if parseDeclaration = EParseFatalError then
    begin
      msg(EMsgFatal, 'Data section contains errors', #0);
      parseDataBlock := EParseFatalError;
    end else 
      parseDataBlock := EParseSuccessful;
  end;
    
  { Other }

  procedure TLanguage.didParseSentence(var sentence: TSentence);
  begin
    sendMessageWithData(C_MSG_ADD_NEW_SENTENCE, getDelegate, @sentence, 0);
  end;

end.
