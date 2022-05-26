## idea必要设置：
1 注释格式修改：
setting->editor->code style->java->code generation->右下角 comment code
                    取消勾选 Line comment at first line 勾选 Add a space at comment start(xml同理)
                                 ->spaces->other->取消勾选after type cast
                                 ->tabs and indents->勾选use tab character

                                 ->JavaDoc->Blank lines-> 取消勾选 After Description
2 文件格式修改
editor->file encoding->所有GBK改成UTF-8
      ->SSH Terminal 同上

3 vmoptions
安装目录bin/和缓存配置目录config/下的idea64.exe.vmoptions 、 idea.exe.vmoptions添加
-Dfile.encoding=UTF-8
2018.3-：-javaagent:D:\JetBrains\jetbrains-agent.jar
2019.3-安装jetbrains-agent.jar插件
2020.3-安装BetterIntelliJ插件

4 推荐几个注释模板和groovyScript脚本
1)
private static final long serialVersionUID = $rand$L;
2)
private Logger logger = LoggerFactory.getLogger($clazzName$.class);
3)
/**
 * @description $desc$
 * @author yourName
 * @date $date$ $time$
 */
4)
/*===========================$fieldName$===========================*/
5)
List<$type$> $typeCamel$List = new ArrayList<>();
Set<$type$> $typeCamel$Set = new HashSet<>();
Map<$type1$, $type2$> $mapName$Map = new HashMap<>();
Map<String, $type$> $typeCamel$Map = new HashMap<>();
Map<String, Object> $mapName$ = new HashMap<>();

5 实用插件
antiBPM
Alibaba Java Coding Guidelines
CamelCase
GitToolBox
SvnToolBox
JRebel And XRebel For IdealiJ
RestfulToolkit
Vue.js
Lombok
MybatisCodeHelperPro
Statistic
Ini
codota ai autocomplete

camelCase(type)

-)
snakeCase(substringBefore(fileName(), ".java")); 获取文件名
groovyScript("_1.toUpperCase()",snakeCase(substringBefore(fileName(), ".java"))); 获取文件名
groovyScript("Math.abs(new Random().nextLong())"); 随机long

5 setting->editor->File And Code Template->Includes->File Header  可以新建类自动加注释：
/**
 * @author bonelf
 * @date ${DATE} ${TIME}
 */
   
## 技巧
####1 
ctrl + enter terminal 保存到configuration中

Q:
idea解决Command line is too long. Shorten command line for ServiceStarter or also for Application报错
1 找到 .idea\workspace.xml。
找到<component name="PropertiesComponent">，在里面添加<property name="dynamic.classpath" value="true" />即可

2 或者：启动配置项 -> shorten command line 选项选择 classpath file 或 java manifest 选项 -> 重新启动工程运行

Q： Slf4j(lombok) 找不到变量 log

A：Annotation Processors 勾选 Enable ..