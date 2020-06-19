function checkUnset(obj, argin)
props = properties(obj);
anonNames = {};
for i=1:length(props)
    p = obj.(props{i});
    if isa(p, 'types.untyped.Anon')
        anonNames = [anonNames;{p.name}];
    elseif isa(p, 'types.untyped.Set')
        anonNames = [anonNames;keys(p) .'];
	end
end
if any(contains(argin,'unit'))
	anonNames = [anonNames;argin{contains(argin,'unit')}];
end

dropped = setdiff(argin, [props;anonNames])
if ~isempty(dropped)
    error('Properties {%s} are not valid property names.',...
        misc.cellPrettyPrint(dropped));
end
end