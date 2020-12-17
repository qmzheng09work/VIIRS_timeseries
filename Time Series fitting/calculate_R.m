function R_square=calculate_R(fun,para,x,y)
R_square=0;
y_est=fun(para,x);
SST=sum((y-mean(y)).^2);
SSE=sum((y-y_est).^2);
R_square=1-SSE/SST;