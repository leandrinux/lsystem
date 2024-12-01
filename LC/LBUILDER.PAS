{
  lbuilder unit
  2024 LRT
}
unit
  lbuilder;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc, ustream, ufstream, umstream,
    lcommon, ltexts, 
    lparser, lilpars, lasmpars, lwriter, lsymbols;

  type
    ELanguage = (
      ELanguageBinary,
      ELanguageIL,
      ELanguageAssembly
    );

    PBuilder = ^TBuilder;
    TBuilder = object (TObject)
    public
      constructor init;
      destructor done; virtual;
      procedure setInputLanguage(language: ELanguage);
      procedure setVerbose(value: boolean);
      procedure runWithStreams(source: PStream; target: PStream);
      procedure runWithPaths(const srcpath, dstPath: string);
    private
      _parser: PParser;
      _verbose: boolean;
    end;

implementation

  { TBuilder public }

  constructor TBuilder.init;
  begin
    inherited init;
    _parser := nil;
    _verbose := false;
  end;

  destructor TBuilder.done;
  begin
    if _parser<>nil then _parser^.release;
    inherited done;
  end;

  procedure TBuilder.setInputLanguage(language: ELanguage);
  begin
    if _parser<>nil then _parser^.release;
    case language of 
      ELanguageIL: 
        _parser := new(PILParser, init);
      ELanguageAssembly: 
        _parser := new(PAssemblyParser, init);
    else
      msg(EMsgFatal, C_STR_UNKNOWN_SRC_TYPE, '');
      _parser := nil;
    end;    
  end;

  procedure TBuilder.setVerbose(value: boolean);
  begin
    _verbose := value;
  end;

  procedure TBuilder.runWithStreams(source: PStream; target: PStream);
  var
    writer: PWriter;
    symbols: PSymbols;
  begin
    if _parser = nil then
    begin
      writeln('Can''t run, parser not set');
      exit;
    end;
    symbols := new(PSymbols, init);

    writer := new(PWriter, init);
    writer^.setSymbols(symbols);

    _parser^.setSource(source);
    _parser^.setWriter(writer);
    _parser^.setSymbols(symbols);
    _parser^.setVerbose(_verbose);
    _parser^.run;

    if not symbols^.replacePendingSymbols(target) then
    begin
      msg(EMsgFatal, 'Build failed due to undefined symbols', #0);
    end else begin
      writer^.save(target);
      msg(EMsgGood, 'Build succeeded', #0);
    end;

    writer^.release;
    symbols^.release;
  end;

  procedure TBuilder.runWithPaths(const srcpath, dstPath: string);
  var
    src, dst: PFileStream;
  begin
    src := new(PFilestream, initWithPath(srcpath, EFileReadOnly));
    dst := new(PFilestream, initWithPath(dstPath, EFileCreate));
    runWithStreams(src, dst);
    src^.release;
    dst^.release;
  end;

  { TBuilder private }

  { Other }

end.
