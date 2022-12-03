local tr = aegisub.gettext

script_name = tr"插入日字特效 (选中行)"
script_description = tr"把台词中的\\N替换为\\N{\\fnSource Han Sans JP Bold\\fs50\\fsvp10}"
script_author = "谢耳朵w"
script_version = "0.2"

re = require 'aegisub.re'
exp = re.compile('\\\\N')
exp_exist = re.compile('\\\\N{\\\\fnSource Han Sans JP Bold\\\\fs50\\\\fsvp10}')

function insert_sep(subs, sels, curr)
    normalsels = {}
    errsels = {}
    for _, i in ipairs(sels) do
        local line = subs[i]
        if not exp_exist:match(line.text) then
            t = exp:sub(line.text, '\\\\N{\\\\fnSource Han Sans JP Bold\\\\fs50\\\\fsvp10}')
            if t == line.text then
                -- not found any \N
                table.insert(errsels, i)
                line.comment = true
            else
                table.insert(normalsels, i)
            end
            line.text = t
            subs[i] = line
        end
    end
    out = ""
    if #errsels > 0 then
        for _, i in ipairs(errsels) do
            out = out .. i .. ": " .. subs[i].text .. "\n"
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
