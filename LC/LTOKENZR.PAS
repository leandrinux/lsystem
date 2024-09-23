{
  Tokenizer unit
  Part of the assembly source code parser component
}
unit 
  ltokenzr;

interface

  uses
    consts, utils, uclasses, types, locale,
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

  constructor TTokenizer.init;
  begin
    inherited init;
  end;

  destructor TTokenizer.done;
  begin
    inherited done;
  end;

  procedure TTokenizer.split(stream: PStream);
  begin
    writeln('split');
  end;

  { TTokenizer private }

  { Other }

end.