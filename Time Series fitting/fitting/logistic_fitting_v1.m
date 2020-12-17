function [k,c_est,RMSE,Rsquare]=logistic_fitting_v1(t,rad,cvg,idx)

%%%%
% k=0; no change；
% k=1 false change;
% k=2 nlinfit wins;
% k=3 lsqcurvefit wins;
% k=4 linear better than log

%%%%%
RMSE=0;
Rsquare=0;
y_rad=rad(idx,:);
y_cvg=cvg(idx,:);
num_obs=length(t);

%%
y_rad0=y_rad; % y_rad0: raw time series; y_rad: cf_cvg masked time series
t0=t;
mask_idx=find(y_cvg<=quantile(y_cvg,.1));
t(mask_idx)=[];
y_rad(mask_idx)=[];

%%  model and estimate change or not
fun_log=inline('c(1)+c(2)./(1+exp(-c(3).*t+c(4)))','c','t');
fun_season=inline('c(1).*sin(2*t*pi./12)+c(2).*cos(2*t*pi./12)+c(3).*sin(4*t*pi./12)+c(4).*cos(4*t*pi./12)','c','t');
fun_full=inline('c(1)+c(2)./(1+exp(-c(3).*t+c(4)))+c(5).*sin(2*t*pi./12)+c(6).*cos(2*t*pi./12)+c(7).*sin(4*t*pi./12)+c(8).*cos(4*t*pi./12)','c','t');
fun_full_linear=inline('c(1)+c(2).*t+c(3).*sin(2*t*pi./12)+c(4).*cos(2*t*pi./12)+c(5).*sin(4*t*pi./12)+c(6).*cos(4*t*pi./12)','c','t');

fun_full2=@(c,t)c(1)+c(2)./(1+exp(-c(3).*t+c(4)))+c(5).*sin(2*t*pi./12)+c(6).*cos(2*t*pi./12)+c(7).*sin(4*t*pi./12)+c(8).*cos(4*t*pi./12);

X=[ones(1,length(t));t]; % y=b+ax
[B,BINT,R,RINT,STATS]=regress(y_rad',X');

P_Value=STATS(3);
threshold=3; % threshold of false change;

if P_Value>0.05 % && abs(B(2))<=0.05  %说明这里需要给一个 change mag的 threshold？？ 但是这个会不是预先就盖棺定论了 影响了后面对变化类型的分类？？？
    fprintf('P_Value=%.2f, slope=%.4f\n',P_Value,abs(B(2)));
    
    fprintf('\n**********************Result**********************\n\n');
    fprintf('No change. No significant change is detected!\n\n');
    fprintf('**********************Result**********************\n\n');
    k=0;
    c_est=B;
    X=[ones(1,length(t));t;sin(2*t*pi./12);cos(2*t*pi./12);sin(4*t*pi./12);cos(4*t*pi./12)]; % y=b+ax
    [B,BINT,R,RINT,STATS]=regress(y_rad',X');
    RMSE=sqrt(sum((y_rad-fun_full_linear(B,t)).^2)/length(t));
    c_est=B;
    Rsquare=STATS(1);
