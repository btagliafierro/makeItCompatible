# makeItCompatible
<p align="justify">
This program creates a set of spectrum-compatible ground motions from a given database that contains more than 8000 recorded accelerograms. The aim of this program is to make sets of accelerogram that can be used for safety checks according to <em> Eurocode 8: Design of structures for earthquake resistance - Part 1 : General rules, seismic actions and rules for buildings.</em> (a.k.a. EC8)

The program will produce for you a folder in which the set is saved. By running the case with the default values and parameters, you'll get:
  
![spectra](https://user-images.githubusercontent.com/27778212/126907291-b246fab6-b5ed-4452-b6e1-ab8cc52ab93e.png)

In order to successfully run this Matlab script, you need to download the following archive:   <a href="https://drive.google.com/open?id=1Vp-eV-uJSjAuZWjb6-XMZbjVAFajxbe2&authuser=btagliafierro%40unisa.it&usp=drive_fs">link!</a> (1.37 GB). Then copy this file.mat into the folder you cloned from this repository. The archive contains 8510 raw ground motions, related to more than 3000 events, along with their elastic response spectra.

Please feel free to report any issue you may find. The code's been tested with Matlab2021a, and it work as intended.

I am building a new archive at the moment, which will contain more than 100.000 post-processed spectrum to be made available soon.
</p>
