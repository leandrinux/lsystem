{
  lbuilder unit
  2024 LRT
}
unit
  lbuilder;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc, ufstream,
    lcommon, ltexts, 
    lparser, lilpars,
    lcwriter, lbinw;

  type
    PBuilder = ^TBuilder;
    TBuilder = object (TObject)
    public
      constructor init;
      destructor done; virtual;
      procedure setSource(const path, fileType: string);
      procedure setTarget(const path, fileType: string);
      procedure run;
    private
      _parser: PParser;
      _codeWriter: PCodeWriter;
    end;

implementation

  { TBuilder public }

  constructor TBuilder.init;
  begin
    inherited init;
    _parser := nil;
    _codeWriter := nil;
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
    if _codeWriter<>nil then _codeWriter^.release;
    if fileType = C_BIN_WRITER_TYPE then 
      _codeWriter := new(PBinaryWriter, init)
    else
      msg(EMsgFatal, C_STR_UNKNOWN_DST_TYPE, '');
    fs := new(PFilestream, initWithPath(path, EFileCreate));
    _codeWriter^.setTarget(fs);
    fs^.release;
  end;

  procedure TBuilder.run;
  begin
    _parser^.setDelegate(_codeWriter);
    _parser^.run;
  end;

  { TBuilder private }

  { Other }

end.
