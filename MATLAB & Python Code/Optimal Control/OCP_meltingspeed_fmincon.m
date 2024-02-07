function outputs = OCP_meltingspeed_fmincon(input,filename)

% Input data
nrun = input.nrun;
nc = input.nc;
endtime = input.endtime_Itf;
tspan = (0:input.dt_plot:endtime)';
Tb_min = input.Tmin;  % lower bound
Tb_max = input.Tmax;  % upper bound
Tb_def = 0.5*(Tb_max+Tb_min);  % default heater temperature 
tb = linspace(0,input.endtime_Itf,nc+1)';
twall = zeros(nrun,1);
Tb = zeros(nc+1,nrun);
fval = zeros(nrun,1);

% Initial guess
if isempty(filename)
    Tb_ini = Tb_def*ones(nc+1,1);
    twall0 = 0;
else
    Data0 = load(filename).Data;
    nc0 = height(Data0.Tb_opt)-1;
    Tb0 = Data0.Tb_opt;
    twall0 = Data0.twall;
    tb0 = linspace(0,endtime,nc0+1)';
    Tb_ini = interp1(tb0 , Tb0, tb);
end

% Optimization using fmincon
for k = 1:nrun
    tic
    Tb_lb = Tb_min*ones(nc+1,1);
    Tb_ub = Tb_max*ones(nc+1,1);
    [Tb(:,k), fval(k)] = fmincon(@(Tb)obj_meltingspeed_pl(Tb, tb, tspan, input.dSdt_obj, input.IC, input.option_ode2, input), ...
        Tb_ini, [], [], [], [], Tb_lb, Tb_ub,[],input.optfmincon);
    twall(k) = toc;
end

% Export data
Data.Tb_opt = Tb(:,1);
Data.tb = tb;
Data.twall = mean(twall) + twall0;
Data.ext = filename;
Data.Tb_ini = Tb_ini;
outputs = Data;

return