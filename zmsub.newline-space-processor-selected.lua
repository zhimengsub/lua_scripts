local tr = aegisub.gettext

script_name = tr("规范换行空格 (选中行)")
script_description = tr("检查选中行的换行符是否规范，如果不规范则设为注释，否则\\N后的空格全部换为全角，前面的空格全部换为半角")
script_author = "谢耳朵w"
script_version = "0.3"

re = require 'aegisub.re'

exp_newline = re.compile("\\\\N(?=\\{\\\\fnSource Han Sans JP Bold)")
exp_jpsp = re.compile("(\\\\N\\{\\\\fnSource Han Sans JP Bold.*\\}.*) {1,}")
exp_zhsp = re.compile("　(?=.*\\\\N)")
exp_fn = re.compile("\\{\\\\fnSource Han Sans JP Bold.*\\}")
exp_sp1 = re.compile("　+")
exp_sp2 = re.compile(" +")

function remove_seq_space(text)
    text = replace_until_same(text, exp_sp1, '　')
    text = replace_until_same(text, exp_sp2, ' ')
    return text
end

function replace_space(text)
    text = replace_until_same(text, exp_zhsp, ' ')
    text = replace_until_same(text, exp_jpsp, '$1　')
    return text
end

function replace_until_same(text, exp, newtxt)
    local ot = text
    repeat 
        ot = text
        text, _ = exp:sub(text, newtxt)
    until ot == text
    return text
end

function is_single_newline(text)
    matches = exp_newline:find(text)
    if not matches or #matches>1 then
        return false
    end
    return true
end

function process_lines_selected(subtitles, selected_lines, active_line)
    sels = {}
    local i_dialogue = 1
	for _, i in ipairs(selected_lines) do
		aegisub.progress.set(i * 100 / #selected_lines)
		local l = subtitles[i]
        if subtitles[i].class == "dialogue" then
            if not is_single_newline(l.text) then
                l.comment = true
                subtitles[i] = l
                table.insert(sels, i)
                aegisub.debug.out(string.format('Line %d format error! "%s"\n\n', i, l.text))
            else
                nt = replace_space(l.text)
                nt = remove_seq_space(nt)
                if nt ~= l.text then
                    l.text = nt
                    -- aegisub.debug.out(string.format('%d: "%s"\n        -> "%s"\n\n', i_dialogue, l.text, nt))
                    subtitles[i] = l
                    table.insert(sels, i)
                end
            end
            i_dialogue = i_dialogue + 1
        end
	end
	aegisub.set_undo_point(script_name)
    return sels
end

aegisub.register_macro(script_name, script_description, process_lines_selected)
