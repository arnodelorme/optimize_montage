# Optimize montage
 
This program uses EEGLAB to create a montage where electrodes are as far from each other as possible. For 
source localization, it is ideal to have a good head coverage.
 
The program uses electrode in the 10-5 notation but could use other
type of template montage.
 
# Dependencies
 
This program requires MATLAB and [EEGLAB](https://eeglab.org/) to be installed.
 
# Usage
 
Edit the file optimize_montage.m and change parameters.
The parameters are as follow:
- montage: 'besa' (spherical head model) or 'BEM' (realistic coordinates). 'besa' is preferable because positions are defined mathematically.
- nchan: number of channels in the final montage
- includeChans: list of channels to include in the montage. Sometimes you might want to include specific channels in your montage.
- ignoreChans: list of channels to ignore (because not practical for some reasons)
- ignore10_5: when true, ignore most 10_5 specific channel (those postfixed with "h"), only consider 10-10 channels
- replaceChans: provide list of channels to replace at the end, one per row replaceChans = { 'CP6' 'FC6'; 'CP5' 'FC5' }
 
# Example

This figure is obtained using the default values in optimize_montage.m

![](example_montage.png)

# Acknowledgements

Thanks to Robert Oostenveld for fruitful discussions.

Robert agrees thta he would go rather for a montage that has low coverage over one that has dense coverage at the top. The bottom electrodes capture a lot of depth information which are useful for source localization. He also mentions an old paper about he could not remember the exact reference (might be Scherg and/or Berg or so).

He would not include I1 and I2. Iz is ok (the inion is bony), but with I1 and I2 you know that more or less for sure that they end up on the muscle. Unless you want to capture neck tension of course (and there might be a good reason for that).

Robert would use FCz as ground and TP9 or TP10 (or the corresponding M1 or M2) as online reference.

# Other similar projects

The [Easycap ressource](https://www.easycap.de/wp-content/uploads/2018/02/Easycap-10-based-electrode-layouts.pdf) contains layouts that others have already thought about. Some of them are more explicit about the number of electrodes (including GND/REF, or DRL/CMS) versus the number of channels, but others are not so. The M24 montage includes 36 electrodes. The BESA EEG33 layout is another interesting montage. 

# Future directions

It would be good to make some 2D plots without the electrode labels (they can be confusing) and 3D renderings of multiple montages, and be able to toggle between alternatives like a flipbook.
