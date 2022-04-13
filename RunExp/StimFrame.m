classdef StimFrame
    properties
        win = -1;
        ifi = 0;
        xx = 0
        yy = 0;
        bgc = 0;
%         letterx = 0;
%         lettery = 0;
        
        verbose = 1;
        skipSyn = 0;
        textFont = 'Arial';
        textSize = 20;
        
        hinge = 500;
        pacRatio = 1;
        lastRatio = 0.5;% for letter
    end
    
    methods
        function obj = StimFrame()
            commandwindow;
            Screen('Preference','SkipSyncTests',obj.skipSyn);
            Screen('Preference', 'VisualDebugLevel', obj.verbose);
            Screens = Screen('Screens'); screenid = max(Screens);
            Resolut = Screen('Resolution',screenid);
            if Resolut.width~=1024
                %¡¡PsychDebugWindowConfigupacRation;
                [obj.win, rect] = Screen('OpenWindow',screenid,obj.bgc,[0,0,1024,768]);
            else
                [obj.win, rect] = Screen('OpenWindow',screenid,obj.bgc);
            end
            obj.ifi = Screen('GetFlipInterval', obj.win);
            topPriorityLevel = MaxPriority(obj.win);
            Priority(topPriorityLevel);
            obj.xx = rect(3)/2;
            obj.yy = rect(4)/2;
            
            Screen('TextFont', obj.win, obj.textFont);
            Screen('TextSize', obj.win, obj.textSize);
%             normBounds = TextBounds(obj.win, 'X');
%             obj.letterx = obj.xx-(normBounds(3)-normBounds(1))/2;
%             obj.lettery = obj.yy-(normBounds(4)-normBounds(2))/2;
            
        end
        
        function PlotFixation(obj)
            Screen('DrawDots',obj.win,[obj.xx; obj.yy],5,255);
        end
        
        function PlotPacman(obj, mode, lum) % radi, lorr, mode, tail
            radius = round((obj.hinge/4)*obj.pacRatio);
            
            geom.top    = [obj.xx, obj.yy-2*radius];
            geom.bottom = [obj.xx, obj.yy+2*radius];
            geom.left   = [obj.xx-2*radius, obj.yy];
            geom.right  = [obj.xx+2*radius, obj.yy];   
            
            para = obj.wedgepara(mode);
            geomPool = fieldnames(geom);
            for i = 1:length(geomPool)
                field = geomPool{i};
                
                center = geom.(field);
                rect = [center-radius, center+radius];      
                
                arcpara = para.(field);
                start = arcpara(1);
                arc = arcpara(2);
                Screen('FillOval',obj.win,lum.(field),rect);
                Screen('FillArc',obj.win,0,rect,start,arc);
            end
        end
        
        function PlotLetter(obj, letter)
            normBounds = Screen('TextBounds', obj.win, letter);
            startx = obj.xx-(normBounds(3)-normBounds(1))/2;
            starty = obj.yy-(normBounds(4)-normBounds(2))/2;
            Screen('DrawText', obj.win, letter, startx, starty, 255);
%             Screen('DrawText', obj.win, letter, obj.letterx, obj.lettery, 255);
        end
        
        function PlotWords(obj)
            bia = [180,5];
            Screen('DrawText', obj.win,'Have a rest, press any key to continue.',...
                obj.xx-bia(1), obj.yy-bia(2), 255);
        end
        
        %
        function ShowFixation(obj)
            PlotFixation(obj);
            Screen('Flip',obj.win);
        end
        
        function ShowTarget(obj, mode, ifx, rgb, dat)
            nlum = length(rgb);
            step = nlum/length(ifx);
            %  last = round(obj.lastRatio*step);
            
            vbl = Screen('Flip', obj.win);
            for i = 1:nlum
                % if any(mod(i+step-1,step)+1 == 1:last)
                idx = floor((i-1)/step)+1;
                PlotLetter(obj,ifx{idx});
                % end
                PlotPacman(obj, mode, rgb(i));
                Screen('DrawingFinished',obj.win);
                vbl = Screen('Flip', obj.win, vbl+0.5*obj.ifi);
%                   a(i) = GetSecs;
                if i == 1
                    dat.DataMarkerIn;
                end
            end
            
%              assignin('base','a',a);
        end
        
        function ShowBlank(obj)
            Screen('Flip',obj.win); 
        end
        
        function ShowWords(obj)
            PlotWords(obj)
            Screen('Flip',obj.win);
        end
        
    end

    methods(Static, Access = 'private')

        function para = wedgepara(oritn)
            if strcmp(oritn,'left')
                para.top    = [180, 45];
                para.bottom = [315, 45];
                para.left   = [45, 90];
                para.right  = [0, 90];
            elseif strcmp(oritn,'right')
                para.top    = [135, 45];
                para.bottom = [0, 45];
                para.left   = [270, 90];
                para.right  = [225, 90];
            elseif strcmp(oritn,'shuffle')
                para.top    = [225, 45];
                para.bottom = [90, 45];
                para.left   = [270, 90];
                para.right  = [315, 90];  
            end
        end
        
     end
end
