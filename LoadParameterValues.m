% =========================================================================
%> @section INTRO LoadParameterValues
%>
%> - 파일에서 초기 변수값을 읽고 이를 출력하는 함수
%>  - 또한 하천에 의한 퇴적물 운반량 수식의 계수를 구하고 이를 반환함
%>
%> @version 0.1
%> @callgraph
%> @callergraph
%> @see ReadParameterValue()
%>
%> @retval OUTPUT_SUBDIR                    : 출력 파일을 저장할 세부 디렉터리
%> @retval Y                                : (초기 지형을 만들 경우) 외곽 경계를 제외한 Y축 크기
%> @retval X                                : (초기 지형을 만들 경우) 외곽 경계를 제외한 X축 크기
%> @retval dX                               : 셀 크기 [m]
%> @retval PLANE_ANGLE                      : (초기 지형을 만들 경우) 평탄면의 경사 [m/m]
%> @retval INIT_BEDROCK_ELEV_FILE           : (초기 지형을 불러올 경우) 초기 지형을 저장한 파일
%> @retval initSedThick                     : 초기 퇴적층 두께 [m]
%> @retval INIT_SED_THICK_FILE              : 초기 지형의 퇴적층 두께를 불러올 경우 이를 저장한 파일
%> @retval TIME_STEPS_NO                    : 총 실행 횟수
%> @retval INIT_TIME_STEP_NO                : 이전 모형 결과에서 이어서 할 경우의 초기 실행 횟수
%> @retval dT                               : TIME_STEPS_NO를 줄이기 위한 만수유량 재현기간 [year]
%> @retval WRITE_INTERVAL                   : 모의 결과를 출력하는 빈도 결정
%> @retval BOUNDARY_OUTFLOW_COND            : 모델 영역으로부터 유출이 발생하는 유출구 또는 경계를 지정
%> @retval TOP_BOUNDARY_ELEV_COND           : 위 외곽 경계 고도 조건
%> @retval IS_LEFT_RIGHT_CONNECTED          : 좌우 외곽 경계 연결을 결정
%> @retval TOTAL_ACCUMULATED_UPLIFT         : 모의 기간 동안 총 지반 융기량 [m]
%> @retval IS_TILTED_UPWARPING              : 경동성 요곡 지반융기 운동을 결정
%> @retval UPLIFT_AXIS_DISTANCE_FROM_COAST  : 해안선으로부터 융기축까지의 거리 [m]
%> @retval RAMP_ANGLE_TO_TOP                : (누적 지반 융기량을 기준) 융기축에서 위 경계로의 각 [radian]
%> @retval Y_TOP_BND_FINAL_ELEV             : 위 경계의 최종 고도 [m]
%> @retval UPLIFT_RATE_TEMPORAL_DISTRIBUTION_COND : 융기율의 시간적 분포 결정
%> @retval acceleratedUpliftPhaseNo         : (융기율 변동 분포 조건) 모의기간 동안 높은 융기율이 발생하는 빈도
%> @retval dUpliftRate                      : (융기율 변동 분포 조건) 평균 연간 융기율을 기준으로 최대 최소 융기율의 차이 비율
%> @retval upliftRate0                      : (융기율 돌출-감쇠 분포 조건) 융기율 감쇠분포의 초기 융기율 [m/yearr]
%> @retval waveArrivalTime                  : (경동성 요곡 지반융기 조건) 영서 외곽 경계 고도가 본격적으로 하강하는 시점 (모의 기간에서 비율)
%> @retval initUpliftRate                   : (경동성 요곡 지반융기 조건) 본격적 하강 이전 침식 기준면 하강율 [m/year]
%> @retval kw0                              : 선형 풍화함수에서 연장되는 노출 기반암의 풍화율 [m/year]
%> @retval kwa                              : 선형 풍화함수의 증가율
%> @retval kw1                              : 지수 감소 풍화함수에서 연장되는 노출 기반암의 풍화율 [m/year]
%> @retval kwm                              : 풍화층 두께 축적 [m]
%> @retval kmd                              : 사면작용의 확산 계수
%> @retval FAILURE_COND                     : Hillslope failure option
%> @retval soilCriticalSlopeForFailure      : 천부활동의 안정 사면각 [radian]
%> @retval rockCriticalSlopeForFailure      : 기반암활동의 안정 사면각 [radian]
%> @retval FLOW_ROUTING                     : Flow routing algorithm option
%> @retval annualPrecipitation              : 연 강우량 [m/year]
%> @retval annualEvapotranspiration         : 연 증발산량 [m/year]
%> @retval kqb                              : 평균유량과 만수유량과의 관계식에서 계수
%> @retval mqb                              : 평균유량과 만수유량과의 관계식에서 지수
%> @retval bankfullTime                     : 만수유량 지속 기간 [s]
%> @retval timeWeight                       : 만수유량 지속기간을 줄이기 위한 침식율 가중치
%> @retval minSubDT                         : 최소한의 세부단위 시간 [s]
%> @retval khw                              : 만수유량과 하폭과의 관계식에서 계수
%> @retval mhw                              : 만수유량과 하폭과의 관계식에서 지수
%> @retval khd                              : 만수유량과 수심과의 관계식에서 계수
%> @retval mhd                              : 만수유량과 수심과의 관계식에서 지수
%> @retval FLUVIALPROCESS_COND              : flooded region의 순 퇴적물 두께 변화율을 추정하는 방법
%> @retval channelInitiation                : 하천 시작 지점 임계값
%> @retval criticalUpslopeCellsNo           : 하천 시작 임계 상부유역 셀 개수
%> @retval mfa                              : 하천에 의한 퇴적물 운반율 수식에서 유량의 지수
%> @retval nfa                              : 하천에 의한 퇴적물 운반율 수식에서 경사의 지수
%> @retval fSRho                            : 운반되는 퇴적물의 평균 밀도 [kg/m^3]
%> @retval fSD50                            : 운반되는 퇴적물의 중간 입경 [m]
%> @retval eta                              : 운반되는 퇴적물의 평균 공극율
%> @retval nA                               : 충적 하천 하도에서의 Manning 저항 계수
%> @retval mfb                              : 기반암 하상 침식율 수식에서 유량의 지수
%> @retval nfb                              : 기반암 하상 침식율 수식에서 경사의 지수
%> @retval kfbre                            : 기반암 하상 연약도
%> @retval nB                               : 기반암 하상 하도에서의 Manning 저항 계수
%>
%> @param INPUT_FILE_PARAM_PATH             : 초기 입력변수가 기록된 파일 이름
% =========================================================================
function [OUTPUT_SUBDIR,Y,X,dX,PLANE_ANGLE,INIT_BEDROCK_ELEV_FILE ...
    ,initSedThick,INIT_SED_THICK_FILE,TIME_STEPS_NO,INIT_TIME_STEP_NO ...
    ,dT,WRITE_INTERVAL,BOUNDARY_OUTFLOW_COND,TOP_BOUNDARY_ELEV_COND ...
    ,IS_LEFT_RIGHT_CONNECTED,TOTAL_ACCUMULATED_UPLIFT ...
    ,IS_TILTED_UPWARPING,UPLIFT_AXIS_DISTANCE_FROM_COAST ...
    ,RAMP_ANGLE_TO_TOP,Y_TOP_BND_FINAL_ELEV ...
    ,UPLIFT_RATE_TEMPORAL_DISTRIBUTION_COND,acceleratedUpliftPhaseNo ...
    ,dUpliftRate,upliftRate0,waveArrivalTime,initUpliftRate,kw0,kwa,kw1 ...
    ,kwm,kmd,FAILURE_OPT,soilCriticalSlopeForFailure,rockCriticalSlopeForFailure ...
    ,FLOW_ROUTING,annualPrecipitation,annualEvapotranspiration,kqb,mqb ...
    ,bankfullTime,timeWeight,minSubDT,khw,mhw,khd,mhd ...
    ,FLUVIALPROCESS_COND,channelInitiation,criticalUpslopeCellsNo,mfa ...
    ,nfa,fSRho,fSD50,eta,nA,mfb,nfb,kfbre,nB] ...
    = LoadParameterValues(INPUT_FILE_PARAM_PATH)
