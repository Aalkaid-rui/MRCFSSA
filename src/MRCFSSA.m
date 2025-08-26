function [fMin , bestX,MRCFSSA_Convergence_curve ] = MRCFSSA(SearchAgents, iter,c,d,dim,fobj  )
P_percent = 0.2;    % The population size of producers accounts for "P_percent" percent of the total population size       
pNum = round( SearchAgents *  P_percent );    % The population size of the producers   

lb= c.*ones( 1,dim );    % Lower limit/bounds/     a vector
ub= d.*ones( 1,dim );    % Upper limit/bounds/     a vector
N = SearchAgents;
x = zeros(N, dim);
TempPos = zeros(N, dim);
fit = zeros(1, N);

for i = 1 : N
    for j = 1:dim
        x(i,j) = lb(j) + (ub(j) - lb(j)) * rand;
    end
    fit(i) = fobj(x(i, :));
end
[fMin, bestI] = min(fit);
bestX = x(bestI, :); 

%% 
for i = 1:N
    for j = 1:dim
        if rand < 0.08
            x_o = lb(j) + ub(j) - x(i,j);
            TempPos(i,j) = (lb(j) + ub(j)) + rand * x_o;
        else
            TempPos(i,j) = (lb(j) + ub(j)) + rand * x(i,j);
        end
    end
end
for i = 1:N
    if fobj(TempPos(i,:)) < fobj(x(i,:))
        x(i,:) = TempPos(i,:);
    end
    
    if fobj(x(i,:)) < fMin
        fMin = fobj(x(i,:));
        bestX = x(i,:);
    end
end
 
pFit = fit;
pX = x;
[fMin, bestI] = min(fit);
bestX = x(bestI, :);

%% 
for t = 1 : iter    
  
  [ans, sortIndex] = sort( pFit );% Sort.
  [fmax,B]=max( pFit );
   worse= x(B,:);  
         
   r2=rand(1);
   w = 0.2 * cos(pi/2 * (1-(t/iter)));
if(r2<0.8)
    for i = 1 : pNum                                                   % Equation (2&3)
         r1=rand(1);
        x( sortIndex( i ), : ) = w * pX( sortIndex( i ), : )*exp(-(i)/(r1*iter));
        x( sortIndex( i ), : ) = Bounds( x( sortIndex( i ), : ), lb, ub );
        fit( sortIndex( i ) ) = fobj( x( sortIndex( i ), : ) ); 
    end
else
   for i = 1 : pNum        
      x( sortIndex( i ), : ) = w * pX( sortIndex( i ), : )+randn(1)*ones(1,dim); 
      x( sortIndex( i ), : ) = Bounds( x( sortIndex( i ), : ), lb, ub );
      fit( sortIndex( i ) ) = fobj( x( sortIndex( i ), : ) ); 
      end
end
  [ ~, bestII ] = min( fit );      
  bestXX = x( bestII, : );          
 
  
  for i = 1 : pNum  
   x(sortIndex( i ), : ) = func_levy( x( sortIndex( i ), : ),bestXX  );  
   x( sortIndex( i ), : ) = Bounds( x( sortIndex( i ), : ), lb, ub );
   fit( sortIndex( i ) ) = fobj( x( sortIndex( i ), : ) );   
 end    
   [ ~, bestII ] = min( fit );      
   bestXX = x( bestII, : );
  
   for i = ( pNum + 1 ) : SearchAgents                 
         A=floor(rand(1,dim)*2)*2-1;
          if( i>(SearchAgents/2))
           x( sortIndex(i ), : )=randn(1)*exp((worse-pX( sortIndex( i ), : ))/(i)^2);
          else
        x( sortIndex( i ), : )=bestXX+(abs(( pX( sortIndex( i ), : )-bestXX)))*(A'*(A*A')^(-1))*ones(1,dim);  
         end  
        x( sortIndex( i ), : ) = Bounds( x( sortIndex( i ), : ), lb, ub );
        fit( sortIndex( i ) ) = fobj( x( sortIndex( i ), : ) );   
   end

   
%% equation6   
   c=randperm(numel(sortIndex));
   b=sortIndex(c(1:20));
for j =  1  : length(b)      % Equation (5)  
    % 
    if (mod(j,2) == 1)      
        for i = 1 : dim         
            r = rand();         
            c = 2*rand()-1;         
            x_criss( sortIndex( b(j) ), i ) = r * pX( sortIndex( b(j) ), i )+(1-r)*pX( sortIndex( b(j+1) ), i )+c*(pX( sortIndex( b(j) ), i )-pX( sortIndex( b(j+1) ), i ));   
        end 
    else      
        for i = 1 : dim     
            r = rand();         
            c = 2*rand()-1;       
            x_criss( sortIndex( b(j) ), i ) = r * pX( sortIndex( b(j-1) ), i )+(1-r)*pX( sortIndex( b(j) ), i )+c*(pX( sortIndex( b(j-1) ), i )-pX( sortIndex( b(j) ), i ));  
        end 
    end    
    if fobj( x_criss( sortIndex( b(j) ), : ) ) < fobj( pX( sortIndex( b(j) ), : ) )   
        x( sortIndex( b(j) ), : ) = x_criss( sortIndex( b(j) ), : ); 
    else    
        x( sortIndex( b(j) ), : ) = pX( sortIndex( b(j) ), : );  
    end   
    x( sortIndex(b(j) ), : ) = Bounds( x( sortIndex(b(j) ), : ), lb, ub );  fit( sortIndex( b(j) ) ) = fobj( x( sortIndex( b(j) ), : ) );
    % 
    for i = 1 : dim    
        d1 = randperm(dim,1);  
        d2 = randperm(dim,1);    
        r1 = rand();     
        x_cross(sortIndex( b(j) ), i) = r1*x( sortIndex(b(j) ), d1 ) + (1-r1)*x( sortIndex(b(j) ), d2 );
    end    
    if fobj( x_cross( sortIndex( b(j) ), : ) ) < fobj( x( sortIndex( b(j) ), : ) )  
        x( sortIndex( b(j) ), : ) = x_cross( sortIndex( b(j) ), : ); 
    else   
        x( sortIndex( b(j) ), : ) = x( sortIndex( b(j) ), : ); 
    end  
    x( sortIndex(b(j) ), : ) = Bounds( x( sortIndex(b(j) ), : ), lb, ub );  
    fit( sortIndex( b(j) ) ) = fobj( x( sortIndex( b(j) ), : ) );
end


    for i = 1 : SearchAgents 
        if ( fit( i ) < pFit( i ) )
            pFit( i ) = fit( i );
            pX( i, : ) = x( i, : );
        end
        
        if( pFit( i ) < fMin )
           fMin= pFit( i );
           bestX = pX( i, : );
        end
    end
   
   MRCFSSA_Convergence_curve(t)=fMin;
  
end

% Application of simple limits/bounds
function s = Bounds( s, Lb, Ub)
  % Apply the lower bound vector
  temp = s;
  I = temp < Lb;
  temp(I) = Lb(I);
  
  % Apply the upper bound vector 
  J = temp > Ub;
  temp(J) = Ub(J);
  % Update this new move 
  s = temp;