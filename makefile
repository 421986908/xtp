CC = g++ -m64
AR = ar
LD = ld
WAY = execute
CC_FLAG = -g #-fPIC
CPP_FLAG = -g
 
INC = -I ./include
LIB = -L ./bin/linux -lxtpquoteapi


SRC = $(wildcard $(shell pwd)/src/*.c)
PC_SRC = $(wildcard $(shell pwd)/*.pc)
CPP_SRC = $(wildcard $(shell pwd)/src/*.cpp)
OBJ = $(patsubst %.c,%.o,$(SRC))
PC_OBJ = $(patsubst %.pc,%.o,$(PC_SRC))
CPP_OBJ = $(patsubst %.cpp,%.o,$(CPP_SRC))

TARGETPATH = ./bin/linux/
TARGET = a.out

#多目标编译方式
#TARGETPATH = 
#TARGET = $(patsubst %.c, %, $(SRC))
 
ifeq ($(WAY),staticlibrary)
all:$(OBJ) $(PC_OBJ) $(CPP_OBJ)
	${AR} rv $(TARGETPATH)/${TARGET} $?
endif

ifeq ($(WAY),dynamiclibrary)
all:$(OBJ) $(PC_OBJ) $(CPP_OBJ)
	$(CC) $? -shared -o $(TARGETPATH)/$(TARGET)
endif

ifeq ($(WAY),execute)
all:$(OBJ) $(PC_OBJ) $(CPP_OBJ)
	$(CC) $(LIB) $? -o $(TARGETPATH)/$(TARGET)
endif

ifeq ($(WAY),multipletarget)
all:$(TARGET)
$(TARGET):%:%.o
	$(CC) $< $(LIB) -o $@
	mv $@ $(TARGETPATH)
endif

$(OBJ):%.o:%.c
	$(CC) $(CC_FLAG) $(INC) -c $< -o $@

$(CPP_OBJ):%.o:%.cpp
	$(CC) $(CPP_FLAG) $(INC) -c $< -o $@

$(PC_OBJ):%.o:%.pc
	proc $(CCOMPSWITCH) include=$(TOPDIR)/include iname=$< oname=$(patsubst %.pc,%.c,$<) code=ANSI_C USERID=$(DBUSER)/$(DBPASSWD) DYNAMIC=ANSI
	$(CC) $(CC_FLAG) $(INC) -c $(patsubst %.pc,%.c,$<) -o $@
	rm $(patsubst %.pc,%.lis,$<) $(patsubst %.pc,%.c,$<)

.PRONY:clean
clean:
	@echo "Removing linked and compiled files......"
	rm -f $(OBJ) $(PC_OBJ) $(CPP_OBJ) $(TARGETPATH)/$(TARGET)