%
%

% 상수 정의
NUMERIC = 1;
STRING = 2;

% 파일 열기
fid = fopen(INPUT_FILE_PARAM_PATH,'r');
if fid == -1
    error('초기 변수값이 저장된 파일을 열지 못한다.\n');
end

% parameterValue file에 대한 설명 부분을 건너 뜀
% tmpStrLine = fgetl(fid);
% tmpStrLine = fgetl(fid);
 
% 초기 변수값 입력
%--------------------------------------------------------------------------
% 디렉터리 및 파일명

OUTPUT_SUBDIR ... % 출력 파일을 저장할 세부 디렉터리
    = ReadParameterValue(fid,'OUTPUT_SUBDIR',STRING); 

%--------------------------------------------------------------------------
% 모델 영역

Y ... % (초기 지형을 만들 경우) 외곽 경계를 제외한 Y 축 크기
    = ReadParameterValue(fid,'Y',NUMERIC); 
X ... % (초기 지형을 만들 경우) 외곽 경계를 제외한 X 축 크기
    = ReadParameterValue(fid,'X',NUMERIC); 
dX ... % 셀 크기 [m]
    = ReadParameterValue(fid,'dX',NUMERIC);
PLANE_ANGLE ... % (초기 지형을 만들 경우) 평탄면의 경사 [radian]
    = ReadParameterValue(fid,'PLANE_ANGLE',NUMERIC);
