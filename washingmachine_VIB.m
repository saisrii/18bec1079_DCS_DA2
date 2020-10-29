clc
clear all
num = xlsread('test550.csv');
num = num(1:2:end,:);                                           % Eliminate ‘NaN’ Values
num(:,1) = num(:,1)*1E-3;                                       % Convert Milliseconds To Seconds
Fs = 1/mean(diff(num(:,1)));                                    % Sampling Frequency (Convert Milliseconds To Seconds)
Fn = Fs/2;                                                      % Nyquist Frequency
Tr = linspace(num(1,1), num(1,end), size(num,1));               % Time Vector (Regular Samples)
Dr = resample(num(:,2:end), Tr);                                % Resample To Constant Sampling Interval
Dr_mc  = Dr - mean(Dr,1);                                       % Subtract Mean
FDr_mc = fft(Dr_mc, [], 1);                                     % Fourier Transform
Fv = linspace(0, 1, fix(size(FDr_mc,1)/2)+1)*Fn;                % Frequency Vector
Iv = 1:numel(Fv);                                               % Iv Vector


figure(1)
plot(Fv, abs(FDr_mc(Iv,:))*2)
grid
hl = legend('B','C','D','E','F', 'Location','NE')
title(hl, 'Excel Columns')
xlabel('Frequency (Hz)')
ylabel('Amplitude')


figure(2);
hold on;
stem(Fv, abs(FDr_mc(Iv,:))*2); % plot of sampled signal
title('SAMPLED SIGNAL  18bec1079');
xlabel('TIME');
ylabel('AMPLITUDE');
hold off;

A=max(num);
B=min(num);

n1=4                                                              ;%NO OF BITS PER SAMPLE
L=2^n1;
del=(A-B)/L;

partition=B:del:A;                                                % definition of decision lines
codebook=(B-(del/2)):del:(A+(del/2));                             % definition of representation levels
[index,quants] = quantiz(Fv,partition,codebook);


figure(3)
stem(quants)
xlabel('TIME(s)');
ylabel('Amplitude(uv)');
title('quantized output');
l1=length(Iv);                                                     % to convert 1 to n as 0 to n-1 indicies
for i=1:l1
if (Iv(i)~=0)
Iv(i)=Iv(i)-1;
end
end
l2=length(quants);
for i=1:l2                                                          % to convert the end representation levels within the range.
if(quants(i)==B-(del/2))
quants(i)=B+(del/2);
end
if(quants(i)==A+(del/2))
quants(i)=A-(del/2);
end
end




code=de2bi(Iv,'left-msb');                                          % DECIMAL TO BINANRY CONV OF INDICIES
k=1;
for i=1:l1                                                          % to convert column vector to row vector
 for j=1:n1
  coded(k)=code(i,j);
  j=j+1;
  k=k+1;
 end
 i=i+1;
end


figure(4);   
hold on;
stairs(coded);                                                      % to plot coded in a stairs
axis([0 200 -2 2])
%plot of digital signal
title('DIGITAL SIGNAL');
xlabel('TIME');
ylabel('AMPLITUDE');
hold off;
% DEMODULATION
code1=reshape(coded,n1,(length(coded)/n1));
Iv1=bi2de(code1,'left-msb');
resignal=del.*(Iv1+B+(del/2));


figure(5);
hold on;
plot(resignal);
title('DEMODULATED SIGNAL');
xlabel('TIME');
ylabel('AMPLITUDE');
hold off;