 # lua_scripts

组内用于Aegisub的实用lua脚本


## 安装方式

在[release的最新版本](https://github.com/zhimengsub/lua_scripts/releases/latest)中下载`zhimengsub_lua_scripts_<发布时间>.zip`

解压后，把所有lua脚本和`zmsub_utils`文件夹放入`<aegisub安装目录>\automation\autoload`内，重新启动`aegisub`即可。

## 脚本功能介绍

### 织梦.对白处理(2304) (选中行) `zmsub.set_tags_for_dialogues.lua`

配合'织梦-对白-2304'样式使用，为选中的`中字\N日字`格式的对白添加特效，并规范空格、数字宽度。

可以放心对已经添加过特效的行再次执行脚本，不用担心重复添加特效标签。

   

### 织梦.对白处理.拆解步骤 `zmsub.newline-space-processor-selected.lua`

"织梦.对白处理(2304) (选中行)" 脚本按顺序依次执行了下面几个功能，你可以按需手动运行其中的步骤。

>  一般不需要用到，就算只做了下面的部分步骤（如已经插入日字特效，需要单独插入模糊阴影），直接运行"织梦.对白处理(2304) (选中行)"也可以达到目的。

1. 插入日字特效

    为选中的`中字\N日字`格式插入`{\fnSource Han Sans JP Bold\fs55\fsvp10}`，并删掉头尾的换行符

2. 插入模糊阴影(2304)

    每行开头插入`\blur3\yshad2.5\xshad1.5`特效

3. 规范空格、数字宽度

    全角空格替换为半角、多个连续空格替换为一个空格；
    
    对白（中日分别处理）只有一位数字则设为全角，两位以上数字则全部设为半角。



### 织梦.歌词排序

 1. 按语言聚集 `zmsub.lyric_sort_by_lang.lua`

     选中按时间交错排序的双字台词，会把台词按语言拆为两块

 2. 按时间交错 `zmsub.lyric_sort_by_time.lua`

     选中按语言聚集排序的双字台词，会把前半部分和后半部分交错在一起
     
        

### 织梦.智能合并对话 `zmsub.smart_join_lines_wspace.lua`、`zmsub.smart_join_lines_nospace.lua`

直接合并多行已处理过的对白。按\N区分，把中文和日文分别合并至各自部分，并保留`模糊阴影(2304)`特效。

合并时的分隔符分为`空格`或`不含分隔符`。

