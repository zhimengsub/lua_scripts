local tr = aegisub.gettext

script_name = tr"插入日字特效 (选中行)"
script_description = tr"把台词中的\\N替换为\\N{\\fnSource Han Sans JP Bold\\fs50\\fsvp10}"
script_author = "谢耳朵w"
script_version = "0.3"

re = require 'aegisub.re'
exp = re.compile('\\\\+N+')
exp_skip = re.compile('\\\\N{\\\\fnSource Han Sans JP Bold\\\\fs50\\\\fsvp10}')

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

function insert_sep(subs, sels, curr)
    offset = linenum_offset(subs)
    normalsels = {}
    errsels = {}
    for _, i in ipairs(sels) do
        local line = subs[i]
        if not exp_skip:match(line.text) then
            matches = exp:find(line.text)
            if #matches > 1 then
                -- found multiple '\N' like
                table.insert(errsels, i)
                line.comment = true
            else
                t = exp:sub(line.text, '\\\\N{\\\\fnSource Han Sans JP Bold\\\\fs50\\\\fsvp10}')
                if t == line.text then
                    -- not found any '\N' like
                    table.insert(errsels, i)
                    line.comment = true
                else
                    table.insert(normalsels, i)
                end
                line.text = t
            end
            subs[i] = line
        end
    end
    out = "Format errors:\n"
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
