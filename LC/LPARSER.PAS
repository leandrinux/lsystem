{
  lparser Unit
  2024 LRT
}
unit
  lparser;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc, ustream, 
    lcommon, lcbase, lwriter, lsymbols;
    
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
      procedure setSymbols(symbols: PSymbols);
      function getSymbols: PSymbols;
      procedure setVerbose(value: boolean);
      procedure msg(const str: string);
      procedure run; virtual;
    private
      _source: PStream;
      _verbose: boolean;
      _writer: PWriter;
      _symbols: PSymbols;
    end;

implementation

  { TParser public }

  constructor TParser.init;
  begin
    inherited init;
    _source := nil;
    _writer := nil;
    _symbols := nil;
    _verbose := false;
  end;

  destructor TParser.done;
  begin
    if _source <> nil then _source^.release;
    if _writer <> nil then _writer^.release;
    if _symbols <> nil then _symbols^.release;
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

  procedure TParser.setSymbols(symbols: PSymbols);
  begin
    if _symbols<>nil then _symbols^.release;
    _symbols := symbols;
    _symbols^.retain;
  end;

  function TParser.getSymbols: PSymbols;
  begin
    getSymbols := _symbols;
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
