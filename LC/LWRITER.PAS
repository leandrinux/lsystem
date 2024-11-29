{
  lwriter Unit
  2024 LRT
}
unit
  lwriter;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc, ustream, umstream,
    lcommon, lcbase;  

  type
    PWriter = ^TWriter;
    TWriter = object (TObject)
    public
      constructor init;
      destructor done; virtual;
      procedure onSentence(const sentence: TSentence); 
      procedure onData(data: pointer; size: longint);
      procedure save(output: PStream);
    private
      _code: PStream;
      _data: PStream;
    end;

implementation

  const
    C_DEFAULT_CODE_MAX_SIZE = 4096;
    C_DEFAULT_DATA_MAX_SIZE = 4096;

  { TWriter public }

  constructor TWriter.init;
  begin
    inherited init;
    _code := new(PMemoryStream, initWithSize(C_DEFAULT_CODE_MAX_SIZE));
    _data := new(PMemoryStream, initWithSize(C_DEFAULT_DATA_MAX_SIZE));
  end;

  destructor TWriter.done;
  begin
    _code^.release;
    _data^.release;
    inherited done;
  end;
  
  procedure TWriter.onSentence(const sentence: TSentence);
  var
    data: array[0..9] of byte;
    value: TUInt32;
  begin
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

      _code^.write(@data, sizeof(data));
    end;
  end;

  procedure TWriter.onData(data: pointer; size: longint);
  begin
    _data^.write(data, size);
  end;

  procedure TWriter.save(output: PStream);
  var
    header: TBinaryFileHeader;
  begin
    with header do
    begin
      signature := C_BINARY_SIGNATURE;
      binaryVersion := 12;
      dataOffset := sizeof(TBinaryFileHeader);
      dataSize := _data^.getSize;
      codeOffset := dataOffset + dataSize;
      codeSize := _code^.getSize;
    end;
    writeln('Saving header ', sizeof(TBinaryFileHeader), ' bytes');
    output^.write(@header, sizeof(TBinaryFileHeader));

    writeln('Saving data ', _data^.getSize, ' bytes');
    _data^.copyAllTo(output);

    writeln('Saving code ', _code^.getSize, ' bytes');
    _code^.copyAllTo(output);
  end;

  { TWriter private }

  { Other }

end.