INIT_BEDROCK_ELEV_FILE ... % (초기 지형을 불러올 경우) 초기 지형을 저장한 파일
    = ReadParameterValue(fid,'INIT_BEDROCK_ELEV_FILE',STRING);
initSedThick ... % 초기 지형의 퇴적층 두게 [m]
    = ReadParameterValue(fid,'initSedThick',NUMERIC);
INIT_SED_THICK_FILE ...    % 초기 지형의 퇴적층 두께를 불러올 경우 이를 저장한 파일
    = ReadParameterValue(fid,'INIT_SED_THICK_FILE',STRING);

%--------------------------------------------------------------------------
% 실행 및 출력 횟수

TIME_STEPS_NO ... % 총 실행 횟수
    = ReadParameterValue(fid,'TIME_STEPS_NO',NUMERIC);
INIT_TIME_STEP_NO ... % 이전 모형 결과에서 이어서 할 경우의 초기 실행 횟수
    = ReadParameterValue(fid,'INIT_TIME_STEP_NO',NUMERIC);
dT ... % TIME_STEPS_NO를 줄이기 위한 만수유량 재현기간 [yr]
    = ReadParameterValue(fid,'dT',NUMERIC);
WRITE_INTERVAL ... % 모의 결과를 출력하는 빈도 결정
    = ReadParameterValue(fid,'WRITE_INTERVAL',NUMERIC);

%--------------------------------------------------------------------------
% 경계조건

BOUNDARY_OUTFLOW_COND ... % 모델 영역으로부터 유출이 발생하는 유출구 또는 경계조건
    = ReadParameterValue(fid,'BOUNDARY_OUTFLOW_COND',NUMERIC);
TOP_BOUNDARY_ELEV_COND ... % 유출구 또는 외곽 경계 고도 조건
    = ReadParameterValue(fid,'TOP_BOUNDARY_ELEV_COND',NUMERIC);
IS_LEFT_RIGHT_CONNECTED ... % 좌우 외곽 경계 연결 조건
    = ReadParameterValue(fid,'IS_LEFT_RIGHT_CONNECTED',NUMERIC);

%--------------------------------------------------------------------------
% 융기율의 공간적 시간적 분포

TOTAL_ACCUMULATED_UPLIFT ... % 모의 기간 동안 총 지반융기량 [m]
    = ReadParameterValue(fid,'TOTAL_ACCUMULATED_UPLIFT',NUMERIC);
IS_TILTED_UPWARPING ... % 경동성 요곡 지반융기 조건
    = ReadParameterValue(fid,'IS_TILTED_UPWARPING',NUMERIC);
UPLIFT_AXIS_DISTANCE_FROM_COAST ... % 해안선으로부터 융기축까지의 거리 [m]
    = ReadParameterValue(fid,'UPLIFT_AXIS_DISTANCE_FROM_COAST',NUMERIC);
