-- Get the types from these module
local astTypes, valueTypes = require("./astTypes.luau"), require("./valueTypes.luau")



local function evalProgram(program : astTypes.Program, environment) : valueTypes.RuntimeVal
	local lastEvaluated = { ["type"] = "null", ["value"] = "null" } :: valueTypes.NullVal
	
	for _, statement in ipairs(program.body) do
		lastEvaluated = evaluate(statement, environment)
	end
	
	return lastEvaluated
end

local function evalNumericBinaryExpr(left : valueTypes.NumberVal, right : valueTypes.NumberVal, operator : string) : valueTypes.NumberVal
	local result = 0
	
	if operator == "+" then
		result = left.value + right.value
	elseif operator == "-" then
		result = left.value - right.value
	elseif operator == "*" then
		result = left.value * right.value
	elseif operator == "/" then
		result = left.value / right.value
	elseif operator == "%" then
		result = left.value % right.value
	end
	
	return {
		valType = "number",
		value = result
	}
end

local function evalBinaryExpr(binop : astTypes.BinaryExpr, environment) : valueTypes.RuntimeVal
	local leftSide = evaluate(binop.left, environment)
	local rightSide = evaluate(binop.right, environment)
	
	if leftSide.valType == "number" and rightSide.valType == "number" then
		return evalNumericBinaryExpr(leftSide :: valueTypes.NumberVal, rightSide :: valueTypes.NumberVal, binop.operator)
	end
	
	-- One or both sides are null
	return {
		
		valType = "null",
		value = "null",
		kind = "null"
	} :: valueTypes.NullVal
end

function evaluate(astNode : astTypes.Stmt, environment) : valueTypes.RuntimeVal
	if astNode.kind == "NumericLiteral" then
		return {
			["kind"] = "number",
			["valType"] = "number",
			["value"] = (astNode :: astTypes.NumericLiteral).value
		}
	elseif astNode.kind == "NullLiteral" then
		return {
			["kind"] = "null",
			["valType"] = "null",
			["value"] = "null"
		}
	elseif astNode.kind == "BinaryExpr" then
		return evalBinaryExpr(astNode :: astTypes.BinaryExpr, environment)
	elseif astNode.kind == "Program" then
		return evalProgram(astNode :: astTypes.Program, environment)
	else -- Error
		print(astNode)
		error("This AST Node has not been setup for interpretation correctly.")
	end
end

return evaluate
