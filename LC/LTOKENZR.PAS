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
      function findNextToken: boolean;
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

  function TTokenizer.getTokens: PList;
  begin
    getTokens := _tokens;
  end;

  procedure TTokenizer.tokenize(stream: PStream);
  begin
    _lineNumber := 1;
    _stream := stream;
    while findNextToken do;
  end;

  { TTokenizer private }

  procedure TTokenizer.addToken(token: PToken);
  begin
    _tokens^.addObject(token);
  end;

  function TTokenizer.findNextToken: boolean;
  var
    ch: char;
    isDone: boolean;
    token: PToken;
  begin
    token := new(PToken, init);
    token^.position := _stream^.getPosition;
    token^.value := '';
    isDone := false;
    while not isDone and (_stream^.read(@ch, 1) > 0) do
    begin
      if ch = C_EOLN_COMMENT_START then 
      begin
        while (ch<>C_CR) do _stream^.read(@ch, 1);
        if ch = C_LF then _stream^.read(@ch, 1);
        token^.position := _stream^.getPosition;
      end else if ch in C_ACCEPTED_DELIMITERS then
      begin
        if length(token^.value)>0 then 
        begin
          _stream^.seek(_stream^.getPosition - 1);
        end else
        begin
          token^.position := _stream^.getPosition;
          token^.value := ch;
        end;
        isDone := true;
      end else if ch in C_DELIMITERS then
      begin
        if length(token^.value)>0 then
        begin
          isDone := true;
        end;
      end else begin
        token^.value := token^.value + ch;
      end;
    end;
    if isDone then addToken(token);
    token^.release;
    findNextToken := isDone;
  end;

  { TTokenizer private }

  { Other }

end.