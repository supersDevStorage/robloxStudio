-- This module is for exporting types for the AST parser

export type NodeType = "Program"
	| "NumericLiteral"
	| "NullLiteral"
	| "BinaryExpr"

export type Stmt = { -- Statement
	kind: NodeType
}

export type Program = {
	-- extensions from Stmt
	kind: "Program",

	body: {Stmt}
}

export type Expr = {
	-- extensions from Stmt
	kind: string
}

export type BinaryExpr = {
	-- extensions of Expr
	kind: "BinaryExpr",

	left: Expr,
	right: Expr,
	operator: string
}

export type NumericLiteral = {
	kind: "NumericLiteral",
	value: number
}

export type NullLiteral = {
	kind: "NullLiteral",
	value: "null"
}

return nil
