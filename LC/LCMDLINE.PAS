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
      verbose: boolean;
    end;

  const cmdline: TCommandLine = (
    srcPath: '\examples\fibo.il';
    srcType: 'il';
    dstPath: '\examples\fiboil.bin';
    verbose: true
  );

implementation

begin
end.