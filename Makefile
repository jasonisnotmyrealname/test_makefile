#本文参考http://www.ruanyifeng.com/blog/2015/02/make.html

#make在linux中的usr/bin中

ifeq ($(wildcard .git),)   #wildcard为通配符，相当于*.git，$为引用make变量或者调用内置函数（注意不是shell指令）。ifeq表示if equal
    $(error YOU HAVE TO USE GIT TO DOWNLOAD THIS REPOSITORY. ABORTING.)
endif

##测试用例1
.PHONY:b  #这是一个label(伪目标)
b:
	touch b

a: b #这是第一个target，如果make指令后面什么都没有，则make生成a
	touch $@   #touch:新建一个文件,这里的‘$@’指target
	echo "hahaha" > $@ 

##测试用例2
srcfiles := $(wildcard *.txt)   #查找所有的.txt文件，注意bash中的通配符*在变量赋值时无法展开(比如srcfiles = *.txt，得到的srcfiles就是'*.txt'，而不是所有的txt文件名。这时候需要用wildcard指令展开*.txt)，
all: 
	@echo "Nothing happened,because there is no prerequisites"  
	@echo "Write something to a text file"  > source.txt
	@echo ${srcfiles}  #打印所有的后缀名为txt的文件

##测试用例3
var = hello
test: 
	#这是测试，本条注释也会被输出
	@#加了'@'就不会被输出了
	@echo TODO
	@echo ${var}
	@echo $$HOME


##测试用例4
FIRST_ARG := $(firstword $(MAKECMDGOALS))
define cmake-build   #定义一个命令包
@set PX4_CONFIG = hello  #这是一个shell指令
@$(shell set PX4_CONFIG = hehe)  #和上面是一个作用,在make中调用shell内置函数
@$(eval PX4_CONFIG = $(1))  #$(1)表示该命令包被调用时的第一个参数，这里PX4_CONFIG是一个Make变量，而不是shell变量。在define中不能写PX4_CONFIG = hello这种
@echo ${PX4_CONFIG}  #引用make变量，名字为PX4_CONFIG
@echo PX4_CONFIG  #引用shell变量，名字也为PX4_CONFIG，和上面的make变量不在一个空间
endef

ALL_CONFIG_TARGETS := t1 t2 t3  #执行:make t1 t2 t3;或者make t1
$(ALL_CONFIG_TARGETS):
	$(call cmake-build, $@)   #$@表示把ALL_CONFIG_TARGETS的每一项目都依次代入到cmake-build中

test_firstword:
	@echo ${FIRST_ARG}
	$(call cmake-build, hi)  #hi作为第一个参数传递给cmake-build
	