{
  Assembly source code parser unit
}
unit
  lparser;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc, ustream, ufstream, ulist, ustring,
    lcommon, lliteral, lcbase, ltokenzr;

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
      _tokens: PList;
      procedure tokenize;
    end;

implementation

  { TAssemblyParser public }

  constructor TAssemblyParser.init;
  begin
    inherited init;
    _source := nil;
    _tokens := nil;
  end;

  destructor TAssemblyParser.done;
  begin
    if (_tokens <> nil) then _tokens^.release;
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

  type
    EParseResult = (
      EParseSuccessful,
      EParseUnsuccessful,
      EParseFatalError
    );

    procedure next;
    begin
      _tokens^.moveForward;
    end;

    function token: string;
    var t: PToken;
    begin
      t := PToken(_tokens^.getObjectAtCursor);
      if t<>nil then 
      begin
        token := t^.value;
        { writeln(t^.value); }
      end else token := '';
    end;

    function lookAhead: string;
    var t: PToken;
    begin
      t := PToken(_tokens^.getObjectAfterCursor);
      if t<>nil then lookAhead := t^.value else lookAhead := '';
    end;

    function parseSentence: boolean;
    var
      success: boolean;
      code, argCount: byte;
    begin
      parseSentence := false;
      if lookAhead = ':' then
      begin
        next;
        next;
      end;
      success := getOpcodeInfoByName(token, code, argCount);

      if success then
      begin
        next;
        case argCount of
          0: parseSentence := true;
          1: begin
            if getParameterType(token) <> EParameterTypeUnknown then 
            begin
              next;
              parseSentence := true;
            end else
              writeln('expected first argument');
          end;
          2: begin
            if getParameterType(token) <> EParameterTypeUnknown then 
            begin
              next;
              if token = ',' then
              begin
                next;
                if getParameterType(token) <> EParameterTypeUnknown then 
                begin
                  next;
                  parseSentence := true;
                end else
                  writeln('expected second argument');
              end else
                writeln('expected ,');
            end else
              writeln('expected first argument');
          end;
        end;
      end;
    end;

    function parseCodeBlock: EParseResult;
    var
      count: longint;
    begin
      parseCodeBlock := EParseUnsuccessful;
      count := 0;
      while parseSentence do inc(count);
      writeln('sentence count is ', count);
      if count > 0 then 
        parseCodeBlock := EParseSuccessful 
      else 
        parseCodeBlock := EParseUnsuccessful;
    end;

    function parseDefinitionItem: EParseResult;
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

    function parseDefinitionDeclaration: EParseResult;
    begin
      if token <> 'def' then 
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

    function parseVariableItem: EParseResult;
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

    function parseVariableDeclaration: EParseResult;
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

    function parseDeclaration: EParseResult;
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

    function parseDataBlock: EParseResult;
    begin
      while parseDeclaration = EParseSuccessful do;
      if parseDeclaration = EParseFatalError then
      begin
        writeln('error in data block');
        parseDataBlock := EParseFatalError;
      end else 
        parseDataBlock := EParseSuccessful;
    end;

    function parseProgram: EParseResult;  
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

  begin
    tokenize;
    writeln('Parsing...');
    if parseProgram = EParseSuccessful then 
      writeln('parse success') 
    else 
      writeln('parse error');
  end;

  { TAssemblyParser private }

  procedure TAssemblyParser.tokenize;
  var
    tokenizer: PTokenizer;
  begin
    writeln('Tokenizing...');
    if _tokens <> nil then _tokens^.release;
    tokenizer := new(PTokenizer, init);
    tokenizer^.tokenize(_source);
    _tokens := tokenizer^.getTokens;
    _tokens^.retain;
    tokenizer^.release;
    _tokens^.moveToStart;
    writeln('Got ', _tokens^.getCount ,' tokens.');
  end;

  { Other }

end.
