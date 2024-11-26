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
      dataMaxSize: word;
      verbose: boolean;
    end;

  const cmdline: TCommandLine = (
    srcPath: '\examples\hello3.il';
    srcType: 'il';
    dstPath: '\examples\hello3.gen';
    dstType: 'bin';
    dataMaxSize: 4096;
    verbose: true
  );

implementation

begin
end.