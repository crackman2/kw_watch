import os, sequtils


proc cleanupWavFiles*(dir:string): void =
  let file_list = toSeq(walkDir(dir, relative=true))
  echo file_list
  echo "cleanup: moving wav files"

  if not dirExists(joinPath(dir,"/dump/")):
    echo "cleanup: dump folder not found. creating: " & joinPath(dir,"/dump/")
    createDir(joinPath(dir,"/dump/"))

  for i in file_list:
    var newname = ""
    if (i.kind == pcFile) and (i.path[i.path.len - 4..^1]) == ".wav":
      #echo "wav. found " & i.path
      if not fileExists(joinPath(dir,"/dump/" & i.path)):
        moveFile(joinPath(dir,i.path), joinPath(dir,"/dump/" & i.path))
        newname = joinPath(dir,"/dump/" & i.path)
      else:
        var index = 1
        let (filedir, filename, fileext) = splitFile(i.path)
        while fileExists(joinPath(dir,"/dump/" & filename & "_" & $(index) & ".wav")):
          index += 1
        newname = joinPath(dir,"/dump/" & filename & "_" & $(index) & ".wav")
        moveFile(joinPath(dir,i.path), joinPath(dir,"/dump/" & filename & "_" & $(index) & ".wav"))
      echo "cleanup: moving file: " & newname


#when isMainModule:
#  cleanupWavFiles("/home/seife/script/github/kw_watch")

