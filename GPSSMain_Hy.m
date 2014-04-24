% =========================================================================
%> @section INTRO GPSS main
%>
%> - 지질시간규모의 지형발달을 컴퓨터 상에서 모의하는 프로그램.
%>  - 입력 변수를 읽어들이고 이를 토대로 다양한 지형형성작용으로 인한 지형속성의
%>    변화를 기록하는 주함수로서 다양한 부함수들을 호출함.
%> - 프로그램명 : GPSS(Geomorphological Process System Simulator)
%> - 작성자 : 변 종 민
%> - 최종 작성일 : 2011-08-19
%>
%> - Histroy
%>  - 2011-10-13
%>   - 하천 수리기하 법칙으로부터 수심 추정
%>  - 2011-08-19
%>   - 사면 셀에서 지표유출로 인한 물질이동을 포함함
%>  - 2010-12-21
%>   - RapidMassMovement 함수에 활동 발생확률 개념을 도입함.
%>  - 2010-12-21
%>   - 갑자기 GPSS 함수가 중단되더라도 이전 결과출력 파일에 이어서 시작할 수
%>     있도록 하기위해 중지되기 직전의 퇴적층 두께를 읽어 들임. 이와 더불어 이전
%>     결과의 단위 시간을 파악하고 이후부터 실행할 수 있도록 수정함.
%>  - 2010-09-28
%>   - RapidMassMovement 함수의 실행 속도를 향상하기 위해 CollapseMex.c를 도입함.
%>
%> - 추가정보
%>  - 이 코드의 변수명은 Johnson (2002)의 변수명 표기 추천을 따르며, 다음과 같음.
%> "1. > 1) > (1) > A. > A) > (A) > a. > a) > (a)"
%>
%> @callgraph
%> @callergraph
%> @version 1.82
%> @see FluvialProcess(), AccumulateUpstreamFlow(), ProcessSink(),
%>      RapidMassMovement(), CalcSDSFlow(), AdjustBoundary(),
%>      CalcInfinitiveFlow(), DefineUpriftRateDistribution(),
%>      EstimateSubDT(), HillslopeProcess(), LoadParameterValues(),
%>      MakeInitialGeomorphology(), RockWeathering(), Uplift()
%>
%> @attention Copyright(c). 2011. 변종민. All rights reserved.
%> - 비상업적인 목적으로 이용할 경우에 한해 사용이 가능함.
%> - 자세한 사항은 변종민(email : cyberzen.byun At gmail.com)에게 문의 바람.
%> 
%> @retval sedThick.txt                     : 퇴적층 두께 [m]
%> @retval bedrockElev.txt                  : 기반암 고도 [m]
%> @retval weatherProduct.txt               : 풍화율 [m/dT]
%> @retval dSedThickByHillslope.txt         : 사면작용에 의한 퇴적층 두께 변화율 [m^3/m^2 dT]
%> @retval chanBedSedBudget.txt             : 하도 내 퇴적층 수지 [m^3/dT]
%> @retval dSedThickByFluvial.txt           : 하천작용에 의한 퇴적층 두께 변화율 [m^3/m^2 dT]
%> @retval dBedrockElevByFluvial.txt        : 하천작용에 의한 기반암 고도 변화율 [m^3/m^2 dT]
%> @retval dSedThickByRapidMassmove.txt     : 활동에 의한 퇴적층 두께 변화율 [m^3/m^2 dT]
%> @retval dBedrockElevByRapidMassmove.txt  : 활동에 의한 기반암 고도 변화율 [m^3/m^2 dT]
%> @retval log.txt                          : GPSS 구동 동안의 상황 기록
%>
%> @param parameterValuesFile               : GPSS 함수의 입력인자로 초기 입력자료를 저장하고 있는 파일 이름
% =========================================================================
function GPSSMain_Hy(parameterValuesFile)

%--------------------------------------------------------------------------
% GPSS 2D 시작
clc;
fprintf('\n*************** GPSS 2D Start ***************\n');
fprintf('Made by Jongmin Byun (Post-doctoral researcher, Department of Geography Education, Korea Univ.)\n');
fprintf('Source download at Blog (http://www.byunjongmin.net)\n');
startedTime = clock; % 시작 시간 기록

% 입출력을 위한 디렉터리와 출력 파일을 정의하고 중요한 초기 변수값을 입력
% * 주의 : 입력을 위한 디렉터리와 출력을 위한 디렉터리가 구분됨. 출력을 위한
%   디렉터리에는 세부 디렉터리를 지정할 수 있음.

% 디렉터리 이름 상수
DATA_DIR = 'data';      % 입출력 파일을 저장하는 최상위 디렉터리
INPUT_DIR = 'input';    % 입력 파일이 저장되는 디렉터리
OUTPUT_DIR = 'output';  % 출력 파일을 저장할 디렉터리

% 디렉터리 경로 상수
INPUT_DIR_PATH = fullfile(DATA_DIR,INPUT_DIR);
OUTPUT_DIR_PATH = fullfile(DATA_DIR,OUTPUT_DIR);

%--------------------------------------------------------------------------
% AnalyseResult 함수와 동일한 부분

% 출력 파일 상수 : 모의 결과를 기록하는 파일
OUTPUT_FILE_SEDTHICK ...                % i번째 퇴적층 두께 [m]
    = 'sedThick.txt';
OUTPUT_FILE_BEDROCKELEV ...             % i번째 기반암 고도 [m]
    = 'bedrockElev.txt';
OUTPUT_FILE_WEATHER ...                 % 풍화율 [m/dT]
    = 'weatherProduct.txt';
OUTPUT_FILE_dSEDTHICK_BYHILLSLOPE ...   % 사면작용에 의한 퇴적층 두께 변화율 [m^3/m^2 dT]
    = 'dSedThickByHillslope.txt';
OUTPUT_FILE_CHANBEDSEDBUDGET ...        % 하도 내 퇴적층 수지 [m^3/dT]
    = 'chanBedSedBudget.txt';
OUTPUT_FILE_dSEDTHICK_BYFLUVIAL ...     % 하천작용에 의한 퇴적층 두께 변화율 [m^3/m^2 dT]
    = 'dSedThickByFluvial.txt';
OUTPUT_FILE_dBEDROCKELEV_BYFLUVIAL ...  % 하천작용에 의한 기반암 고도 변화율 [m^3/m^2 dT]
    = 'dBedrockElevByFluvial.txt';
OUTPUT_FILE_dSEDTHICK_BYRAPIDMASS ...   % 빠른 매스무브먼트에 의한 퇴적층 두께 변화율 [m^3/m^2 dT]
    = 'dSedThickByRapidMassmove.txt';
OUTPUT_FILE_dBEDROCKELEV_BYRAPIDMASS ... % 빠른 매스무브먼트에 의한 기반암 고도 변화율 [m^3/m^2 dT]
    = 'dBedrockElevByRapidMassmove.txt';
OUTPUT_FILE_LOG ...                     % GPSS 2D 구동 동안의 상황 기록
    = 'log.txt';

% 중요한 초기 변수값을 입력함
INPUT_FILE_PARAM_PATH ...   % 입력 파일 경로 상수
    = fullfile(INPUT_DIR_PATH,parameterValuesFile);
