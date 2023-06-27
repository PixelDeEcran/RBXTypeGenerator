local Selection = game:GetService("Selection")
local ServerStorage = game:GetService("ServerStorage")
local ChangeHistoryService = game:GetService("ChangeHistoryService")

local toolbar = plugin:CreateToolbar("TypeGenerator")
local generateButton = toolbar:CreateButton("GenerateTypes", "Generate types for selected instances.", "rbxassetid://13879732804", "Generate Types")
generateButton.ClickableWhenViewportHidden = true

function getInstanceType(tabStr: string, instance: Instance): string
	local str = instance.ClassName
	
	if #instance:GetChildren() > 0 then
		str = str .. " & {\n"
		local childTabStr = tabStr .. "\t"
		
		for _, child in ipairs(instance:GetChildren()) do
			local name = child.Name
			if string.match(name, "%a%w*") ~= name then
				name = "[\"" .. name .. "\"]"
			end
			
			str = str .. childTabStr  .. name .. ": " .. getInstanceType(childTabStr, child) .. ",\n"
		end
		
		str = str .. tabStr .. "}"
	end
	
	return str
end

local function generate(instance: Instance)
	local source = "export type Type = " .. getInstanceType("", instance)

	source = source .. "\n\nreturn nil"

	local moduleScript = Instance.new("ModuleScript")
	moduleScript.Name = instance.Name
	moduleScript.Source = source
	
	local parentFolder = ServerStorage:FindFirstChild("TypeGenerator")
	if not parentFolder then
		parentFolder = Instance.new("Folder")
		parentFolder.Name = "TypeGenerator"
		parentFolder.Parent = ServerStorage
	end
	
	moduleScript.Parent = parentFolder
end

generateButton.Click:Connect(function()
	for _, selection in ipairs(Selection:Get()) do
		generate(selection)
	end
	
	ChangeHistoryService:SetWaypoint("Generated Types")
end)