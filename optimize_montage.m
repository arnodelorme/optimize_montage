% ----------
% Parameters
% ----------

montage = 'besa'; % use BESA or BEM
nchan   = 32;     % number of channels in final montage
ignoreChans  = { 'AF9' 'AF10' }; % list of channels to ignore (because not possible for some reasons)
ignore10_5   = true; % Ignore most 10_5 specific channel (those postfixed with "h"), only consider 10-10 channels
includeChans = { 'FP1','FP2','F3','F4','C3','C4','P3','P4','O1','O2','F7','F8','T3','T4','T5','T6','FZ','CZ','PZ' }; % includeChans = { 'FPz' 'CZ' 'Iz' }; % minimalist
replaceChans = { }; % provide list of channels to replace at the end, one per row replaceChans = { 'CP6' 'FC6'; 'CP5' 'FC5' } 

% -----------------
% End of parameters
% -----------------

% Copyright (C) 2021 Arnaud Delorme
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
%
% 1. Redistributions of source code must retain the above copyright notice,
% this list of conditions and the following disclaimer.
%
% 2. Redistributions in binary form must reproduce the above copyright notice,
% this list of conditions and the following disclaimer in the documentation
% and/or other materials provided with the distribution.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
% THE POSSIBILITY OF SUCH DAMAGE.

try
    eeglab; close;
catch
    error('make sure to add EEGLAB to your path');
end

% load channels
dipfitdefs;
if strcmpi(montage, 'besa')
    template_file = template_models(1).chanfile; % 1 is besa and 2 is BEM montage (realistic)
    chansTemplate = readlocs(template_file);
else
    template_file = template_models(2).chanfile; % 1 is besa and 2 is BEM montage (realistic)
    chansTemplate = readlocs(template_file);
    
    % need 90 degrees rotation
    chaninfo.nosedir = '+Y';
    EEG = eeg_emptyset;
    [EEG.chanlocs  EEG.chaninfo] = eeg_checkchanlocs(chansTemplate, chaninfo);
    
    EEG.nbchan = length(EEG.chanlocs);
    EEG.data = zeros(EEG.nbchan,10);
    EEG = eeg_checkset(EEG);
    chansTemplate = EEG.chanlocs;
end

% remote EOGs and fiducials
eogChans = strmatch('EOG', { chansTemplate.type }, 'exact');
fidChans = strmatch('FID', { chansTemplate.type }, 'exact');
chansTemplate([fidChans; eogChans]) = [];

% remove other channels
indRm = [];
for ind = 1:length(ignoreChans)
    indTmp = strmatch(ignoreChans{ind}, {chansTemplate.labels}, 'exact');
    indRm = [ indRm indTmp ];
end
chansTemplate(indRm) = [];

% remove 10-5 channels
if ignore10_5
    indRm = [];
    for iChan = 1:length(chansTemplate)
        if chansTemplate(iChan).labels(end) == 'h'
            indRm = [ indRm iChan];
        end
    end
    chansTemplate(indRm) = [];
end

% find addition channels
while length(chans) < nchan
    [~,ind1,~] = intersect_bc(lower({ chansTemplate.labels }), lower(chans));
    chansChoosen    = chansTemplate(ind1);
    chansNotChoosen = chansTemplate(setdiff(1:length(chansTemplate), ind1));
    
    allDots = zeros(length(chansChoosen),length(chansNotChoosen));
    for iChan1 = 1:length(chansChoosen)
        for iChan2 = 1:length(chansNotChoosen)
            % compute angles between all pairs of channels
            c1 = chansChoosen(   iChan1);
            c2 = chansNotChoosen(iChan2);
            allDots(iChan1,iChan2) = c1.X*c2.X + c1.Y*c2.Y + c1.Z*c2.Z;
            mag1 = sqrt(c1.X.^2 + c1.Y.^2 + c1.Z.^2);
            mag2 = sqrt(c2.X.^2 + c2.Y.^2 + c2.Z.^2);
            allDots(iChan1,iChan2) = acos(allDots(iChan1,iChan2)/mag1/mag2);
        end
    end
    
    % Choose the channels with minimum angles
    maxDot = min(allDots);
    
    % Among those choose the channel with the maximum change
    [~,minChan] = max(maxDot);
    fprintf('Adding channel %s (%d)\n', chansNotChoosen(minChan).labels, minChan);
    
    % Add to the list of channels
    chans = [ chans chansNotChoosen(minChan).labels ];
end

% replace channel
for ind = 1:length(replaceChans)
    chans(strmatch(replaceChans{ind,1}, chans, 'exact')) = { replaceChans{ind,2} };
end

% plot results
[~,ind1,~] = intersect_bc(lower({ chansTemplate.labels }), lower(chans));
chansChoosen    = chansTemplate(ind1);
figure; topoplot([], chansChoosen, 'style', 'blank',  'electrodes', 'labelpoint');
setfont(gcf, 'fontsize', 14);

