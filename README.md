# QuickArgParse
Fast command line argument parsing in Julia. No bells and whistles.

When QuickArgParse is used to parse command line arguments, required arugments must be provided in order
before optional arguments.  

Optional arguments are preceded by --

Flags are preceded by a single - and must be single letter. Their value is false by default,
and changes to true if the flag is included as a command line argument (ie -w).

### Example
All inputs except the req vector are optional.  
```Julia
req = ["Arg1","Arg2"]
reqhelp = ["First Argument","Second Argument"]
opts= ["opt1","opt2"]
optsHelp = ["First optional argument","Second optional argument"]
optsDefault = ["opt1Default",28]
flags = ["w"]
flagHelp = ["a flag, value is always true/false (default false)"]
title = "Example usage statement"
desc = "A demo version of a usage statement showing the code required to generate it"

#process the input vectors
R = process_reqs(req;reqHelp=reqhelp,flags=flags,flagHelp=flagHelp,title=title,desc=desc,
	optTag=opts,optHelp=optsHelp,optDefault=optsDefault)  

#build a usage statement string
build_usage!(R)  

#attempt to parse the ARGS vector according to the above requirements.  
#if not possible, return the usage statement instead.
A = parse_args(R)
```

The resulting dict A contains the values for all command line arguments, keyed by the string
variable specified in the input vectors to process_reqs (ie "Arg1", "opt1", "w"). If optional
argument names are provided (the opt vector), default values must also be provided (optsHelp).
These can be any type.  

### Usage statement format
>\#  
>\#  Example usage statement  
>\#  
>
>A demo version of a usage statement showing the code required to generate it
>
>  [required arguments] [options]
>
>\# Required Arguments  
>  Arg1 : First Argument  
>  Arg2 : Second Argument  
>
>\# Optional Arguments < default >  
>  --opt1 < opt1Default > : First optional argument  
>  --opt2 < 28 > : Second optional argument  
>
>\#  Optional Flags  
>  -w : a flag, value is always true/false (default false)


