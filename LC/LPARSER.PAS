{
  lparser Unit
  2024 LRT
}
unit
  lparser;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc, ustream;    

  type
    PParser = ^TParser;
    TParser = object (TObject)
    public
      constructor init;
      destructor done; virtual;
      procedure setSource(source: PStream);
    private
      _source: PStream;
    end;

implementation

  { TParser public }

  constructor TParser.init;
  begin
    inherited init;
    _source := nil;
  end;

  destructor TParser.done;
  begin
    if _source <> nil then _source^.release;
    inherited done;
  end;

  procedure TParser.setSource(source: PStream);
  begin
    if _source <> nil then _source^.release;
    _source := source;
    _source^.retain;
  end;

  { TParser private }

  { Other }

end.
