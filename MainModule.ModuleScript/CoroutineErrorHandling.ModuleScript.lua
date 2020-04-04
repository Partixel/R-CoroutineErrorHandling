local function ErrorHandler(Error)
	local Trace = debug.traceback(nil, 2):sub(1, -2)
	return {Error, Trace:sub(1, #Trace - Trace:reverse():find(".\n") - 1) .. "\n"}
end

local Stacks = {}
local function RunFunction(Func, ...)
	local Results = {xpcall(Func, ErrorHandler, ...)}
	local Thread = coroutine.running()
	if not Results[1]  then
		local Stack = Stacks[Thread]
		Stacks[Thread] = nil
		error(Results[2][1] .. "\nStack Begin\n" .. Results[2][2] .. Stack .. "Stack End", 0)
	else
		Stacks[Thread] = nil
		return unpack(Results)
	end
end

-- Use this instead of coroutine.resume() if you want the error stack to trace from when you run this function instead of when you initially ran CoroutineWithStack
function ResumeWithStack(Thread, ...)
	Stacks[Thread] = debug.traceback(nil, Stacks[Thread] == true and 3 or 2)
	local Results = {coroutine.resume(Thread, ...)}
	if not Results[1] then
		error(Results[2], 0)
	else
		return unpack(Results, 2)
	end
end

-- Use this if you want the error stack to trace from when you run this function even after resuming the thread from coroutine.resume
function CoroutineWithStack(Func, ...)
	local Thread = coroutine.create(RunFunction)
	Stacks[Thread] = true
	return ResumeWithStack(Thread, Func, ...)
end

return {CoroutineWithStack = CoroutineWithStack, ResumeWithStack = ResumeWithStack}