local tr = aegisub.gettext

script_name = tr("检查换行并统一半角空格(选中行)")
script_description = tr("检查选中行的换行符是否规范，如果不规范则设为注释，否则空格全部替换为半角")
script_author = "谢耳朵w"
script_version = "0.1"

re = require 'aegisub.re'

exp_newline = re.compile("\\\\N(?=\\{\\\\fnSource Han Sans JP Bold)")
exp_fwsp = re.compile("　+")

function linenum_offset(subs)
    offset = 0
    for i = 1, #subs do
        if subs[i].class ~= "dialogue" then
            offset = i
        else
            break
        end
    end
    return offset
end

function replace_space(text)
    text = replace_until_same(text, exp_fwsp, ' ')
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
    offset = linenum_offset(subtitles)
    sels = {}
    errsels = {}
	for _, i in ipairs(selected_lines) do
		aegisub.progress.set(i * 100 / #selected_lines)
		local l = subtitles[i]
        if subtitles[i].class == "dialogue" then
            if not is_single_newline(l.text) then
                l.comment = true
                subtitles[i] = l
                table.insert(errsels, i)
                aegisub.debug.out(string.format('Line %d format error! "%s"\n\n', i-offset, l.text))
            else
                nt = replace_space(l.text)
                if nt ~= l.text then
                    l.text = nt
                    -- aegisub.debug.out(string.format('%d: "%s"\n        -> "%s"\n\n', i-offset, l.text, nt))
                    subtitles[i] = l
                    table.insert(sels, i)
                end
            end
        end
	end
	aegisub.set_undo_point(script_name)
    if #errsels > 0 then
        aegisub.debug.out('These lines will be selected and commented out!')
        return errsels
    end
    return sels
end

aegisub.register_macro(script_name, script_description, process_lines_selected)
