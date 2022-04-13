classdef DataTrans
    properties
        saveDir = ['.', filesep, 'data', filesep];
        cfgsDir = ['..', filesep, 'GenCfg', filesep];
        fid = -1;
        name = 'test';
        task = '';
        title = {};
        
        isexist = 'j';
        noexist = 'f';
        
        LPT = 'D010';
        address = [];
        io = [];
        marker = 0;
    end
    
    methods
        function obj = DataTrans(title)
            if exist('title', 'var')
                [input, obj] = obj.SubjInfo();
                
                fid = fopen([obj.saveDir,[input{1},'_',input{4}],'.txt'],'w');
                obj.fid = fid;
                
                for i = 1:length(input)
                    if i == length(input)
                        spec = '%s\t\n';
                    else
                        spec = '%s\t';
                    end
                    fprintf(fid,spec,input{i});
                end               
                
                for i = 1:length(title)
                    if i == length(title)
                        spec = '%s\t\n';
                    else
                        spec = '%s\t';
                    end
                    fprintf(fid,spec,title{i});
                end
                obj.title = title;
            end
            
            obj.io = io64;
            status = io64(obj.io);
            if status ~= 0
                disp('LPT unconnected')
                return
            end
            obj.address = hex2dec(obj.LPT);
        end
        
        function [input, obj] = SubjInfo(obj)

            id = dir(strcat(obj.saveDir,'*.txt'));
            id_list = cell(1,length(id));
            for i = 1:length(id)
                id_list{i} = id(i).name(1:length(id(i).name)-4);
            end
            
            prompt = {'Name','Gender','Age','Task','Date'};
            default = {'test','x','0','g',date};
            input = inputdlg(prompt,'', 1, default, 'on');

            subjname = input{1};
            obj.name = subjname;
            if strcmpi(input{4}, 'g')
                obj.task =  'global';
            elseif strcmpi(input{4}, 'l')
                obj.task =  'local';
            end
            
            if ~strcmp('test',subjname) && any(strcmp(id_list,subjname))
                button = questdlg('The name already exists.Do you want to overwrite it?',...
                    'Warning!','YES','NO','NO');
                if strcmp(button,'NO')
                    input = scan_files(obj.saveDir);
                end
            end
        end
        
        function DataInput(obj,varargin)
            ninput = length(varargin);
            keys = varargin(1:2:ninput);
            args = varargin(2:2:ninput);

            npara = length(obj.title);
            newargs = cell(1,npara); 
            for i = 1:npara
                para = obj.title(i);
                ibool = strcmpi(keys,para);
                if any(ibool)
                    newargs{i} = args{ibool};   
                else
                    newargs{i} = NaN;
                end
            end
            
            for i = 1:npara 
                value = newargs{i};
                if isnumeric(value)
                    if isnan(value) || round(value)-value == 0
                        spec = '%d\t';
                    else
                        nall = find(num2str(value) == '.') + 2;
                        spec = ['%',num2str(nall),'.3f\t',];
                    end
                elseif ischar(value)
                    spec = '%s\t';
                end
                
                if i == npara 
                    spec = [spec(1:end-1),'r\n'];
                end
                fprintf(obj.fid, spec, newargs{i});
            end
        end
        
        function DataLoad(obj, varName, cfgName, taskName)
            if strcmp(cfgName, 'test')
                stim = importdata([obj.cfgsDir,'testcfgs.mat']);
            else
                stim = importdata([obj.cfgsDir,'cfgs.mat']);  
            end
            stim = stim.(taskName);
            assignin('caller',varName,stim)
        end
        
        function acc = DataJudge(obj, event, capture)
            if isempty(event)
                acc = nan;
            else
                iscon = strcmp(capture, '1') == strcmp(event,obj.isexist);
                if iscon, acc = 1; else, acc = 0; end
            end

        end
        
        function DataEstimate(obj)
            fileID = fopen([obj.saveDir,[obj.name,'_',obj.task(1)],'.txt']);
            C = textscan(fileID,'%*d %*s %s ','headerlines',2);
            beha = C{1};
            acc = nan(length(beha),1);
            for i = 1:length(beha)
                acc(i) = str2double(beha{i});
            end
            accrate = nanmean(acc);
            nanrate = mean(isnan(acc));
            
            fprintf(['accuracy: ',num2str(accrate*100),'%%.\n'])
            fprintf(['nanumber: ',num2str(nanrate*100),'%%.\n'])
            fclose(fileID);
        end
        
        function DataMarkerIn(obj)
            io64(obj.io,obj.address,obj.marker); 
        end
        
        function marker = DataMarkerSet(obj, shape, syn, ifx)
            if strcmp(obj.task, 'global')
                capture = str2double(syn);
            elseif strcmp(obj.task, 'local')
                capture = str2double(ifx);
            else
                disp('wrong task name');
            end
            
            if capture
                marker = 8;
            else
                if strcmp(shape,'left')
                    marker = 1;
                elseif strcmp(shape,'right')
                    marker = 2;
                elseif strcmp(shape,'shuffle')
                    marker = 3;
                end
            end
        end
        
        function DataClose(obj)
            fclose('all');
            sca; ShowCursor;
            RestrictKeysForKbCheck([]);
        end
    end
    
end