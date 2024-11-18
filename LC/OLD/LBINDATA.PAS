{
  This unit handles the binary code and data information used to build the program
}
unit
  lbindata;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc, ulist,
    lcommon, lcbase, lsymbols, lliteral, ltexts;

  const
    C_SENTENCES_PER_BLOCK = 5;

  type
    PBinaryData = ^TBinaryData;
    TBinaryData = object (TObject)
    public
      constructor init;
      destructor done; virtual;
      procedure addCode(const labelName: TIdentifier; const opName: TOperationName; const arg0, arg1: TArgumentValue);
    private
      _symbols: PSymbols;          { keeps track of the symbols like labels or defines }
      _sentences: PList;           { the list of non compiled, parsed sentences }
      procedure initSentence(var sentence: TSentence);
      procedure addSentence(const sentence: TSentence);
      procedure addData(data: pointer; size: longint);
      procedure addSymbol(const name: TString30; value: TUInt32);
      procedure parseLiteral(var arg: TSentenceArgument);
      procedure parseAddress(var arg: TSentenceArgument);
      procedure parseRegister(var arg: TSentenceArgument);
      procedure parsePointer(var arg: TSentenceArgument);
    end;

    PSentenceBlock = ^TSentenceBlock;
    TSentenceBlock = object (TObject)    
        items: array [0..C_SENTENCES_PER_BLOCK-1] of TSentence;
        count: byte;
        constructor init;
    end;

implementation

  { auxiliar objects }

  constructor TSentenceBlock.init;
  begin
    inherited init;
    count := 0;
  end;

  { TBinaryData public }

  constructor TBinaryData.init;
  begin
    inherited init;
    _symbols := new(PSymbols, init);
    _sentences := new(PList, init);
  end;

  destructor TBinaryData.done;
  begin
    _sentences^.release;
    _symbols^.release;
    inherited done;
  end;

  procedure TBinaryData.addCode(const labelName: TIdentifier; const opName: TOperationName; const arg0, arg1: TArgumentValue);
  var
    sentence: TSentence;
  begin
    sentence.labelName := labelName;
    sentence.opName := opName;
    sentence.args[0].stringValue := arg0;
    sentence.args[1].stringValue := arg1;
    initSentence(sentence);
    addSentence(sentence);
  end;

  { TBinaryData private }

  procedure TBinaryData.initSentence(var sentence: TSentence);
  begin
    { determine the type of each argument }
    with sentence.args[0] do argType := getParameterType(stringValue);
    with sentence.args[1] do argType := getParameterType(stringValue);

    { according to type, interpret the value or values for each one}
    with sentence do case args[0].argType of
      EParameterTypeLiteral: parseLiteral(args[0]);
      EParameterTypeAddress: parseAddress(args[0]);
      EParameterTypeRegister: parseRegister(args[0]);
      EParameterTypePointer: parsePointer(args[0]);
    end;
    with sentence do case args[1].argType of
      EParameterTypeLiteral: parseLiteral(args[1]);
      EParameterTypeAddress: parseAddress(args[1]);
      EParameterTypeRegister: parseRegister(args[1]);
      EParameterTypePointer: parsePointer(args[1]);
    end;
  end;

  procedure TBinaryData.parseLiteral(var arg: TSentenceArgument);
  var
    success: boolean;
  begin
    if (length(arg.stringValue) = 3) and 
      (arg.stringValue[1] = '''') and
      (arg.stringValue[3] = '''') then
    begin
      arg.intValue := ord(arg.stringValue[2]);
      success := true;
    end else
      success := any2int(arg.stringValue, arg.intValue);
    if not success then 
      msg(EMsgFatal, C_STR_UNRECOGNIZABLE_ARGUMENT, arg.stringValue);
  end;

  procedure TBinaryData.parseAddress(var arg: TSentenceArgument);
  var
    success: boolean;
    token: TString30;
    i: byte;
  begin
    i := pos(']', arg.stringValue);
    if i=0 then msg(EMsgFatal, C_STR_UNRECOGNIZABLE_ARGUMENT, arg.stringValue);
    token := copy(arg.stringValue, 2, i-2);
    success := any2int(token, arg.intValue);
    if not success then msg(EMsgFatal, C_STR_UNRECOGNIZABLE_ARGUMENT, arg.stringValue);
  end;

  procedure TBinaryData.parseRegister(var arg: TSentenceArgument);
  var 
    success: boolean;
    code, bitSize: byte;
  begin
    success := getRegisterInfoByName(arg.stringValue, code, bitSize);
    if not success then msg(EMsgFatal, C_STR_UNRECOGNIZABLE_ARGUMENT, arg.stringValue);
    arg.registerCode := code;
  end;

  procedure TBinaryData.parsePointer(var arg: TSentenceArgument);
  var 
    param, token: TString30;
    i, j: byte;
    constantValue: TUInt32;
    code, bitSize: byte;
    success: boolean;
  begin
    param := arg.stringValue;
    i := pos('+', param);
    if i = 0 then i := pos('-', param);
    if i = 0 then i := pos(']', param);

    { extract the register part }
    j := pos('[', param) + 1;
    while param[j]=' ' do inc(j);      
    token := copy(param, j, i-j);
    success := getRegisterInfoByName(token, code, bitSize);
    if not success then msg(EMsgFatal, C_STR_UNRECOGNIZABLE_ARGUMENT, token);
    arg.registerCode := code;

    { extract the constant value part }
    if param[i] = ']' then
      arg.offset := 0
    else begin
      j := pos(']', param);
      token := copy(param, i+1, j-i-1);
      success := any2int(token, constantValue);
      if not success then msg(EMsgFatal, C_STR_INVALID_POINTER_CONSTANT, token);
      if param[i] = '-' then constantValue := -constantValue;
      if (constantValue<-32768) or (constantValue>32767) then 
        msg(EMsgFatal, C_STR_INVALID_POINTER_CONSTANT_RANGE, '');
      arg.offset := constantValue;
    end;
  end;

  procedure TBinaryData.addSentence(const sentence: TSentence);
  var
    sentenceBlock: PSentenceBlock;
  begin
    sentenceBlock := PSentenceBlock(_sentences^.getLast);

    if (sentenceBlock = nil) or (sentenceBlock^.count = C_SENTENCES_PER_BLOCK) then
    begin
      sentenceBlock := new(PSentenceBlock, init);
      _sentences^.addObject(sentenceBlock);
      sentenceBlock^.release;
    end;
    with sentenceBlock^ do 
    begin
      items[count] := sentence;
      count := count + 1;
    end;
  end;

  procedure TBinaryData.addData(data: pointer; size: longint);
  begin
  end;
  
  procedure TBinaryData.addSymbol(const name: TString30; value: TUInt32);
  begin
    _symbols^.addValue(name, value);
  end;
  
  { Other }

end.
