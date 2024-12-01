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
    lcommon, lcbase, lliteral;  

  type
    PWriter = ^TWriter;
    TWriter = object (TObject)
    public
      constructor init;
      destructor done; virtual;
      procedure onSentence(const sentence: TSentence); 
      procedure onData(data: pointer; size: longint);
      procedure save(output: PStream);
      function getCodeSize: longint;
      function getDataSize: longint;
    private
      _code: PStream;
      _data: PStream;
      function getArgumentValue(arg: TSentenceArgument): TUInt32;
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
      {writeln('arg[0]: ', args[0].value);}
      {value := hexToLong(args[0].value);}
      value := getArgumentValue(args[0]);
      data[2] := value and $FF;
      data[3] := (value shr 8) and $FF;
      data[4] := (value shr 16) and $FF;
      data[5] := (value shr 24) and $FF;

      { second argument }
      {writeln('arg[1]: ', args[1].value);}
      {value := hexToLong(args[1].value);}
      value := getArgumentValue(args[1]);
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

  function TWriter.getCodeSize: longint;
  begin
    getCodeSize := _code^.getSize;
  end;

  function TWriter.getDataSize: longint;
  begin
    getDataSize := _data^.getSize;
  end;

  { TWriter private }

  function TWriter.getArgumentValue(arg: TSentenceArgument): TUInt32;
  var
    resultValue: TUInt32;
    code, bitSize: byte;
  begin
    resultValue := 0;
    case arg.argType of 
      EParameterTypeLiteral, EParameterTypeAddress:
      begin
        any2int(arg.value, resultValue);
      end;

      EParameterTypeRegister:
      begin
        getRegisterInfoByName(arg.value, code, bitSize);
        resultValue := code;
      end;

    else 
      writeln('Argument value "', arg.value ,'", type ', ord(arg.argType), ' not parsed!');
    end;  
    getArgumentValue := resultValue;
  end;

  { Other }

end.
