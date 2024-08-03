local types, lexerReturns = require("./astTypes.luau"), require("./lexer.luau")
local tokenize, CreateToken = lexerReturns[1], lexerReturns[2]
local TokenType = require("./tokenTypes.luau")
local append = table.insert
local remove = table.remove

local tokens = {}

local function at()
	return tokens[1]
end

local function advance()
	return remove(tokens, 1)
end

local function expect(tokenType, errorMessage)
	local prev = remove(tokens, 1)
	if not prev or prev.tokenType ~= tokenType then
		local newErrorMessage = errorMessage or ""
		error(newErrorMessage .. " Expected " .. tokenType .. " but got " .. prev.tokenType .. " (" .. prev.value .. ")")
	end
end

local function notEOF()
	return (tokens[1].tokenType ~= TokenType.EndOfFile)
end



local parseExpr

local function parsePrimaryExpr() -- returns an Expr
	local tk = at().tokenType

	if tk == TokenType.Identifier then
		return {
			kind = "Identifier",
			symbol = advance().value
		}
	elseif tk == TokenType.Null then
		advance()
		return {
			kind = "NullLiteral",
			value = "null"
		}
	elseif tk == TokenType.Number then
		return {
			kind = "NumericLiteral",
			value = tonumber(advance().value)
		}
	elseif tk == TokenType.OpenParen then
		advance() -- remove opening parentheses
		local value = parseExpr()
		expect(TokenType.CloseParen, "Open parentheses never closed.") -- remove closing parentheses
		return value
	else
		print(at())
		error("Unexpected token found during parsing")
	end
end

local function parseMultiplicativeExpr() -- returns an Expr
	local left = parsePrimaryExpr()

	while at().value == "*" or at().value == "/" or at().value == "%" do
		local operator = advance().value
		local right = parsePrimaryExpr()
		left = {
			kind = "BinaryExpr",
			left = left,
			right = right,
			operator = operator
		}
	end

	return left
end

local function parseAdditiveExpr() -- returns an Expr
	local left = parseMultiplicativeExpr()
	
	while at().value == "+" or at().value == "-" do
		local operator = advance().value
		local right = parseMultiplicativeExpr()
		left = {
			kind = "BinaryExpr",
			left = left,
			right = right,
			operator = operator
		}
	end
	
	return left
end



parseExpr = function() -- returns an Expr
	return parseAdditiveExpr()
end

local Parser = {}
Parser = {
	
	produceAST = function(sourceCode: string): types.Program
		tokens = tokenize(sourceCode)
		local program: types.Program = {
			kind = "Program",
			body = {}
		}
		
		append(program.body, parseExpr())

		return program
	end,
}

return Parser
