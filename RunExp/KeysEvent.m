classdef KeysEvent
    properties
        keys;
    end
    
    methods
        function  obj = KeysEvent()
            try
                HideCursor;
                obj.keys = obj.KeyDefine();
                RestrictKeysForKbCheck(struct2array(obj.keys));
            catch
                ShowCursor
                RestrictKeysForKbCheck([]);
            end
        end
        
        function [flag, event]= WaitPress(obj, mode, duration)
            tic;
            flag = 0;
            event = '';    
            if strcmp(mode,'fixed')
                t = toc;
                while t < duration - 0.0015
                    [keyIsDown, ~, keyCode] = KbCheck;
                    if keyIsDown && ~keyCode(obj.keys.space) && isempty(event)
                        event = obj.KeyCheck(keyCode);
                    end
                    t = toc;
                end
      
            elseif strcmp(mode,'limit')
                t = toc;
                while t < duration - 0.0015 && isempty(event)
                    [keyIsDown, ~, keyCode] = KbCheck;
                    if keyIsDown && ~keyCode(obj.keys.space)
                        event = obj.KeyCheck(keyCode);
                    end
                    t = toc;
                end

            elseif strcmp(mode,'pause')
                [keyIsDown, ~, keyCode] = KbCheck;
                while ~keyIsDown || ~(keyCode(obj.keys.space) || keyCode(obj.keys.escape))
                    [keyIsDown, ~, keyCode] = KbCheck;
                end     

            end
            
            if strcmp(event,'escape')
                sca; ShowCursor;
                RestrictKeysForKbCheck([]);
                flag = 1;
            end
        end
        
        function keyName = KeyCheck(obj, keyCode)
            allkeys = fieldnames(obj.keys);
            keyID = find(keyCode);
            for i = 1:length(allkeys)
                if obj.keys.(allkeys{i}) == keyID
                    keyName = allkeys{i};
                end
            end
        end
        
    end
    
    methods(Static)
        function  keys = KeyDefine()
            KbName('UnifyKeyNames');
            keys.j      = KbName('j');
            keys.f      = KbName('f');
            keys.escape = KbName('ESCAPE');
            keys.space  = KbName('Space');
        end
    end
    
end

