overwire = {}

function overwire.deserialize(serialized)
	return loadstring(overwire.sanitize(serialized))()
end


function overwire.sanitize(serialized)
	-- So... lua doesn't come with a full feature regex engine ...
	-- I'm going to hold off on this, unless someone complains.
	
	--[=[
		local securityRegex = [[((V = {}(\\n|$))|(^V%[[0-9]+%]%[V%[[0-9]+%]\\]=V%[[0-9]+%](\\n|$))|(^V%[[0-9]+%] = ({}|[0-9]+|'[^']*')(\\n|$))|(^(\\n|$))|return V%[0%])+]]
		local matched = string.match(serialized, securityRegex)
		if matched == nil or #matched ~= #serialized then
			print('someone tried to execute non overwire code')
			return nil
		end
	--]=]
	return serialized
end

function overwire.serialize(obj)
	createVertexList, V = overwire.createVertexList(obj)
	createEdgeList = overwire.createEdgeList(obj, V)
	code =  createVertexList .. createEdgeList .. 'return V[0]'
	return code
end

function overwire.createEdgeList(obj, V)

	-- V contains a reference to every distict variable that will exist in the final object graph as the key, and the position in the serialized V as the value

	-- the list of Lua lines in our runnable serializetion result	
	lines = {''}

	openList = {obj}
	closeList = {}
	while #openList > 0 do
	
		currentNode = table.remove(openList)
		closeList[currentNode] = true
		--print('current Node: ' .. tostring(currentNode))

		if type(currentNode) == 'table' then
			for k, v in pairs(currentNode) do

				parentIndex = V[currentNode]
				labelIndex = V[k]
				childIndex = V[v]

				line = 'V[' .. parentIndex .. '][V['..labelIndex..']]=V['..childIndex..']'
				table.insert(lines, line)

				if not closeList[k] then
					table.insert(openList, k)
				end

				if not closeList[v] then
					table.insert(openList, v)
				end
			end
		end
	end
	luaCodeCreateEdgeList = table.concat(lines, '\n')
	return luaCodeCreateEdgeList .. '\n'
end



function overwire.createVertexList(obj)

	V = {}
	lines = {''}
	initLine = 'V = {}'
	table.insert(lines, initLine)

	openList = {obj}
	closeList = {}

	index = 0

	while #openList > 0 do
		currentNode = table.remove(openList)
		closeList[obj] = true
		V[currentNode] = index
		line = 'V['.. index ..'] = ' .. overwire.describeLiteral(currentNode)
		index = index + 1
		table.insert(lines, line)

		if type(currentNode) == 'table' then
			for k,v in pairs(currentNode) do
				if closeList[k] == nil then
					table.insert(openList, k)
				end
	
				if closeList[v] == nil then
					table.insert(openList, v)
				end
			end
		end
	end
	return table.concat(lines, '\n')..'\n', V
end

function overwire.describeLiteral(obj)
	return 
		type(obj) == 'number' and '' .. obj 
		or
		type(obj) == 'table' and '{}'
		or 
		type(obj) == 'string' and 
		(
			string.match(obj, '[%[%]=]+') == nil and '[['..obj..']]'
			or 
			'overwire.desanitizeString([['..overwire.sanitizeString(obj)..']])'
		)
end

function overwire.sanitizeString(obj)
	return 
		string.gsub(
			string.gsub(	obj,
					'%[',
					'[z'),
			'%]',
			']z'
		)
end

function overwire.desanitizeString(obj)
	return 
		string.gsub(
			string.gsub(	obj,
					'%[z',
					'['),
			'%]z',
			']'
		)
end
