% Data: 2021/12/30
% Author: Tongyu Wang
% Description: Pacman, trf, local, global

function Pacman()

try
    dat = DataTrans({'Trial', 'Resp', 'Acc'});
    plt = StimFrame;
    key = KeysEvent;
    
    dat.DataLoad('cfg', dat.name, dat.task);
    
    plt.ShowFixation;
    flag = key.WaitPress('pause');
    if flag == 1, return; end
    
    for i = 1:cfg.ntrial
        dat.marker = 0;
        dat.DataMarkerIn;
        plt.ShowFixation;
        flag = key.WaitPress('fixed', 0.3);
        if flag == 1, break; end
        
        shape = cfg.shape{i};
        ifx = cfg.existx{i};
        letter = cfg.letter{i};
        syn = cfg.syncro{i};
        rgbset = cfg.rgbset{i};
        
%                 a(1) = GetSecs;
        dat.marker = dat.DataMarkerSet(shape, syn, ifx);
        plt.ShowTarget(shape, letter, rgbset, dat);
%                 a(2) = GetSecs;
%         assignin('base','a',a);

        plt.ShowFixation;
        [flag, event] = key.WaitPress('limit',1);
        if flag == 1, break; end
        
        if strcmp(dat.task, 'global')
            capture = syn;
        elseif strcmp(dat.task, 'local')
            capture = ifx;
        end
        
        acc = dat.DataJudge(event, capture);
        dat.DataInput('Trial',i, 'Resp',event, 'Acc',acc);
        
        plt.ShowBlank;
        flag = key.WaitPress('fixed',(randi(3)+2)/10);
        if flag == 1, break; end
             
        if ~strcmp(dat.name,'test') && ...
            mod(i,round(cfg.ntrial/3)) == 0 && i~= cfg.ntrial
            plt.ShowWords;
            flag = key.WaitPress('pause');
            if flag == 1, break; end
        end  
    end

    dat.DataClose;
    dat.DataEstimate;
    
catch ME
    dat.DataClose;
    disp('Error!'); rethrow(ME);
end