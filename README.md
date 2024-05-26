# 수치지형발달모형 GPSS
- 프로그램명 : GPSS(Geomorphological Process System Simulator)
- 목적 : 지질시간 규모의 지형발달을 모의하는 프로그램
- 프로그램 언어 : MATLAB과 C (속도 향상을 위해 MEX 파일)
- 사사 : Gregory E. Tucker의 GOLEM과 Steven L. Eddins의 Upslope Toolbox 등과 같이 인터넷에 공개된 프로그램의 소스 코드 없이는 본 프로그램이 나올 수 없었음. 참고한 알고리듬은 개별 함수 코드에서 명시하였음.

# GPSS 설치

- GitHub GPSS 사이트(https://github.com/byunjongmin/GPSS)에서 소스코드 다운로드
- 압축 풀기 및 디렉토리 설정
  - GPSS 라는 디렉토리 생성 후(예. C:\GPSS), 압축 파일을 GPSS 디렉터리내에서 풀기
  - MATLAB 언어로 작성된 함수와 스크립트, MEX, 그리고 README.md 등의 파일로 구성됨
  - GPSS 디렉터리 내 data 디렉토리를 생성하고, data 디렉토리 안에 input(C:\GPSS\data\input)과 output 디렉토리 C:\GPSS\data\input)를 각각 만듦
