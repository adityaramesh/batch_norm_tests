# Overview

The goal of this repository is to answer the following questions via evaluation
on SVHN:

- Regarding performance optimization:
  - What's the penalty for forming the mini-batches on the fly? If there is a
  noticeable penalty, we should preshuffle the training instances.
  - A: I couldn't find any measurable difference between using `JoinTable` and
  directly transferring the images from the original array.

  - YUV vs LAB: is there a noticeable difference? If so, which is better?
  - What's the benefit of using GCN/LCN:
    - Independently?
    - Together?
    - Does avoiding LCN on the luma channel help?
    - Affect with/without whitening (find the best PP scheme without whitening
    first)?
    - I think it makes more sense to use GCN/LCN before whitening. This would
    also mean that we have to regenerate the data on vines (again).

  - Which value of epsilon to use for batch normalization? Is performance
  sensitive to the chosen value of epsilon?
  - If whitening helps alone, does it still help if we use batch normalization?
  - Does batch normalization hurt or help with dropout?
  - Does dropout with small probability for the convolutional layers (as Sergey
  does) help? If so, does SpatialDropout provide a benefit over regular dropout
  here? (first check if using BN + dropout only on the FC layer helps; if not
  then don't pursue dropout for conv layers)

# Experiments

- Experiment 1: is YUV or LAB better? Is per-pixel or per-image GCN better?
  - RGB + per-pixel GCN + LCN
  - RGB + per-image GCN + LCN
  - YUV + GCN + LCN
  - LAB + GCN + LCN

- Experiment 2: which normalization scheme is best for SVHN?
  - no preprocessing
  - GCN
  - LCN
  - LCN (color channels only)
  - GCN + LCN
  - GCN + LCN (color channels only)
  - subtracting mean image

- Experiment 3: how to use whitening?
  - best scheme from experiment 2 (without whitening)
  - whitening raw image
  - whitening raw image with eps = 0.1
  - whitening normalized image
  - whitening normalized image with eps = 0.1

- Experiment 4: how to use batch normalization?
  - TODO plan this
