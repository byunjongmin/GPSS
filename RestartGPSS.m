% =========================================================================
%> @section INTRO RestartGPSS
%>
%> - GPSS 구동이 갑자기 정지된 경우에도 연속하여 모의실험을 진행할 수 있도록
%>   도와주는 함수
%>  - 지금까지 기록된 모의결과 파일로 부터 다음 실행시 시작횟수를 파악하고
%>    다음 실행에 초기 지형 조건으로 들어가는 기반암 고도와 퇴적층 두께를
%>    추출하여 파일에 기록함
%>  - 다음 실행에 사용될 기반암 고도와 퇴적층 두께 파일을 input 디렉토리에
%>    옮기고, paraterValues.txt에서는 아래의 항목을 수정하고 GPSSMain()을
%>    재실행하면 됨
%>    - INIT_BEDROCK_ELEV_FILE : (초기지형을 불러올 경우) 초기지형을 저장한 파일. 없다면 No 라고 표기함
%>    - newInitBedrockElev.txt
%>    - ...
%>    - INIT_SED_THICK_FILE : 초기 지형의 퇴적층 두께를 불러올 경우 이를 저장한 파일. 없다면 No 라고 표기함
%>    - newInitSedThick.txt
%>    - ...
%>    - INIT_TIME_STEP_NO : 이전 모형 결과에서 이어서 할 경우의 초기 실행 횟수. 이어서 하지 않는다면 1
%>    - newInitTimeStepNo
%>
%> - 최종 작성일 : 2011-10-08
%>
%> - Histroy
%>
%> - 추가정보
%>  - 이 코드의 변수명은 Johnson (2002)의 변수명 표기 추천을 따르며, 다음과 같음.
%> "1. > 1) > (1) > A. > A) > (A) > a. > a) > (a)"
%>
%> @callgraph
%> @callergraph
%> @version 0.1
%>
%> 
%> @retval newInitTimeStepNo            : 다음 실행시 초기 실행 횟수
%>
%> @param OUTPUT_SUBDIR                 : GPSS 구동이 중지된 모의실험 결과가 저장된 디렉터리명
%> @param Y                             : 외곽 경계를 제외환 Y축 크기
%> @param X                             : 외곽 경계를 제외한 X축 크기
%> @param dT                            : 만제유량 재현기간
%> @param WRITE_INTERVAL                : 모의결과를 출력하는 빈도
%>
% =========================================================================
function newInitTimeStepNo = RestartGPSS(OUTPUT_SUBDIR,Y,X,WRITE_INTERVAL)
%
% RestartGPSS
%

% 상수 정의
mRows = Y + 2;
nCols = X + 2;

% 1. 모의결과 출력 파일들을 엶

% 모의결과 파일을 포함하는 디렉터리 설정
DATA_DIR = 'data';      % 입출력 파일을 저장하는 최상위 디렉터리
OUTPUT_DIR = 'output';  % 출력 파일을 저장할 디렉터리
OUTPUT_DIR_PATH = fullfile(DATA_DIR,OUTPUT_DIR);
OUTPUT_SUBDIR_PATH = fullfile(OUTPUT_DIR_PATH,OUTPUT_SUBDIR);

% 모의결과 파일 설정
OUTPUT_FILE_SEDTHICK ...                % i번째 퇴적층 두께 [m]
    = 'sedThick.txt';
OUTPUT_FILE_BEDROCKELEV ...             % i번째 기반암 고도 [m]
    = 'bedrockElev.txt';
OUTPUT_FILE_WEATHER ...                 % 풍화율 [m/dT]
    = 'weatherProduct.txt';
OUTPUT_FILE_dSEDTHICK_BYHILLSLOPE ...   % 사면작용에 의한 퇴적층 두께 변화율 [m^3/m^2 dT]
    = 'dSedThickByHillslope.txt';
OUTPUT_FILE_CHANBEDSEDBUDGET ...        % 사면작용에 의한 하도 양안으로부터 하도로의 공급율 [m^3/m^2 dT]
    = 'chanBedSedBudget.txt';
OUTPUT_FILE_dSEDTHICK_BYFLUVIAL ...     % 하천작용에 의한 퇴적층 두께 변화율 [m^3/m^2 dT]
    = 'dSedThickByFluvial.txt';
OUTPUT_FILE_dBEDROCKELEV_BYFLUVIAL ...  % 하천작용에 의한 기반암 고도 변화율 [m^3/m^2 dT]
    = 'dBedrockElevByFluvial.txt';
