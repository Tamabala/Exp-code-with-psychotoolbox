field = 'global';%%%%%%%%%***¼ÇµÃÐÞ¸Ä***%%%%%%%%%
% field = 'local';

dat = DataTrans;
plt = StimFrame;
key = KeysEvent;
para  = load('..\GenCfg\testcfgs.mat');
cfg = para.testcfgs.(field);

plt.ShowFixation;
flag = key.WaitPress('pause');
if flag == 1, return; end

for i = [1,5,6]
    plt.ShowFixation;
    flag = key.WaitPress('pause');
    if flag == 1, break; end
    
    shape = cfg.shape{i};
    letter = cfg.letter{i};
    rgbset = cfg.rgbset{i};
    
    plt.ShowTarget(shape, letter, rgbset, dat);
    
    plt.ShowFixation;
    flag = key.WaitPress('pause');
    if flag == 1, break; end
    
    plt.ShowBlank;
    flag = key.WaitPress('pause');
    if flag == 1, break; end
end
dat.DataClose;