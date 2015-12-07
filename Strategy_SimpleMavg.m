classdef Strategy_SimpleMavg < handle
    %   Moving Average Cross Strategy 
    %   to gerenate signals
    
    properties
        
        %{
        PROPERTIES MANUAL
        
        symbol: the symbol/name of the asset
        time: the time vector used as time axis
        prices: the price(s) matrix, each a price vector as a column
        win_short/win_long: short and long window of mavg
        signals: long/short signals generated according to trading rules
        unit_position: unit holding position
        %}
        
        strat
        symbol
        time
        prices
        win_short
        win_long
        signals
        unit_position
    end
    
    methods
        function obj = Strategy_SimpleMavg(symbol, time, prices, ...
                win_short, win_long)
            % to initiate a strat object with attributes
            obj.strat = 'simple';
            obj.symbol = symbol;
            obj.time = time;
            obj.prices = prices;
            obj.win_short = win_short;
            obj.win_long = win_long;
            
            % to generate signals and unit_positions
            obj.signals = gen_signals(obj);
            obj.unit_position = [zeros(1, size(obj.signals, 2)); ...
                diff(obj.signals)];
        end

        function signals = gen_signals(obj)
            % to generate singals
            mavg_short = tsmovavg(obj.prices, 's', obj.win_short, 1);
            %size(mavg_short)
            mavg_long = tsmovavg(obj.prices, 's', obj.win_long, 1);
            %size(mavg_long)
            signals = (mavg_short > mavg_long);
        end

    end
    
end

