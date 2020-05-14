local CoroutineErrorHandling = {}

function CoroutineErrorHandling.ErrorHandler(Error)
	local Trace = debug.traceback(nil, 2):sub(1, -2)
	return {Error, Trace:sub(1, #Trace - Trace:reverse():find(".\n") - 1) .. "\n"}
end

function CoroutineErrorHandling.GetError(Result, Stack)
	return Result[1] .. "\nStack Begin\n" .. Result[2] .. (Stack or debug.traceback(nil, 2)) .. "Stack End"
end

local Stacks = {}
function CoroutineErrorHandling.RunFunctionWithStack(Func, ...)
	local Results = {xpcall(Func, CoroutineErrorHandling.ErrorHandler, ...)}
	local Thread = coroutine.running()
	if not Results[1]  then
		local Stack = Stacks[Thread] or debug.traceback(nil, 2)
		Stacks[Thread] = nil
		error(CoroutineErrorHandling.GetError(Results[2], Stack), 0)
	else
		Stacks[Thread] = nil
		return unpack(Results)
	end
end

-- Use this instead of coroutine.resume() if you want the error stack to trace from when you run this function instead of when you initially ran CoroutineWithStack
function CoroutineErrorHandling.ResumeWithStack(Thread, ...)
	Stacks[Thread] = debug.traceback(nil, Stacks[Thread] == true and 3 or 2)
	local Results = {coroutine.resume(Thread, ...)}
	if not Results[1] then
		error(Results[2], 0)
	else
		return unpack(Results)
	end
end

-- Use this if you want the error stack to trace from when you run this function even after resuming the thread from coroutine.resume
function CoroutineErrorHandling.CoroutineWithStack(Func, ...)
	local Thread = coroutine.create(CoroutineErrorHandling.RunFunctionWithStack)
	Stacks[Thread] = true
	return select(2, CoroutineErrorHandling.ResumeWithStack(Thread, Func, ...))
end

return CoroutineErrorHandling