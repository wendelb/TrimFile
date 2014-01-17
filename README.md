TrimFile
========

Delphi Application to remove trailing and leading whitespace from text files


Usage
-----
     TrimFile.exe [OPTION] [input-file]

The following parameters are availible
* **-stdout** Print the result to StdOutput instead of saving it to the file
* **-stdin** Read from StdInput instead from file
* **-trimleft** Removes all leading whitespace
* **-trimright** Removes all trailing whitespace
* **-trimboth** Short for _-trimleft -trimright_

As long as one of _-stdout_ or _-stdin_ is missing, a filename has to be given.

TrimFile homepage: https://github.com/wendelb/TrimFile

Please report any issues you encounter at the issue tracker.


(c) by Bernhard Wendel, 2014