else
    
    %%
    % estimating initial parameter
    c1_0=mean(y_rad(1:10));
    c2_0=mean(y_rad(end-9:end))-mean(y_rad(1:10));
    Smag=0.5*(std(y_rad(1:10))+std(y_rad(end-9:end)));
    y_temp=c2_0./(y_rad-c1_0-Smag)-1;
    mask_idx2=find(y_temp<=0);
    y_temp(mask_idx2)=[];
    t_temp=t;
    t_temp(mask_idx2)=[];
    y_est=log(y_temp);
    X=[ones(1,length(t_temp));t_temp];
    [B0,BINT,R,RINT,STATS0]=regress(y_est',X');
    c0=[c1_0,c2_0,-1*B0(2),B0(1),1,1,1,1];
    
    %% nlinfit
    
    opts = statset('nlinfit');
    opts2=opts;
    opts2.MaxIter=2000;
    opts.MaxIter=1000;
    opts.Robust='on';
    
    c_est1=nlinfit(t,y_rad,fun_full,c0,opts);
    %%%这边只考虑 mask掉 outlier之后的 (t,y_rad)用来评价拟合优度
    Rsquare1=calculate_R(fun_full,c_est1,t,y_rad);
    RMSE1=sqrt(sum((y_rad-fun_full(c_est1,t)).^2)/length(t));
    fprintf('nlinfit\t');
    fprintf('RMSE=%.3f,  R-Square=%.3f\n',RMSE1,Rsquare1);
    disp(c_est1)
    
    %% ls
    options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt','MaxIterations',2000);
    lb = [];
    ub = [];
    [c_est2,norm,res,ef,out,lam,jac] = lsqcurvefit(fun_full2,c0,t,y_rad,lb,ub,options);  %% ef >0 =收敛 otherwise 不收敛
    Rsquare2=calculate_R(fun_full,c_est2,t,y_rad);
    RMSE2=sqrt(sum((y_rad-fun_full(c_est2,t)).^2)/length(t));
    if ef<0
        fprintf('不收敛');
    else
    end
    fprintf('lsqcurvefit\t');
    fprintf('RMSE=%.3f,  R-Square=%.3f,  ',RMSE2,Rsquare2);
    fprintf('LM iterations=%d\n',out.iterations);
    disp(c_est2)
    
    %% linear regression
    X=[ones(1,length(t));t;sin(2*t*pi./12);cos(2*t*pi./12);sin(4*t*pi./12);cos(4*t*pi./12)]; % y=b+ax
    [B,BINT,R,RINT,STATS]=regress(y_rad',X');
    RMSE3=sqrt(sum((y_rad-fun_full_linear(B,t)).^2)/length(t));
    
    
    fprintf('\n**********************Result**********************\n\n');
    
    if RMSE1<RMSE2  %% nlin is better；
        y_log_est=fun_log(c_est1(1:4),t0);
        mag_change=abs(mean(y_log_est(1:10))-mean(y_log_est(end-9:end)));
        if Rsquare1<0.3
            fprintf('Low R-square warning! R2=%.3f\n',Rsquare1);
        end
        if Rsquare1<STATS(1)
            k=4;
            c_est=B;
            Rsquare=STATS(1);
            RMSE=RMSE3;
            fprintf('Linear model wins\n\n');
            
        else
            if mag_change<=threshold
                fprintf('No change. False change is detected!\n\n');
                k=1;
                c_est=B;
                Rsquare=STATS(1);
                RMSE=RMSE3;
            else
                fprintf('nlinfit wins, and the estimated parameters are:\n');
                disp(c_est1)
                k=2;
                c_est=c_est1;
                RMSE=RMSE1;
                Rsquare=Rsquare1;
            end
            
        end
    else  %%% LM wins
        y_log_est=fun_log(c_est2(1:4),t0);
        mag_change=abs(mean(y_log_est(1:10))-mean(y_log_est(end-9:end)));
        if Rsquare2<0.3
            fprintf('Low R-square warning! R2=%.3f\n',Rsquare1);
        end
        if Rsquare2<STATS(1)
            k=4;
            c_est=B;
            Rsquare=STATS(1);
             RMSE=RMSE3;
            fprintf('Linear model wins\n\n');
        else
            if mag_change<=threshold
                fprintf('No change. False change is detected!\n\n');
                k=1;
                c_est=B;
                Rsquare=STATS(1);
                RMSE=RMSE3;
            else
                fprintf('lsqcurvefit wins, and the estimated parameters are:\n');
                disp(c_est2)
                k=3;
                c_est=c_est2;
                RMSE=RMSE2;
                Rsquare=Rsquare2;
            end
            
        end
    end
    fprintf('**********************Result**********************\n\n');
end
