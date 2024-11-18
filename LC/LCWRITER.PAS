{
  lcwriter Unit
  2024 LRT
}
unit
  lcwriter;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc, ustream,
    lparser, lcbase;  

  type
    PCodeWriter = ^TCodeWriter;
    TCodeWriter = object (TObject)
    public
      constructor init;
      destructor done; virtual;
      procedure setTarget(target: PStream);
      procedure onParsedSentence(const sentence: TSentence); virtual;
      procedure receiveMessage(msg: PObjectMessage); virtual;
    private
      _target: PStream;
    end;

implementation

  { TCodeWriter public }

  constructor TCodeWriter.init;
  begin
    inherited init;
    _target := nil;
  end;

  destructor TCodeWriter.done;
  begin
    if _target <> nil then _target^.release;
    inherited done;
  end;

  procedure TCodeWriter.setTarget(target: PStream);
  begin
    if _target <> nil then _target^.release;
    _target := target;
    _target^.retain;
  end;

  procedure TCodeWriter.onParsedSentence(const sentence: TSentence);
  begin
  end;

  procedure TCodeWriter.receiveMessage(msg: PObjectMessage);
  begin
    if msg^.opcode = C_MSG_ON_PARSED_SENTENCE then
      onParsedSentence(PSentence(msg^.payload)^);
  end;

  { TCodeWriter private }

  { Other }

end.
