classdef mktptf < handle
    %   Market Portfolio 
    %   generate positions, holdings, cash, total asset and returns
    
    properties
        strat
        symbol
        time
        prices
        signals
        initial_capital
        holdings
        cashes
        total_asset
        returns
        total_ret
    end
    
    methods
        function obj = mktptf(StrategyInstance, ...
                initial_capital)
            %{
                to initiate a portfolio object with initial attributes:
                    symbol
                    time axis
                    pricess
                    signals
                    initial capital
            %}
            obj.strat = StrategyInstance.strat;
            obj.symbol = StrategyInstance.symbol;
            obj.time = StrategyInstance.time;
            obj.prices = StrategyInstance.prices;
            obj.signals = StrategyInstance.signals;
            obj.initial_capital = initial_capital;
        end
        
        function obj = backtest(obj)
            
            cash = zeros(length(obj.prices), 1);
            cash(1) = obj.initial_capital;
            
            pos = zeros(length(obj.prices), 1);
            
            holding = zeros(length(obj.prices), 1);
            holding(1) = 0;
           
            unit_pos = [0; diff(obj.signals)];
            
            % for each trading day
            for i = 2 : length(obj.prices)
                if unit_pos(i) == 1
                    pos(i) = cash(i-1) / obj.prices(i);
                    holding(i) = pos(i) .* obj.prices(i);
                    cash(i) = 0;
                elseif unit_pos(i) == -1
                    pos(i) = 0;
                    holding(i) = 0;
                    cash(i) = pos(i-1) * obj.prices(i);  
                elseif unit_pos(i) == 0 
                    pos(i) = pos(i-1);
                    holding(i) = pos(i) * obj.prices(i);
                    cash(i) = cash(i-1); 
                end

            end
                
            
            obj.cashes = cash;
            obj.holdings = holding;
            obj.total_asset = cash + holding;
            
            obj.returns = price2ret(obj.total_asset);
            obj.total_ret = log( prod( exp(obj.returns) ));
            
            
        end
        
        function drct_accur = get_drctaccur(obj)
          
            tmp = obj.returns >= 0 ;
            drct_accur = sum(tmp, 1) / length(tmp);
            
        end
        
        function sharpes = get_sharpes(obj)
            sharpes = sharpe(obj.returns, 0);            
        end
        
        function maxdrawd = get_maxdrawd(obj)
            maxdrawd = maxdrawdown(obj.total_asset);
        end
        
        function h = plot_portfolio(obj, which)
            % plot hp_filter strategy total asset, for one series
            h = figure();
            plot(obj.time, obj.total_asset(:, which));
            title(['Total Asset:' ' ' obj.strat]);
            xlabel('Time');
            legend(obj.symbol(which));
         end
        
        
    end
    
end