RAMP_ANGLE_TO_TOP ... % (누적 지반융기량을 기준) 융기축에서 위 경계로의 각
    = ReadParameterValue(fid,'RAMP_ANGLE_TO_TOP',NUMERIC);
Y_TOP_BND_FINAL_ELEV ... % (경동성 요곡 지반융기 모의시) 위 경계의 최종 고도
    = ReadParameterValue(fid,'Y_TOP_BND_FINAL_ELEV',NUMERIC);
UPLIFT_RATE_TEMPORAL_DISTRIBUTION_COND ... % 융기율의 시간적 분포 조건
    = ReadParameterValue(fid,'UPLIFT_RATE_TEMPORAL_DISTRIBUTION_COND',NUMERIC);
acceleratedUpliftPhaseNo ... % (융기율 변동 분포 조건) 모의기간 동안 높은 융기율이 발생하는 빈도
	=  ReadParameterValue(fid,'acceleratedUpliftPhaseNo',NUMERIC);
dUpliftRate ... % (융기율 변동 분포 조건) 평균 연간 융기율을 기준으로 최대 최소 융기율의 차이 비율 
	=  ReadParameterValue(fid,'dUpliftRate',NUMERIC); % * 주의: 0 < dUFraction <= 1
upliftRate0 ... % (융기율 돌출-감쇠 분포 조건) 융기율 감쇠분포의 초기 융기율 [m/yr]
	=  ReadParameterValue(fid,'upliftRate0',NUMERIC); % * 참고: Min et al. (2008)
waveArrivalTime ... % (경동성 요곡 지반융기 조건) 영서 외곽 경계 고도가 본격적으로 하강하는 시점 (모의 기간에서 비율)
	=  ReadParameterValue(fid,'waveArrivalTime',NUMERIC);
initUpliftRate ... % (경동성 요곡 지반융기 조건) 본격적 하강 이전 침식 기준면 하강율 [m/yr]
	=  ReadParameterValue(fid,'initUpliftRate',NUMERIC);

%--------------------------------------------------------------------------
% 기반암 풍화 함수

% * 원리: Anderson(2002)의 기반암 풍화 함수를 이용.
kw0 ... % 선형 풍화 함수에서 연장되는 노출 기반암의 풍화율 [m/yr]
    = ReadParameterValue(fid,'kw0',NUMERIC);
kwa ... % 선형 풍화 함수의 증가율
    = ReadParameterValue(fid,'kwa',NUMERIC);
kw1 ... % 지수 감소 풍화 함수에서 연장되는 노출 기반암의 풍화율 [m/yr]
    = ReadParameterValue(fid,'kw1',NUMERIC);
kwm ... % 풍화층 두께 축적 [m]
    = ReadParameterValue(fid,'kwm',NUMERIC);

%--------------------------------------------------------------------------
% 사면작용

kmd ... % 사면작용의 확산 계수 [m2/m yr]
    = ReadParameterValue(fid,'kmd',NUMERIC);
FAILURE_OPT ... % Hillslope failure option
    = ReadParameterValue(fid,'FAILURE_OPT',NUMERIC);
% * 주의: 암석붕괴 안정사면각보다 작게 설정함
soilCriticalSlopeForFailure ... % 쇄설류의 안정 사면각
    = ReadParameterValue(fid,'soilCriticalSlopeForFailure',NUMERIC);
% * 참고: 남대천 및 사천천 최상류에서는 0.5. * 주의: 해상도에 따라 달라짐
rockCriticalSlopeForFailure ... % 암석붕괴의 안정 사면각
    = ReadParameterValue(fid,'rockCriticalSlopeForFailure',NUMERIC);

%--------------------------------------------------------------------------
% 수문

FLOW_ROUTING ... % FLOW_ROUTING [m]
    = ReadParameterValue(fid,'FLOW_ROUTING',NUMERIC);
annualPrecipitation ... % 연간 강우량 [m/yr]
    = ReadParameterValue(fid,'annualPrecipitation',NUMERIC);
annualEvapotranspiration ... % 연간 증발산량 [m/yr]
    = ReadParameterValue(fid,'annualEvapotranspiration', NUMERIC);

%--------------------------------------------------------------------------
% 만수유량

