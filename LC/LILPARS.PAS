{
  lilpars Unit
  2024 LRT
}
unit
  lilpars;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc,
    lparser;

  const
    C_IL_PARSER_TYPE = 'il';

  type
    PILParser = ^TILParser;
    TILParser = object (TParser)
    public
      constructor init;
      destructor done; virtual;
    private
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

  { TILParser private }

  { Other }

end.
