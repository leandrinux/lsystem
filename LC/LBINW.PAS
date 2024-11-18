{
  lbinw Unit
  2024 LRT
}
unit
  lbinw;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc,
    lcwriter, lparser, lcbase;

  const 
    C_BIN_WRITER_TYPE = 'bin';

  type
    PBinaryWriter = ^TBinaryWriter;
    TBinaryWriter = object (TCodeWriter)
    public
      constructor init;
      destructor done; virtual;
      procedure onParsedSentence(const sentence: TSentence); virtual;
    private
    end;

implementation

  { TBinaryWriter public }

  constructor TBinaryWriter.init;
  begin
    inherited init;
  end;

  destructor TBinaryWriter.done;
  begin
    inherited done;
  end;

  procedure TBinaryWriter.onParsedSentence(const sentence: TSentence);
  begin
    writeln('BinaryWriter: writing ', sentence.opname); 
  end;

  { TBinaryWriter private }

  { Other }

end.
