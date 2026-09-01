-- shows yaml path in status bar

require('vis')

local function check_line(line)
	if not line then return false end
	if line:match('^ *$') then return false end
	if line:find('^ *#') then return false end
	if line:find('^ *%*') then return false end
	if line:find('^ *%&') then return false end
	return true
end

local function is_sequence(line)
	return line:find('^ *%- ') ~= nil
end

local function set_seq_indicator(line)
	if is_sequence(line) then
		return '[]'
	end
	return ''
end

local function get_indent(line)
	local indent = line:find('[^ ]') or 1
	if is_sequence(line) then
		indent = indent + 2
	end
	return indent
end

local function get_yaml_key(line)
	local key = line:match('^ *-? *([^ ]+):')
	if not key then return false end
	if key:find('.', 1, true) then
		key = string.format('"%s"', key)
	end
	return key
end

vis:map(vis.modes.NORMAL, "<C-p>", function(keys)
	local line_num = vis.win.selection.line
	local curr_line = vis.win.file.lines[line_num]
	if not curr_line or not check_line(curr_line) then return false end

	local curr_indent = get_indent(curr_line)
	local trigger_indent = curr_indent

	local yaml_key = get_yaml_key(curr_line)
	if not yaml_key then return false end
	local yaml_path = yaml_key

	while curr_indent > 1 do
		line_num = line_num - 1
		if line_num < 1 then break end
		curr_line = vis.win.file.lines[line_num]
		if curr_line and check_line(curr_line) then
			curr_indent = get_indent(curr_line)
			if curr_indent < trigger_indent then
				trigger_indent = curr_indent
				local seq_indicator = set_seq_indicator(curr_line)
				local parent_key = get_yaml_key(curr_line)
				if parent_key then
					if seq_indicator ~= '' then
						yaml_path = string.format('%s%s.%s', parent_key, seq_indicator, yaml_path)
					else
						yaml_path = string.format('%s.%s', parent_key, yaml_path)
					end
				end
			end
		end
	end

	vis:info(yaml_path)
	return true
end, "yaml path")
