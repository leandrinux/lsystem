{
  Binary code generator unit
}
unit
  lbingen;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc, ustream,
    lbindata, lcbase;

  type
    PBinaryGenerator = ^TBinaryGenerator;
    TBinaryGenerator = object (TObject)
    public
      constructor initWithBinaryData(binaryData: PBinaryData);
      destructor done; virtual;
      procedure make(stream: PStream);
    private
      _binaryData: PBinaryData;
    end;

implementation

  { TBinaryGenerator public }

  constructor TBinaryGenerator.initWithBinaryData(binaryData: PBinaryData);
  begin
    inherited init;
    _binaryData := binaryData;
    _binaryData^.retain;
  end;

  destructor TBinaryGenerator.done;
  begin
    _binaryData^.release;
    inherited done;
  end;

  procedure TBinaryGenerator.make(stream: PStream);
  begin
  end;

  { TBinaryGenerator private }

  { Other }

end.
