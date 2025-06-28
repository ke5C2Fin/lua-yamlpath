-- shows yaml path in status bar

require('vis')

local function check_line(line)
	if line:match('^ *$') then return false end
	if line:find('^ *#') then return false end
	if line:find('^ *%*') then return false end
	if line:find('^ *%&') then return false end
	return true
end

local function get_indent(line)
	local indent = line:find('[^ ]')
	local is_seq = false
	if line:find('^ *%- ') then
		is_seq = true
		indent = indent + 2
	end
	return indent, is_seq
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
	if not check_line(curr_line) then return false end

	local curr_indent, is_seq = get_indent(curr_line)
	local trigger_indent = curr_indent

	local yaml_key = get_yaml_key(curr_line)
	if not yaml_key then return false end
	local yaml_path = yaml_key

	while curr_indent > 1 do
		line_num = line_num - 1
		if line_num == 0 then
			break
		end

		curr_line = vis.win.file.lines[line_num]
		if not curr_line then return false end

		if check_line(curr_line) then
			local seq_indicator = ''
			if is_seq then
				seq_indicator = '[]'
			end

			curr_indent, is_seq = get_indent(curr_line)
			if curr_indent < trigger_indent then
				trigger_indent = curr_indent

				yaml_key = get_yaml_key(curr_line)
				if not yaml_key then return false end
				yaml_path = string.format('%s%s.%s', yaml_key, seq_indicator, yaml_path)
			end
		end
	end

	vis:info(yaml_path)
	return yaml_path
end, "yaml path")