[OUTPUT_SUBDIR ...          % 출력 파일을 저장할 세부 디렉터리
,Y ...                      % (초기 지형을 만들 경우) 외곽 경계를 제외한 Y축 크기
,X ...                      % (초기 지형을 만들 경우) 외곽 경계를 제외한 X축 크기
,dX ...                     % 셀 크기
,PLANE_ANGLE ...            % (초기 지형을 만들 경우) 평탄면의 경사 [m/m]
,INIT_BEDROCK_ELEV_FILE ... % (초기 지형을 불러올 경우) 초기 지형을 저장한 파일
,initSedThick ...           % 초기 퇴적층 두께 [m]
,INIT_SED_THICK_FILE ...    % 초기 지형의 퇴적층 두께를 불러올 경우 이를 저장한 파일
,TIME_STEPS_NO ...          % 총 실행 횟수
,INIT_TIME_STEP_NO ...      % 이전 모형 결과에서 이어서 할 경우의 초기 실행 횟수
,dT ...                     % TIME_STEPS_NO를 줄이기 위한 만제유량 재현기간 [yr]
,WRITE_INTERVAL ...         % 모의 결과를 출력하는 빈도 결정
,BOUNDARY_OUTFLOW_COND ...  % 모델 영역으로부터 유출이 발생하는 유출구 또는 경계를 지정
,TOP_BOUNDARY_ELEV_COND ...     % 위 외곽 경계 고도 조건
,IS_LEFT_RIGHT_CONNECTED ...    % 좌우 외곽 경계 연결을 결정
,TOTAL_ACCUMULATED_UPLIFT ...   % 모의 기간 동안 총 지반 융기량 [m]
,IS_TILTED_UPWARPING ...        % 경동성 요곡 지반융기 운동을 결정
,UPLIFT_AXIS_DISTANCE_FROM_COAST ...    % 해안선으로부터 융기축까지의 거리 [m]
,RAMP_ANGLE_TO_TOP ...          % (누적 지반 융기량을 기준) 융기축에서 위 경계로의 각
,Y_TOP_BND_FINAL_ELEV ...       % 위 경계의 최종 고도
,UPLIFT_RATE_TEMPORAL_DISTRIBUTION_COND ... % 융기율의 시간적 분포 결정
,acceleratedUpliftPhaseNo ...   % (간헐적 융기조건) 모의기간 동안 높은 융기율이 발생하는 빈도
,dUpliftRate ...            % (간헐적 융기조건) 평균 연간 융기율을 기준으로 최대 최소 융기율의 차이 비율
,upliftRate0 ...            % (융기율 감소조건) 융기율 감쇠분포의 초기 융기율 [m/yr]
,waveArrivalTime ...        % (경동성 요곡 지반융기 조건) 영서 외곽 경계 고도가 본격적으로 하강하는 시점 (모의 기간에서 비율)
,initUpliftRate ...         % (경동성 요곡 지반융기 조건) 본격적 하강 이전 침식 기준면 하강율 [m/yr]
,kw0 ...                    % 선형 풍화함수에서 연장되는 노출 기반암의 풍화율 [m/yr]
,kwa ...                    % 선형 풍화함수의 증가율
,kw1 ...                    % 지수 감소 풍화함수에서 연장되는 노출 기반암의 풍화율 [m/yr]
,kwm ...                    % 풍화층 두께 축적 [m]
,kmd ...                    % 사면작용의 확산 계수
,soilCriticalSlopeForFailure ... % 천부활동의 안정 사면각
,rockCriticalSlopeForFailure ... % 기반암활동의 안정 사면각
,annualPrecipitation ...    % 연 강우량 [m/yr]
,annualEvapotranspiration ... % 연 증발산량 [m/yr]
,kqb ...                    % 평균유량과 만제유량과의 관계식에서 계수
,mqb ...                    % 평균유량과 만제유량과의 관계식에서 지수
,bankfullTime ...           % 만제유량 지속 기간 [s]
,timeWeight ...             % 만제유량 지속기간을 줄이기 위한 침식율 가중치
,minSubDT ...               % 최소한의 세부단위 시간 [s]
,khw ...                    % 만제유량과 하폭과의 관계식에서 계수
,mhw ...                    % 만제유량과 하폭과의 관계식에서 지수
,khd ...                    % 만제유량과 수심과의 관계식에서 계수
,mhd ...                    % 만제유량과 수심과의 관계식에서 지수
,FLUVIALPROCESS_COND ...    % flooded region의 순 퇴적물 두께 변화율을 추정하는 방법
,channelInitiation ...      % 하천 시작 지점 임계값
,criticalUpslopeCellsNo ... % 하천 시작 임계 상부유역 셀 개수
,mfa ...                    % 하천에 의한 퇴적물 운반율 수식에서 유량의 지수
,nfa ...                    % 하천에 의한 퇴적물 운반율 수식에서 경사의 지수
,fSRho ...                  % 운반되는 퇴적물의 평균 밀도
,fSD50 ...                  % 운반되는 퇴적물의 중간 입경
,eta ...                    % 운반되는 퇴적물의 평균 공극율
,nA ...                     % 충적 하천 하도에서의 Manning 저항 계수
,mfb ...                    % 기반암 하상 침식율 수식에서 유량의 지수
,nfb ...                    % 기반암 하상 침식율 수식에서 경사의 지수
,kfbre ...                  % 기반암 하상 연약도
,nB] ...                    % 기반암 하상 하도에서의 Manning 저항 계수
    = LoadParameterValues(INPUT_FILE_PARAM_PATH);

% -------------------------------------------------------------------------
% 차후 LoadParameterValues 함수에 포함될 초기 입력값

% 1. 반복문 내 임시 세부 단위시간 설정과 관련된 변수의 계수와 지수
% (최적화된 값을 파악하기 어려워 여기서 일단 고정함)
basicManipulationRatio = 0.5; nt = 4;

%--------------------------------------------------------------------------

% 모의 결과를 저장하는 세부 디렉터리
mkdir(OUTPUT_DIR_PATH,OUTPUT_SUBDIR);
OUTPUT_SUBDIR_PATH = fullfile(OUTPUT_DIR_PATH,OUTPUT_SUBDIR);

% 출력 파일 경로 상수
OUTPUT_FILE_WEATHER_PATH ...
    = fullfile(OUTPUT_SUBDIR_PATH,OUTPUT_FILE_WEATHER);
OUTPUT_FILE_SEDTHICK_PATH ...
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

% 개별 파일을 열어둠
FID_SEDTHICK = fopen(OUTPUT_FILE_SEDTHICK_PATH,'a');
FID_BEDROCKELEV = fopen(OUTPUT_FILE_BEDROCKELEV_PATH,'a');
FID_WEATHER = fopen(OUTPUT_FILE_WEATHER_PATH,'a');
FID_dSEDTHICK_BYHILLSLOPE = fopen(OUTPUT_FILE_dSEDTHICK_BYHILLSLOPE_PATH,'a');
FID_CHANBEDSEDBUDGET = fopen(OUTPUT_FILE_CHANBEDSEDBUDGET_PATH,'a');
FID_dSEDTHICK_BYFLUVIAL = fopen(OUTPUT_FILE_dSEDTHICK_BYFLUVIAL_PATH,'a');
FID_dBEDROCKELEV_BYFLUVIAL = fopen(OUTPUT_FILE_dBEDROCKELEV_BYFLUVIAL_PATH,'a');
FID_dSEDTHICK_BYRAPIDMASS = fopen(OUTPUT_FILE_dSEDTHICK_BYRAPIDMASS_PATH,'a');
FID_dBEDROCKELEV_BYRAPIDMASS = fopen(OUTPUT_FILE_dBEDROCKELEV_BYRAPIDMASS_PATH,'a');
FID_LOG = fopen(OUTPUT_FILE_LOG_PATH,'a');

%--------------------------------------------------------------------------
% 상수 및 변수 초기화

[bedrockElev ...    % 초기 기반암 고도
,sedimentThick ...
,Y ...              % (저장된 초기 지형을 불러올 경우) Y 좌표
,X] ...             % (저장된 초기 지형을 불러올 경우) X 좌표
    = MakeInitialGeomorphology(Y,X,dX,PLANE_ANGLE ...
    ,INPUT_DIR_PATH,OUTPUT_SUBDIR_PATH ...
    ,INIT_BEDROCK_ELEV_FILE,initSedThick,INIT_SED_THICK_FILE);

[mRows ...          % 모델 (외곽 경계 포함) 영역 행 개수
,nCols] ...         % 모델 (외곽 경계 포함) 영역 열 개수
    = size(bedrockElev);

