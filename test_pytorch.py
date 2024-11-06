import torch

if torch.cuda.is_available() and torch.version.hip:
    # do something specific for HIP
    print("HIP")
elif torch.cuda.is_available() and torch.version.cuda:
    print("CUDA")

