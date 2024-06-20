# Spectrum-Compatible Ground Motion Generation for Eurocode 8 Safety Check
<p align="justify">
This program creates a set of spectrum-compatible ground motions from a given database that contains more than 8000 recorded accelerograms. The aim of this program is to make sets of accelerogram that can be used for safety checks according to <em> Eurocode 8: Design of structures for earthquake resistance - Part 1 : General rules, seismic actions and rules for buildings.</em> (a.k.a., EC8)

The program will produce for you a folder in which the set is saved. By running the case with the default values and parameters, you'll get:
  
![spectra](https://user-images.githubusercontent.com/27778212/126907291-b246fab6-b5ed-4452-b6e1-ab8cc52ab93e.png)

In order to successfully run this Matlab script, you need to download the following archive:

<a href="https://drive.google.com/open?id=17HCFzHRFHDPMOKp3tyNP51tiQoR6Gj5K&usp=drive_fs">archive.mat</a> (1.32 GB and it containes a 8510 accelerograms and their synthetic description). 

<a href="https://drive.google.com/open?id=1FAqECtXcqnlCBOALgAzDVKUXI0zCihJ7&usp=drive_fs">archiveSpectra.mat!</a> (20 MB and it containes the spectra calcutated at a 3% damping). 

Then copy this file.mat into the folder you cloned from this repository. The archive contains 8510 raw ground motions, related to more than 3000 events, along with their elastic response spectra. You need the following class as well: elasticSpectrum <a href="https://github.com/btagliafierro/EC8Spectra/blob/master/elasticSpectrum.m">elasticSpectrum!</a>

Please feel free to report any issue you may find. The code's been tested with Matlab2021a, and it works as intended.

I am building a new archive at the moment, which will contain more than 100.000 post-processed spectrum to be made available soon.
</p>
