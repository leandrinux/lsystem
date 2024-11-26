{
  lbinw Unit
  2024 LRT
}
unit
  lbinw;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc, ustream,
    lcommon, lcwriter, lparser, lcbase;

  const 
    C_BIN_WRITER_TYPE = 'bin';

  type
    PBinaryWriter = ^TBinaryWriter;
    TBinaryWriter = object (TCodeWriter)
    public
      procedure onFileCreated; virtual;
      procedure onParsedSentence(const sentence: TSentence); virtual;
    private
    end;

implementation

  { TBinaryWriter public }

  procedure TBinaryWriter.onFileCreated;
  var
    header: TBinaryFileHeader;
  begin
    fillchar(header, sizeof(TBinaryFileHeader), 0);
    header.signature := C_BINARY_SIGNATURE;
    getTarget^.write(@header, sizeOf(TBinaryFileHeader));
  end;

  procedure TBinaryWriter.onParsedSentence(const sentence: TSentence);
  var
    stream: PStream;
    data: array[0..9] of byte;
    value: TUInt32;
  begin
    stream := getTarget;
    with sentence do
    begin

      { opcode }
      data[0] := opcode;

      { parameter types }
      data[1] := (byte(args[0].argType) shl 4) or byte(args[1].argType);

      { first argument }
      value := hexToLong(args[0].value);
      data[2] := value and $FF;
      data[3] := (value shr 8) and $FF;
      data[4] := (value shr 16) and $FF;
      data[5] := (value shr 24) and $FF;

      { second argument }
      value := hexToLong(args[1].value);
      data[6] := value and $FF;
      data[7] := (value shr 8) and $FF;
      data[8] := (value shr 16) and $FF;
      data[9] := (value shr 24) and $FF;

      {
      write('BinaryWriter: ', opname, '(', byteToHex(opcode), ') '); 
      write(C_PARAMETER_TYPES[args[0].argType], ', ', C_PARAMETER_TYPES[args[1].argType], ' ');
      write(longToHex(args[0].value), ', ', longToHex(args[1].value));
      writeln;
      }
      stream^.write(@data, sizeof(data));
    end;
  end;

  { TBinaryWriter private }

  { Other }

end.
