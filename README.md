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

- Experiment 1: which color scheme is best?
  - RGB (no preprocessing)
  - RGB + image-wide GCN
  - YUV + image-wide GCN
  - LAB + image-wide GCN

- Answer: GCN allowed the optimizer to make much more rapid progress.
Surprisingly, RGB was the most effective color scheme by a considerable margin.
At first, this seems somewhat counterintuitive, since LAB components are the
least correlated, at least for natural images. I suspect that this doesn't hold
for the house numbers. Since houses are designed by humans, the distribution of
the colors used may be better described using RGB than YUV and LAB.

- Experiment 2: how to do GCN?
  - best setting from experiment 1
  - best setting from experiment 1 using pixel-wide GCN
  - best setting from experiment 1 using image-wide GCN followed by pixel-wide GCN

- Answer: not clear which scheme is better. Will proceed with only image-wide
GCN for now. I would have expected image-wide and pixel-wide GCN to be better
than using either one individually, but I didn't really see any difference.

- Experiment 3: how to do LCN?
  - best setting from experiment 2
  - best setting with LCN
  - best setting with LCN (color channels only)
  - best setting with GCN + LCN
  - best setting with GCN + LCN (color channels only)

- Answer: GCN + LCN on all channels is best here.

- Experiment 4: how to do whitening?
  - best scheme from experiment 3 (no whitening)
  - whitening raw image with eps in [1e-1, 1e-3, 1e-5, 1e-7, 0]
  - whitening normalized image with eps in [1e-1, 1e-3, 1e-5, 1e-7, 0]

- Choosing epsilon too small results in garbage, but choosing epsilon
effectively does nothing. I couldn't visually see much effect until epsilon was
brought up to 0.1 or so. But for SVHN, using a value of epsilon this large
results in some of the images being garbage. There doesn't seem to be an
obvious way to choose epsilon based on the distribution of eigenvalues -- the
values corresponding to where the "tail" starts are all at least 100. I doubt
using values of epsilon this large would reallly do anything. Questions to answer:
  - Try epsilon = 0.1, 1, 5, 10, and the predicted value from the method that
  cuts off the tail. Which works best? Does using a large value of epsilon have
  any effect even though we don't visually see any change?

Note: using the "cutoff" technique in which we set the scale for all
eigenvalues that we believe are noise to 1 is not a good idea.

- Whitening seems to produce noisy junk for SVHN.
