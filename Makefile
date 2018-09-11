#本文参考http://www.ruanyifeng.com/blog/2015/02/make.html

ifeq ($(wildcard .git),)   #wildcard为通配符，相当于*.git，$为引用。ifeq表示if equal
    $(error YOU HAVE TO USE GIT TO DOWNLOAD THIS REPOSITORY. ABORTING.)
endif

.PHONY:b  #这是一个label(伪目标)
b:
	touch b

a: b #这是第一个target，如果make指令后面什么都没有，则make生成a
	touch $@   #touch:新建一个文件,这里的‘$@’指target
	echo "hahaha" > $@ 

srcfiles := $(wildcard *.txt)   #查找所有的.txt文件，注意bash中的通配符*在变量赋值时无法展开(比如srcfiles = *.txt，得到的srcfiles就是'*.txt'，而不是所有的txt文件名。这时候需要用wildcard指令展开*.txt)，
all: 
	@echo "Nothing happened,because there is no prerequisites"  
	@echo "Write something to a text file"  > source.txt
	@echo ${srcfiles}  #打印所有的后缀名为txt的文件

var = hello

test: 
	#这是测试，本条注释也会被输出
	@#加了'@'就不会被输出了
	@echo TODO
	@echo ${var}
	@echo $$HOME