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
      constructor initWithTarget(target: PStream);
      destructor done; virtual;
      function getTarget: PStream;
      procedure onFileCreated; virtual;
      procedure onParsedSentence(const sentence: TSentence); virtual;
      procedure receiveMessage(msg: PObjectMessage); virtual;
    private
      _target: PStream;
    end;

implementation

  { TCodeWriter public }

  constructor TCodeWriter.initWithTarget(target: PStream);
  begin
    inherited init;
    _target := target;
    _target^.retain;
    onFileCreated;
  end;

  destructor TCodeWriter.done;
  begin
    _target^.release;
    inherited done;
  end;

  function TCodeWriter.getTarget: PStream;
  begin
    getTarget := _target;
  end;
  
  procedure TCodeWriter.onFileCreated;
  begin
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
