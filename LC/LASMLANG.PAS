{
  Language parser helper unit
}
unit 
  lasmlang;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc, ulist,
    lcbase, lasmtknz;

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
  end;

implementation

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
    if token = '.data' then
    begin
      next;
      result := parseDataBlock;
      if result = EParseSuccessful then writeln('data section parsed ok');
    end else
      result := EParseSuccessful;

    if result = EParseFatalError then
    begin
      writeln('data block error');
      exit;
    end;

    if token = '.code' then
    begin
      next;
      result := parseCodeBlock;
      if result = EParseSuccessful then writeln('code block ok');
      if result = EParseUnsuccessful then writeln('code block fail');
    end else
    begin
      writeln('expected .code, got ''', token, '''');
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
      { writeln(t^.value); }
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
    {
      code, argCount: byte;
      labelName: TIdentifier;
      operationName: TOperationName;
      arg0, arg1: TArgumentValue;
    }
    sentence: TSentence;
  begin
    parseSentence := EParseUnsuccessful;
    if lookAhead = ':' then
    begin
      sentence.labelName := token;
      next; 
      next;
    end;
    sentence.opname := token; 
    with sentence do success := getOpcodeInfoByName(opname, opcode, argCount);

    if success then
    begin
      next;
      case sentence.argCount of
        0: parseSentence := EParseSuccessful;
        1: begin
          sentence.args[0].argType := getParameterType(token);
          if sentence.args[0].argType <> EParameterTypeUnknown then 
          begin
            next;
            parseSentence := EParseSuccessful;
          end else
            writeln('expected first argument');
        end;
        2: begin
          sentence.args[0].argType := getParameterType(token);
          if sentence.args[0].argType <> EParameterTypeUnknown then 
          begin
            next;
            if token = ',' then
            begin
            next;
            sentence.args[1].argType := getParameterType(token);
            if sentence.args[1].argType <> EParameterTypeUnknown then 
            begin
              next;
              parseSentence := EParseSuccessful;
            end else begin
              writeln('expected second argument');
              parseSentence := EParseFatalError;
            end;
            end else begin
            writeln('expected ,');
            parseSentence := EParseFatalError;
            end;
          end else begin
            writeln('expected first argument');
            parseSentence := EParseFatalError;
          end;
        end;
      end;
      sendMessageWithData(C_MSG_ON_PARSED_SENTENCE, getDelegate, @sentence, sizeof(TSentence));
    end;
  end;

  function TLanguage.parseCodeBlock: EParseResult;
  var
    count: longint;
  begin
    parseCodeBlock := EParseUnsuccessful;
    count := 0;
    while parseSentence = EParseSuccessful do inc(count);
    writeln('sentence count is ', count);
    if parseSentence = EParseFatalError then
    begin
      writeln('code block parse error');
      parseCodeBlock := EParseFatalError;
    end else 
    if count > 0 then 
      parseCodeBlock := EParseSuccessful 
    else 
      parseCodeBlock := EParseUnsuccessful;
  end;

  function TLanguage.parseDefinitionItem: EParseResult;
  begin
    if not isValidIdentifier(token) then 
    begin
      writeln('expected valid identifier, got "', token , '"');
      parseDefinitionItem := EParseFatalError;
      exit;
    end;
    next;
    if token <> '=' then
    begin
      writeln('expected = after definition identifier, got ', token);
      parseDefinitionItem := EParseFatalError;
      exit;
    end;
    next;
    if not isValidNumericLiteral(token) then
    begin
      writeln('expected a numeric literal, got ', token, ' ');
      parseDefinitionItem := EParseFatalError;
      exit;
    end;
    next;
    parseDefinitionItem := EParseSuccessful;
  end;

  function TLanguage.parseDefinitionDeclaration: EParseResult;
  begin
    if token <> 'let' then 
    begin
      parseDefinitionDeclaration := EParseUnsuccessful;
      exit;
    end;
    repeat
      next;
      if parseDefinitionItem = EParseFatalError then
      begin
        writeln('fatal error on data definition declaration');
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
      writeln('expected valid identifier, got "', token , '"');
      parseVariableItem := EParseFatalError;
      exit;
    end;
    next;
    if token <> ':' then
    begin
      writeln('expected : after variable identifier, got ', token);
      parseVariableItem := EParseFatalError;
      exit;
    end;
    next;
    if not isValidVariableType(token) then 
    begin
      writeln('expected valid variable type, got "', token , '"');
      parseVariableItem := EParseFatalError;
      exit;
    end;
    next;

    if token = '=' then
    begin
      next;
      if not isValidLiteral(token) then
      begin
        writeln('expected a literal, got ', token, ' ');
        exit;
      end else begin
        next;
      end;
    end;
    parseVariableItem := EParseSuccessful;
  end;

  function TLanguage.parseVariableDeclaration: EParseResult;
  begin
    if token <> 'var' then 
    begin
    parseVariableDeclaration := EParseUnsuccessful;
    exit;
    end;
    repeat
      next;
      if parseVariableItem = EParseFatalError then
      begin
        writeln('fatal error on data variable declaration');
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
        writeln('error in data block declaration');
        exit;
      end;
      if result = EParseUnsuccessful then
      begin
        result := parseVariableDeclaration;
        if result = EParseFatalError then
        begin
          writeln('error in data block declaration');
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
      writeln('error in data block');
      parseDataBlock := EParseFatalError;
    end else 
      parseDataBlock := EParseSuccessful;
  end;
    
  { Other }

end.
