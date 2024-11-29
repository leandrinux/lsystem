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
    srcPath: '\examples\write.asm';
    srcType: 'asm';
    dstPath: '\examples\write.bin';
    verbose: true
  );

implementation

begin
end.