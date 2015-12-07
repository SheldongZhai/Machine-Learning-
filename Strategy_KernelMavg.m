classdef Strategy_KernelMavg
    
    properties
        strat
        symbol
        time
        prices
        win_short
        win_long
        parm
        kernel_estimate
        signals
        unit_position
        smpl_prd
        dist
    end
    
    methods
        
        function obj = Strategy_KernelMavg(symbol, time, price,...
                sample_period, win_short, win_long, dist)
            % to initiate a strat object with attributes
            obj.strat = 'kernel';
            obj.symbol = symbol;
            obj.time = time;
            obj.prices = price;
            obj.win_short = win_short;
            obj.win_long = win_long;
            obj.dist = dist;
            obj.smpl_prd = sample_period;
            
            % to generate kernel-regression-generated prices
            obj.kernel_estimate = gen_kernel_estimate(obj);
            
            % to generate signals and unit positions
            obj.signals = gen_signals(obj);
            obj.unit_position = [zeros(1, size(obj.signals, 2)); ...
                diff(obj.signals)];
        end
        
        function kernel_estimate = gen_kernel_estimate(obj)
            % h = bandwidth
            % dist = distribution to use
            % dist = obj.dist;
            
%             pd_tag = Backtest.get_datetimeFrom(obj.smpl_prd(2));
%             pd_tag = find(obj.time == pd_tag) + 1;
              pd_tag = obj.smpl_prd;
            
            %kernel_estimate = obj.prices;
            
            x = transpose(1:length(obj.prices)); % kernel reg, time kernel
            y = obj.prices; % prices

            N = length(obj.prices);
            
            hx = median(abs(x-median(x)))/0.6745*(4/3/N)^0.2;
            hy = median(abs(y-ones(length(y),1)*median(y)))/...
                0.6745*(4/3/N)^0.2;
            h=sqrt(hy*hx); % optimal bandwith
                       

            kernel_estimate = obj.prices;
            for i = pd_tag:N
                r = ksr(1:i, obj.prices(1:i), ...
                h, i);
                kernel_estimate(i) = r.f(end);
            end
            
%             cc = zeros(10000,1);
%             
%             for i = 1001:10000
%                 r = ksr(i-100:i, ...
%                     Data.price(i-100:i), ...
%                     2.58, 101);
%                 cc(i) = r.f(end);
%             end

        end
        
  
        function signals = gen_signals(obj)
            mavg_short = tsmovavg(obj.kernel_estimate, 's', ...
                obj.win_short, 1);
            mavg_long = tsmovavg(obj.kernel_estimate, 's', ...
                obj.win_long, 1);
            
%            pd_tag = Backtest.get_datetimeFrom(obj.smpl_prd(2));
%             pd_tag = find(obj.time == pd_tag) + 1;
%             
%             signals = zeros(size(obj.kernel_estimate));
%             signals(pd_tag:end, :) = (mavg_short(pd_tag:end, :) > ...
%                 mavg_long(pd_tag:end, :));
            signals = (mavg_short > mavg_long);
        end
        
        
        
    end
    
end