OUTPUT_FILE_dSEDTHICK_BYRAPIDMASS ...   % 빠른 매스무브먼트에 의한 퇴적층 두께 변화율 [m^3/m^2 dT]
    = 'dSedThickByRapidMassmove.txt';
OUTPUT_FILE_dBEDROCKELEV_BYRAPIDMASS ... % 빠른 매스무브먼트에 의한 기반암 고도 변화율 [m^3/m^2 dT]
    = 'dBedrockElevByRapidMassmove.txt';
OUTPUT_FILE_LOG ...                     % GPSSMain() 구동 동안의 상황 기록
    = 'log.txt';

% 모의결과 파일의 경로 설정
OUTPUT_FILE_WEATHER_PATH ...
    = fullfile(OUTPUT_SUBDIR_PATH,OUTPUT_FILE_WEATHER);
OUTPUT_FILE_SEDTHICK_PATH ...`
    = fullfile(OUTPUT_SUBDIR_PATH,OUTPUT_FILE_SEDTHICK);
OUTPUT_FILE_BEDROCKELEV_PATH ...
    = fullfile(OUTPUT_SUBDIR_PATH,OUTPUT_FILE_BEDROCKELEV);
OUTPUT_FILE_dSEDTHICK_BYHILLSLOPE_PATH ...
    = fullfile(OUTPUT_SUBDIR_PATH,OUTPUT_FILE_dSEDTHICK_BYHILLSLOPE);
OUTPUT_FILE_CHANBEDSEDBUDGET_PATH ...
    = fullfile(OUTPUT_SUBDIR_PATH,OUTPUT_FILE_CHANBEDSEDBUDGET);
OUTPUT_FILE_dSEDTHICK_BYFLUVIAL_PATH ...
    = fullfile(OUTPUT_SUBDIR_PATH,OUTPUT_FILE_dSEDTHICK_BYFLUVIAL);
OUTPUT_FILE_dBEDROCKELEV_BYFLUVIAL_PATH ...
    = fullfile(OUTPUT_SUBDIR_PATH,OUTPUT_FILE_dBEDROCKELEV_BYFLUVIAL);
OUTPUT_FILE_dSEDTHICK_BYRAPIDMASS_PATH ...
    = fullfile(OUTPUT_SUBDIR_PATH,OUTPUT_FILE_dSEDTHICK_BYRAPIDMASS);
OUTPUT_FILE_dBEDROCKELEV_BYRAPIDMASS_PATH ...
    = fullfile(OUTPUT_SUBDIR_PATH,OUTPUT_FILE_dBEDROCKELEV_BYRAPIDMASS);
OUTPUT_FILE_LOG_PATH ...
    = fullfile(OUTPUT_SUBDIR_PATH,OUTPUT_FILE_LOG);

% 개별 파일을 열어둠: read 모드로 파일을 엶
FID_SEDTHICK = fopen(OUTPUT_FILE_SEDTHICK_PATH,'r');
FID_BEDROCKELEV = fopen(OUTPUT_FILE_BEDROCKELEV_PATH,'r');
FID_WEATHER = fopen(OUTPUT_FILE_WEATHER_PATH,'r');
FID_dSEDTHICK_BYHILLSLOPE = fopen(OUTPUT_FILE_dSEDTHICK_BYHILLSLOPE_PATH,'r');
FID_CHANBEDSEDBUDGET = fopen(OUTPUT_FILE_CHANBEDSEDBUDGET_PATH,'r');
FID_dSEDTHICK_BYFLUVIAL = fopen(OUTPUT_FILE_dSEDTHICK_BYFLUVIAL_PATH,'r');
FID_dBEDROCKELEV_BYFLUVIAL = fopen(OUTPUT_FILE_dBEDROCKELEV_BYFLUVIAL_PATH,'r');
FID_dSEDTHICK_BYRAPIDMASS = fopen(OUTPUT_FILE_dSEDTHICK_BYRAPIDMASS_PATH,'r');
FID_dBEDROCKELEV_BYRAPIDMASS = fopen(OUTPUT_FILE_dBEDROCKELEV_BYRAPIDMASS_PATH,'r');
FID_LOG = fopen(OUTPUT_FILE_LOG_PATH,'r');

% 2. 다음 시작 횟수를 파악함

% 1) sedThick.txt의 마지막 줄 번호를 파악함
nLines = 0;
while (fgets(FID_SEDTHICK) ~= -1) % 텍스트 문자열(string)이 'eof' 지시자를 가지지 않을 경우
    nLines = nLines + 1;
end
fseek(FID_SEDTHICK, 0, 'bof'); % 다음을 위해 파일의 처음으로 돌아감

% 2) 다음 실행의 초기 실행 횟수
lastWritingCount = nLines / (mRows * nCols) - 1; % 마지막으로 기록된 횟수

% * 주의: dt를 곱하지 않음 
newInitTimeStepNo = lastWritingCount * WRITE_INTERVAL + 1;

% 3. 다음 실행의 초기 기반암 고도와 퇴적층 두께를 구함


% 1) 초기 퇴적층 두께와 기반암 고도 읽음

% * 주의: 이는 초기 지형 및 초기 퇴적층 두께를 결과 파일에 출력하기 때문임
initSedThick = fscanf(FID_SEDTHICK,'%f',[mRows,nCols]);
initBedrockElev = fscanf(FID_BEDROCKELEV,'%f',[mRows,nCols]);

% 2) 마지막으로 기록된 횟수 전까지 읽어들임
for ithWritingStep = 1:(lastWritingCount - 1)
    
    % * 주의: 불러오는 퇴적층 두께 및 기반암 고도는 GPSSMain()에서 AdjustBoundary,
    %   Uplift 함수가 반영되었지만 외적 작용은 반영되지 않은 시점의 것임
    sedimentThick ...                   % (외적 작용 이전) 퇴적층 두께
        = fscanf(FID_SEDTHICK,'%f',[mRows,nCols]);
    
    bedrockElev ...                     % (외적 작용 이전) 기반암 고도
        = fscanf(FID_BEDROCKELEV,'%f',[mRows,nCols]);
    
    weatheringProduct ...               % 풍화율 [m/dT]
        = fscanf(FID_WEATHER,'%f',[mRows,nCols]);
    
    dSedThickByHillslopePerDT ...       % 사면작용에 의한 퇴적층 두께 변화율 [m^3/m^2 dT]
        = fscanf(FID_dSEDTHICK_BYHILLSLOPE,'%f',[mRows,nCols]);
    
    dSedThickByRapidMassPerDT ... % 빠른 사면작용에 의한 퇴적층 두께 변화율 [m^3/m^2 dT]
        = fscanf(FID_dSEDTHICK_BYRAPIDMASS,'%f',[mRows,nCols]);
    
    dBedrockElevByRapidMassPerDT ... % 빠른 사면작용에 의한 기반암 고도 변화율 [m^3/m^2 dT]
        = fscanf(FID_dBEDROCKELEV_BYRAPIDMASS,'%f',[mRows,nCols]);
    
    dSedThickByFluvialPerDT ...         % 하천작용에 의한 퇴적물 두께 변화율 [m^3/m^2 dT]
        = fscanf(FID_dSEDTHICK_BYFLUVIAL,'%f',[mRows,nCols]);
    
    dBedrockElevByFluvialPerDT ...      % 하천작용에 의한 기반암 고도 변화율[m^3/m^2 dT]
        = fscanf(FID_dBEDROCKELEV_BYFLUVIAL,'%f',[mRows,nCols]);
    
    chanBedSedBudget ...                % 하도 내 하상 퇴적물 물질 수지 [m^3/dT]
        = fscanf(FID_CHANBEDSEDBUDGET,'%f',[mRows,nCols]);
    
end

% 3) 마지막으로 기록된 횟수의 변수를 저장함
sedimentThick ...                   % (외적 작용 이전) 퇴적층 두께
    = fscanf(FID_SEDTHICK,'%f',[mRows,nCols]);

bedrockElev ...                     % (외적 작용 이전) 기반암 고도
    = fscanf(FID_BEDROCKELEV,'%f',[mRows,nCols]);

weatheringProduct ...               % 풍화율 [m/dT]
    = fscanf(FID_WEATHER,'%f',[mRows,nCols]);

dSedThickByHillslopePerDT ...       % 사면작용에 의한 퇴적층 두께 변화율 [m^3/m^2 dT]
    = fscanf(FID_dSEDTHICK_BYHILLSLOPE,'%f',[mRows,nCols]);

dSedThickByRapidMassPerDT ... % 빠른 사면작용에 의한 퇴적층 두께 변화율 [m^3/m^2 dT]
    = fscanf(FID_dSEDTHICK_BYRAPIDMASS,'%f',[mRows,nCols]);

dBedrockElevByRapidMassPerDT ... % 빠른 사면작용에 의한 기반암 고도 변화율 [m^3/m^2 dT]
    = fscanf(FID_dBEDROCKELEV_BYRAPIDMASS,'%f',[mRows,nCols]);

dSedThickByFluvialPerDT ...         % 하천작용에 의한 퇴적물 두께 변화율 [m^3/m^2 dT]
    = fscanf(FID_dSEDTHICK_BYFLUVIAL,'%f',[mRows,nCols]);

dBedrockElevByFluvialPerDT ...      % 하천작용에 의한 기반암 고도 변화율[m^3/m^2 dT]
    = fscanf(FID_dBEDROCKELEV_BYFLUVIAL,'%f',[mRows,nCols]);

% chanBedSedBudget ...                % 하도 내 하상 퇴적물 물질 수지 [m^3/dT]
%     = fscanf(FID_CHANBEDSEDBUDGET,'%f',[mRows,nCols]);

% 4) 마지막 횟수에서 외적 작용으로 인한 변화율을 기반암 고도와 퇴적층 두께에 반영함
bedrockElev = bedrockElev - weatheringProduct ...
            + dBedrockElevByFluvialPerDT + dBedrockElevByRapidMassPerDT;

sedimentThick = sedimentThick + weatheringProduct ...
                + dSedThickByHillslopePerDT + dSedThickByFluvialPerDT ...
                + dSedThickByRapidMassPerDT;
            
% 3. 파일로 출력하기
OUTPUT_FILE_NEWINIT_SEDTHICK ...                % 다음 실행의 초기 퇴적층 두께 [m]
    = 'newInitSedThick.txt';
OUTPUT_FILE_NEWINIT_BEDROCKELEV ...             % 다음 실행의 초기 기반암 고도 [m]
    = 'newInitBedrockElev.txt';

OUTPUT_FILE_NEWINIT_SEDTHICK_PATH ...`
    = fullfile(OUTPUT_SUBDIR_PATH,OUTPUT_FILE_NEWINIT_SEDTHICK);
