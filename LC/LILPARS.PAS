{
  lilpars Unit
  2024 LRT
}
unit
  lilpars;

interface

  uses
    consts, utils, uclasses, types, locale, strings,
    uobject, uexc, ustream,
    lcommon, lliteral, lcbase, lparser;

  const
    C_IL_PARSER_TYPE = 'il';

  type
    PILParser = ^TILParser;
    TILParser = object (TParser)
    public
      constructor init;
      destructor done; virtual;
      procedure run; virtual;
    private
      procedure readDataBytes(const line: string);
      function readSentence(const line: string; var sentence: TSentence): boolean;
      procedure didParseSentence(sentence: PSentence);
    end;

implementation

  { TILParser public }

  constructor TILParser.init;
  begin
    inherited init;
  end;

  destructor TILParser.done;
  begin
    inherited done;
  end;

  procedure TILParser.run;
  type
    EState = (
      EStateStart,
      EStateCode,
      EStateData,
      EStateFail
    );
  var
    s: PStream;
    ln: string;
    state: EState;
    sentence: TSentence;
  begin
    s := getSource;
    state := EStateStart;
    while (not s^.isEOF) and (state <> EStateFail) do
    begin
      ln := trim(s^.readln);
      if length(ln) = 0 then continue;
      if ln[1] = ';' then continue;

      case state of 
        EStateStart:
        begin
          if ln = '.data' then
          begin
            msg('Compiling data...');
            state := EStateData;
          end else if ln = '.code' then
          begin
            msg('Compiling code...');
            state := EStateCode;
          end else begin
            writeln('Unexpected section name "', ln, '"');
            state := EStateFail;
          end;
        end;

        EStateData: 
        begin
          if ln = '.code' then
          begin
            state := EStateCode;
            if getData <> nil then 
              msg('Final data size is ' + intToStr(getData^.getSize));
            msg('Compiling code...');
          end else
            readDataBytes(ln);
        end;

        EStateCode:
        begin
          if readSentence(ln, sentence) then 
            didParseSentence(@sentence);
        end;

      end;
    end;
    msg('Parsing ended.');
  end;

  { TILParser private }

  procedure TILParser.readDataBytes(const line: string);
  const
    C_HEX_CHARACTERS: set of char = ['0'..'9', 'A'..'F'];
  var 
    i, c: byte;
    token: string[2];
    value: byte;
  begin
    if getData = nil then begin
      msg('Skipping data line because data stream is not set');
      exit;
    end;
    i := 1;
    c := length(line);
    while (i <= c) and (line[i]<>';') do 
    begin
      if line[i] in C_HEX_CHARACTERS then
        if ((i+1) <= c) and (line[i+1] in C_HEX_CHARACTERS) then
        begin
          token := line[i] + line[i+1];
          value := hexToByte(token);
          getData^.write(@token, 1);
        end;
      inc(i);
    end; 
  end;

  function TILParser.readSentence(const line: string; var sentence: TSentence): boolean;
  type
    TToken = string[3];
  var 
    token: TToken;
    idx: byte;
    value, longValue: TUInt32;

  function readToken: boolean;
  begin
    readToken := false;
    token := '$';
    while (idx<=length(line)) and (line[idx] = ' ') do inc(idx);
    if idx <= length(line) then token := token + line[idx]; inc(idx);
    if idx <= length(line) then token := token + line[idx]; inc(idx);
    if length(token) <> 3 then exit;
    if not hex2int(token, value) then exit;
    readToken := true;
  end;

  begin
    readSentence := false;
    idx := 1;

    { opcode }
    if not readToken then exit;
    sentence.opcode := value;
    getInfoByOpcode(value, sentence.opname, sentence.argCount);

    { param types }
    if not readToken then exit;
    sentence.args[0].argType := EParameterType(value shr 4);
    sentence.args[1].argType := EParameterType(value and $F);

    { param value 0 }
    if not readToken then exit; longValue := value;
    if not readToken then exit; longValue := longValue or (value shl 8);
    if not readToken then exit; longValue := longValue or (value shl 16);
    if not readToken then exit; longValue := longValue or (value shl 24);
    sentence.args[0].value := longToHex(longValue);

    { param value 1 }
    if not readToken then exit; longValue := value;
    if not readToken then exit; longValue := longValue or (value shl 8);
    if not readToken then exit; longValue := longValue or (value shl 16);
    if not readToken then exit; longValue := longValue or (value shl 24);
    sentence.args[1].value := longToHex(longValue);

    readSentence := true;
  end;

  procedure TILParser.didParseSentence(sentence: PSentence);
  begin
    sendMessageWithData(C_MSG_ON_PARSED_SENTENCE, getDelegate, sentence, sizeof(TSentence));
  end;

  { Other }

end.
