function outputs = input_processing(input)

% Operating Conditions
input.Tmin = input.Tm;
input.Tmax = input.Tb;

% Fluid Properties
input.alp1 = input.k1/(input.Cp1*10^3*input.rho1);  % thermal diffusivity of ice (m2/s)
input.alp2 = input.k2/(input.Cp2*10^3*input.rho2);   % thermal diffusivity of water (m2/s)
if isempty(input.alp)
    input.alp = input.alp2/input.alp1;  % Dimensionless thermal diffusivity
end

% Dimensionless Parameters
input.temp_non = @(x) (x-input.Tm)/(input.T0-input.Tm);  % temperature conversion (from actual to dimensionless)
input.temp_dim = @(x) x*(input.T0-input.Tm) + input.Tm;  % temperature conversion (from dimensionless to actual)
input.time_non = @(x) (x*input.alp1*60)/(input.b)^2;  % time conversion (from actual to dimensionless)
input.time_dim = @(x) (x*(input.b)^2)/(input.alp1*60);  % time conversion (from dimensionless to actual)
input.Tb_d = input.temp_non(input.Tb);  % dimensionless boundary temperature
input.Tm_d = 0;  % dimensionless melting point
input.Ste = input.Cp1*(input.T0-input.Tm)/input.L;  % Stefan number (dimensionless)
input.Tini_d = input.temp_non(input.Tini);  % dimensionless initial temperature
input.IC = [input.Tm_d*ones(2*input.n1,1); 1-input.tol];  % initial condition
input.TAH_d = input.temp_non(input.TAH);  % dimensionless temperature alarm high
input.U_d = input.U*input.b/input.k2;

% Numerics
input.endtime_d = input.time_non(input.endtime);  % dimensionless end time
input.dR = 1/input.n1;
input.option_ode1 = odeset('RelTol', input.tol_ode, 'AbsTol', input.tol_ode);  % options
input.option_ode2 = odeset('Events', @(t,T)Event_CompleteMelting(t,T,input), 'RelTol', ...
    input.tol_ode,'AbsTol', input.tol_ode);  % options with event checking
input.optfmincon = optimoptions('fmincon');
input.optfminconpar = optimoptions('fmincon','UseParallel',true);
input.optIpopt = optiset('solver','Ipopt');
input.optCSD = [];
 
% Export
outputs = input;

return
