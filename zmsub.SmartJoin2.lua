local tr = aegisub.gettext

script_name = tr("智能合并对话 (含空格)")
script_description = tr("合并多行时，按\\N区分，把中文和日文分别合并至各自部分")
script_author = "谢耳朵w"
script_version = "0.2"

re = require 'aegisub.re'
pat = re.compile("(.+)(\\\\N\\{\\\\fnSource Han Sans JP Bold.*\\})(.+)")

function smartjoinlines(subs, sels)
    zhs = ''
    mid = ''
    jps = ''
    rm = {}
	for _, i in ipairs(sels) do
        if subs[i].class == "dialogue" then
            res = pat:match(subs[i].text)
            zhs = zhs .. ' ' .. res[2]['str']
            mid = res[3]['str']
            jps = jps .. ' ' .. res[4]['str']
            table.insert(rm, i)
        end
	end
    local first = table.remove(rm, 1)
    local edtime = subs[rm[#rm]].end_time
    subs.delete(rm)
    local nl = subs[first]
    nl.text = zhs .. mid .. jps
    if edtime > 0 then
        nl.end_time = edtime
    end
    subs[first] = nl

	aegisub.set_undo_point(script_name)
    return {first}
end

aegisub.register_macro(script_name, script_description, smartjoinlines)
