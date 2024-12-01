{
  this unit is in charge of keeping track of the symbols list
}
unit
  lsymbols;

interface

  uses
    consts, utils, uclasses, types, locale, strings,
    uobject, uexc, ulist, ustream,
    ltexts, lcommon, lcbase;

  type
    PSymbol = ^TSymbol;
    TSymbol = object (TObject)
      name: TIdentifier;
      value: TUInt32;
    end;

    PUnknownSymbol = ^TUnknownSymbol;
    TUnknownSymbol = object (TObject)
      name: TIdentifier;
      offset: TUInt32;
    end;

    PSymbols = ^TSymbols;
    TSymbols = object (TObject)
    public
      constructor init;
      destructor done; virtual;
      procedure addSymbol(symbol: PSymbol);
      procedure addUnknownValue(const name: TIdentifier; offset: TUInt32);
      function getValue(const name: TIdentifier; var value: TUInt32): boolean;
      function replacePendingSymbols(stream: PStream): boolean;
    private
      _known: PList;
      _unknown: PList;
    end;

implementation

  { TSymbols public }

  constructor TSymbols.init;
  begin
    inherited init;
    _known := new(PList, init);
    _unknown := new(PList, init);
  end;

  destructor TSymbols.done;
  begin
    _known^.release;
    _unknown^.release;
    inherited done;
  end;

  procedure TSymbols.addSymbol(symbol: PSymbol);
  begin
    {writeln('Add symbol ', symbol^.name, ', value: ', symbol^.value);}
    _known^.addObject(symbol);
  end;

  function TSymbols.getValue(const name: TIdentifier; var value: TUInt32): boolean;
  var
    symbol: PSymbol;
  begin
    _known^.moveToStart;
    symbol := PSymbol(_known^.getObjectAtCursor);
    while (symbol<>nil) and (symbol^.name <> name) do 
    begin
      _known^.moveForward;
      symbol := PSymbol(_known^.getObjectAtCursor);
    end;
    if symbol <> nil then
    begin
      getValue := true;
      value := symbol^.value;
    end else begin
      getValue := false;
      value := 0;
    end;
  end;

  procedure TSymbols.addUnknownValue(const name: TIdentifier; offset: TUInt32);
  var
    symbol: PUnknownSymbol;
  begin
    symbol := new(PUnknownSymbol, init);
    symbol^.name := name;
    symbol^.offset := offset;
    _unknown^.addObject(symbol);
    symbol^.release;
  end;

  function TSymbols.replacePendingSymbols(stream: PStream): boolean;
  var 
    symbol: PUnknownSymbol;
    value: TUInt32;
    success: boolean;
  begin
    _unknown^.moveToStart;
    symbol := PUnknownSymbol(_unknown^.getObjectAtCursor);
    while symbol <> nil do
    begin
      success := getValue(symbol^.name, value);
      if not success then
      begin
        writeln('Symbol "', symbol^.name, '" is undefined');
        replacePendingSymbols := false;
        exit;
      end;
      stream^.seek(symbol^.offset);
      stream^.write(@value, sizeOf(value));
      _unknown^.moveForward;
      symbol := PUnknownSymbol(_unknown^.getObjectAtCursor);
    end;
    replacePendingSymbols := true;
  end;

  { TSymbols private }

  { Other }

end.