kqb ... % 평균유량과 만수유량과의 관계식에서 계수
    = ReadParameterValue(fid,'kqb',NUMERIC); 
mqb ... % 평균유량과 만수유량과의 관계식에서 지수
    = ReadParameterValue(fid,'mqb',NUMERIC);
bankfullTime ... % 만수유량 지속기간[s]
    = ReadParameterValue(fid,'bankfullTime',NUMERIC);
timeWeight ... % 만수유량 지속기간을 줄이기 위한 운반율 및 침식율 가중치
    = ReadParameterValue(fid,'timeWeight',NUMERIC);
minSubDT ... % 최소한의 세부단위 시간[s]
    = ReadParameterValue(fid,'minSubDT',NUMERIC);

%--------------------------------------------------------------------------
% 하천의 수리 기하

khw ... % 만수유량과 하폭과의 관계식에서 계수
    = ReadParameterValue(fid,'khw',NUMERIC); 
mhw ... % 만수유량과 하폭과의 관계식에서 지수
    = ReadParameterValue(fid,'mhw',NUMERIC);
khd ... % 만수유량과 수심과의 관계식에서 계수
    = ReadParameterValue(fid,'khd',NUMERIC); 
mhd ... % 만수유량과 수심과의 관계식에서 지수
    = ReadParameterValue(fid,'mhd',NUMERIC);

%--------------------------------------------------------------------------
% 하천 작용

FLUVIALPROCESS_COND ... % flooded region의 순 퇴적물 두께 변화율을 추정하는 방법
    = ReadParameterValue(fid,'FLUVIALPROCESS_COND',NUMERIC);
% * 원리: 다음 기준(AS^2 > 임의의 값)을 만족할 경우 하천이라 간주함
%   참고문헌 : Montgomery and Dietrich (1992)
% * 참고: 2만 5천 지형도 기준으로 남대천 최상류 일차 하천의 시작 지점의
%   AS^2는 28351, 곤신봉 일대는 6319로 편차가 큼. 하지만 이 값을 기준으로
%   하면 모의 초기에 하천이 발달하지 않고 그것이 계속되는 현상이 발생함.
%   야외조사 결과를 기준으로 심곡리 상류 확실한 사면 지역은 30 정도임.
%   따라서 100 정도를 고려하고 있음. 추후 야외조사를 통해 보완할 생각임
channelInitiation ...           % 하천 시작 지점 임계값
	= ReadParameterValue(fid,'channelInitiation',NUMERIC);
criticalUpslopeCellsNo ...      % 하천 시작 임계 상부유역 셀 개수
	= ReadParameterValue(fid,'criticalUpslopeCellsNo',NUMERIC);
mfa ...                         % 하천에 의한 퇴적물 운반 수식에서 유량의 지수
    = ReadParameterValue(fid,'mfa',NUMERIC); 
nfa ...                         % 하천에 의한 퇴적물 운반 수식에서 경사의 지수
    = ReadParameterValue(fid,'nfa',NUMERIC); 
fSRho ...                       % 운반되는 퇴적물의 평균 밀도
    = ReadParameterValue(fid,'fSRho',NUMERIC); 
fSD50 ...                       % 운반되는 퇴적물의 중간 입경
    = ReadParameterValue(fid,'fSD50',NUMERIC); 
eta ...                         % 운반되는 퇴적물의 평균 공극율
    = ReadParameterValue(fid,'eta',NUMERIC); 
nA ...                          % 충적 하천 하도에서의 Manning 저항 계수
    = ReadParameterValue(fid,'nA',NUMERIC); 
mfb ...                         % 기반암 하상 침식 수식에서 유량의 지수
    = ReadParameterValue(fid,'mfb',NUMERIC);
nfb ...                         % 기반암 하상 침식 수식에서 경사의 지수
    = ReadParameterValue(fid,'nfb',NUMERIC);
kfbre ...                       % 기반암 하상 연약도
    = ReadParameterValue(fid,'kfbre',NUMERIC); 
nB ...                          % 기반암 하상 하도에서의 Manning 저항 계수
    = ReadParameterValue(fid,'nB',NUMERIC); 

%--------------------------------------------------------------------------
% parameterValuesFile을 닫는다.
fclose(fid);

end % LoadParameterValues end
