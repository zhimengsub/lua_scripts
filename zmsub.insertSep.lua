local tr = aegisub.gettext

script_name = tr"插入日字特效 (选中行)"
script_description = tr"把台词中的\\N替换为\\N{\\fnSource Han Sans JP Bold\\fs50\\fsvp10}"
script_author = "谢耳朵w"
script_version = "0.1"

re = require 'aegisub.re'
exp = re.compile('\\\\N')
exp_exist = re.compile('\\\\N{\\\\fnSource Han Sans JP Bold\\\\fs50\\\\fsvp10}')

function paste_tags(subs, sels, curr)
    same = {}
    for _, i in ipairs(sels) do
        local line = subs[i]
        if not exp_exist:match(line.text) then
            t = exp:sub(line.text, '\\\\N{\\\\fnSource Han Sans JP Bold\\\\fs50\\\\fsvp10}')
            if t == line.text then
                table.insert(same, i)
            end
            line.text = t
            subs[i] = line
        end
    end
    out = ""
    if #same > 0 then
        for _, i in ipairs(same) do
            out = out .. i .. ": " .. subs[i].text .. "\n"
        end
        aegisub.debug.out(out)
    end
    aegisub.set_undo_point(script_name)
end

aegisub.register_macro(script_name, script_description, paste_tags)
