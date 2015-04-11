parfor_progress(0); clc
N = 100;
parfor_progress(N);
parfor i=1:N+1
    pause(rand); % Replace with real code
    parfor_progress;
end
