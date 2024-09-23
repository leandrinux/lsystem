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
      procedure split(stream: PStream);
    private
    end;

implementation

  { TTokenizer public }

  const
    C_EOLN_COMMENT_START = '#';
    C_ALPHANUMERIC: set of char = ['a'..'z', 'A'..'Z', '0'..'9'];

  constructor TTokenizer.init;
  begin
    inherited init;
  end;

  destructor TTokenizer.done;
  begin
    inherited done;
  end;

  procedure TTokenizer.split(stream: PStream);
  var
    ch: char;
    token: string;
  begin
    token := '';
    while stream^.read(@ch, 1) > 0 do
    begin

      if ch = C_EOLN_COMMENT_START then 
      begin
        while (ch<>C_CR) do stream^.read(@ch, 1);
        if ch = C_LF then stream^.read(@ch, 1);
      end else if ch in C_ALPHANUMERIC then
      begin
        token := token + ch;
      end else if length(token) > 0 then 
      begin
        writeln(token);
        token := '';
      end;

    end;
  end;

  { TTokenizer private }

  { Other }

end.