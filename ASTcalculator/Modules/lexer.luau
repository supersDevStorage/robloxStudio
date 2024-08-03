local insert = table.insert

local function shift(str : {string})
	return table.remove(str, 1)
end

local TokenType = require("./tokenTypes.luau")

local Keywords = {
	["nil"] = TokenType.Null
}

local function CreateToken(val : string, typeOfToken : number)
	return { value = val, tokenType = typeOfToken }
end

local function isAlpha(str : string)
	return (string.upper(str) ~= string.lower(str))
end

local function isInt(str : string)
	return (true and tonumber(str)) or false
end

local function isSkippable(str : string)
	return (str == " " or str == "\n" or str == "\t")
end

local function tokenize(sourceCode : string): {number}
	local tokens = {}
	local src = string.split(sourceCode, "")

	while #src > 0 do
		if src[1] == "(" then
			insert(tokens, CreateToken(shift(src), TokenType.OpenParen))
		elseif src[1] == "+" or src[1] == "-" or src[1] == "*" or src[1] == "/" or src[1] == "%" then
			insert(tokens, CreateToken(shift(src), TokenType.BinaryOperator))
		elseif src[1] == ")" then
			insert(tokens, CreateToken(shift(src), TokenType.CloseParen))
		elseif src[1] == "=" then
			insert(tokens, CreateToken(shift(src), TokenType.Equals))
		else -- Handle tokens that span more than 1 character
			if isInt(src[1]) then -- Handle number tokens
				local num = ""
				while #src > 0 and isInt(src[1]) do
					num = num .. shift(src)
				end
				insert(tokens, CreateToken(num, TokenType.Number))
			elseif isAlpha(src[1]) then -- Handle identifier tokens (ex. Identifier = Value)
				local identifier = ""
				while #src > 0 and isAlpha(src[1]) do
					identifier = identifier .. shift(src)
				end
				-- Check for reserved lua keywords
				local reserved = Keywords[identifier]
				if typeof(reserved) == "number" then
					insert(tokens, CreateToken(identifier, Keywords[identifier]))
				else
					insert(tokens, CreateToken(identifier, TokenType.Identifier))
				end
			elseif isSkippable(src[1]) then
				shift(src) continue
			else
				print("Unrecognized character in source:" .. src[1])
				return tokens
			end
		end
	end
	insert(tokens, CreateToken("EndOfFile", TokenType.EndOfFile))
	return tokens
end

return { tokenize, CreateToken }
