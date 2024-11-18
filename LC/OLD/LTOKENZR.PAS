{
  Tokenizer unit
  Part of the assembly source code parser component
}
unit 
  ltokenzr;

interface

  uses
    ascii, consts, utils, uclasses, types, locale,
    uobject, uexc, ustream, ulist;

  type
    PToken = ^TToken;
    TToken = object (TObject)
      value: string;
      position: longint;
    end;

    PTokenizer = ^TTokenizer;
    TTokenizer = object (TObject)
    public
      constructor init;
      destructor done; virtual;
      function getTokens: PList;
      procedure tokenize(stream: PStream);
    private
      _stream: PStream;
      _tokens: PList;
      _lineNumber: longint;
      procedure addToken(token: PToken);
      function createNextToken: PToken;
    end;

implementation

  { TTokenizer public }

  constructor TTokenizer.init;
  begin
    inherited init;
    _stream := nil;
    _stream^.retain;
    _tokens := new (PList, init);
  end;

  destructor TTokenizer.done;
  begin
    if _stream <> nil then _stream^.release;
    _tokens^.release;
    inherited done;
  end;

  function TTokenizer.getTokens: PList;
  begin
    getTokens := _tokens;
  end;

  procedure TTokenizer.tokenize(stream: PStream);
  var
    token: PToken;
  begin
    _lineNumber := 1;
    _stream := stream;
    token := createNextToken;
    while token<>nil do 
    begin
      addToken(token);
      token^.release;
      token := createNextToken;
    end;    
  end;

  { TTokenizer private }

  procedure TTokenizer.addToken(token: PToken);
  begin
    _tokens^.addObject(token);
  end;

  function TTokenizer.createNextToken: PToken;
  type
    EState = (
      EStateStart,
      EStateComment,
      EStateString,
      EStateEnd
    );
  var 
    state: EState;
    ch: char;
    value: string;
    token: PToken;
  begin
    token := new(PToken, init);
    token^.position := 0;
    value := '';
    state := EStateStart;

    while (state<>EStateEnd) do
    begin
      if _stream^.read(@ch, 1) = 0 then state := EStateEnd;
      case state of
        EStateStart: begin
          if ch = '#' then state := EStateComment
          else if ch = '''' then 
          begin
            value := value + ch;
            state := EStateString;
          end else if ch in [',', ':'] then
          begin
            if length(value)=0 then 
              value := value + ch
            else
              _stream^.seek(_stream^.getPosition - 1);
            state := EStateEnd;
          end else if ch in [C_CR, C_LF, ' '] then
          begin
            if length(value)>0 then state := EStateEnd;
          end else
          begin
            value := value + ch;
          end;
        end;

        EStateComment: begin
          if ch = C_LF then state := EStateStart;
        end;

        EStateString: begin
          if ch in [C_CR, C_LF] then 
            state := EStateEnd
          else
          begin
            value := value + ch;
            if ch = '''' then state := EStateEnd;
          end;
        end;

      end;
    end;

    if value <> '' then
    begin
      token^.value := value;
      createNextToken := token;
    end else
      createNextToken := nil;

  end;

  { TTokenizer private }

  { Other }

end.