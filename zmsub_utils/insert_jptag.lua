-- version 0.4.4

re = require 'aegisub.re'

exp_jptag = re.compile('\\\\N{\\\\fnSource Han Sans JP Bold.*?\\}')
-- 增加容错性，防止校对手滑写错符号导致错误
exp_newline = re.compile('[\\\\/]+N+')
exp_lstrip_nl = re.compile('^[\\\\/]+N+')
exp_rstrip_nl = re.compile('[\\\\/]+N+$')

new_jptag = '\\\\N{\\\\fnSource Han Sans JP Bold\\\\fs55\\\\fsvp10}'

function replace_until_same(text, exp, newtxt)
    local ot = text
    repeat 
        ot = text
        text = exp:sub(text, newtxt)
    until ot == text
    return text
end

-- 把台词中的\\N替换为\\N{\\fnSource Han Sans JP Bold\\fs55\\fsvp10}。换行符匹配[\\/]+N+形式，并删掉头尾的换行符
function insert_jptag(line)
    if exp_jptag:match(line.text) then
        -- 已存在类似日字特效，替换为新版
        line.text = exp_jptag:sub(line.text, new_jptag)
        return true
    else
        -- 不存在特效，在\N后添加特效标签
        -- 去除开头和结尾多余的\N
        line.text = replace_until_same(line.text, exp_lstrip_nl, '')
        line.text = replace_until_same(line.text, exp_rstrip_nl, '')

        -- 寻找句中的\N
        local matches = exp_newline:find(line.text)
        if not matches or #matches > 1 then
            -- 错误, 不存在'\N'或存在多个\N
            return false
        else
            -- 只有一个\N，替换为新特效标签
            line.text = exp_newline:sub(line.text, new_jptag)
            return true
        end
    end
end