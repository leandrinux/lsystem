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
        writeln(t^.value);
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

    function parseCodeBlock: boolean;
    var
      count: longint;
    begin
      parseCodeBlock := false;
      if token = '.code' then
      begin
        writeln('valid code header block');
        next;
        count := 0;
        while parseSentence do 
        begin
          writeln('valid sentence');
          inc(count);
        end;
        writeln('sentence count is ', count);
        parseCodeBlock := count > 0
      end;
    end;

    function parseDefinitionItem: boolean;
    var
      value: TUInt32;
    begin
      parseDefinitionItem := false;
      if not isValidIdentifier(token) then exit;
      next;
      if token <> '=' then exit;
      next;
      parseDefinitionItem := any2int(token, value);
    end;

    function parseDefinition: boolean;
    begin
      parseDefinition := false;
      if token <> 'def' then exit;
      parseDefinitionItem;
      while lookAhead = ',' do
      begin
        next; 
        parseDefinitionItem;
      end;
      parseDefinition := true;    
    end;

    function parseVariable: boolean;
    begin
      parseVariable := false;
    end;

    function parseDeclaration: boolean;      
    begin
      parseDeclaration := false;
      while parseDefinition or parseVariable do parseDeclaration := true;
    end;

    function parseDataBlock: boolean;
    begin
      if token = '.code' then
      begin
        writeln('valid code header block, skipping data');
        parseDataBlock := true;
        exit;
      end;

      parseDataBlock := false;
      if token <> '.data' then exit;
      next;
      writeln('valid data header block');
      while parseDeclaration do;
      parseDataBlock := true;
    end;

    function parseProgram: boolean;  
    begin
      parseProgram := parseDataBlock and parseCodeBlock;
    end;

  begin
    tokenize;
    writeln('Parsing...');
    if parseProgram then 
      writeln('success') 
    else 
      writeln('error');
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
