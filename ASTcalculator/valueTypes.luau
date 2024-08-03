export type ValueType = "null" | "number"

export type RuntimeVal = {
	kind: ValueType
}

export type NullVal = RuntimeVal & {
	["valType"]: string,
	["value"]: string
}

export type NumberVal = RuntimeVal & {
	["valType"]: string,
	["value"]: number
}

return nil
