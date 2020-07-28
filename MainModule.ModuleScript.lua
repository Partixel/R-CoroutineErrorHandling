if game:GetService("RunService"):IsRunning() then
	local Module = script:WaitForChild("CoroutineErrorHandling"):Clone()
	Module.Parent = game:GetService("ReplicatedStorage")
	return require(Module)
else
	return require(script.CoroutineErrorHandling)
end