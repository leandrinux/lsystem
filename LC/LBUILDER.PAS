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
    lparser, lilpars, lasmpars,
    lcwriter, lbinw;

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
      procedure setOutputLanguage(language: ELanguage);
      procedure setVerbose(value: boolean);
      procedure runWithStream(source: PStream);
      procedure runWithPath(const path: string);
    private
      _parser: PParser;
      _verbose: boolean;
      _codeWriter: PCodeWriter;
    end;

implementation

  const
    C_DEFAULT_DATA_MAX_SIZE = 4096;
    C_DEFAULT_CODE_MAX_SIZE = 4096;

  { TBuilder public }

  constructor TBuilder.init;
  begin
    inherited init;
    _parser := nil;
    _codeWriter := nil;
    _verbose := false;
  end;

  destructor TBuilder.done;
  begin
    if _parser<>nil then _parser^.release;
    if _codeWriter<>nil then _codeWriter^.release;
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

  procedure TBuilder.setOutputLanguage(language: ELanguage);
  begin
    case language of
      ELanguageBinary: 
        _codeWriter := new(PBinaryWriter, init)
    else
      msg(EMsgFatal, C_STR_UNKNOWN_DST_TYPE, '');
    end;
  end;

  procedure TBuilder.setVerbose(value: boolean);
  begin
    _verbose := value;
  end;

  procedure TBuilder.runWithStream(source: PStream);
  var
    data: PMemoryStream;
    code: PMemoryStream;
  begin
    if _parser = nil then
    begin
      writeln('Can''t run, parser not set');
      exit;
    end;

    _parser^.setSource(source);
    _parser^.setVerbose(_verbose);
    _parser^.setDelegate(_codeWriter);

    data := new(PMemoryStream, initWithSize(C_DEFAULT_DATA_MAX_SIZE));
    _parser^.setData(data);

    code := new(PMemoryStream, initWithSize(C_DEFAULT_CODE_MAX_SIZE));
    _codeWriter^.setTarget(code);

    _parser^.run;

    msg(EMsgGood, 'Build completed. code %0 bytes, data %1 bytes', intToStr(data^.getSize) + #0 + intToStr(code^.getSize));
    data^.release;
    code^.release;
  end;

  procedure TBuilder.runWithPath(const path: string);
  var
    fs: PFileStream;
  begin
    fs := new(PFilestream, initWithPath(path, EFileReadOnly));
    runWithStream(fs);
    fs^.release;
  end;

  { TBuilder private }

  { Other }

end.