Y_TOP_BND = 1;          % 모델 외곽 위 경계 Y 좌표값
Y_BOTTOM_BND = mRows;   % 모델 외곽 아래 경계 Y 좌표값
Y_INI = 2;              % 모델 영역 Y 시작 좌표값
Y_MAX = Y+1;            % 모델 영역 Y 마지막 좌표값

X_LEFT_BND = 1;         % 모델 외곽 좌 경계 X 좌표값
X_RIGHT_BND = nCols;    % 모델 외곽 우 경계 X 좌표값
X_INI = 2;              % 모델 영역 X 시작 좌표값
X_MAX = X+1;            % 모델 영역 X 마지막 좌표값

OUTER_BOUNDARY = true(mRows,nCols); % 모델 영역 외곽 경계
OUTER_BOUNDARY(Y_INI:Y_MAX,X_INI:X_MAX) = false;

CELL_AREA = dX * dX; % 셀 면적

bankfullTime = ceil(bankfullTime / timeWeight); % 줄어든 만제유량 지속기

QUARTER_PI = 0.785398163397448;     % pi * 0.25
HALF_PI = 1.57079632679490;         % pi * 0.5
ROOT2 = 1.41421356237310;           % sqrt(2)

DISTANCE_RATIO_TO_NBR = [1 ROOT2 1 ROOT2 1 ROOT2 1 ROOT2];

[arrayX ...             % 모델 (외곽 경계 포함) 영역 X 좌표 행렬
,arrayY] ...            % 모델 (외곽 경계 포함) 영역 Y 좌표 행렬
    = meshgrid(X_LEFT_BND:X_RIGHT_BND,Y_TOP_BND:Y_BOTTOM_BND);

% * 주의 : 접두사 's'는 (mRows*mCols) 보다 작은 Y*X 크기를 가지는 행렬
[sArrayX ...            % 모델 (외곽 경계 제외) 영역 X 좌표 행렬
,sArrayY] ...            % 모델 (외곽 경계 제외) 영역 Y 좌표 행렬
    = meshgrid(X_INI:X_MAX,Y_INI:Y_MAX);

% (무한 유향을 구하는 과정에서) facet을 구성하는 중앙 셀(e0) 색인 행렬
e0LinearIndicies ...
    = (arrayX-1) * mRows + arrayY;
% * 주의: 좌우 외곽 경계가 연결되었다면, 좌우 외곽 경계 색인을 수정함
if IS_LEFT_RIGHT_CONNECTED == true
    e0LinearIndicies(:,X_LEFT_BND) = e0LinearIndicies(:,X_MAX);
    e0LinearIndicies(:,X_RIGHT_BND) = e0LinearIndicies(:,X_INI);    
end
sE0LinearIndicies = (sArrayX-1) * mRows + sArrayY;

% (최대하부경사 유향을 구하는 과정에서) 8 방향 이웃 셀을 가리키는 3차원 색인 배열
s3IthNbrLinearIndicies = zeros(Y,X,8);

% * 주의: 순서는 동쪽에서  반 시계 방향.
ithNbrYOffset ... % 중앙 셀로 부터 8 방향 이웃 셀을 가리키기 위한 Y축 옵셋
    = [0 -1 -1 -1  0  1  1  1];
ithNbrXOffset ... % 중앙 셀로 부터 8 방향 이웃 셀을 가리키기 위한 X축 옵셋
    = [1  1  0 -1 -1 -1  0  1];

% facet을 구성하는 e1과 e2의 색인 배열 선언
s3E1LinearIndicies = zeros(Y,X,8);
s3E2LinearIndicies = zeros(Y,X,8);

% * 주의: 반 시계 방향이 절대 아님. Tarboton(1997)의 Figure 2와 Table 1 참고
ithFacetE1Offset ... % e0로부터 facet을 구성하는 e1을 가리키기 위한 옵셋
    = [ mRows   -1       -1       -mRows   ...
       -mRows    1        1        mRows  ];
ithFacetE2Offset ... % e0로부터 facet을 구성하는 e2를 가리키기 위한 옵셋
    = [ mRows-1  mRows-1 -mRows-1 -mRows-1 ...
       -mRows+1 -mRows+1  mRows+1  mRows+1];

% 8 방향 이웃 셀의 색인 및 8 방향 facet의 e1, e2 색인
for ithDir = 1:8
    
    % (동쪽에서 반 시계 방향으로)
    s3IthNbrLinearIndicies(:,:,ithDir) ...  % 각 방향의 이웃 셀 색인
        = e0LinearIndicies(sE0LinearIndicies ...
        + (ithNbrXOffset(ithDir) * mRows + ithNbrYOffset(ithDir)));

    % (동쪽에서 반 시계 방향으로 )
    s3E1LinearIndicies(:,:,ithDir) ...  % 각 facet의 e1 색인
        = e0LinearIndicies(sE0LinearIndicies + ithFacetE1Offset(ithDir));
    s3E2LinearIndicies(:,:,ithDir) ...  % 각 facet의 e2 색인
        = e0LinearIndicies(sE0LinearIndicies + ithFacetE2Offset(ithDir));

end

vectorY = reshape(sArrayY,[],1); % Y 좌표 행렬의 벡터
vectorX = reshape(sArrayX,[],1); % X 좌표 행렬의 벡터

SECPERYEAR = 31536000;          % = 365 * 24 * 60 * 60
FLOODED = 2;                    % flooded region 태그

dTAfterLastShallowLandslide = zeros(mRows,nCols); % 마지막 천부활동 이후 경과 시간
dTAfterLastBedrockLandslide = zeros(mRows,nCols); % 마지막 기반암활동 이후 경과 시간

% oldChanBedSed ...               % 이전 하도 내 하상 퇴적물 [m^3]
%     = zeros(mRows,nCols);    
% dChanBedSedPerDT ...            % 이전 하도 내 하상 퇴적물과의 차이 [m^3/dT]
%     = zeros(mRows,nCols);
chanBedSedBudgetPerDT ...       % 잔존 하상 퇴적물과 새로 구한 퇴적물과의 차이 [m^3/dT]
    = zeros(mRows,nCols);
remnantChanBedSed ...           % 잔존 하상 퇴적물 [m^3]
    = zeros(mRows,nCols);

%--------------------------------------------------------------------------
% 충적 하천에 의한 퇴적물 운반율 수식(Einstein-Brown)의 계수

% * 주의: Hortonian Overlandflow를 가정하였지만, 다른 수문 환경을 첨가할 예정
annualRunoff ...        % 연간 지표 유출량[m/year]
    = annualPrecipitation - annualEvapotranspiration;

g = 9.8;                % 중력 가속도 [m/s^2]
nu = 1.47 * 10^(-6);    % 수분의 동적 점성도 (kinematic viscosity) [m^2/s]
wGamma = 1000;          % 물 비중 [kgf/m^3]
wRho = 1000;            % 물 밀도 [kg/m^3]
fSGamma = fSRho;        % 퇴적물 비중 [kgf/m^3]
s = fSGamma / wGamma;   % 퇴적물 상대 밀도 []
F ...                   % 무차원 사립자 침강 속도 (Brown(1950),Yang(2003))
    = (2/3 + (36 * nu^2) / (g * fSD50^3 * (s-1)))^0.5 ...
     - ((36 * nu^2) / (g * fSD50^3 * (s-1)))^0.5;
kfa ...                 % 퇴적물 운반율 수식 계수 
    = (1 / (fSGamma * (1 - eta))) ... % [kg/m s] -> [m^2/s]
    * 40 * fSGamma * F * (g * (s-1) * fSD50^3)^0.5 ...
    * (1 / ((s-1) * fSD50))^3 * nA ^ 1.8;

%--------------------------------------------------------------------------
% 모의기간 동안 융기율의 공간적, 시간적 분포를 정의함

