{
  lbuilder unit
  2024 LRT
}
unit
  lbuilder;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc, ufstream, umstream,
    lcommon, ltexts, 
    lparser, lilpars, lasmpars,
    lcwriter, lbinw;

  type
    PBuilder = ^TBuilder;
    TBuilder = object (TObject)
    public
      constructor init;
      destructor done; virtual;
      procedure setSource(const path, fileType: string);
      procedure setTarget(const path, fileType: string);
      procedure setDataMaxSize(maxSize: word);
      procedure setVerbose(value: boolean);
      procedure run;
    private
      _parser: PParser;
      _codeWriter: PCodeWriter;
      _verbose: boolean;
    end;

implementation

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

  procedure TBuilder.setSource(const path, fileType: string);
  var
    fs: PFileStream;
  begin
    if _parser<>nil then _parser^.release;
    if fileType = C_IL_PARSER_TYPE then 
      _parser := new(PILParser, init)
    else if fileType = C_ASM_PARSER_TYPE then
      _parser := new(PAssemblyParser, init)
    else
      msg(EMsgFatal, C_STR_UNKNOWN_SRC_TYPE, '');
    fs := new(PFilestream, initWithPath(path, EFileReadOnly));
    _parser^.setSource(fs);
    fs^.release;
  end;

  procedure TBuilder.setTarget(const path, fileType: string);
  var
    fs: PFileStream;
  begin
    fs := new(PFilestream, initWithPath(path, EFileCreate));
    if _codeWriter<>nil then _codeWriter^.release;
    if fileType = C_BIN_WRITER_TYPE then 
      _codeWriter := new(PBinaryWriter, initWithTarget(fs))
    else
      msg(EMsgFatal, C_STR_UNKNOWN_DST_TYPE, '');
    fs^.release;
  end;

  procedure TBuilder.setVerbose(value: boolean);
  begin
    _verbose := value;
  end;

  procedure TBuilder.setDataMaxSize(maxSize: word);
  var
    ms: PMemoryStream;
  begin
    if _parser = nil then exit;
    ms := new(PMemoryStream, initWithSize(maxSize));
    _parser^.setData(ms);
    ms^.release;
  end;

  procedure TBuilder.run;
  begin
    _parser^.setVerbose(_verbose);
    _parser^.setDelegate(_codeWriter);
    _parser^.run;
  end;

  { TBuilder private }

  { Other }

end.
