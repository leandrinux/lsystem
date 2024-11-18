{
  this unit handles the compiler command line arguments
}
unit lcmdline;

interface

  type
    TFilePath = string;
    TFileType = string[3];

    TCommandLine = record
      srcPath: TFilePath;
      srcType: TFileType;
      dstPath: TFilePath;
      dstType: TFileType;
    end;

  const cmdline: TCommandLine = (
    srcPath: '\examples\abc.il';
    srcType: 'il';
    dstPath: '\examples\abc.gen';
    dstType: 'bin'
  );

implementation

begin
end.