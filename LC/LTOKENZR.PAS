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
    ETokenKind = (
      ETokenKindUnknown
    );

    PToken = ^TToken;
    TToken = object (TObject)
      kind: ETokenKind;
      value: string;
      position: longint;
      lineNumber: longint;
    end;

    PTokenizer = ^TTokenizer;
    TTokenizer = object (TObject)
    public
      constructor init;
      destructor done; virtual;
      procedure addToken(token: PToken);
      function getToken(index: longint): PToken;
      function getTokenCount: longint;
      procedure tokenize(stream: PStream);
    private
      _stream: PStream;
      _tokens: PList;
      _lineNumber: longint;
      function findToken: boolean;
    end;

implementation

  const
    C_EOLN_COMMENT_START = '#';
    C_DELIMITERS = [C_CR, C_LF, ' ', ','];
    C_ACCEPTED_DELIMITERS = [',', ':'];

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

  procedure TTokenizer.addToken(token: PToken);
  begin
    _tokens^.addObject(token);
  end;

  function TTokenizer.getToken(index: longint): PToken;
  begin
    getToken := PToken(_tokens^.getObject(index));
  end;

  function TTokenizer.getTokenCount: longint;
  begin
    getTokenCount := _tokens.getCount;
  end;

  procedure TTokenizer.tokenize(stream: PStream);
  begin
    _lineNumber := 1;
    _stream := stream;
    while findToken do;
  end;

  function TTokenizer.findToken: boolean;
  var
    ch: char;
    isDone: boolean;
  begin
    token.value := '';
    token.position := stream^.getPosition;
    isDone := false;
    while not isDone and (stream^.read(@ch, 1) > 0) do
    begin
      if ch = C_EOLN_COMMENT_START then 
      begin
        while (ch<>C_CR) do stream^.read(@ch, 1);
        if ch = C_LF then stream^.read(@ch, 1);
      end else if ch in C_ACCEPTED_DELIMITERS then
      begin
        if length(token.value)>0 then 
        begin
          stream^.seek(stream^.getPosition - 1);
        end else
          token.value := ch;
        isDone := true;
      end else if ch in C_DELIMITERS then
      begin
        if length(token.value)>0 then
        begin
          isDone := true;
        end;
      end else begin
        token.value := token.value + ch;
      end;
    end;
    findToken := isDone;
  end;

  { TTokenizer private }

  { Other }

end.