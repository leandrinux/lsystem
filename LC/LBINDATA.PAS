{
  This unit handles the binary code and data information used to build the program
}
unit
  lbindata;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc, ulist,
    lcommon, lcbase, lsymbols;

  const
    C_SENTENCES_PER_BLOCK = 5;

  type
    PBinaryData = ^TBinaryData;
    TBinaryData = object (TObject)
    public
      constructor init;
      destructor done; virtual;
      procedure addSentence(const sentence: TSentence);
      procedure addData(data: pointer; size: longint);
      procedure addSymbol(const name: TString30; value: TUInt32);
    private
      _symbols: PSymbols;          { keeps track of the symbols like labels or defines }
      _sentences: PList;           { the list of non compiled, parsed sentences }
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
  
  { TBinaryData private }

  { Other }

end.
