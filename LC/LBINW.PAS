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
  var
    stream: PStream;
    data: array[0..9] of byte;
  begin
    stream := getTarget;
    with sentence do
    begin
      data[0] := opcode;
      data[1] := (byte(args[0].argType) shl 4) or byte(args[1].argType);
      data[2] := args[0].value and $FF;
      data[3] := (args[0].value shr 8) and $FF;
      data[4] := (args[0].value shr 16) and $FF;
      data[5] := (args[0].value shr 24) and $FF;
      data[6] := args[1].value and $FF;
      data[7] := (args[1].value shr 8) and $FF;
      data[8] := (args[1].value shr 16) and $FF;
      data[9] := (args[1].value shr 24) and $FF;
      write('BinaryWriter: ', opname, '(', byteToHex(opcode), ') '); 
      write(C_PARAMETER_TYPES[args[0].argType], ', ', C_PARAMETER_TYPES[args[1].argType], ' ');
      write(longToHex(args[0].value), ', ', longToHex(args[1].value));
      writeln;
      stream^.write(@data, sizeof(data));
    end;
  end;

  { TBinaryWriter private }

  { Other }

end.
