local utilities = {}

function utilities:printTable( table )
    for k,v in pairs( table ) do
        print(k)

        if type(v) == 'table' then
            printtable(v)
        else
            print(v)
        end
    end
end

function utilities:deepcopy(t, cache)
    if type(t) ~= 'table' then
        return t
    end

    cache = cache or {}
    if cache[t] then
        return cache[t]
    end

    local new = {}

    cache[t] = new

    for key, value in pairs(t) do
        new[deepcopy(key, cache)] = deepcopy(value, cache)
    end

    return new
end

return utilities
