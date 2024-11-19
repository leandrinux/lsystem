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
      EStateCode,
      EStateData
    );
  var
    s: PStream;
    ln: string;
    state: EState;
    sentence: TSentence;
  begin
    s := getSource;
    state := EStateData;
    while not s^.isEOF do
    begin
      ln := trim(s^.readln);
      if length(ln) = 0 then continue;
      if ln[1] = ';' then continue;

      case state of 
        EStateData: 
        begin
          if ln = '.code' then
          begin
            state := EStateCode;
          end else  
            writeln('ILParser: unexpected text in data block');
        end;

        EStateCode:
        begin
          if readSentence(ln, sentence) then 
            didParseSentence(@sentence);
        end;
      end;
    end;
  end;

  { TILParser private }

  function TILParser.readSentence(const line: string; var sentence: TSentence): boolean;
  type
    TToken = string[3];

  var 
    token: TToken;
    idx: byte;
    value: TUInt32;

  procedure readToken;
  begin
    token := '$';
    while (idx<=length(line)) and (line[idx] = ' ') do inc(idx);
    if idx <= length(line) then token := token + line[idx]; inc(idx);
    if idx <= length(line) then token := token + line[idx]; inc(idx);
  end;

  begin
    readSentence := false;
    idx := 1;

    { opcode }
    readToken;
    if length(token) <> 3 then exit;
    if not hex2int(token, value) then exit;
    getInfoByOpcode(value, sentence.opname, sentence.argCount);

    { param types }
    readToken;
    if length(token) <> 3 then exit;
    if not hex2int(token, value) then exit;
    sentence.args[0].argType := EParameterType(value shr 4);
    sentence.args[1].argType := EParameterType(value and $F);

    readSentence := true;
  end;

  procedure TILParser.didParseSentence(sentence: PSentence);
  begin
    sendMessageWithData(C_MSG_ON_PARSED_SENTENCE, getDelegate, sentence, sizeof(TSentence));
  end;

  { Other }

end.
