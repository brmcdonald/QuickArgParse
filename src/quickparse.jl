
mutable struct ArgQAP
	req::Vector{String}
	reqHelp::Vector{String}
	optTag::Dict{String,Any}
	optHelp::Dict{String,String}
	flags::Dict{String,Bool}
	flagHelp::Dict{String,String}
	title::String
	desc::String
	usage::String
end

function isnumber(x::String)
	try
		parse(Float64,x)
		return true
	catch
		return false
	end
end
function isnumber(x::Number)
	return true
end
function vector2dict(keys::Vector{String},values::AbstractArray;keytype=Any)
	D = Dict{String,keytype}()
	for idx in range(1,stop=length(keys))
		D[keys[idx]] = values[idx]
	end
	return D
end

function sanitize_reqs(inputNames,inputHelp,inputDefaults,inputType)
	badargs = [x for x in inputNames if startswith(x,"-")]
	if length(badargs) > 0
		print("\nERROR: No argument names may begin with '-'. Dashes are added by QuickArgParse. Exiting")
		exit()
	end
	if inputType == "flags"
		badargs = [x for x in inputNames if length(x) > 1 || isnumber(x) == true]
		if length(badargs) > 0
			print("\nERROR: Flag arguments must be a single non-numerical character. Exiting")
			exit()
		end
	end
	if length(inputHelp) > 0 && length(inputHelp) != length(inputNames)
		print("\nERROR: $inputType argument help vector must be zero length or same length as $inputType. Exiting")
		exit()
	end
	if inputType == "optional_arguments"
		if length(inputDefaults) > 0 && length(inputDefaults) != length(inputNames)
			print("\nERROR: $inputType argument defaults vector must be zero length or same length as $inputType. Exiting")
			exit()
		end
	end
	return
end

function process_reqs(req::Vector{String};reqHelp::Vector{String}=String[],
	optTag::Vector{String}=String[],optDefault::AbstractArray=[],optHelp::Vector{String}=String[],
	flags::Vector{String}=String[],flagHelp::Vector{String}=String[],
	title::String="",desc::String="",sanitize::Bool=true)

	if sanitize == true
		sanitize_reqs(req,reqHelp,[],"required_arguments")
		sanitize_reqs(optTag,optHelp,optDefault,"optional_arguments")
		sanitize_reqs(flags,flagHelp,[],"flags")
	end

	if length(reqHelp) == 0
		reqHelp = fill("",length(req))
	end
	if length(optHelp) == 0
		optHelp = fill("",length(optTag))
	end
	if length(flagHelp) == 0
		flagHelp = fill("",length(flags))
	end
	if length(optDefault) == 0
		optDefault = fill(nothing,length(optTag))
	end

	optDict = vector2dict(optTag,optDefault,keytype=Any)
	optHelpDict = vector2dict(optTag,optHelp,keytype=String)
	flagDict = vector2dict(flags,fill(false,length(flags)),keytype=Bool)
	flagHelpDict = vector2dict(flags,flagHelp,keytype=String)

	argData = ArgQAP(req,reqHelp,optDict,optHelpDict,flagDict,flagHelpDict,title,desc,"")
	return argData
end

function build_usage!(data::ArgQAP;style::String="std")
	if style == "std"
		#Argument type specific sections
		reqI = String[]
		for idx in range(1,stop=length(data.req))
			if length(data.reqHelp[idx]) > 0
				push!(reqI,"  $(data.req[idx]) : $(data.reqHelp[idx])")
			else
				push!(reqI,"  $(data.req[idx])")
			end
		end
		reqL = join(reqI,"\n") * "\n\n"

		if length(data.optTag) > 0
			optI = String[]
			for k in keys(data.optTag)
				if length(data.optHelp[k]) > 0
					push!(optI,"  --$k < $(data.optTag[k]) > : $(data.optHelp[k])")
				else
					push!(optI,"  --$k < $(data.optTag[k]) >")
				end
			end
			optL = join(optI,"\n") * "\n\n"
		end

		if length(data.flags) > 0
			flagI = String[]
			for k in keys(data.flags)
				if length(data.flagHelp[k]) > 0
					push!(flagI,"  -$(k) : $(data.flagHelp[k])")
				else
					push!(flagI,"  -$(k)")
				end
			end
			flagL = join(flagI,"\n") * "\n\n"
		end

		#Building usage statement
		if length(data.title) > 0
		h = "\n#\n#  $(data.title)\n#\n"
		else
			h = ""
		end

		if length(data.desc) > 0
			d = "\n$(data.desc)\n\n"
		else
			d = ""
		end
		if length(data.optTag) > 0 || length(data.flags) > 0
			inputSpec = "  [required arguments]" * " [options]\n\n"
		else
			inputSpec = ""
		end

		r = inputSpec * "# Required Arguments\n" * reqL
		if length(data.optTag) > 0
			o = "# Optional Arguments < default >\n" * optL
		else
				o = ""
		end
		if length(data.flags) > 0
			f = "#  Optional Flags\n" * flagL
		else
			f = ""
		end
	end #end std style

	data.usage = "$h$d$r$o$f"
end

function parse_args(data::ArgQAP)
	cleanArgs = Dict{String,Any}()
	if length(ARGS) < length(data.req)
		print(data.usage)
		exit()
	end

	#Parse required inputs
	reqInputs = ARGS[1:length(data.req)]
	for idx in range(1,stop=length(data.req))
		cleanArgs[data.req[idx]] = reqInputs[idx]
	end

	#Fill defaults for other argmuents and flags
	for i in keys(data.optTag)
		cleanArgs[i] = data.optTag[i]
	end
	for i in keys(data.flags)
		cleanArgs[i] = false
	end

	if length(ARGS) > length(data.req)
		allOpts = ARGS[length(data.req)+1:end]

		#Search for optional args
		optArgs = [idx for idx in range(1,stop=length(allOpts)) if startswith(allOpts[idx],"--")]
		for idx in optArgs
			oTag = allOpts[idx][3:end]
			if length(allOpts) < idx+1
				print("\nERROR1: No value provided to optional argument $oTag. Exiting\n")
				exit()
			else
				oValue = allOpts[idx+1]
			end

			if haskey(data.optTag,oTag) == false
				print("\nERROR2: No optional argument $oTag. Exiting\n")
				exit()
			elseif startswith(oValue,"-") && isnumber(oValue) == false
				print("\nERROR3: No value provided to optional argument $oTag. Exiting\n")
				exit()
			else
				if isnumber(oValue) == true && isnumber(data.optTag[oTag]) == true
					if occursin(".",oValue)
						cleanArgs[oTag] = parse(Float64,oValue)
					else
						cleanArgs[oTag] = parse(Int,oValue)
					end
				else
					cleanArgs[oTag] = oValue	
				end
			end
		end

		#Search for flags
		optFlags = [x for x in allOpts if startswith(x,"-") == true && length(x) == 2 && isnumber(x) == false]
		for o in optFlags
			oFlag = o[2:end]
			if haskey(data.flags,oFlag) == false			
				print("\nERROR: No optional flag $oFlag. Exiting\n")
				exit()
			else
				cleanArgs[oFlag] = true
			end
		end
	end

	return cleanArgs
end
