# Uncovering Stress Fields and Defect Distributions in Graphene Using Deep Neural Networks

This repository contains several MATLAB scripts used to generate LAMMPS data/input files as well as postprocessing the numerical results of the simulations (i.e., to transformed into image-based data) in our recent article in the [International Journal of Fracture (2023)](https://doi.org/10.1007/s10704-023-00704-z). A video abstract of the article is [available here](https://youtu.be/cUXWU6oaud4).

The architecture of the cGAN is shown in Fig. 3a. The generator is trained to produce images that the discriminator cannot distinguish from real images. The discriminator is adversarially trained to distinguish between predicted images (Fig. a) and real images (Fig. b). 

 <img src="CGAN architecture.JPG" width="600">

The trained neural networks and the complete data set are freely [available here](https://doi.org/10.5281/zenodo.7834444).
