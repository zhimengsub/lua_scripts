local tr = aegisub.gettext

script_name = tr("检查换行|空格换为半角|规范数字宽度 (选中行)")
script_description = tr("检查选中行的换行符是否规范，如果不规范则设为注释；空格全部替换为半角，一句只有一位数字时替换为全角，否则所有数字替换为半角")
script_author = "谢耳朵w"
script_version = "0.2.001"

include("unicode.lua")
re = require 'aegisub.re'

exp_newline = re.compile("\\\\N(?=\\{\\\\fnSource Han Sans JP Bold)")
exp_fwsp = re.compile("　+")
exp_sep = re.compile("(.+)(\\\\N\\{\\\\fnSource Han Sans JP Bold.*?\\})(.+)")
-- exp_single_digit = re.compile("(?<!\\d)\\d(?!\\d)")
-- exp_multi_digit = re.compile("\\d{2,}")
exp_digit = re.compile("\\d")
exp_tag = re.compile("(\\{[^{}]*\\})")

to_fullwidth = {['1'] = '１', ['2'] = '２', ['3'] = '３', ['4'] = '４', ['5'] = '５',
                ['6'] = '６', ['7'] = '７', ['8'] = '８', ['9'] = '９', ['0'] = '０'}
to_halfwidth = {['１'] = '1', ['２'] = '2', ['３'] = '3', ['４'] = '4', ['５'] = '5',
                ['６'] = '6', ['７'] = '7', ['８'] = '8', ['９'] = '9', ['０'] = '0'}

function linenum_offset(subs)
    local offset = 0
    for i = 1, #subs do
        if subs[i].class ~= "dialogue" then
            offset = i
        else
            break
        end
    end
    return offset
end

function process_partial_digits(text)
    local in_tags = false
    local res_hw = ""
    local res_fw = ""
    local cnt = 0
    for c in unicode.chars(text) do
        if c == "{" then
            in_tags = true
        end
        if in_tags or not exp_digit:find(c) then
            res_hw = res_hw .. c
            res_fw = res_fw .. c
        else
            cnt = cnt + 1
            res_hw = res_hw .. (to_halfwidth[c] and to_halfwidth[c] or c)
            res_fw = res_fw .. (to_fullwidth[c] and to_fullwidth[c] or c)
        end
        if c == "}" then
            in_tags = false
        end
    end
    if cnt >= 2 then
        -- 两位以上数字全部半角
        return res_hw
    end
    -- 只有一位数字则全角
    return res_fw
end

function process_digits(text)
    local res = exp_sep:match(text)
    -- 中文部分
    local zhs = res[2]['str']
    -- 换行符+特效
    local sep = res[3]['str']
    -- 日文部分
    local jps = res[4]['str']

    zhs = process_partial_digits(zhs)
    jps = process_partial_digits(jps)
    return zhs..sep..jps
end

function replace_space(text)
    local text = exp_fwsp:sub(text, ' ')
    return text
end

function is_single_newline(text)
    local matches = exp_newline:find(text)
    if not matches or #matches>1 then
        return false
    end
    return true
end

function process_lines_selected(subtitles, selected_lines, active_line)
    local offset = linenum_offset(subtitles)
    local sels = {}
    local errsels = {}
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
                nt = process_digits(nt)
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