- GPSS 소스코드 저장 디렉토리(C:\GPSS)를 MATLAB path에 추가함
- GPSS 구동 및 결과 분석을 위한 MATLAB toolbox 설치
  - Tree data structure as a MATLAB class (https://www.mathworks.com/matlabcentral/fileexchange/35623-tree-data-structure-as-a-matlab-class) 다운로드
  - TopoToolbox (https://www.mathworks.com/matlabcentral/fileexchange/50124-topotoolbox) 다운로드
  - 이상의 toolbox 에 대한 MATLAB path 설정
- GPSS 내 MEX 파일 컴파일
  - 실행 속도를 높이기 위해 GPSS 일부 코드는 MATLAB에서 호출 가능한 C 언어 함수(MEX 파일)로 작성되었음
    - C언어로 작성한 부분은 C(또는 C++) 컴파일러로 컴파일을 해야함
      - 지원 및 호환 컴파일러 목록 안내 사이트 : https://www.mathworks.com/support/requirements/supported-compilers.html
  - MEX 파일 : MATLAB에서 생성된 함수로, C/C++ 프로그램 또는 Fortran 서브루틴을 호출함. MEX 함수는 MATLAB 스크립트 또는 함수처럼 동작함
  - GPSS 내 MEX 파일
    - CollapseMex.c, EstimateDElevByFluvialProcess.c, EstimateDElevByFluvialProcessBySDS.c, EstimateSubDTMex.c, EstimateUpstreamFlow.c, EstimateUpstramFlowBySDS.c, HillslopeProcessMex.c
  - Windows 운영체제에서는 컴파일러로 Visual Studio Community 설치를 권장함. 아래는 Visual Studio Community 설치 과정
    - 마이크로 소프트 비주얼 스튜디오 다운로드 사이트(https://visualstudio.microsoft.com/ko/downloads/)로 이동
    - 가장 왼쪽에 있는 ‘Community’ 무료 다운로드 클릭하여 설치 파일(VisualStudioSetup.exe) 다운로드
    - 설치 파일을 더블클릭하면 Visual Studio Installer 가 실행됨
      - 만일 “이 앱이 디바이스를 변경할 수 있도록 허용하시겠어요?”라는 창이 뜬다면 “예”를 클릭
      - 사용 조건에 동의하는지를 묻는 창이 뜨면, “계속”을 클릭
    - 설치할 개발툴을 선택하는 화면이 뜨면, 아래쪽으로 스크롤해서, “데스크톱 및 모바일” 아래 “C++을 사용한 데스크톱 개발” 모듈을 선택하고 설치 버튼 클릭
    - 설치가 모두 끝나면 마이크로소프트 계정으로 로그인하라는 대화상자가 열림. 로그인하지 않은 상태에서 평가판 라이선스로 30일만 사용할  있음. 따라서 마이크로소프트 계정이 있다면 “로그인”을 클릭하고 없다면 계정 만들고 로그인 할 것
    - 환경 설정을 하는 대화상자가 열리면 “개발 설정” 드롭다운 버튼을 클릭하여 “Visual Studio 시작” 버튼을 클릭함
  - MATLAB 명령어 창에서 GPSS MEX 파일 컴파일
````matlab
% Compile GPSS MEX file
mex -v CollapseMex.c
mex -v EstimateDElevByFluvialProcess.c
mex -v EstimateDElevByFluvialProcessBySDS.c
mex -v EstimateUpstreamFlow.c
mex -v EstimateUpstreamFlowBySDS.c
mex -v EstimateSubDTMex.c
mex -v EstimateUpstreamFlow.c
mex -v HillslopeProcessMex.c
````

# GPSS 프로그램 내 주요 함수 목록

## GPSS 실행 관련
- AccumulateUpstreamFlow : 상부 유역으로부터의 유량과 누적 셀 개수를 구하는 함수
- AdjustBoundary	: 경계조건에 따라 외곽 경계의 기반암 고도와 퇴적물 두께를 정의하는 함수
- CalcFacetFlow : 동-북동 facet 흐름의 향과 경사를 구하는 함수
- CalcInfinitiveFlow : Tarboton(1997)의 무한 유향 알고리듬을 이용하여 유향과 경사를 구하는 함수
- CalcSDSFlow : 최대 하부 경사를 가지는 이웃 셀을 찾아 이의 방향과 경사를 반환하고, 이 이웃 셀의 좌표를 SDSNbrX, SDSNbrY에기록하는 함수
- CheckOversteepSlopes : 활동 유형 - 천부활동(shallow landsliding)과 기반암활동(bedrock landsliding)에 따라 불안정한 사면을 파악하는 함수.
- Collapse : 불안정한 셀에서 활동을 발생시켜 사면 물질을 사면 하부로 연쇄적으로 이동시키는 함수.
- DefineUpliftRateDistribution : 융기율의 공간적 시간적 분포를 정의하는 함수
- EstimateSubDT	: 임시 세부 단위시간 동안 하천에 의한 고도 변화율을 이용해 하류 방향으로 다음 셀과의 경사가 0이 되는데 걸리는 시간[trialTime]을 구하여 이를 세부 단위시간으로 정의하는 함수
- FindSDSDryNbr : 가장 낮은 셀의 이웃 셀을 탐색하여 이웃 셀 중 flooded region에 속하지 않고 속하지 않고 동시에 최대 하부 경사를 가지는 이웃 셀이 있다면 가장 낮은 셀의 경사와 유향을 변경하고 조건을 만족하는 이웃 셀이 없다면 유출구가 없다고 반환하는 함수
- FluvialProcess	: 하천작용에 의한 퇴적층 두께 및 기반암 고도 변화율을 구하는 함수
- **GPSSMain** : GPSS 주함수
  - GPSSMain_Hy : 하천 수리기하 법칙으로부터 수심을 추정함
  - GPSSMAin_Ma : Manning 흐름 저항식으로부터 수심을 추정함
- HillslopeProcess : 사면작용에 의한 퇴적물 두께 변화율[m/dT]을 구하는 함수
- IsBoundary : 입력되는 셀의 좌표(y,x)가 모형 외곽 경계에 위치하는지를 확인하는 함수
- IsDry : 가장 낮은 셀의 이웃 셀의 flood 상태를 확인하여, 1) 유향이 정의되어 있거나 또는 SINK인 경우 true를 반환하고, 2) 현재 처리 중인 flooded region인 경우 false를 반환하는 함수
- LoadParameterValues : 파일에서 초기 변수값을 읽고 이를 출력하는 함수
- MakeFlatAreas	: 일정한 경사를 가진 평탄면을 만드는 함수
- MakeInitialGeomorphology	 : 초기 지형(초기 기반암 고도와 퇴적층 두께를 포함)을 만드는 함수
- ProcessSink : 유향이 정의되지 않은 셀(SINK)의 유출구를 찾아 이의 좌표를 SDSNbrY, SDSNbrX에 기록하는 함수
- RapidMassMovement : 불안정한 사면을 파악하고, 이들에 활동을 발생시키는 함수
- ReadElevation :	파일로부터 초기 지형의 고도를 읽어 들여 이를 반환하는 함수
- ReadParameterValue : 다양한 형태의 변수값을 읽는 함수
- RockWeathering : 단위시간 당 풍화율을 추정하는 함수.
- Uplift : 모형 영역에 지반융기를 반영하고, 융기로 인한 고도 변화율을 구하는 함수

## GPSS 분석 관련
- AnalyseResult : GPSS 결과를 분석하는 함수. 박사학위 논문의 실험 조건에 만들어진 분석결과를 분석하는데 최적화되어 있음
- AnalyseResultGeneral : GPSS 결과를 분석하는 함수로서 , 박사학위 논문의 실험 조건에 만들어진 결과를 분석하는데 최적화된 AnalyseResult 함수를 일반적인 모의 결과 분석에 적합한 모듈만 선택하여 수정한 함수
- AnalyseResultGeneralBySDS : 좀 더 확인이 필요함. 어떤 용도로 사용하였을까? SDS가 아니라 CalcInfitiveFlow 함수를 호출하고 있기 때문임
- ToGRIDobj :  To convert the GPSS output final result to TopoToolbox grid object 

# GPSS 주함수(GPSSMain_Hy.m) 흐름
- 입출력을 위한 디렉터리와 출력 파일을 정의하고 중요한 초기 변수값을 입력
  - 모의기간 동안 융기율의 공간적, 시간적 분포를 정의함
- 단위시간마다 아래를 반복함
  - [영역설정] 경계조건에 따라 외곽 경계의 기반암 고도와 퇴적물 두께를 정의함
  - (내인적 작용) 지반융기 발생
  - (외인적 작용) 기반암 풍화 및 이로 인한 퇴적층 두께 및 기반암 고도 변화율을 반영함
    - (하도 양안 퇴적층 두께를 구하기 위해) 현 지형 및 기후 조건에서의 만제유량, 만제유량시 하폭 및 수심 그리고 하도 내 하상 퇴적물량을 추정
    - 풍화작용으로 인한 퇴적층 두께 및 기반암 고도 갱신
  - (외인적 작용) 사면작용과 이로 인한 퇴적층 두께 변화
  - (외인적 작용) 하천작용에 의한 퇴적층 두께 및 기반암 고도 변화율
    - 하천작용에 의한 퇴적물 두께 및 기반암 변화율
    - 세부 단위시간의 퇴적물 두께 및 기반암 고도 변화율을 누적하고 하도 내 하상 퇴적물을 갱신함
    - 퇴적물 두께 및 기반암 고도 변화율을 현 지형에 반영함

# GPSS 입력 변수 설정 및 실행

- GPSS 모의실험을 위한 GPSS 입력변수 파일 생성
  - GPSS 모의실험을 위한 지형형성과정별 입력 변수를 설정
    - guideForParameterInput.xlsx 파일 내 지형형성과정별 입력 변수 설정을 돕는 각각의 시트를 참고할 것
      - 시트: Uplift, Weathering, Hillslope Process, Hydrology, Alluvial Channel, Bedrock Channel 
  - 설정한 입력변수를 기록한 GPSS 입력변수 파일을 생성
    - 참고 : OUTPUT_SUBDIR 변수의 값을 모의 날짜와 시간을 결합하여 만들 것을 권함(예. 2022년 11월 18일 오후 6시에 실행하는 경우, 20221118_1800)
    - guideForParameterInput.xlsx 파일 내 ‘For Output’ 시트에서 ‘Write an Input Parameter’ 아이콘을 클릭하면 OUTPUT_SUBDIR 이름을 포함하는 입력 변수 파일을 생성함(예. parameter_20240423_1800.txt)
  - 생성한 GPSS 입력변수 파일을 input 디렉터리 내로 이동함
- GPSS 디렉터리(예. C:\GPSS)를 MATLAB ‘current folder’로 설정함
- MATLAB 명령창에 입력변수 파일 이름(예. parameter_20221118_1800.txt)을 인자로 넣고 GPSS 메인함수 실행
  - 예, GPSSMain_Hy('parameter_20221118_1800.txt’)

# GPSS 결과 확인 및 분석

## GPSS 모의결과 파일 확인
- 프로그램 구동이 끝나면 output 디렉터리 내 OUTPUT_SUBDIR 이름으로 된 디렉터리로 이동(예. C:\GPSS\output\20221118_1800)
- GPSS 모의결과 파일을 확인함
  - sedThick.txt : 퇴적층 두께 [m] 
  - bedrockElev.txt : 기반암 고도 [m] 
  - weatherProduct.txt : 풍화율 [m/dT] 
  - dSedThickByHillslope.txt : 사면작용에 의한 퇴적층 두께 변화율 [m3/m2 dT] 
  - chanBedSedBudget.txt : 하도 내 퇴적층 수지 [m3/dT] 
  - dSedThickByFluvial.txt : 하천작용에 의한 퇴적층 두께 변화율 [m3/m2 dT] 
  - dBedrockElevByFluvial.txt : 하천작용에 의한 기반암 고도 변화율 [m3/m2 dT] 
  - dSedThickByRapidMassmove.txt : 활동에 의한 퇴적층 두께 변화율 [m3/m2 dT] 
  - dBedrockElevByRapidMassmove.txt : 활동에 의한 기반암 고도 변화율 [m3/m2 dT] 
  - log.txt : GPSS 구동 동안의 상황 기록

## GPSS 모의결과 분석
- GPSS 디렉터리(예. C:\GPSS)를 MATLAB ‘current folder’로 설정하고 아래 절차를 통해 모의결과를 분석함
  - 1. AnalyzeResultGeneral.m 함수 이용하여 시간에 따른 모의결과를 저장(majorOutput) 및 확인함
    - 예. GPSS 입력변수 파일이 parameter_20221118_1800.txt 일 경우, 아래와 같이 입력
    - > majorOutput = AnalyseResultGeneral(‘20221118_1800＇,＇parameter_20221118_1800.txt＇,1,1,1,1,1);
  - 2. ToGRIDobj 함수 이용하여 최종 모의결과를 TopoToolbox GRIDobj 형식으로 변환하고 이를 TopoToolbox 명령어를 통해 분석함
````matlab
% output results of TopoToolbox GRIDobj
[finalSedThick,finalBedElev] = ToGRIDobj(majorOutputs);
% critical upslope cells number
criticalUpslopeCellsNo = majorOutputs.criticalUpslopeCellsNo;

% Vizualize the DEM of the final result
finalDEM = finalBedElev + finalSedThick;
figure(31)
imagesc(finalDEM); colorbar
````