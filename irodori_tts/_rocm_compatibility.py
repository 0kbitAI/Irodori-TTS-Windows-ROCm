import types
import torch

# Stub torch.distributed for Windows ROCm where distributed features are not implemented.
# This prevents audiotools from raising an AttributeError during import.
if not hasattr(torch, "distributed"):
    torch.distributed = types.ModuleType("distributed")

if not hasattr(torch.distributed, "ReduceOp"):
    class DummyReduceOp:
        SUM = AVG = PRODUCT = MIN = MAX = BAND = BOR = BXOR = "UNUSED"
    torch.distributed.ReduceOp = DummyReduceOp