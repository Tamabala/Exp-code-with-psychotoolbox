classdef CfgsCreate
    properties
        ntrial = [];
        ntest = 10;
        nfull = 150;
        nlum = 120*5;
        nsyn = 120*1;
        nletter = 90;
        shapePara = {'left','right','shuffle'};
        syncroPara = {'0','0','0','0','1'};
        letterPara = {'0','0','0','0','1'};
%         letterPool = {'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'O', 'P',...
%             'A', 'S', 'D', 'G', 'H', 'K', 'L',...
%             'Z', 'C', 'V', 'B', 'N', 'M'};
        letterPool = {'Q', 'E', 'R', 'T', 'U', 'I', 'O', 'P',...
            'S', 'D', 'G', 'H', 'L', 'Z', 'C', 'B', 'N'};
        
        gammaPara = [];
    end
    
    methods
        
        function obj = CfgsCreate
            
            obj.gammaPara = obj.lumFit('gray');
            
            cfgs.global =  CfgsArrays(obj);
            cfgs.local  =  CfgsArrays(obj);
            save('cfgs', 'cfgs')  
            
            testcfgs.global = CfgsPrac(obj);
            testcfgs.local = CfgsPrac(obj);
            save('testcfgs', 'testcfgs')
        end
        
        function cfgs = CfgsPrac(obj)
            obj.ntrial = obj.ntest;
            
            isshape = repmat(obj.shapePara',ceil(obj.ntest/length(obj.shapePara)),1);
            isshape = isshape(1:obj.ntest);
            
            ifsyncro = repmat(obj.syncroPara',ceil(obj.ntest/length(obj.syncroPara)),1);
            ifsyncro = ifsyncro(1:obj.ntest);
            
            ifletter = repmat(obj.letterPara',ceil(obj.ntest/length(obj.letterPara)),1);
            ifletter = ifletter(1:obj.ntest);

            [lumset, rgbset] = CfgsLuminace(obj, ifsyncro);
            letter = CfgsLetter(obj, ifletter);
            
            cfgs = [];
            cfgs.shape = isshape(randperm(obj.ntrial));
            seeda = randperm(obj.ntrial);
            cfgs.syncro = ifsyncro(seeda);
            cfgs.lumset = lumset(seeda);
            cfgs.rgbset = rgbset(seeda);
            seedb = randperm(obj.ntrial);
            cfgs.existx = ifletter(seedb);
            cfgs.letter = letter(seedb);
            cfgs.ntrial = obj.ntrial;  
        end
        
        function cfgs = CfgsArrays(obj)
            obj.ntrial = obj.nfull;
            
            [isshape, ifsyncro, ifletter] = CfgsCondition(obj);
            [lumset, rgbset] = CfgsLuminace(obj, ifsyncro);
            letter = CfgsLetter(obj, ifletter);

            seed = randperm(obj.ntrial);
            cfgs = [];
            cfgs.shape = isshape(seed);
            cfgs.syncro = ifsyncro(seed);
            cfgs.lumset = lumset(seed);
            cfgs.rgbset = rgbset(seed);
            cfgs.existx = ifletter(seed);
            cfgs.letter = letter(seed);
            cfgs.ntrial = obj.ntrial;
        end
        
        function  [isshape, ifsyncro, ifletter] = CfgsCondition(obj)
            block0 = obj.ntrial/length(obj.shapePara);
            isshape = repelem(obj.shapePara',block0,1);
            
            block0 = block0/length(obj.syncroPara);
            ifsyncro = repelem(obj.syncroPara',block0,1);
            block1 = obj.ntrial/length(ifsyncro);
            ifsyncro = repmat(ifsyncro,block1,1);
            
            block0 = block0/length(obj.letterPara);
            ifletter = repelem(obj.syncroPara',block0,1);
            block1 = obj.ntrial/length(ifletter);
            ifletter = repmat(ifletter,block1,1);

        end
        
        function [lumset, rgbset] = CfgsLuminace(obj, syncro)

            fields = {'top', 'bottom', 'left', 'right'};
            nfield = length(fields);
            synRange = round([obj.nlum*0.1, obj.nlum*0.9-obj.nsyn]);
            
            lumset = cell(obj.ntrial,1); rgbset = cell(obj.ntrial,1);
            for i = 1:obj.ntrial           
                lum = nan(obj.nlum, nfield); 
                rgb = nan(obj.nlum, nfield);    
                for j = 1:nfield
                    [lum(:,j), rgb(:,j)] = CfgsLum(obj);               
                end
                
                if strcmp(syncro{i}, '1')
                    start = randi(synRange);
                    synIdx = start:start+obj.nsyn-1;
                    halfIdx = synIdx(1:3:end);
                    lum(synIdx,:) = repelem(lum(halfIdx,1), 3, 4);
                    rgb(synIdx,:) = repelem(rgb(halfIdx,1), 3, 4);  
                end
                
                lum = mat2cell(num2cell(lum), obj.nlum, ones(1,nfield));
                rgb = mat2cell(num2cell(rgb), obj.nlum, ones(1,nfield));
                arglum = [fields; lum]; lumset{i} = struct(arglum{:});
                argrgb = [fields; rgb]; rgbset{i} = struct(argrgb{:});     
            end
        end
        
        function letters = CfgsLetter(obj, ifx)         
            letters = cell(obj.ntrial,1);
            for j = 1:length(ifx)
                isx = ifx{j};
                letter = cell(obj.nletter,1);
                
                idx = randi(length(obj.letterPool));
                letter(1) = obj.letterPool(idx);
                for i = 2:obj.nletter
                    idx = randi(length(obj.letterPool));
                    foreIdx = max(1,i-6);
                    while any(strcmp(letter(foreIdx:i-1),obj.letterPool(idx)))
                        idx = randi(length(obj.letterPool));
                    end
                    letter(i) = obj.letterPool(idx);
                end
                
                if strcmp(isx, '1')
                    xloca = randi(round([obj.nletter*0.1,obj.nletter*0.9]));
                    letter{xloca} = 'X';
                end
                letters{j} = letter;
            end
        end
        
        function [lum, rgb]= CfgsLum(obj)
            b = obj.gammaPara.b;
            m = obj.gammaPara.m;
            lumrange = b*255^m;
            
            lumValue = lumrange*rand(1,obj.nlum);
            fourier = fft(lumValue);
            power = abs(fourier);
            mpower = mean(power);
            
            newpower = nan(obj.nlum,1);
            for i = 1:obj.nlum
                ratio = mpower/abs(fourier(i));
                newpower(i) = fourier(i)*ratio;
            end
            lumNew = ifft(newpower);
            
            lumMap = lumNew*lumrange/(max(lumNew)-min(lumNew));
            lum = lumMap - min(lumMap);
            rgb = round(nthroot(lum/b,m));
        end
    end
    
    methods(Static, Access = 'private')
        function para = lumFit(colour)
            warning('off');
            
            lumGray = mean([
                0.00, 0.00, 0.00, 0.00, 0.00 ;...
                0.13, 0.12, 0.12, 0.12, 0.13 ;...
                0.63, 0.63, 0.63, 0.62, 0.64 ;...
                1.65, 1.69, 1.69, 1.69, 1.70 ;...
                3.24, 3.40, 3.38, 3.33, 3.25 ;...
                1.72, 5.55, 5.76, 5.65, 5.72 ;...
                8.93, 8.73, 8.87, 8.88, 8.73 ;...
                12.3, 12.8, 12.6, 12.6, 12.4 ;...
                17.2, 17.3, 17.2, 17.3, 17.5 ;...
                23.3, 22.5, 22.8, 23.1, 22.8 ;...
                28.8, 29.8, 29.9, 28.7, 29.5 ;...
                36.1, 36.0, 36.1, 35.9, 36.1 ;...
                44.7, 44.5, 44.4, 45.2, 45.9 ;...
                50.2, 49.9, 50.5, 51.5, 50.3 ;...
                60.2, 60.1, 60.8, 60.2, 61.3 ;...
                69.1, 68.2, 67.5, 67.8, 67.8 ;...
                73.4, 73.5, 73.6, 73.9, 73.6 ;...
                81.0, 81.5, 80.3, 80.8, 81.0 ;], 2);
            
            lumRed = mean([
                ]);
            lumBlue = mean([
                ]);
            lumGreen = mean([
                ]);
            
            if strcmpi(colour,'gray')
                y = lumGray;
            elseif strcmpi(colour,'red')
                y = lumRed;
            elseif strcmpi(colour,'blue')
                y = lumBlue;
            elseif strcmpi(colour,'green')
                y = lumGreen;
            else
                disp('error');
                return
            end
            
            x = 0:15:255;
            coef = fit(x',y,'b*x^m');
            para.b = coef.b;
            para.m = coef.m;
            
        end
    end
end

