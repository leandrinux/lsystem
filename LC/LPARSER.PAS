{
  lparser Unit
  2024 LRT
}
unit
  lparser;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc, ustream, lcommon, lcbase;   
    
  const
    C_MSG_ON_PARSED_SENTENCE = $F0;

  type
    PParser = ^TParser;
    TParser = object (TObject)
    public
      constructor init;
      destructor done; virtual;
      procedure setSource(source: PStream);
      function getSource: PStream;
      procedure run; virtual;
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

  function TParser.getSource: PStream;
  begin
    getSource := _source;
  end;

  procedure TParser.run;
  begin
  end;

  { TParser private }

  { Other }

end.
