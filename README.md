#overwire
#####A Primitive Lua serialization utility.

Overwire is a very simple library which can be used to explore or serialize basic objects in Lua.

I created overwire as a way to familiarize myself with Lua's syntax and capabilities. 
Finding it useful, I am making it publicly available, though several similar libraries exist.

Overwire handles all strings safely, but cannot serialize threads, userdata, or functions.

Reference loops are handled properly, as shown in the demo below.

TODO: I'd like to make a different version of overwire that has a more succinct serialization format (As close to the original as possible. Think JSON). 
Hopefully I'll get around to that soon.

##Demo:
The following can be seen by running 'lua testOverwire.lua'.

####Input:
```
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
```

####Output:
```
V = {}
V[0] = {}
V[1] = {}
V[2] = [[value]]
V[3] = [[key]]
V[4] = [[table]]
V[5] = 42
V[6] = [[int]]
V[7] = [[alpha]]
V[8] = [[alpha]]
V[9] = 3.14159
V[10] = [[numeric]]
V[11] = overwire.desanitizeString([[ a [z[z0]z]z b [z=[z1]z=]z ]])
V[12] = [[dangerousAlpha]]
V[13] = {}
V[14] = [[testTable]]
V[15] = {}
V[16] = [[value]]
V[17] = [[key]]

V[0][V[15]]=V[13]
V[0][V[12]]=V[11]
V[0][V[10]]=V[9]
V[0][V[8]]=V[8]
V[0][V[6]]=V[5]
V[0][V[4]]=V[15]
V[15][V[17]]=V[16]
V[13][V[14]]=V[0]
V[15][V[17]]=V[16]
return V[0]
```
