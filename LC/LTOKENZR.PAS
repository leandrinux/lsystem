{
  Tokenizer unit
  Part of the assembly source code parser component
}
unit 
  ltokenzr;

interface

  uses
    ascii, consts, utils, uclasses, types, locale,
    uobject, uexc,
    ustream;

  type
    PTokenizer = ^TTokenizer;
    TTokenizer = object (TObject)
    public
      constructor init;
      destructor done; virtual;
      function next(stream: PStream): string;
    private
    end;

implementation

  { TTokenizer public }

  const
    C_EOLN_COMMENT_START = '#';
    C_DELIMITERS = [C_CR, C_LF, ' ', ','];
    C_ACCEPTED_DELIMITERS = [','];

  constructor TTokenizer.init;
  begin
    inherited init;
  end;

  destructor TTokenizer.done;
  begin
    inherited done;
  end;

  function TTokenizer.next(stream: PStream): string;
  var
    ch: char;
    token: string;
    isDone: boolean;
  begin
    token := '';
    isDone := false;
    while not isDone and (stream^.read(@ch, 1) > 0) do
    begin
      if ch = C_EOLN_COMMENT_START then 
      begin
        while (ch<>C_CR) do stream^.read(@ch, 1);
        if ch = C_LF then stream^.read(@ch, 1);
      end else if ch in C_ACCEPTED_DELIMITERS then
      begin
        next := token;
        isDone := true;
      end else if ch in C_DELIMITERS then
      begin
        next := token;
        isDone := true;
      end else begin
        token := token + ch;
      end;
    end;
    next := token;
  end;

  { TTokenizer private }

  { Other }

end.