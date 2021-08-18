# QuickArgParse
Fast command line argument parsing in Julia. No bells and whistles.

### Example
All inputs except req are optional.  

```Julia
req = ["Arg1","Arg2"]
reqhelp = ["First Argument","Second Argument"]
opts= ["opt1","opt2"]
optsHelp = ["First optional argument","Second optional argument"]
optsDefault = ["opt1 default","opt2 default"]
flags = ["w"]
flagHelp = ["a flag, true/false (default false)"]
title = "Example usage statement"
desc = "A demo version of a usage statement showing the code required to generate it"


R = process_reqs(req;reqHelp=reqhelp,flags=flags,flagHelp=flagHelp,title=title,desc=desc,
	optTag=opts,optHelp=optsHelp,optDefault=optsDefault)
build_usage!(R)
A = parse_args(R)
```