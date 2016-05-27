require("overwire")

testTable = {
	alpha = "alpha",
	dangerousAlpha = [===[ a [[0]] b [=[1]=] ]===],
	numeric = 3.14159,
	int = 42,
	table = {
		key = "value"
	}
}

testTable[testTable.table]= {testTable=testTable} -- Lua can get a bit silly :)



serialized = overwire.serialize(testTable)
print(serialized)


deserialized = overwire.deserialize(serialized)

assert(deserialized.alpha == testTable.alpha, "alpha conversion failed")
assert(deserialized.dangerousAlpha == testTable.dangerousAlpha, "dangerousAlpha conversion failed")
assert(deserialized.numeric == testTable.numeric, "numeric test failed")
assert(deserialized.int == testTable.int, "int test failed")
assert(deserialized.table.key == testTable.table.key, "table key test failed")
assert(deserialized[deserialized.table]["testTable"] == deserialized, "recursive reference failed")

print('all tests successful')
