#本文参考http://www.ruanyifeng.com/blog/2015/02/make.html
#参考:<跟我一起写Makefile>
#注:make在linux中的usr/bin中

#makefile的语法:
##target ... : prerequisites ...
##	command

#makefile的执行方式就是make target。也可以有多个target一起执行，比如make target1 target2 ....

#在make过程中如果要打印某个make变量，用echo。

##测试用例0:wildcard, ifeq
ifeq ($(wildcard .git),)   #wildcard为通配符，相当于*.git，$为引用make变量或者调用内置函数（注意不是shell指令）。ifeq表示if equal
    $(error YOU HAVE TO USE GIT TO DOWNLOAD THIS REPOSITORY. ABORTING.)
endif

##测试用例1:PHONY
.PHONY:b  #这是一个label(伪目标)
b:
	touch b

a: b #这是第一个target，如果make指令后面什么都没有，则make生成a
	touch $@   #touch:新建一个文件,这里的‘$@’指target
	echo "hahaha" > $@ 


##测试用例2: @、echo
var = hello
test: 
	#这是测试，本条注释也会被输出
	@#加了'@'就不会被输出了
	@echo TODO
	@echo ${var}
	@echo $$HOME


##测试用例3:wildcard
srcfiles := $(wildcard *.txt)   #查找所有的.txt文件，注意bash中的通配符*在变量赋值时无法展开(比如srcfiles = *.txt，得到的srcfiles就是'*.txt'，而不是所有的txt文件名。这时候需要用wildcard指令展开*.txt)，
all: 
	@echo "Nothing happened,because there is no prerequisites"  
	@echo "Write something to a text file"  > source.txt
	@echo ${srcfiles}  #打印所有的后缀名为txt的文件


##测试用例4: call、eval
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

#测试用例5:MAKEFILE_LIST
#参考https://ftp.gnu.org/old-gnu/Manuals/make/html_node/make_17.html
include ./tt/inc.mk  #包含一个新的makefile,那么这个makefile的名称将被append到MAKEFILE_LIST的末端
SRC_DIR := $(MAKEFILE_LIST)  #当前的所有的makefile名称
SRC_DIR := $(lastword $(MAKEFILE_LIST))  #最后一个makefile的名称
SRC_DIR := $(realpath $(lastword $(MAKEFILE_LIST)))  #最后一个makefile的路径(含makefile名称)
SRC_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))  #最后一个makefile的路径(不含makefile名称)
.PHONY: testMAKEFILELIST
testMAKEFILELIST:
	@echo $(MAKEFILE_LIST)
	@echo $(SRC_DIR)

#测试用例6:MAKECMDGOALS
FIRST_ARG := $(firstword $(MAKECMDGOALS))   #测试:make testMAKECMDGOALS hh
ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
.PHONY: testMAKECMDGOALS hh
testMAKECMDGOALS:
	@echo $(FIRST_ARG)
hh:
	@echo $(FIRST_ARG)
	@echo ${ARGS}
	@echo ${MAKE}  #用{}或者()表示引用都行