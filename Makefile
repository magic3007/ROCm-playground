run.hip:
	hipcc -o HelloWorld.exe HelloWorld.hip && ./HelloWorld.exe

run.cuda:
	hipify vector_addition.cu -o vector_addition.hip && hipcc -o vector_addition.exe vector_addition.hip && ./vector_addition.exe

.PHONY: build

build:
	mkdir -p build && cd build && cmake .. -DCMAKE_INSTALL_PREFIX=../install -DBOOST_ROOT=/datamy/test/projects/dreamplace.workspace/boost_1_86_0
