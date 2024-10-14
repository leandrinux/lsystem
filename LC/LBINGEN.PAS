{
  Binary code generator unit
}
unit
  lbingen;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc;

  type
    PBinaryGenerator = ^TBinaryGenerator;
    TBinaryGenerator = object (TObject)
    public
      constructor init;
      destructor done; virtual;
    private
    end;

implementation

  { TBinaryGenerator public }

  constructor TBinaryGenerator.init;
  begin
    inherited init;
  end;

  destructor TBinaryGenerator.done;
  begin
    inherited done;
  end;

  { TBinaryGenerator private }

  { Other }

end.
