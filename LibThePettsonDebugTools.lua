local MAJOR, MINOR = "ThePettsonDebugTools-1.0", 2
local DebugTools = LibStub:NewLibrary(MAJOR, MINOR)

if not DebugTools then return end -- No upgrade needed

local RegisteredTargets = {}
local Severity = {
	INFO = "INFO",
	DEBUG = "DEBUG",
	ERROR = "ERROR",
	WARNING = "WARNING",
}
local ColorLookup = {
	[Severity.INFO] = "00ffffff",
	[Severity.DEBUG] = "00ffffff",
	[Severity.ERROR] = "00ff0000",
	[Severity.WARNING] = "00eed202",
}

local stringformat = string.format

function DebugTools:New(target, name, enableDebug)
	if target == nil then
		error(stringformat("Missing argument \"target\""))
	elseif type(target) ~= "table" then
		error(stringformat("Invalid argument \"target\" - Must be a Table"))
	end

	if name == nil then
		error(stringformat("Missing argument \"name\""))
	elseif type(name) ~= "string" then
		error(stringformat("Invalid argument \"name\" - Must be a String"))
	end

	if RegisteredTargets[target] then
		error(stringformat("Unable to register ThePettsonDebugTools to %q. Target is already registered to %q", name, RegisteredTargets[target]))
	end

	if target.__debugTools then
		error(stringformat("Unable to register ThePettsoNDebugTools, \"__debugTools\" is already defined"))
	end

	target.__debugTools = {
		debug = enableDebug,
		name = name,
	}

	self:Embed(target)

	RegisteredTargets[target] = name

	return {
		Severity = Severity,
	}
end

local lpad = function(len)
    return string.rep(" ", len)
end


-- Local functions that will be embeded
local function Print(target, msg, ...)
	print(string.format("[%s] %s", target.__debugTools.name, string.format(msg, ...)))
end

local function DPrint(target, severity, msg, ...)
	if target.__debugTools.debug then
		print(string.format("[%s]|c%s[%s] %s|r", target.__debugTools.name, ColorLookup[severity], severity, string.format(msg, ...)))
	end
end

local function SetDebug(target, enabled)
	target.__debugTools.debug = enabled
end

local function TableDump(target, tbl, indent)
	indent = indent or 0
	for k, v in pairs(tbl) do
		local vType = v and type(v) or "nil"
		if vType == "string" or vType == "number" or vType == "nil" or vType == "boolean" then
			print(stringformat("%s%s: %s", lpad(indent), k, tostring(v)))
		elseif vType == "userdata" then
			print(stringformat("%s%s: userdata", lpad(indent), k))
		elseif vType == "table" then
			TableDump(target, v, indent + 4)
		end
	end
end

local function DebugEnabled(target)
	return target.__debugTools.debug
end

local MixIns = {
	print = Print,
	dprint = DPrint,
	Print = Print,
	DPrint = Print,
	SetDebug = SetDebug,
	DebugEnabled = DebugEnabled,
	tDump = TableDump,
	TableDump = TableDump,
}
function DebugTools:Embed(target)
	for k, v in pairs(MixIns) do
		target[k] = v
	end
end