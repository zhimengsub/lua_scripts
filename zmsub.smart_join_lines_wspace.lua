local tr = aegisub.gettext

script_name = tr("织梦.智能合并对话 (空格分隔)")
script_description = tr("合并多行时，按\\N区分，把中文和日文分别合并至各自部分")
script_author = "谢耳朵w"
script_version = "0.3"

require 'zmsub_utils.smart_join_lines'

function smart_join_2(subs, sels)
    return smart_join_lines(subs, sels, ' ')
end

aegisub.register_macro(script_name, script_description, smart_join_2)
