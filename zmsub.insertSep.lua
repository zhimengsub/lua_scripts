local tr = aegisub.gettext

script_name = tr"插入日字特效 (选中行)"
script_description = tr"把台词中的\\N替换为\\N{\\fnSource Han Sans JP Bold\\fs50\\fsvp10}。换行符匹配[\\/]+N+形式，并删掉头尾的换行符"
script_author = "谢耳朵w"
script_version = "0.4.2.001"

re = require 'aegisub.re'
exp_newline = re.compile('[\\\\/]+N+')
exp_skip = re.compile('\\\\N{\\\\fnSource Han Sans JP Bold.*?\\}')
exp_lstrip = re.compile('^[\\\\/]+N+')
exp_rstrip = re.compile('[\\\\/]+N+$')

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

function replace_until_same(text, exp, newtxt)
    local ot = text
    repeat 
        ot = text
        text = exp:sub(text, newtxt)
    until ot == text
    return text
end

function insert_sep(subs, sels, curr)
    local offset = linenum_offset(subs)
    local normalsels = {}
    local errsels = {}
    for _, i in ipairs(sels) do
        local line = subs[i]
        if not exp_skip:match(line.text) then
            -- strip \N
            line.text = replace_until_same(line.text, exp_lstrip, '')
            line.text = replace_until_same(line.text, exp_rstrip, '')
            local matches = exp_newline:find(line.text)
            if not matches or #matches > 1 then
                -- error, found multiple '\N'-like, or not found any '\N'-like
                table.insert(errsels, i)
                line.comment = true
            else
                -- found only one '\N'-like
                t = exp_newline:sub(line.text, '\\\\N{\\\\fnSource Han Sans JP Bold\\\\fs50\\\\fsvp10}')
                table.insert(normalsels, i)
                line.text = t
            end
            subs[i] = line
        end
    end
    local out = "Format errors:\n"
    if #errsels > 0 then
        for _, i in ipairs(errsels) do
            out = out .. i-offset .. ": " .. subs[i].text .. "\n"
        end
        aegisub.debug.out(out)
        aegisub.debug.out('These lines will be selected and commented out!')
    end
    aegisub.set_undo_point(script_name)
    if #errsels > 0 then
        return errsels
    else
        return normalsels
    end
end

aegisub.register_macro(script_name, script_description, insert_sep)