[meanUpliftRateSpatialDistribution ...  % (모의기간 평균) 연간 융기율의 공간적 분포
,upliftRateTemporalDistribution ...     % (모의기간) 연간 융기율의 시간적 분포
,meanUpliftRateAtUpliftAxis ...         % 융기축의 (모의기간 평균) 연간 융기율
,topBndElev] ...                        % 외곽 위 경계에서의 고도
    = DefineUpliftRateDistribution(Y,X,Y_INI,X_INI,Y_MAX,X_MAX,dX ...
    ,TIME_STEPS_NO,TOTAL_ACCUMULATED_UPLIFT,dT ...
    ,IS_TILTED_UPWARPING,UPLIFT_AXIS_DISTANCE_FROM_COAST ...
    ,TOP_BOUNDARY_ELEV_COND,Y_TOP_BND_FINAL_ELEV ...
    ,RAMP_ANGLE_TO_TOP ...
    ,UPLIFT_RATE_TEMPORAL_DISTRIBUTION_COND ...
    ,dUpliftRate,acceleratedUpliftPhaseNo,upliftRate0 ...
    ,waveArrivalTime,initUpliftRate);

%--------------------------------------------------------------------------
% 로그 파일에 기록

fprintf(FID_LOG,'%i\n%i\n',mRows,nCols);    % (외곽 경계 포함) 행, 열 기록
fprintf(FID_LOG, ...                        % GPSS 2D 시작 시간 기록
    'GPSS 2D started time : %i[year] %i[month] %i[day] %i[hr] %i[min] %f[sec]\n' ...
    ,startedTime);
fprintf(FID_BEDROCKELEV,'%f\n',bedrockElev);    % 초기 기반암 고도 기록
fprintf(FID_SEDTHICK,'%f\n',sedimentThick);     % 초기 퇴적층 두께 기록

% 운반 수식의 계수값 출력
fprintf(FID_LOG,'(Hillslope Process)    Diffusion Coefficient (kmd):    %f\n',kmd);
fprintf(FID_LOG,'(Fluvial Process)  Transport Capacity Eq. Coefficient (kfa):   %f\n',kfa);
fprintf(FID_LOG,'(Fluvial Process)  Transport Capacity Eq. Exponent (mfa):  %f\n',mfa);
fprintf(FID_LOG,'(Fluvial Process)  Transport Capacity Eq. Exponent (nfa):  %f\n',nfa);
fprintf(FID_LOG,'(To Compare with Previous Research) Bedrock Incision Eq. Coefficient and Exponents\n');
KO = bankfullTime * kfbre * wRho * g * nB^mfb * kqb^((1 - mhw) * mfb) ...
    * annualRunoff^((1 - mhw) * mqb * mfb) ...
    * SECPERYEAR^((mhw - 1) * mqb * mfb) / khw^mfb;
mO = mqb * (1 - mhw) * mfb;
nO = nfb;
fprintf(FID_LOG,'(Fluvial Process)  Bedrock Incision Eq. Coefficient (K):   %f\n',KO);
fprintf(FID_LOG,'(Fluvial Process)  Bedrock Incision Eq. Coefficient (m):   %f\n',mO);
fprintf(FID_LOG,'(Fluvial Process)  Bedrock Incision Eq. Coefficient (n):   %f\n',nO);

% parameterValuesFile 을 OUTPUT_SUBDIR 에 복사함
copyfile(INPUT_FILE_PARAM_PATH,OUTPUT_SUBDIR_PATH);

%--------------------------------------------------------------------------
% (GPSS 2D 주 함수) 단위시간마다 아래를 반복함

