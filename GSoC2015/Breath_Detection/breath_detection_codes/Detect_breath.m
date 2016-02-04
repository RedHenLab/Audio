%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%  Code to detect Breath segments in given audio signals  %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  Written on 02/08/2015  %%%%%%%%%%%%%%%%%%%%%

function [] = Detect_breath(datadir,outdir)

path1 = datadir;
foldet = dir(fullfile(path1,'*.wav'));
folnam = {foldet.name};
nf = length(folnam);

disp('Detecting breath segments');

for fileno = 1 : nf
    
    disp('Processing the file:');
    finame = folnam(fileno)
    fname = cell2mat(finame);
    filnam = sprintf('%s%s',path1,fname);
    fnam = fname(1:end - 4);
    outname = sprintf('%s%s%s',outdir,fnam,'.txt');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%  Read the sample values of audio files  %%%%%%%%%%%%%%%%%%%%
    
    [s_1,fs1] = wavread(filnam);
    s = s_1(:,1);
    s = resample(s,16000,fs1);
    len = length(s);
    s = s./max(abs(s));
    fs = 16000;
    
    %%%%%%%%%%%%%%%%%%%%%%%%  Extract GCI locations using ZFF method  %%%%%%%%%%%%%%%%%%%%
    
    [~,vnv,~,~,~,gci] = epochStrengthExtract_voc(s,fs);
    ngci = length(gci);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%  Code snippet to remove short segments detected using Zero frequency energy  %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    vnv_reg = vnv;
    vnv_reg(1) = 0;
    vnv_reg(end) = 0;
    
    vnv_diff = zeros(len,1);
    vnv_diff(2:end) = diff(vnv_reg);
    vnv_seg_st = find(vnv_diff == 1);
    vnv_seg_end = find(vnv_diff == -1);
    nsegs = length(vnv_seg_st);
    %     vnv_seg_dur = vnv_seg_end - vnv_seg_st;
    
    if nsegs >= 1
        
        for k = 1 : nsegs
            
            if vnv_seg_end(k) - vnv_seg_st(k) <= 800 %%% 800 samples = 50 msec
                
                vnv_reg(vnv_seg_st(k) : vnv_seg_end(k)) = 0;
                
            end
            
        end
        
    end
    
    vnv = vnv_reg;
    
    %%%%%%%%%%%%%%%%%%%%%%  calculation of DRF & DRS values  %%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%  DRF means Dominant resonance frequency  %%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%  DRS means dominant resonance strength  %%%%%%%%%%%%%%%%%%
    
    [s1,pos1,hngdM] = HNGDandMSSPs(s,fs,fs*0.01);
    
    drf_1 = pos1(:,1) * fs/(2 * 512);  %%%%  drf_1 = 1st DRF
    drf_1(end + 1 : len) = drf_1(end);
    drf = zeros(ngci,1);
    
    str_1 = s1(:,1);
    str_1(end + 1 : len) = str_1(end);
    str_2 = s1(:,2);
    str_2(end + 1 : len) = str_2(end);
    str1 = zeros(ngci,1);
    str2 = zeros(ngci,1);
    
    for k = 1 : ngci
        
        if gci(k) <= 16
            
            pos_part = drf_1(1 : gci(k) + 16);
            drf(k) = sum(pos_part)/(gci(k) + 16);
            str1_part = str_1(1 : gci(k) + 16);
            str2_part = str_2(1 : gci(k) + 16);
            str1(k) = sum(str1_part);
            str2(k) = sum(str2_part);
            
        else
            
            pos_part = drf_1(gci(k) - 16 : gci(k) + 16);
            drf(k) = sum(pos_part)/33;
            str1_part = str_1(gci(k) - 16 : gci(k) + 16);
            str2_part = str_2(gci(k) - 16 : gci(k) + 16);
            str1(k) = sum(str1_part);
            str2(k) = sum(str2_part);
            
        end
        
    end
    
    str1 = str1./max(abs(str1));
    
    %%%%%%%%%%  Find high to low frequency energy ratio using HNGD  %%%%%%%
    %%%%%%%%%%  Find energy ratio in [1-1000] Hz & [1000-3500] Hz  %%%%%%%%
    
    hngdM = hngdM';
    hngd_l1 = hngdM(:,1:64);
    hngd_h1 = hngdM(:,64:224);
    hngd_l2 = hngd_l1.^2;
    hngd_h2 = hngd_h1.^2;
    hngd_l = sum(hngd_l2,2)/64;
    hngd_h = sum(hngd_h2,2)/160;
    hngd_l(end+1:len) = hngd_l(end);
    hngd_h(end+1:len) = hngd_h(end);
    hngd_ratio = hngd_h./hngd_l;
    hngd_ratio(end+1:len) = hngd_ratio(end);
    %     hngd_h = hngd_h./max(abs(hngd_h));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%  High to low frequency energy ratio at only GCIs  %%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    h2lf_ratio = zeros(ngci,1);
    
    for k = 1 : ngci
        
        if gci(k) <= 16
            
            h2lf_part = hngd_ratio(1 : gci(k) + 16);
            h2lf_ratio(k) = sum(h2lf_part)/(gci(k) + 16);
            
        else
            
            h2lf_part = hngd_ratio(gci(k) - 16 : gci(k) + 16);
            h2lf_ratio(k) = sum(h2lf_part)/33;
            
        end
        
    end
    
    %     hngd_ratio = hngd_ratio./max(abs(hngd_ratio));
    h2lf_ratio = h2lf_ratio./max(abs(h2lf_ratio));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%  Spectral variance of the speech signal  %%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    hngdm = hngdM';
    var_hngd = var(hngdm);
    var_hngd = var_hngd';
    var_hngd(end+1:len) = var_hngd(end);
    %     var_hngd = var_hngd./max(abs(var_hngd));
    
    var_hngd_gci = zeros(ngci,1);
    
    for k = 1 : ngci
        
        if gci(k) <= 16
            
            var_part = var_hngd(1 : gci(k) + 16);
            var_hngd_gci(k) = sum(var_part)/(gci(k) + 16);
            
        else
            
            var_part = var_hngd(gci(k) - 16 : gci(k) + 16);
            var_hngd_gci(k) = sum(var_part)/33;
            
        end
        
    end
    
    var_hngd_gci = var_hngd_gci./max(abs(var_hngd_gci));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%  Apply thresholds to detect breath segments  %%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%  Required GCIs considered for breath detection  %%%%%%%%%
    
    req_reg1 = (vnv - 1).*(-1); %%%% regions obtained based on excitation source features.
    
    %%%%%%%%%%%%%%%%%%%  Required regions based on DRF values  %%%%%%%%%%%%
    
    drf_gci = drf;
    drf_gci_req = (drf_gci <= 2500 & drf_gci > 30); %% changed from 2500 to 2400
    
    %%%%%%%%%%%%%%%%%%%  Required regions based on DRS values  %%%%%%%%%%%%
    
    drs_gci = str1;
    drs_gci_req = (drs_gci <= 0.012 & drs_gci > 1*(10^-4)); %% changed from 0.016 to 0.012, 5*10^-6 to 1*10^-5
    
    %%%%%%%  Req. Regions using High to low Freq. energy ratio values  %%%%
    
    h2lf_gci = h2lf_ratio;
    h2lf_gci_req = (h2lf_gci >= 6*(10^-5)); %% changed from 5 to 6
    
    %%%%%%%%%%%%%%  Req. Regions using spectral variance values  %%%%%%%%%%
    
    var_gci = var_hngd_gci;
    var_gci_req = (var_gci <= 13*(10^-5)); %% changed from 15 to 12
    
    %%%%%%%%%%%%%  Combine all evidences to obtain final regions  %%%%%%%%%
    
    gci_comb1 = drf_gci_req .* drs_gci_req;
    gci_comb2 = gci_comb1 .* h2lf_gci_req;
    gci_comb3 = gci_comb2 .* var_gci_req;
    
    det_reg1 = zeros(len,1);
    
    for k = 1 : ngci
        
        if gci_comb3(k) == 1
            
            if k == 1 && k < ngci
                
                det_reg1(gci(k) : gci(k+1) -1) = 1;
                
            elseif k == ngci
                
                det_reg1(gci(k)) = 1;
                
            else
                
                det_reg1(gci(k) : gci(k+1) - 1) = 1;
                
            end
            
        end
        
    end
    
    %%%  Obtain final decision by considering excitation sorce features  %%
    
    det_fin = det_reg1 .* req_reg1;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%  Remove short segments  %%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%  Code snippet to join detected req segments  %%%%%%%%%%%
    
    req_regions_sig = det_fin;
    req_regions_mod2 = req_regions_sig;
    req_regions_mod2(1) = 0;
    req_regions_mod2(end) = 0;
    
    req_seg = zeros(len,1);
    req_seg(2:end) = diff(req_regions_mod2);
    req_seg_st = find(req_seg == 1);
    req_seg_end = find(req_seg == -1);
    no_seg = length(req_seg_st);
    
    if no_seg >=2
        
        for k = 2 : no_seg
            
            if req_seg_st(k) - req_seg_end(k-1) <= 200 %%% 200 samples = 12.5 msec, changed from 240 to 200
                
                req_regions_mod2(req_seg_end(k-1) : req_seg_st(k)) = 1;
                
            end
            
        end
        
    end
    
    req_regions_sig = req_regions_mod2;
    
    %%%%%%%%%%%  Code to remove short segments detected as req  %%%%%%%%%%
    
    req_regions_mod3 = req_regions_sig;
    req_regions_mod3(1) = 0;
    req_regions_mod3(end) = 0;
    
    req_seg = zeros(len,1);
    req_seg(2:end) = diff(req_regions_mod3);
    req_seg_st = find(req_seg == 1);
    req_seg_end = find(req_seg == -1);
    no_seg = length(req_seg_st);
    
    if no_seg >= 1
        for k = 1 : no_seg
            
            if req_seg_end(k) - req_seg_st(k) <= 1600 %%% 1600 samples = 100msec, changed from 960 to 1600
                
                req_regions_mod3(req_seg_st(k) : req_seg_end(k)) = 0;
                
            end
            
        end
        
    end
    
    req_regions_sig = req_regions_mod3;
    
    %%%%%%%%%%%%%%%%%%%  Code snippet to join nearby segments  %%%%%%%%%%%%
    
    req_regions_mod2 = req_regions_sig;
    req_regions_mod2(1) = 0;
    req_regions_mod2(end) = 0;
    
    req_seg = zeros(len,1);
    req_seg(2:end) = diff(req_regions_mod2);
    req_seg_st = find(req_seg == 1);
    req_seg_end = find(req_seg == -1);
    no_seg = length(req_seg_st);
    
    if no_seg >=2
        
        for k = 2 : no_seg
            
            if req_seg_st(k) - req_seg_end(k-1) <= 800 %%% 800 samples = 50 msec,
                
                req_regions_mod2(req_seg_end(k-1) : req_seg_st(k)) = 1;
                
            end
            
        end
        
    end
    
    req_regions_sig = req_regions_mod2;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%  Post-Processing End  %%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%  Algorithm End  %%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%  Code to write breath segment boundaries to a file  %%%%%%%%
    
    breath_bound = req_regions_sig;
    breath_bound(1) = 0;
    breath_bound(end) = 0;
    
    breath_seg = zeros(len,1);
    breath_seg(2:end) = diff(breath_bound);
    breath_seg_st = find(breath_seg == 1);
    breath_seg_end = find(breath_seg == -1);
    
    breath_st_time = breath_seg_st./fs;
    breath_end_time = breath_seg_end./fs;
    no_seg = length(breath_st_time);
    
    non_breath_end_time = zeros(no_seg + 1,1);
    non_breath_st_time = zeros(no_seg + 1,1);
    
    if no_seg == 0
        
        non_breath_end_time = len/fs;
        non_breath_st_time = 0;
        
    else
        
        non_breath_end_time(1:end - 1) = (breath_seg_st)./fs;
        non_breath_end_time(end) = len/fs;
        non_breath_st_time(2:end) = (breath_seg_end)./fs;
        
    end
    
    fid = fopen(outname,'w');
    
    if no_seg >= 1
        
        for k = 1 : no_seg
            
            fprintf(fid,'%f\t%f\t%s\n',non_breath_st_time(k),non_breath_end_time(k),'non breath');
            fprintf(fid,'%f\t%f\t%s\n',breath_st_time(k),breath_end_time(k),'breath');
            
        end
        
        fprintf(fid,'%f\t%f\t%s',non_breath_st_time(k+1),non_breath_end_time(k+1),'non breath');
        
    else
        
        fprintf(fid,'%f\t%f\t%s',non_breath_st_time(1),non_breath_end_time(1),'non breath');
        
    end
    
end

disp('Breath segment detection done for all files');
