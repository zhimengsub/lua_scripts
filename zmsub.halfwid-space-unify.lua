local tr = aegisub.gettext

script_name = tr("检查换行|空格换为半角|规范数字宽度 (选中行)")
script_description = tr("检查选中行的换行符是否规范，如果不规范则设为注释；空格全部替换为半角，一位数字替换为全角，多位数字替换为半角")
script_author = "谢耳朵w"
script_version = "0.2"

include("unicode.lua")
re = require 'aegisub.re'

exp_newline = re.compile("\\\\N(?=\\{\\\\fnSource Han Sans JP Bold)")
exp_fwsp = re.compile("　+")
exp_sep = re.compile("(.+)(\\\\N\\{\\\\fnSource Han Sans JP Bold.*\\})(.+)")
exp_single_digit = re.compile("(?<!\\d)\\d(?!\\d)")
exp_multi_digit = re.compile("\\d{2,}")

to_fullwidth = {['1'] = '１', ['2'] = '２', ['3'] = '３', ['4'] = '４', ['5'] = '５',
                ['6'] = '６', ['7'] = '７', ['8'] = '８', ['9'] = '９', ['0'] = '０'}
to_halfwidth = {['１'] = '1', ['２'] = '2', ['３'] = '3', ['４'] = '4', ['５'] = '5',
                ['６'] = '6', ['７'] = '7', ['８'] = '8', ['９'] = '9', ['０'] = '0'}

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

function replace_digits(text)
    local res = exp_sep:match(text)
    zhs = res[2]['str']
    sep = res[3]['str']
    jps = res[4]['str']
    zhs = exp_single_digit:sub(zhs, function(s) return to_fullwidth[s] end)
    jps = exp_single_digit:sub(jps, function(s) return to_fullwidth[s] end)
    zhs = exp_multi_digit:sub(zhs, function(s) res='' for c in unicode.chars(s) do res=res..(to_halfwidth[c] and to_halfwidth[c] or c)end return res end)
    jps = exp_multi_digit:sub(jps, function(s) res='' for c in unicode.chars(s) do res=res..(to_halfwidth[c] and to_halfwidth[c] or c)end return res end)
    return zhs..sep..jps
end

function replace_space(text)
    text = exp_fwsp:sub(text, ' ')
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
                nt = replace_digits(nt)
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