for ithTimeStep = INIT_TIME_STEP_NO:TIME_STEPS_NO
    
    fprintf('%g\n', ithTimeStep);   % 실행 횟수 출력
    
    % 1. 경계조건에 따라 외곽 경계의 기반암 고도와 퇴적물 두께를 정의함
    % * 주의: 외곽 경계의 고도는 AdjustBoundary 함수에서만 정의함. 따라서
    %   아래의 지형형성작용에 의해 경계로 전해지는 물질은 다음 고도에 반영되지
    %   않음. 즉 경계로 유입되는 물질은 모두 제거된다고 가정함
    [bedrockElev ...            % 외곽 경계조건을 준 기반암 고도 [m]
    ,sedimentThick] ...         % 외곽 경계조건을 준 퇴적층 두께 [m]
        = AdjustBoundary(Y_INI,Y_MAX,X_INI,X_MAX ...
        ,Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND ...
        ,bedrockElev,sedimentThick,OUTER_BOUNDARY ...
        ,BOUNDARY_OUTFLOW_COND,TOP_BOUNDARY_ELEV_COND ...
        ,topBndElev,ithTimeStep,meanUpliftRateAtUpliftAxis);
    
    % 2. 지반융기 발생
    bedrockElev ...            % 지반융기율이 반영된 기반암 고도 [m]
        = Uplift(Y_INI,Y_MAX,X_INI,X_MAX ...
        ,bedrockElev ...
        ,upliftRateTemporalDistribution(ithTimeStep) ...
        ,meanUpliftRateSpatialDistribution ...
        ,meanUpliftRateAtUpliftAxis);
    
    % * 외적 작용 이전 기반암 고도 및 퇴적층 두께를 기록하여 결과 출력에 이용함
    preBedrockElev = bedrockElev;
    preSedThick = sedimentThick;
    
    % 3. 기반암 풍화 및 이로 인한 퇴적층 두께 및 기반암 고도 변화율을 반영함
    
    % 1) (하도 양안 퇴적층 두께를 구하기 위해) 현 지형 및 기후 조건에서의
    %    만제유량, 만제유량시 하폭 및 수심 그리고 하도 내 하상 퇴적물량을 추정
    % * 원리: 하도 내에서는 풍화작용이 일어나지 않는다고 가정함. 하안 또는 사면
    %   퇴적층에 한해서 풍화작용이 발생하여 기반암이 풍화됨.
    
    % (1) 유향과 경사
    
    % A. 고도 갱신
    elev = bedrockElev + sedimentThick;
    
    % B. (무한 유향 알고리듬을 이용한) 유향과 경사
    [facetFlowDirection ...     % 유향
    ,facetFlowSlope ...         % 경사
    ,e1LinearIndicies ...       % 다음 셀(e1) 색인
    ,e2LinearIndicies ...       % 다음 셀(e2) 색인
    ,outputFluxRatioToE1 ...    % 다음 셀(e1)로의 유입율
    ,outputFluxRatioToE2] ...   % 다음 셀(e2)로의 유입율
        = CalcInfinitiveFlow(mRows,nCols,Y,X,Y_INI,Y_MAX,X_INI,X_MAX ...
        ,QUARTER_PI,HALF_PI,elev,dX ...
        ,sE0LinearIndicies,s3E1LinearIndicies,s3E2LinearIndicies);
    
    % C. (최대하부경사 유향 알고리듬을 이용한) 유향과 경사
    [steepestDescentSlope ...   % 경사
    ,slopeAllNbr ...            % 8개 이웃 셀과의 경사
    ,SDSFlowDirection ...       % 유향
    ,SDSNbrY ...                % 다음 셀 Y 좌표값
    ,SDSNbrX] ...               % 다음 셀 X 좌표값
        = CalcSDSFlow(mRows,nCols,Y,X,Y_INI,Y_MAX,X_INI,X_MAX ...
        ,Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND ...
        ,QUARTER_PI,DISTANCE_RATIO_TO_NBR,elev,dX ...
        ,IS_LEFT_RIGHT_CONNECTED ...
        ,ithNbrYOffset,ithNbrXOffset ...
        ,sE0LinearIndicies,s3IthNbrLinearIndicies);
    
    % D. 유향이 정의되지 않은 셀에 유향을 정의함
    % * sink에 유향을 부여하고, flooded region에 유향을 재설정함
    [flood ...                      % flooded region
    ,SDSNbrY ...                    % 수정된 다음 셀의 Y 좌표값
    ,SDSNbrX ...                    % 수정된 다음 셀의 X 좌표값
    ,SDSFlowDirection ...           % 수정된 (최대하부경사 유향 알고리듬의) 유향
    ,steepestDescentSlope ...       % 수정된 (최대하부경사 유향 알고리듬의) 경사
    ,integratedSlope ...            % 수정된 (무한 유향 알고리듬) 경사
    ,floodedRegionIndex ...         % flooded region 색인
    ,floodedRegionCellsNo ...       % 각 flooded region 구성 셀 개수
    ,floodedRegionLocalDepth ...    % flooded region 고도와 유출구 고도와의 차이
    ,floodedRegionTotalDepth ...    % local depth 총 합
    ,floodedRegionStorageVolume] ...% flooded region 총 저장량
        = ProcessSink(mRows,nCols,X_INI,X_MAX ...
        ,Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND,QUARTER_PI,CELL_AREA ...
        ,elev,ithNbrYOffset,ithNbrXOffset ...
        ,OUTER_BOUNDARY,IS_LEFT_RIGHT_CONNECTED ...
        ,slopeAllNbr,steepestDescentSlope ...
        ,facetFlowSlope,SDSNbrY,SDSNbrX,SDSFlowDirection);
    
    % (2) 만제유량, 만제유량시 수심 및 하폭을 구함
    
    % A. 연간 유량[m^3/yr]

    % A) 셀들을 고도 순으로 정렬
    elevForSorting = elev;
    
    % B) flooded region을 제외함
    % * 원리 : 제외하는 셀의 고도값에는 - inf를 입력함
    elevForSorting(flood == FLOODED) = - inf;

    % C) 높은 고도 순으로 정렬하고 이의 Y,X 좌표값을 구함
    vectorElev = reshape(elevForSorting(Y_INI:Y_MAX,X_INI:X_MAX),[],1);
    sortedYXElevForUpstreamFlow = [vectorY,vectorX,vectorElev];
    sortedYXElevForUpstreamFlow = sortrows(sortedYXElevForUpstreamFlow,-3);

    % D) AccumulateUpstreamFlow 함수의 대상 셀 수
    consideringCellsNoForUpstreamFlow = find(vectorElev > - inf);
    consideringCellsNoForUpstreamFlow ...
        = size(consideringCellsNoForUpstreamFlow,1);

    % E) 연간유량 [m^3/yr]
    [annualDischarge1 ...   % 연간유량 [m^3/yr]
    ,isOverflowing] ...     % flooded region 저수량 초과 여부 태그
        = AccumulateUpstreamFlow(mRows,nCols ...
        ,Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND,CELL_AREA ...
        ,sortedYXElevForUpstreamFlow ...
        ,consideringCellsNoForUpstreamFlow ...
        ,OUTER_BOUNDARY,annualRunoff ...
        ,flood,floodedRegionCellsNo ...
        ,floodedRegionStorageVolume,floodedRegionIndex ...
        ,facetFlowDirection,e1LinearIndicies,e2LinearIndicies ...
        ,outputFluxRatioToE1,outputFluxRatioToE2,SDSNbrY,SDSNbrX);    

    % B. 만제유량, 만제유량시 수심과 하폭
    
    % A) 연 평균유량 [m^3/s]
    meanDischarge = annualDischarge1 / SECPERYEAR;

    % B) 만제유량 [m^3/s]
    bankfullDischarge = kqb * meanDischarge .^ mqb;

    % C) 만제유량시 하폭 [m]
    bankfullWidth = khw * bankfullDischarge .^ mhw;

    % D) 만제유량시 수심[m]
    bankfullDepth = khd * bankfullDischarge .^ mhd; % 하천 수리기하 법칙으로부터 추정
    % bankfullDepth = ( (bankfullDischarge ./ bankfullWidth) ... % Manning 흐름 저항식으로 부터 추정
    %    * nA .* integratedSlope .^ -0.5 ) .^ 0.6;
    
    % C. 하도 내 하상 퇴적층 [m^3]
    % * 참고: 하도 내 평균 하상 퇴적층. FluvialProcess 함수에서 분리제어
    %   환경과 운반제어 환경을 구분하는 기준이 됨. 현 지형 및 기후 조건하에서
    %   하천의 수리기하특성에 따라 하폭과 수심을 정의하고, 하폭을 따라
    %   하상에서부터 기반암까지를 하상 퇴적층으로 추정함.
    % * 참고: 하도 내 하상 퇴적층을 명시적으로 고려하기 시작한 이유
    %   이를 통해 '사면에서 하도로의 유입율'을 파악하고, '하천작용에 의해
    %   제거되는 정도'를 파악하여 하상 퇴적물의 공간적 시간적 수지를 분석하기
    %   위함. 하지만 하도 양안에서 하도로의 물질 이동 매커니즘(느린 매스무브먼트?
    %   빠른 매스무브먼트? 하천 측방 침식으로 인한 하안으로부터의 공급?)과
    %   유입율이 불분명하기 때문에 과도한 parameterization이 필요하여 더 이상
    %   진행하지 않음. 하지만 여기서 chanBedSedBudget을 통해 잔존 chanBedSed의
    %   증감율 파악을 위한 시도를 함.
    
    % A) 현 퇴적층 두께와 현 하천 수리기하특성으로부터 구한 하도 내 하상 퇴적층
    
    % (A) 현 조건에서의 하천을 포함한 셀 정의
    upslopeArea = annualDischarge1 ./ annualRunoff; % 상부 유역면적 [m^3/yr]/[m/yr]
    
    channel ...
        = DefineChannel(upslopeArea,integratedSlope,channelInitiation ...
        ,CELL_AREA,criticalUpslopeCellsNo,flood,FLOODED);
        
    % (B) 하도 내 하상 퇴적층 두께 [m/bankfullWidth]
    chanBedSedThick = zeros(mRows,nCols);
    chanBedSedThick(channel) ...
        = sedimentThick(channel) ...
        + bankfullWidth(channel) .* bankfullDepth(channel) ./ dX ...
        - bankfullDepth(channel);
    
    % * 주의: 모델 내에서 하상 퇴적층 두께가 음일 경우, 대부분은 유량이 많아
    %   하도가 넓은데 sedimentThick은 작은 것으로 추정됨
    chanBedSedThick(chanBedSedThick < 0) = 0;
    
    % D. 사면 및 하도 양안 퇴적층 두께
    
    % A) 사면 퇴적층 두께 [m]
    sedThickOutsideChannel = sedimentThick;
    
    % B) 하도 양안 퇴적층 두께 [m]
    sedThickOutsideChannel(channel) ...
        = chanBedSedThick(channel) + bankfullDepth(channel);
    
    % 2) 풍화율 [m/dT]
    % * 주의: flooded region을 포함하지 않음. flooded region에서는 풍화층
    %   생산이 없다고 가정함
    weatheringProductPerDT ...
        = RockWeathering(kwa,kw0,kw1,kwm ...
        ,sedThickOutsideChannel,bankfullWidth,dX,dT);
    
    weatheringProductPerDT(flood == FLOODED) = 0;
    
    % 3) 풍화작용으로 인한 퇴적층 두께 및 기반암 고도 갱신
    sedimentThick(Y_INI:Y_MAX,X_INI:X_MAX) ...
        = sedimentThick(Y_INI:Y_MAX,X_INI:X_MAX) ...
        + weatheringProductPerDT(Y_INI:Y_MAX,X_INI:X_MAX);
    bedrockElev(Y_INI:Y_MAX,X_INI:X_MAX) ...
        = bedrockElev(Y_INI:Y_MAX,X_INI:X_MAX) ...
        - weatheringProductPerDT(Y_INI:Y_MAX,X_INI:X_MAX);

    % 4. 사면작용과 이로 인한 퇴적층 두께 변화
    
    % 1) 고도를 갱신하지 않음 (풍화로 인한 고도 변화는 없으므로 생략)
    % elev = bedrockElev + sedimentThick;

    % 2) (셀 외부로) 사면작용 발생 셀들을 높은 고도 순으로 정렬함
    elevForSorting = elev;
    
    % (1) 하천인 셀을 제외함
    % * 주의: 하천인 셀을 따로 정의하지 않음
    elevForSorting(flood == FLOODED | channel) = - inf;

    % (2) 높은 고도 순으로 정렬하고 이의 Y,X 좌표값을 구함
    vectorElev = reshape(elevForSorting(Y_INI:Y_MAX,X_INI:X_MAX),[],1);
    sortedYXElev = [vectorY,vectorX,vectorElev];
    sortedYXElev = sortrows(sortedYXElev,-3);

    % (3) 사면작용이 일어나는 셀들의 수를 구함
    consideringCellsNo = find(vectorElev > - inf);
    consideringCellsNo = size(consideringCellsNo,1);

    % 3) 사면작용에 의한 퇴적층 두께 변화율과 하도로의 사면물질 공급율
    dSedThickByHillslopePerDT ... % 사면작용으로 인한 퇴적층 두께 변화율 [m/dT]
        = HillslopeProcess(mRows,nCols,Y,X,Y_INI,Y_MAX,X_INI,X_MAX ...
        ,dX,dT,CELL_AREA ...
        ,sortedYXElev,consideringCellsNo ...
        ,s3IthNbrLinearIndicies ...
        ,sedimentThick,kmd ...
        ,flood,floodedRegionCellsNo,floodedRegionIndex ...
        ,SDSNbrY,SDSNbrX,slopeAllNbr);
    
    % 4) 퇴적층 두께를 갱신함
    sedimentThick(Y_INI:Y_MAX,X_INI:X_MAX) ...
        = sedimentThick(Y_INI:Y_MAX,X_INI:X_MAX) ...
        + dSedThickByHillslopePerDT(Y_INI:Y_MAX,X_INI:X_MAX);
    
    % 4. 하천작용에 의한 퇴적층 두께 및 기반암 고도 변화율
    % * 주의 : 상류와 하류의 기복 역전 문제를 해결하기 위해, 만제유량
    %   지속기간보다 작은 세부 단위시간을 설정하고 만제유량 지속기간에 도달할
    %   때까지 반복함
    
    % 1) 세부 단위시간 관련 변수 초기화
    ithSubTimeStep = 1;             % 세부 단위 실행 횟수
    sumSubDT = 0;                   % 세부 단위시간의 누적 합계
    dSedThickByFluvialPerDT ...     % 퇴적물 두께 변화율[m^3/m^2 dT]
        = zeros(mRows,nCols);
    dBedrockElevByFluvialPerDT ...  % 기반암 고도 변화율[m^3/m^2 dT]
        = zeros(mRows,nCols);
    
    % 2) 만제유량 지속기간에 도달할 때까지 반복함
    while (sumSubDT < bankfullTime)
        
        % (1) 세부 단위시간 동안의 유향과 경사를 정의함

        % A. (유향과 경사를 구하기 위해) 고도를 갱신함
        % * 주의 : EstimateSubDT 함수에서 입력 변수로도 사용됨
        elev = bedrockElev + sedimentThick;
        
        % B. 무한 유향 알고리듬을 이용한 유향과 경사
        [facetFlowDirection ...     % 유향
        ,facetFlowSlope ...         % 경사
        ,e1LinearIndicies ...       % 다음 셀(e1) 색인
        ,e2LinearIndicies ...       % 다음 셀(e2) 색인
        ,outputFluxRatioToE1 ...    % 다음 셀(e1)로의 분배율
        ,outputFluxRatioToE2] ...   % 다음 셀(e2)로의 분배율
            = CalcInfinitiveFlow(mRows,nCols,Y,X,Y_INI,Y_MAX,X_INI,X_MAX ...
            ,QUARTER_PI,HALF_PI,elev,dX ...
            ,sE0LinearIndicies,s3E1LinearIndicies,s3E2LinearIndicies);

        % C. 최대하부경사 유향 알고리듬을 이용한 유향과 경사
        [steepestDescentSlope ...   % 경사
        ,slopeAllNbr ...            % 8 이웃 셀과의 경사
        ,SDSFlowDirection ...       % 유향
        ,SDSNbrY ...                % 다음 셀의 Y 좌표값
        ,SDSNbrX] ...               % 다음 셀의 X 좌표값
            = CalcSDSFlow(mRows,nCols,Y,X,Y_INI,Y_MAX,X_INI,X_MAX ...
            ,Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND ...
            ,QUARTER_PI,DISTANCE_RATIO_TO_NBR,elev,dX ...
            ,IS_LEFT_RIGHT_CONNECTED ...
            ,ithNbrYOffset,ithNbrXOffset ...
            ,sE0LinearIndicies,s3IthNbrLinearIndicies);

        % D. 유향이 정의되지 않은 셀에 유향을 부여함
        % * sink에 유향을 부여하고, flooded region에 유향을 재설정함
        [flood ...                      % flooded region
        ,SDSNbrY ...                    % 수정된 다음 셀의 Y 좌표값
        ,SDSNbrX ...                    % 수정된 다음 셀의 X 좌표값
        ,SDSFlowDirection ...           % 수정된 유향
        ,steepestDescentSlope ...       % 수정된 경사
        ,integratedSlope ...            % 수정된 facet flow 경사
        ,floodedRegionIndex ...         % flooded region 색인
        ,floodedRegionCellsNo ...       % 각 flooed region 구성 셀 개수
        ,floodedRegionLocalDepth ...    % flooded region 고도와 유출구 고도와의 차이
        ,floodedRegionTotalDepth ...    % 총 local depth
        ,floodedRegionStorageVolume] ...% flooded region 총 저장량
            = ProcessSink(mRows,nCols,X_INI,X_MAX ...
            ,Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND,QUARTER_PI,CELL_AREA ...
            ,elev,ithNbrYOffset,ithNbrXOffset ...
            ,OUTER_BOUNDARY,IS_LEFT_RIGHT_CONNECTED ...
            ,slopeAllNbr,steepestDescentSlope ...
            ,facetFlowSlope,SDSNbrY,SDSNbrX,SDSFlowDirection);

        % (2) 갱신된 유향에 따라 만제유량 [m^3/s]을 구하고, 하천의 수리기하
        %     특성을 이용해 만제유량시 하폭과 수심을 구함
        % * 원리: 만제유량은 연 평균유량[m^3/s]과의 관계식에서 구함

        % A. 연간유량 [m^3/dT]

        % A) (연간유량을 구하기 위해) 셀들을 고도 순으로 정렬
        
        % (A) flooded region을 제외함
        % * 원리: 제외하는 셀의 고도값에는 - inf 를 입력
        elevForSorting = elev;
        elevForSorting(flood == FLOODED) = - inf;
        
        % (B) 높은 고도 순으로 정렬하고 Y,X 좌표값을 구함
        vectorElev = reshape(elevForSorting(Y_INI:Y_MAX,X_INI:X_MAX),[],1);
        sortedYXElevForUpstreamFlow = [vectorY,vectorX,vectorElev];
        sortedYXElevForUpstreamFlow ...
            = sortrows(sortedYXElevForUpstreamFlow,-3);
        
        % B) AccumulateUpstreamFlow 함수 대상 셀들의 수
        consideringCellsNoForUpstreamFlow = find(vectorElev > - inf);
        consideringCellsNoForUpstreamFlow ...
            = size(consideringCellsNoForUpstreamFlow,1);

        % C) 연간유량
        [annualDischarge1 ...   % 연간 유량 [m^3/dT]
        ,isOverflowing] ...     % flooded region 저수량 초과 여부 태그
            = AccumulateUpstreamFlow(mRows,nCols ...
            ,Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND,CELL_AREA ...
            ,sortedYXElevForUpstreamFlow ...
            ,consideringCellsNoForUpstreamFlow ...
            ,OUTER_BOUNDARY,annualRunoff ...
            ,flood,floodedRegionCellsNo ...
            ,floodedRegionStorageVolume,floodedRegionIndex ...
            ,facetFlowDirection,e1LinearIndicies,e2LinearIndicies ...
            ,outputFluxRatioToE1,outputFluxRatioToE2,SDSNbrY,SDSNbrX);

        % B. 만제유량, 만제유량시 하폭과 수심
        
        % A) 연 평균유량[m^3/s]
        meanDischarge = annualDischarge1 / SECPERYEAR;

        % B) 만제유량[m^3/s]
        bankfullDischarge = kqb * meanDischarge .^ mqb;

        % C) 만제유량시 하폭[m]
        bankfullWidth = khw * bankfullDischarge .^ mhw;
        
        % D) 만제유량시 수심[m]
        bankfullDepth = khd * bankfullDischarge .^ mhd; % 하천 수리기하 법칙으로부터 추정
        % bankfullDepth = ( (bankfullDischarge ./ bankfullWidth) ... % Manning 흐름 저항식으로 부터 추정
        %    * nA .* integratedSlope .^ -0.5 ) .^ 0.6;        
        
        % (3) 세부 단위시간을 정의함
        % * 원리: 임시 세부 단위시간 동안 하천작용에 의한 퇴적물 두께 및 기반암
        %   고도 변화로 인해 다음 셀과의 경사가 0이 되는 최소 시간(기복역전이
        %   발생하지 않는 최대 시간)을 구하고 이를 세부 단위시간으로 설정함
        
        % A. 임시 세부 단위시간 동안의 하천작용에 의한 퇴적층 두께 및 기반암
        %    고도 변화율을 구함
        
        % A) 셀들을 고도 순으로 정렬함
                
        % (A) 하천을 정의하고, 하천이 아닌 셀들은 제외함
        % * 주의: flooded region도 포함함. 이의 고도 변화율도 FluvialProcess
        %   함수에서 구하기 때문임
        % * 주의: shalow overland flow로 인한 물질이동을 고려할 경우, 사면에서
        %   릴 또는 포상률에 의한 침식이 발생함. 따라서 이를 고려하기 위해
        %   hillslope을 정의함
        elevForSorting = elev;        
        
        upslopeArea = annualDischarge1 ./ annualRunoff; % 상부 유역면적 [m^3/yr]/[m/yr]

        channel ...
            = DefineChannel(upslopeArea,integratedSlope,channelInitiation ...
            ,CELL_AREA,criticalUpslopeCellsNo,flood,FLOODED);
        
        hillslope = ~ channel;
        
        % 하천이 아닌 셀들을 제외할 경우
        % elevForSorting(flood == FLOODED | ~ channel) = - inf;
        % 사면에서의 토양 침식까지 모두 구할 경우
        elevForSorting(flood == FLOODED) = - inf;
        
        % (B) 높은 고도 순으로 정렬하고 이의 Y,X 좌표값을 구함
        vectorElev = reshape(elevForSorting(Y_INI:Y_MAX,X_INI:X_MAX),[],1);
        sortedYXElevForFluvial = [vectorY,vectorX,vectorElev];
        sortedYXElevForFluvial = sortrows(sortedYXElevForFluvial,-3);

        % B) 하천작용이 일어나는 셀들의 수를 구함
        consideringCellsNoForFluvial = find(vectorElev > - inf);
        consideringCellsNoForFluvial ...
            = size(consideringCellsNoForFluvial,1);
        
        % C) 임시 세부 단위시간을 설정함
        trialTime ...
            = bankfullTime * basicManipulationRatio ^ nt;
                
        % D) 하도 내 하상 퇴적층 [m^3]
        
        % (A) 하도 내 하상 퇴적층 두께 [m/bankfullWidth]
        chanBedSedThick = zeros(mRows,nCols);
        chanBedSedThick(channel) ...
            = sedimentThick(channel) ...
            + bankfullWidth(channel) .* bankfullDepth(channel) ./ dX ...
            - bankfullDepth(channel);
        
        % * 주의: 모델 내에서 하상 퇴적층 두께가 음일 경우, 대부분은 유량이 많아
        %   하도가 넓은데 sedimentThick은 작은 것으로 추정됨
        chanBedSedThick(chanBedSedThick < 0) = 0;
        
        % (B) 하도 내 하상 퇴적층 부피 [m^3]
        chanBedSed = chanBedSedThick * dX .* bankfullWidth;
        
        % (C) 이전 하도 내 하상 퇴적층 부피와 비교
        % * 확인할 사항: 1) 증가하는 경우와 2) 감소하는 경우가 어떠한 조건일 때
        %   발생하는지 확인해볼 것. 현재로는 현 지형 또는 기후 조건 아래에서 유량의
        %   증감과 이에 따라 수리기하의 변화로 인한 증감이 예상됨. 특히 하천의
        %   수리기하특성상 수심보다는 하폭의 증가율이 크므로, 유량 증가는 일차적으로
        %   하폭을 넓히고 이로 인해 이전 하상 퇴적층보다 증가할 것으로 예상됨.
        % dChanBedSedPerDT = chanBedSedPerDT + (chanBedSed - oldChanBedSed);

        % oldChanBedSed = chanBedSed;

        % (D) 이전 하천작용 이후 하도 내 하상 퇴적층 부피의 변화
        % * 원리: 1) 증가하는 경우: 하도의 활발한 침식으로 인한 하도 양안
        %   퇴적층으로부터의 공급(하천의 측방침식 또는 하도 양안의 사면작용)
        %   * (C)의 1)로 인한 효과도 포함할 것임
        %   2) 감소하는 경우: 상류로부터의 하상 퇴적물 유입 또는 사면작용에 의한
        %   사면물질 유입율이 많았던 경우. 감소된 양은 하도 양안에 퇴적되었다고
        %   가정함. * (C)의 2)로 인한 효과도 포함할 것임
        chanBedSedBudgetPerDT = chanBedSedBudgetPerDT ...
            + (chanBedSed - remnantChanBedSed); 
        
        % E) 임시 세부 단위시간 동안 퇴적층 두께 및 기반암 고도 변화율
        [dSedThickByFluvialForSubDT ...     % 퇴적층 두게 변화율[m/trialTime]
        ,dBedrockElevByFluvialForSubDT ...  % 기반암 고도 변화율[m/trialTime]
        ,dChanBedSedForSubDT] ...            % 하도 내 하상 퇴적층 두께 [m^3]   
            = FluvialProcess(mRows,nCols ...
            ,Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND,CELL_AREA ...
            ,FLUVIALPROCESS_COND,timeWeight ...
            ,sortedYXElevForFluvial,consideringCellsNoForFluvial ...
            ,channel,chanBedSed,hillslope,sedimentThick ...
            ,OUTER_BOUNDARY ...
            ,bankfullDischarge,bankfullWidth,flood ...
            ,floodedRegionIndex,floodedRegionCellsNo,floodedRegionLocalDepth ...
            ,floodedRegionTotalDepth,floodedRegionStorageVolume ...
            ,e1LinearIndicies,e2LinearIndicies,outputFluxRatioToE1 ...
            ,outputFluxRatioToE2,SDSNbrY,SDSNbrX,integratedSlope ...
            ,kfa,mfa,nfa,kfbre,fSRho,g,nB,mfb,nfb,trialTime,dX);
        
        % B. 세부 단위시간을 정의함
        [subDT ...              % 세부 단위시간 [s]
        ,sumSubDT ...           % 누적 세부 단위시간 [s]
        ,nt] ...                % 세부 단위시간 추정을 위한 변수
            = EstimateSubDT(mRows,nCols,elev ...
            ,dSedThickByFluvialForSubDT,dBedrockElevByFluvialForSubDT ...
            ,trialTime,sumSubDT,minSubDT ...
            ,basicManipulationRatio,nt,bankfullTime ...
            ,consideringCellsNoForFluvial,sortedYXElevForFluvial ...
            ,SDSNbrY,SDSNbrX,floodedRegionCellsNo ...
            ,e1LinearIndicies,outputFluxRatioToE1 ...
            ,e2LinearIndicies,outputFluxRatioToE2);
        
        % (4) 세부 단위시간 동안 하천작용에 의한 퇴적물 두께 및 기반암 변화율
        
        % A. 하천작용에 의한 퇴적물 두께 및 기반암 변화율
        % * 셀들을 고도 순으로 다시 정렬하지 않고, EstimateMinTakenTime 함수
        %   시에 정렬했던 것을 이용함
        [dSedThickByFluvialPerSubDT ...    % 퇴적물 두께 변화율 [m^3/m^2 subDT]
        ,dBedrockElevByFluvialPerSubDT ...      % 기반암 고도 변화율 [m^3/m^2 subDT]
        ,dChanBedSedPerSubDT] ...               % 하도 내 하상 퇴적층 두께 [m^3]
            = FluvialProcess(mRows,nCols ...
            ,Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND,CELL_AREA ...
            ,FLUVIALPROCESS_COND,timeWeight ...
            ,sortedYXElevForFluvial,consideringCellsNoForFluvial ...
            ,channel,chanBedSed,hillslope,sedimentThick ...
            ,OUTER_BOUNDARY ...
            ,bankfullDischarge,bankfullWidth,flood ...
            ,floodedRegionIndex,floodedRegionCellsNo ...
            ,floodedRegionLocalDepth,floodedRegionTotalDepth ...
            ,floodedRegionStorageVolume ...
            ,e1LinearIndicies,e2LinearIndicies,outputFluxRatioToE1 ...
            ,outputFluxRatioToE2,SDSNbrY,SDSNbrX,integratedSlope ...
            ,kfa,mfa,nfa,kfbre,fSRho,g,nB,mfb,nfb,subDT,dX);
        
        % B. 세부 단위시간의 퇴적물 두께 및 기반암 고도 변화율을 누적하고
        %    하도 내 하상 퇴적물을 갱신함
        dSedThickByFluvialPerDT ...
            = dSedThickByFluvialPerDT + dSedThickByFluvialPerSubDT;
        dBedrockElevByFluvialPerDT ...
            = dBedrockElevByFluvialPerDT + dBedrockElevByFluvialPerSubDT;
        remnantChanBedSed = chanBedSed + dChanBedSedPerSubDT;
        
        % C. 퇴적물 두께 및 기반암 고도 변화율을 현 지형에 반영함
        sedimentThick(Y_INI:Y_MAX,X_INI:X_MAX) ...
            = sedimentThick(Y_INI:Y_MAX,X_INI:X_MAX) ...
            + dSedThickByFluvialPerSubDT(Y_INI:Y_MAX,X_INI:X_MAX);
        bedrockElev(Y_INI:Y_MAX,X_INI:X_MAX) ...
            = bedrockElev(Y_INI:Y_MAX,X_INI:X_MAX) ...
            + dBedrockElevByFluvialPerSubDT(Y_INI:Y_MAX,X_INI:X_MAX);
        
        % (5) 세부 실행 횟수를 하나 증가함
        ithSubTimeStep = ithSubTimeStep + 1;
        
    end % while (sumSubDT < bankfullTime)
    
    % 5. 빠른 매스무브먼트로 인한 퇴적층 두께 및 기반암 고도 변화율
    % * 원리: 불안정한 사면을 파악하고, 이들에 대해 빠른 매스무브먼트를 발생시켜
    %   사면물질을 하부로 연쇄이동 시킴
    
    % 1) 빠른 매스무브먼트로 인한 퇴적층 두께 및 기반암 고도 변화율
    [dBedrockElevByRapidMass ...        % 기반암 고도 변화율 [m/dT]
    ,dSedThickByRapidMass ...          % 퇴적층 두께 변화율 [m/dT]
    ,dTAfterLastShallowLandslide ...    % 마지막 천부활동 이후 경과 시간
    ,dTAfterLastBedrockLandslide] ...   % 마지막 기반암활동 이후 경과 시간
        = RapidMassMovement(mRows,nCols,Y,X,Y_INI,Y_MAX,X_INI,X_MAX ...
        ,Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND,dT,ROOT2,QUARTER_PI ...
        ,CELL_AREA,DISTANCE_RATIO_TO_NBR,soilCriticalSlopeForFailure ...
        ,rockCriticalSlopeForFailure,bedrockElev,sedimentThick ...
        ,dTAfterLastShallowLandslide,dTAfterLastBedrockLandslide ...
        ,dX,OUTER_BOUNDARY,IS_LEFT_RIGHT_CONNECTED ...
        ,ithNbrYOffset,ithNbrXOffset ...
        ,sE0LinearIndicies,s3IthNbrLinearIndicies);

    % 2) 기반암 고도와 퇴적층 두께를 갱신함
    bedrockElev(Y_INI:Y_MAX,X_INI:X_MAX) ...
        = bedrockElev(Y_INI:Y_MAX,X_INI:X_MAX) ...
        + dBedrockElevByRapidMass(Y_INI:Y_MAX,X_INI:X_MAX);
    sedimentThick(Y_INI:Y_MAX,X_INI:X_MAX)...
        = sedimentThick(Y_INI:Y_MAX,X_INI:X_MAX) ...
        + dSedThickByRapidMass(Y_INI:Y_MAX,X_INI:X_MAX);
    % for debug
    if sum(sum(dSedThickByRapidMass(Y_INI:Y_MAX,X_INI:X_MAX))) > 0
       
        fprintf('%g\n', ithTimeStep);   % 실행 횟수 출력
        
    end
    
    % 일정 실행 횟수 간격으로 모의 결과를 파일에 기록한다.
    if mod(ithTimeStep,WRITE_INTERVAL) == 0
       
        % 풍화층 분포
        fprintf(FID_WEATHER,'%14.10f\n',weatheringProductPerDT);        
        % (외적 작용으로 인한 변화 전) 퇴적층 두께
        fprintf(FID_SEDTHICK,'%14.10f\n',preSedThick);        
        % (외적 작용으로 인한 변화 전) 기반암 고도
        fprintf(FID_BEDROCKELEV,'%14.10f\n',preBedrockElev);        
        % 사면작용에 의한 퇴적층 두께 변화율
        fprintf(FID_dSEDTHICK_BYHILLSLOPE,'%14.10f\n',dSedThickByHillslopePerDT);
        % 하도 내 하상 퇴적층 수지
        fprintf(FID_CHANBEDSEDBUDGET,'%14.10f\n',chanBedSedBudgetPerDT);
        % 하천작용에 의한 퇴적물 두께 변화율
        fprintf(FID_dSEDTHICK_BYFLUVIAL,'%14.10f\n',dSedThickByFluvialPerDT);        
        % 하천작용에 의한 기반암 고도 변화율
        fprintf(FID_dBEDROCKELEV_BYFLUVIAL,'%14.10f\n',dBedrockElevByFluvialPerDT);
        % 빠른 매스무브먼트에 의한 퇴적물 두께 변화율
        fprintf(FID_dSEDTHICK_BYRAPIDMASS,'%14.10f\n',dSedThickByRapidMass);        
        % 빠른 매스무브먼트에 의한 기반암 고도 변화율
        fprintf(FID_dBEDROCKELEV_BYRAPIDMASS,'%14.10f\n',dBedrockElevByRapidMass);
        
    end % if mod(ithTimeStep,WRITE_INTERVAL) == 0
    
end % for ithTimeStep = 1:TIME_STEPS_NO

% GPSS 2D 종료 시간과 전체 소요 시간을 로그 파일에 기록한다.
finishedTime = clock;
elapsedTime = datenum(finishedTime) - datenum(startedTime);
elapsedTime = datevec(elapsedTime);

fprintf(FID_LOG,'GPSS 2D finished time : %i[year] %i[month] %i[day] %i[hr] %i[min] %f[sec]\n' ...
    ,finishedTime);

fprintf(FID_LOG,'GPSS 2D running time : %i[year] %i[month] %i[day] %i[hr] %i[min] %f[sec]\n' ...
    ,elapsedTime);

% 모든 출력 파일을 닫는다.
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

end % main function end