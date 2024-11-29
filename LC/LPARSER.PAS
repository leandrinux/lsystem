{
  lparser Unit
  2024 LRT
}
unit
  lparser;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc, ustream, lcommon, lcbase, lcwriter;   
    
  type
    PParser = ^TParser;
    TParser = object (TObject)
    public
      constructor init;
      destructor done; virtual;
      procedure setSource(source: PStream);
      function getSource: PStream;
      procedure setWriter(writer: PWriter);
      function getWriter: PWriter;
      procedure setVerbose(value: boolean);
      procedure msg(const str: string);
      procedure run; virtual;
    private
      _source: PStream;
      _verbose: boolean;
      _writer: PWriter;
    end;

implementation

  { TParser public }

  constructor TParser.init;
  begin
    inherited init;
    _source := nil;
    _writer := nil;
    _verbose := false;
  end;

  destructor TParser.done;
  begin
    if _source <> nil then _source^.release;
    if _writer <> nil then _writer^.release;
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

  procedure TParser.setWriter(writer: PWriter);
  begin
    if _writer <> nil then _writer^.release;
    _writer := writer;
    _writer^.retain;
  end;

  function TParser.getWriter: PWriter;
  begin
    getWriter := _writer;
  end;

  procedure TParser.setVerbose(value: boolean);
  begin
    _verbose := value;
  end;

  procedure TParser.msg(const str: string);
  begin
    if _verbose then lcommon.msg(EMsgNormal, str, '');
  end;

  procedure TParser.run;
  begin
  end;

  { TParser private }

  { Other }

end.