OUTPUT_FILE_NEWINIT_BEDROCKELEV_PATH ...
    = fullfile(OUTPUT_SUBDIR_PATH,OUTPUT_FILE_NEWINIT_BEDROCKELEV);

FID_NEWINIT_SEDTHICK = fopen(OUTPUT_FILE_NEWINIT_SEDTHICK_PATH,'w');
FID_NEWINIT_BEDROCKELEV = fopen(OUTPUT_FILE_NEWINIT_BEDROCKELEV_PATH,'w');

% 다음 실행의 초기 퇴적층 두께
fprintf(FID_NEWINIT_SEDTHICK,'%i\n',mRows);
fprintf(FID_NEWINIT_SEDTHICK,'%i\n',nCols);
fprintf(FID_NEWINIT_SEDTHICK,'%14.10f\n',sedimentThick);        
% 다음 실행의 초기 기반암 고도
% * 주의: 초기 기반암 고도를 가진 파일에는 파일 첫줄과 둘째줄에 행과 열 정보가
%   기록되어야 함.
fprintf(FID_NEWINIT_BEDROCKELEV,'%i\n',mRows);
fprintf(FID_NEWINIT_BEDROCKELEV,'%i\n',nCols);
fprintf(FID_NEWINIT_BEDROCKELEV,'%14.10f\n',bedrockElev);

% 4. 파일 닫기
fclose(FID_WEATHER);
fclose(FID_SEDTHICK);
fclose(FID_BEDROCKELEV);
fclose(FID_dSEDTHICK_BYHILLSLOPE);
fclose(FID_CHANBEDSEDBUDGET);
fclose(FID_dSEDTHICK_BYFLUVIAL);
fclose(FID_dBEDROCKELEV_BYFLUVIAL);
fclose(FID_dSEDTHICK_BYRAPIDMASS);
fclose(FID_dBEDROCKELEV_BYRAPIDMASS);
fclose(FID_LOG);

fclose(FID_NEWINIT_SEDTHICK);
fclose(FID_NEWINIT_BEDROCKELEV);


% 5. 확인하기
% elev = bedrockElev + sedimentThick;
% Y_INI = 2;
% Y_MAX = Y + 1;
% X_INI = 2;
% X_MAX = X + 1;
% imshow(elev(Y_INI:Y_MAX,X_INI:X_MAX),[],'InitialMagnification','fit')
% colormap jet
% colorbar

