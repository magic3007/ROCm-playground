run.hip:
	hipcc -o HelloWorld HelloWorld.hip && ./HelloWorld

run.cuda:
	hipify vector_addition.cu -o vector_addition.hip && hipcc -o vector_addition vector_addition.hip && ./vector_addition
